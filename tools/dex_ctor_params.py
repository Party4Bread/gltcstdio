"""Read per-filter parameter overrides out of dex bytecode.

`tools/smali_ctor.py` handles constructors jadx turned into a register dump,
but for some classes jadx emits nothing at all -- only "Method dump skipped".
`HeightMap` is one, and losing its overrides mattered: its `colorFog` default
is a transparent black, and the type-derived opaque black turned the filter's
fog fully on, which mixes every pixel to the fog colour and renders a flat
image.

So the constructor is read from the dex instead.  It is a straight-line
sequence of builder calls on parameter descriptors:

    sget-object    v2, LV4/h2;->h2       <- the colorFog descriptor
    sget-object    v3, LV4/o;->m         <- colour constant (0,0,0,0)
    invoke-virtual v2, v3, c2->p(...)    <- .p(that colour): set the default

Registers are tracked through that sequence and the builder methods are
applied with the same slot map the Java-side extractor uses.
"""

from __future__ import annotations

import json
import re
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

import matrices  # noqa: E402
from extract_params import METHOD_CONST, METHOD_FIELD  # noqa: E402

DESCRIPTOR_CLASS = "LV4/c2;"
REGISTRY_CLASS = "LV4/h2;"
COLOUR_CLASS = "LV4/o;"
# `E2.c` is a vec4 and `E2.f` a mat4 built from four of them.  Its accessor
# rejects an index outside 0..3 with "column must be in 0..3", and the
# constructor names its arguments x, y, z, w -- so the four are columns.
VEC3_CLASS = "LE2/b;"
VEC4_CLASS = "LE2/c;"
MAT3_CLASS = "LE2/e;"
MAT4_CLASS = "LE2/f;"
# The static transform builders (`E1.n0` and friends).
BUILDER_CLASS = "Lcom/google/android/gms/internal/measurement/E1;"
# `x.c.F(m)` is a cofactor expansion of the 4x4 inverse.
INVERSE_METHOD = ("Lx/c;", "F")
# `V4.q2` is the RGBA colour value the descriptors carry as a default.
COLOUR_VALUE_CLASS = "LV4/q2;"
BOXED_CLASSES = {
    "Ljava/lang/Double;",
    "Ljava/lang/Float;",
    "Ljava/lang/Integer;",
    "Ljava/lang/Boolean;",
}

SGET = re.compile(r"^(v\d+),\s*(L[\w/$]+;)->(\w+)\s")
# `<init>` has to be part of the method-name group: constructors are how the
# vector and matrix defaults are built.
INVOKE_VIRT = re.compile(r"^(.*?),\s*(L[\w/$]+;)->(<?\w+>?)\(([^)]*)\)")
INVOKE_STAT = INVOKE_VIRT
CONST = re.compile(r"^(v\d+),\s*(-?\d+)")


def jadx_to_dex(name: str) -> str:
    """`f8000h2` -> `h2`: jadx prefixes the real field name with f<number>."""
    m = re.match(r"^f\d+(.*)$", name)
    return m.group(1) if m else name


def load_specs() -> tuple[dict, dict]:
    """(registry field -> spec, colour field -> rgba), keyed by dex name."""
    params = json.loads(Path("work/params.json").read_text())
    specs = {}
    for jadx_name, spec in params.items():
        if spec.get("name"):
            specs[jadx_to_dex(jadx_name)] = spec

    colours = {}
    src = Path("work/decompiled/sources/V4/AbstractC0597o.java")
    if src.exists():
        pat = re.compile(
            r"(f\d+\w*)\s*=\s*new C0610q2\(\s*([\d.eE+-]+)f?\s*,\s*([\d.eE+-]+)f?\s*,"
            r"\s*([\d.eE+-]+)f?\s*,\s*([\d.eE+-]+)f?\s*\)"
        )
        for m in pat.finditer(src.read_text()):
            colours[jadx_to_dex(m.group(1))] = [float(m.group(i)) for i in range(2, 6)]
    return specs, colours


class Const32:
    """A 32-bit `const` literal, which dex stores without a type.

    The same instruction carries the integer `100` and the bit pattern of
    `0.3`; only the signature of the method the value flows into says which.
    Guessing by magnitude got `torus-map` a radius of 1050253722 and a camera
    translated by -1088841318, which put its torus outside every ray.
    """

    __slots__ = ("raw",)

    def __init__(self, raw: int) -> None:
        self.raw = raw

    def typed(self, code: str):
        if code == "F":
            return struct.unpack("<f", struct.pack("<I", self.raw & 0xFFFFFFFF))[0]
        if code == "Z":
            return bool(self.raw)
        return self.raw

    def __repr__(self) -> str:  # pragma: no cover - debugging aid
        return f"Const32({self.raw})"


def _numeric_shape(value) -> bool:
    """True for a vector or a matrix of numbers, nothing else."""
    if not isinstance(value, (list, tuple)) or not value:
        return False
    if all(isinstance(x, (int, float)) for x in value):
        return True
    return all(
        isinstance(row, (list, tuple))
        and row
        and all(isinstance(x, (int, float)) for x in row)
        for row in value
    )


def invert4(rows: list[list[float]]) -> list[list[float]] | None:
    """Gauss-Jordan inverse of a 4x4, or None if it is singular."""
    a = [list(map(float, r)) + [1.0 if i == j else 0.0 for j in range(4)] for i, r in enumerate(rows)]
    for col in range(4):
        pivot = max(range(col, 4), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-9:
            return None
        a[col], a[pivot] = a[pivot], a[col]
        scale = a[col][col]
        a[col] = [v / scale for v in a[col]]
        for r in range(4):
            if r == col:
                continue
            factor = a[r][col]
            if factor:
                a[r] = [v - factor * w for v, w in zip(a[r], a[col])]
    return [row[4:] for row in a]


def wide_to_double(raw: int) -> float:
    """A const-wide literal is the double's bit pattern."""
    return struct.unpack("<d", struct.pack("<Q", raw & 0xFFFFFFFFFFFFFFFF))[0]


class CtorReader:
    """Abstract interpretation of one constructor's builder chain."""

    def __init__(self, specs: dict, colours: dict):
        self.specs = specs
        self.colours = colours
        # Vectors and matrices a class builds once in `<clinit>` and hands to
        # a descriptor by field reference, as `PerspectiveKt.a` does.
        self.statics: dict[str, object] = {}

    def read(self, method) -> dict:
        code = method.get_code()
        if code is None:
            return {}
        regs: dict[str, object] = {}
        pending = None  # result of the last invoke, awaiting move-result
        out: dict[str, dict] = {}

        for ins in code.get_bc().get_instructions():
            name = ins.get_name()
            text = ins.get_output()

            if name.startswith("move-result"):
                m = re.match(r"^(v\d+)", text.strip())
                if m and pending is not None:
                    regs[m.group(1)] = pending
                pending = None
                continue

            if name.startswith("sput-object"):
                m = SGET.match(text.strip())
                if m:
                    src, owner, field = m.groups()
                    value = regs.get(src)
                    if _numeric_shape(value):
                        self.statics[f"{owner}->{field}"] = value
                continue

            if name.startswith("sget-object"):
                m = SGET.match(text.strip())
                if m:
                    dst, owner, field = m.groups()
                    static = self.statics.get(f"{owner}->{field}")
                    if static is not None:
                        regs[dst] = static
                    elif owner == REGISTRY_CLASS and field in self.specs:
                        base = dict(self.specs[field])
                        regs[dst] = base
                        # Registers are reused, so record each descriptor as it
                        # appears rather than reading the final register file.
                        if base.get("name"):
                            out.setdefault(base["name"], base)
                    elif owner == COLOUR_CLASS and field in self.colours:
                        regs[dst] = list(self.colours[field])
                    else:
                        regs.pop(dst, None)
                continue

            if name.startswith("move-object") or name in ("move", "move/16", "move/from16"):
                m = re.match(r"^(v\d+),\s*(v\d+)", text.strip())
                if m:
                    src = regs.get(m.group(2))
                    if src is None:
                        regs.pop(m.group(1), None)
                    else:
                        regs[m.group(1)] = src
                continue

            if name.startswith("new-instance"):
                # The register holds nothing until `<init>` runs; leaving the
                # previous occupant would let it be read as a component.
                m = re.match(r"^(v\d+)", text.strip())
                if m:
                    regs.pop(m.group(1), None)
                continue

            if name.startswith("const-string"):
                m = re.match(r"^(v\d+)", text.strip())
                if m:
                    regs[m.group(1)] = ins.get_raw_string()
                continue

            if name.startswith("const-wide"):
                m = CONST.match(text.strip())
                if m:
                    reg = m.group(1)
                    regs[reg] = wide_to_double(int(m.group(2)))
                    # A double occupies a register pair; the second half holds
                    # no value of its own and must not be read as an argument.
                    regs.pop("v%d" % (int(reg[1:]) + 1), None)
                continue

            if name.startswith("const"):
                m = CONST.match(text.strip())
                if m:
                    # Left untyped; the call it feeds decides int or float.
                    regs[m.group(1)] = Const32(int(m.group(2)))
                continue

            if name.startswith("invoke"):
                pending = self._call(text, regs)
                if isinstance(pending, dict) and pending.get("name"):
                    # Later calls refine the same descriptor; keep the latest.
                    out[pending["name"]] = pending
                continue

        return out

    @staticmethod
    def _typed(param_types: list[str], args: list[str], regs: dict) -> dict:
        """Register -> value, with each `const` read as the signature says.

        The declared parameters line up with the tail of the register list:
        a virtual call puts `this` first, a static call has nothing extra, and
        a `D` or `J` parameter occupies two registers of which only the first
        carries the value.
        """
        slots = sum(2 if t in ("D", "J") else 1 for t in param_types)
        if slots > len(args):
            return {}
        tail = args[len(args) - slots :]
        typed, i = {}, 0
        for code in param_types:
            reg = tail[i]
            value = regs.get(reg)
            typed[reg] = value.typed(code) if isinstance(value, Const32) else value
            i += 2 if code in ("D", "J") else 1
        return typed

    def _call(self, text: str, regs: dict):
        m = INVOKE_VIRT.match(text.strip())
        if not m:
            return None
        args = [a.strip() for a in m.group(1).split(",") if a.strip().startswith("v")]
        owner, method = m.group(2), m.group(3)

        # dex constants are untyped, so read them the way this call declares
        # them; anything the signature does not cover keeps its raw integer.
        # Writes still go to `regs`, which is the caller's register file.
        typed = self._typed(m.group(4).split(), args, regs)

        def read(reg):
            if reg in typed:
                return typed[reg]
            value = regs.get(reg)
            return value.raw if isinstance(value, Const32) else value

        # A matrix default is assembled rather than read from a field:
        # four vec4 columns, then the mat4 that holds them.  `wireframe`
        # builds its `model3DTransform` this way, and it is a translation of
        # -1 in z -- the step that moves the camera off the surface it is
        # meant to be marching towards.  Without it the camera sits at the
        # origin and every ray misses.
        if method == "<init>" and len(args) == 5:
            if owner == VEC4_CLASS:
                vals = [read(a) for a in args[1:]]
                if all(isinstance(v, (int, float)) for v in vals):
                    regs[args[0]] = [float(v) for v in vals]
                else:
                    regs.pop(args[0], None)
                return None
            if owner == MAT4_CLASS:
                cols = [read(a) for a in args[1:]]
                if all(isinstance(c, list) and len(c) == 4 for c in cols):
                    # Columns in, and the bank stores matrices row-major.
                    regs[args[0]] = [[cols[c][r] for c in range(4)] for r in range(4)]
                else:
                    regs.pop(args[0], None)
                return None

        # A colour, either spelled out or through `q2.a(alpha)`, which is
        # `new C0610q2(0, 0, 0, alpha)` -- a transparent black at that alpha.
        if owner == COLOUR_VALUE_CLASS:
            if method == "a" and len(args) == 1:
                alpha = read(args[0])
                return [0.0, 0.0, 0.0, float(alpha)] if isinstance(alpha, (int, float)) else None
            if method == "<init>" and len(args) == 5:
                vals = [read(a) for a in args[1:]]
                if all(isinstance(v, (int, float)) for v in vals):
                    regs[args[0]] = [float(v) for v in vals]
                else:
                    regs.pop(args[0], None)
                return None

        # The transform builders, and the `.b`/`.c` product that composes
        # them.  `rgb-spike` states all four of its transforms this way.
        if owner == BUILDER_CLASS and method in matrices.BUILDERS:
            return matrices.build(method, [read(a) for a in args])
        if owner in (MAT3_CLASS, MAT4_CLASS) and method in matrices.MULTIPLY_METHODS:
            if len(args) == 2:
                left, right = read(args[0]), read(args[1])
                if _numeric_shape(left) and _numeric_shape(right) and len(left) == len(right):
                    return matrices.mul(left, right)
            return None
        if owner == VEC3_CLASS and method == "<init>":
            vals = [read(a) for a in args[1:]]
            if len(vals) == 4 and isinstance(vals[0], int):
                # The synthetic constructor: a set bit zeroes that component.
                flags = vals[0]
                vals = [0.0 if flags & (1 << i) else v for i, v in enumerate(vals[1:])]
            if len(vals) == 3 and all(isinstance(v, (int, float)) for v in vals):
                regs[args[0]] = [float(v) for v in vals]
            else:
                regs.pop(args[0], None)
            return None
        if owner == MAT3_CLASS and method == "<init>":
            cols = [read(a) for a in args[1:]]
            cols = [c for c in cols if isinstance(c, list) and len(c) == 3]
            if len(cols) == 3:
                regs[args[0]] = matrices.columns_to_rows(cols)
            else:
                regs.pop(args[0], None)
            return None

        if (owner, method) == INVERSE_METHOD and len(args) == 1:
            mat = read(args[0])
            if isinstance(mat, list) and len(mat) == 4:
                return invert4(mat)
            return None

        if owner in BOXED_CLASSES and method == "valueOf":
            # The boxed value is just its argument, already read at the type
            # `valueOf` declares.
            return read(args[0]) if args else None

        # The registry's own descriptor factories: `b(name)` defaults to 1.0
        # and `a(name, i)` to i.  Parameters built this way otherwise fall back
        # to the type default, which for `channelMultiplier` multiplied every
        # channel by zero.
        if owner == REGISTRY_CLASS and method in ("a", "b") and args:
            name = read(args[0])
            if isinstance(name, str):
                spec = {"name": name, "label": name}
                if method == "b":
                    spec["default"] = 1.0
                else:
                    v = read(args[1]) if len(args) > 1 else None
                    spec["default"] = v if isinstance(v, (int, float)) else 0
                return spec
            return None

        if owner == DESCRIPTOR_CLASS and args:
            spec = read(args[0])
            if not isinstance(spec, dict):
                return None
            spec = dict(spec)
            values = [read(a) for a in args[1:]]
            self._apply(spec, method, values)
            regs[args[0]] = spec
            return spec

        # `A.f.k(descriptor, name, label, category)` and `m0.n.g(descriptor,
        # name, label, unit)` take the descriptor first; every other helper
        # takes it last.
        if method in ("k", "g") and len(args) == 4:
            spec = read(args[0])
            names = [read(a) for a in args[1:]]
            if not isinstance(spec, dict) or not all(isinstance(n, str) for n in names):
                return None
            spec = dict(spec)
            last = "unit" if method == "g" else "category"
            spec["name"], spec["label"], spec[last] = names
            regs[args[0]] = spec
            return spec

        # `m0.n.d(min, max, descriptor)` and friends: the descriptor is last.
        if method in ("d", "e", "t", "v", "f", "i", "j") and args:
            spec = read(args[-1])
            if not isinstance(spec, dict):
                return None
            spec = dict(spec)
            raw = [read(a) for a in args[:-1]]
            if method == "j":
                # A default colour: all four components must be numbers.
                if len(raw) == 4 and all(isinstance(n, (int, float)) for n in raw):
                    spec["default"] = [float(n) for n in raw]
                regs[args[-1]] = spec
                return spec
            nums = [n for n in raw if isinstance(n, (int, float))]
            if method in ("d", "f", "v") and len(nums) >= 2:
                spec["min"], spec["max"] = float(nums[0]), float(nums[1])
            elif method == "e" and nums:
                # `n.e(s, p)` is `p.p(E1.n0(s))`: a uniform scale matrix.
                spec["default"] = matrices.build("n0", [nums[0]])
            elif method == "i" and nums:
                spec["default"] = nums[0]
            # `t` widens a secondary range the UI does not use.
            regs[args[-1]] = spec
            return spec
        return None

    @staticmethod
    def _apply(spec: dict, method: str, values: list) -> None:
        if method in METHOD_CONST:
            field, value = METHOD_CONST[method]
            spec[field] = value
            return
        field = METHOD_FIELD.get(method)
        if field is None or not values:
            return
        value = values[0]
        if field == "name" and isinstance(value, str):
            # `.L("sourceColor")` renames a shared descriptor; without this the
            # override is filed under the base name and never reaches the
            # parameter it was meant for.
            spec["name"] = value
        elif field == "default":
            # Only a number, a vector or a matrix is a plausible default;
            # register tracking can otherwise hand back a neighbouring string
            # and wipe the one the base descriptor already carried.
            if isinstance(value, (int, float, bool)) or _numeric_shape(value):
                spec["default"] = value
        elif field == "range" and isinstance(value, (list, tuple)) and len(value) >= 2:
            spec["min"], spec["max"] = float(value[0]), float(value[1])
        elif field in ("label", "category", "widget") and isinstance(value, str):
            spec[field] = value


def main() -> None:
    from androguard.core.dex import DEX

    try:
        from loguru import logger

        logger.remove()
    except Exception:  # noqa: BLE001
        pass

    specs, colours = load_specs()
    print(f"{len(specs)} registry descriptors, {len(colours)} colour constants")

    shaders = json.loads(Path("work/shaders.json").read_text())
    by_dex = {}
    for fid, rec in shaders.items():
        p = Path(rec["source_path"])
        parts = list(p.parts)
        if "sources" in parts:
            parts = parts[parts.index("sources") + 1 :]
        parts[-1] = parts[-1].removesuffix(".java")
        by_dex.setdefault("L" + "/".join(parts) + ";", []).append(fid)
        if parts[-1].endswith("Kt"):
            # The shader text often sits in the companion `FooKt`, but the
            # constructor stating the parameters is on `Foo` itself.  Keyed
            # only by where the GLSL was found, `charts` missed its own
            # constructor and kept the type's `precizion` of 1 where the app
            # sets 3.
            sibling = parts[:-1] + [parts[-1].removesuffix("Kt")]
            by_dex.setdefault("L" + "/".join(sibling) + ";", []).append(fid)

    dex_path = sys.argv[1] if len(sys.argv) > 1 else "work/apk/classes.dex"
    dex = DEX(Path(dex_path).read_bytes())
    reader = CtorReader(specs, colours)

    # Static initialisers first: a constructor may take a matrix default from
    # a field its companion built, and `Perspective` reads `PerspectiveKt.a`
    # that way -- the camera translation without which its rays hit nothing.
    for cls in dex.get_classes():
        if "/pap2/" not in cls.get_name():
            continue
        for method in cls.get_methods():
            if method.get_name() == "<clinit>":
                reader.read(method)
    print(f"  {len(reader.statics)} vector/matrix constants in static fields")

    out: dict[str, dict] = {}
    # Every class's own constructor result and its superclass, so a filter
    # that is a parameterisation of an abstract base can inherit the base's
    # parameter list.  The `shape-*` family declares nothing of its own --
    # `AbstractShape` states `multiplier` and `insideLock` for all fourteen.
    by_class_name: dict[str, dict] = {}
    superclass: dict[str, str] = {}
    # Parameters keyed by name across every effect class, used as a fallback
    # for descriptors a filter inherits from a composite it references --
    # `channelMultiplier` takes its channel weights from a separate
    # six-channel node, and those default to 1.0, not the type's 0.0.
    by_name: dict[str, dict] = {}
    for cls in dex.get_classes():
        if "/pap2/effects/" not in cls.get_name():
            continue
        fids = by_dex.get(cls.get_name())
        superclass[cls.get_name()] = cls.get_superclassname()
        for method in cls.get_methods():
            if method.get_name() != "<init>":
                continue
            found = reader.read(method)
            if not found:
                continue
            by_class_name.setdefault(cls.get_name(), {}).update(found)
            for name, spec in found.items():
                if spec.get("default") is not None and name not in by_name:
                    by_name[name] = spec
            if fids:
                for fid in fids:
                    out[fid] = found

    # A filter takes what the class it extends states, under anything it says
    # itself.  Merging rather than skipping matters: `RayMarcherCube` states
    # only its own `roundness`, while `RayMarcher` places the camera -- and an
    # identity `camera3DTransform` sits at the origin, inside the object the
    # marcher is meant to be looking at.
    inherited = 0
    for dex_name, fids in by_dex.items():
        seen, parent = set(), superclass.get(dex_name)
        base: dict = {}
        while parent and parent not in seen:
            seen.add(parent)
            found = by_class_name.get(parent)
            if found:
                base = {**found, **base}
            parent = superclass.get(parent)
        if not base:
            continue
        for fid in fids:
            merged = {**base, **out.get(fid, {})}
            if merged != out.get(fid):
                inherited += 1
            out[fid] = merged
    print(f"  {inherited} filters inherited a base class's parameters")

    Path("work/dex_param_names.json").write_text(
        json.dumps(by_name, indent=1, sort_keys=True, default=str)
    )
    print(f"  {len(by_name)} parameter names with a default")

    dest = Path("work/dex_ctor_params.json")
    dest.write_text(json.dumps(out, indent=1, sort_keys=True, default=str))
    print(f"{len(out)} filters with overrides from bytecode -> {dest}")
    hm = out.get("height-map", {})
    if hm:
        print("  height-map colorFog:", hm.get("colorFog", {}).get("default"))


if __name__ == "__main__":
    main()
