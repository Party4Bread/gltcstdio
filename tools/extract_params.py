"""Recover the pap2 parameter registry from V4/AbstractC0565h2.java.

The registry is a static-init block that builds ~700 `C0540c2` parameter
descriptors through a chained immutable builder.  We interpret that block
statement by statement, tracking local variables and static fields, so that
`AbstractC0565h2.f8029p1` resolves to a full spec:

    {name: "smoothen", label: "Smooth", default: 0.0, min: 0.0, max: 1.0}

Builder-method semantics were recovered by inspecting which positional slot
of the copy helper `b(this, ...)` each method writes; see SLOT_* below.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import matrices  # noqa: E402
from javaexpr import match_paren, parse_chain, split_args  # noqa: E402

# Builder method -> semantic field, derived from the b() slot map.
METHOD_FIELD = {
    "L": "name",       # slot 0
    "Z": "gl_type",    # slot 1
    "p": "default",    # slot 2
    "r": "default",    # slot 2
    "s": "default",    # slot 2
    "O": "options",    # slot 3
    "H": "widget",     # slot 6
    "W": "range",      # slot 8
    "V": "range",      # slot 8
    "E": "range_alt",  # slot 9
    "D": "category",   # slot 12
    "v": "label",      # slot 13
    "S": "unit",       # slot 14
    "U": "step",       # slot 17
}

# Static helpers that decorate a descriptor and hand it back.  `d`/`e`/`f`/`t`
# are the registry's own range and default helpers; `i`/`j`/`k` are the
# synthetic wrappers jadx creates when it folds duplicated call sites away.
HELPERS = ("d", "e", "f", "g", "t", "i", "j", "k")

# Zero-arg builder shorthands that expand to a known value.
METHOD_CONST = {
    "X": ("step", 0.1),
    # `q()` writes 2.0 into the default slot.  `bump` gates its whole effect
    # on `measure(v, power)` landing below 1, and `pow(x, 1/0)` is infinite,
    # so losing this left the filter doing nothing at any setting.
    "q": ("default", 2.0),
    "N": ("wrap", "mirrored_repeat"),
    "P": ("widget", "palette_tint"),
    "Q": ("widget", "pattern"),
}

RANGE_RE = re.compile(r"\bY\(\s*(-?[\d.]+)[dDfF]?\s*,\s*(-?[\d.]+)[dDfF]?\s*\)")
# Enum choices appear as `z.T(new h(0, "fixed"), new h(1, "continuous"))` and
# as `T.T(AbstractC1134r0.H(0, "red"), ...)`.
OPTION_RE = re.compile(r"\b(?:new h|\w+\.H)\(\s*(-?\d+)\s*,\s*\"((?:[^\"\\]|\\.)*)\"\s*\)")


def _is_matrix(value) -> bool:
    """A square nested list of numbers."""
    return (
        isinstance(value, list)
        and len(value) in (3, 4)
        and all(
            isinstance(row, list)
            and len(row) == len(value)
            and all(isinstance(x, (int, float)) for x in row)
            for row in value
        )
    )


def find_options(expr: str) -> list[dict] | None:
    pairs = OPTION_RE.findall(expr)
    if not pairs:
        return None
    seen, out = set(), []
    for value, label in pairs:
        v = int(value)
        if v in seen:
            continue
        seen.add(v)
        out.append({"value": v, "label": label})
    return out or None
NUM_RE = re.compile(r"^-?\d+(\.\d+)?([dDfFL])?$")
STR_RE = re.compile(r'^"(.*)"$', re.S)


def unquote(tok: str) -> str | None:
    m = STR_RE.match(tok.strip())
    if not m:
        return None
    return m.group(1).encode().decode("unicode_escape")


def as_number(tok: str) -> float | int | None:
    tok = tok.strip()
    m = re.match(r"^Double\.valueOf\((.+)\)$|^Integer\.valueOf\((.+)\)$", tok)
    if m:
        tok = (m.group(1) or m.group(2)).strip()
    if not NUM_RE.match(tok):
        return None
    tok = re.sub(r"[dDfFL]$", "", tok)
    return float(tok) if "." in tok else int(tok)


def find_range(expr: str) -> tuple[float, float] | None:
    m = RANGE_RE.search(expr)
    if m:
        return float(m.group(1)), float(m.group(2))
    return None


COLOR_RE = re.compile(
    r"(f\d+\w*)\s*=\s*new C0610q2\(\s*([\d.eE+-]+)f?\s*,\s*([\d.eE+-]+)f?\s*,"
    r"\s*([\d.eE+-]+)f?\s*,\s*([\d.eE+-]+)f?\s*\)"
)


def load_colors(root: Path) -> dict[str, list[float]]:
    """Named RGBA constants used as colour-parameter defaults."""
    path = root / "sources/V4/AbstractC0597o.java"
    if not path.exists():
        return {}
    out = {}
    for m in COLOR_RE.finditer(path.read_text()):
        out[m.group(1)] = [float(m.group(i)) for i in range(2, 6)]
    return out


class Registry:
    """Interprets the static-init block into resolved parameter specs."""

    def __init__(
        self,
        src: str,
        colors: dict[str, list[float]] | None = None,
        scopes: dict[str, dict] | None = None,
    ):
        self.src = src
        self.colors = colors or {}
        # Other classes' resolved fields, keyed by simple class name, so that
        # `HalftoneKt.f12054a` resolves while extracting a filter.
        self.scopes = scopes or {}
        self.env: dict[str, dict] = {}     # local var / field -> spec
        self.consts: dict[str, object] = {}  # local var -> literal value

    # -- literal environment -------------------------------------------------
    def scan_consts(self, body: str) -> None:
        # Colour constants are bound to locals before use, e.g.
        #   C0610q2 c0610q2 = AbstractC0597o.f8115b;
        for m in re.finditer(r"\bC0610q2\s+(\w+)\s*=\s*[\w.]*?\.?(f\d+\w*)\s*;", body):
            rgba = self.colors.get(m.group(2))
            if rgba:
                self.consts[m.group(1)] = rgba
        for m in re.finditer(r"\b(?:Double|Integer|Boolean)\s+(\w+)\s*=\s*([^;]+);", body):
            val = as_number(m.group(2))
            if val is None:
                low = m.group(2).strip()
                val = True if "TRUE" in low else False if "FALSE" in low else None
            if val is not None:
                self.consts[m.group(1)] = val

    def resolve_matrix(self, tok: str):
        """`E1.u0(0.0, 0.0).b(E1.n0(0.2))` -- a transform default.

        These are how constructors state their transforms; read as a plain
        value the call collapses to its first number, which for `rgb-spike`
        meant a mat3 of zeros and a blank render.
        """
        base, calls = parse_chain(tok.strip())
        # `E1.u0(...)` parses as the owner plus a call, while register code
        # spells the whole thing out as one base.  The owner is fully
        # qualified there, so match on its last segment.
        owner = base.strip()
        tail = owner.rsplit(".", 1)[-1]
        if calls and tail.isidentifier() and calls[0][0] in matrices.BUILDERS:
            name, args = calls[0]
            calls = calls[1:]
        elif tail.isidentifier() and _is_matrix(self.consts.get(owner)):
            # Register code spreads a transform over several statements, so
            # the chain starts from a value already computed:
            #     r4 = E1.n0(0.75)
            #     r4 = r4.b(r6)
            # Losing this dropped the translation from `mandelbrot-orbits`.
            value = self.consts[owner]
            for method, call_args in calls:
                if method not in matrices.MULTIPLY_METHODS or len(call_args) != 1:
                    return None
                other = self.resolve_matrix(call_args[0])
                if other is None or len(other) != len(value):
                    return None
                value = matrices.mul(value, other)
            return value
        else:
            m = re.match(r"^(?:[\w.]+\.)?(\w+)\((.*)\)$", base.strip(), re.S)
            if not m or m.group(1) not in matrices.BUILDERS:
                return None
            name = m.group(1)
            args = split_args(m.group(2)) if m.group(2).strip() else []
        value = matrices.build(name, [self.resolve_value(a) for a in args])
        if value is None:
            return None
        for method, call_args in calls:
            if method not in matrices.MULTIPLY_METHODS or len(call_args) != 1:
                return None
            other = self.resolve_matrix(call_args[0])
            if other is None or len(other) != len(value):
                return None
            value = matrices.mul(value, other)
        return value

    def eval_list(self, expr: str) -> list[dict] | None:
        """A constructor argument that is a whole list of descriptors.

        The orbit fractals do not pass their parameters one by one; they build
        lists and concatenate them:

            List a = T5.n.X(new C0540c2[]{p1, p2, p3});
            List b = OrbitsFractalKt.f12331a;        // shared orbit params
            super(T5.m.P0(a, b));

        Read as a single argument the whole group was lost, which left
        `colorPower` on the type's 0.0 -- and `pow(orbitDistance, 0.0)` is 1
        for every pixel, so all three orbit fractals rendered one colour.
        """
        expr = expr.strip()

        concat = re.match(r"^(?:[\w.]+\.)?(?:P0|Q0|z0)\((.*)\)$", expr, re.S)
        if concat:
            parts = split_args(concat.group(1))
            if len(parts) == 2:
                left, right = (self.eval_list(p) for p in parts)
                if left is not None and right is not None:
                    return left + right
            return None

        listed = re.match(r"^(?:[\w.]+\.)?[nm]\.X\((.*)\)$", expr, re.S)
        if listed:
            # `n.X` is varargs, so it takes either one array or the
            # descriptors themselves.
            inner = split_args(listed.group(1))
            if len(inner) == 1:
                nested = self.eval_list(inner[0])
                if nested is not None:
                    return nested
            specs = [self.eval_expr(a) for a in inner]
            specs = [s for s in specs if s and s.get("name")]
            return specs or None

        array = re.match(r"^new\s+[\w.$]+\[\]\s*\{(.*)\}$", expr, re.S)
        if array:
            specs = [self.eval_expr(a) for a in split_args(array.group(1))]
            return [s for s in specs if s and s.get("name")]

        if re.match(r"^[\w.]+$", expr):
            owner, _, field = expr.rpartition(".")
            scope = self.scopes.get(owner.split(".")[-1]) if owner else None
            value = (scope or self.env).get(field if owner else expr)
            if isinstance(value, list):
                return [s for s in value if isinstance(s, dict) and s.get("name")]
        return None

    def resolve_value(self, tok: str):
        tok = tok.strip()
        s = unquote(tok)
        if s is not None:
            return s
        if "(" in tok:
            # Numbers reach the builders boxed, as `Double.valueOf(0.1d)`.
            boxed = re.match(
                r"^(?:\w+\.)*(?:Double|Float|Integer|Long|Short|Byte|Boolean)"
                r"\.valueOf\((.*)\)$",
                tok,
                re.S,
            )
            if boxed:
                return self.resolve_value(boxed.group(1))
            # `new E2.a(x, y)` is a vec2, which is what the translation
            # builder `E1.t0` takes.
            vec = re.match(r"^new\s+[\w.$]*\ba\((.*)\)$", tok, re.S)
            if vec:
                parts = [as_number(a) for a in split_args(vec.group(1))]
                if len(parts) == 2 and all(p is not None for p in parts):
                    return [float(p) for p in parts]
            # `AbstractC0597o.G0(intensity, colour, hardness, transform)` is
            # the vignette composite: one descriptor standing for four
            # sub-parameters, which filters expose as `vignette_*`.  Dropped,
            # they fell back to type defaults and the app's hardness of 0.3
            # became 0.
            comp = re.match(r"^(?:[\w.]+\.)?G0\((.*)\)$", tok, re.S)
            if comp:
                parts = split_args(comp.group(1))
                if len(parts) == 4:
                    keys = ("intensity", "color", "hardness", "transform")
                    out = {}
                    for key, raw in zip(keys, parts):
                        value = self.resolve_value(raw)
                        if value is not None:
                            out[f"vignette_{key}"] = value
                    if out:
                        return out
            # `T5.n.X(a, b)` is a list literal, and it is how an array
            # parameter states its default -- `palette-posterize-lp` starts
            # from a two-entry black and white palette.
            listed = re.match(r"^(?:\w+\.)*n\.X\((.*)\)$", tok, re.S)
            if listed:
                items = [self.resolve_value(a) for a in split_args(listed.group(1))]
                if items and all(i is not None for i in items):
                    return items
            mat = self.resolve_matrix(tok)
            if mat is not None:
                return mat
        # Colour constants, named plainly or fully qualified as
        # `V4.AbstractC0597o.f8119g` in register code.
        if "AbstractC0597o." in tok:
            rgba = self.colors.get(tok.split(".")[-1])
            if rgba:
                return rgba
        n = as_number(tok)
        if n is not None:
            return n
        if tok in self.consts:
            return self.consts[tok]
        if tok.endswith(".TRUE") or tok == "true":
            return True
        if tok.endswith(".FALSE") or tok == "false":
            return False
        return None

    # -- statement interpretation -------------------------------------------
    def eval_expr(self, expr: str) -> dict | None:
        expr = expr.strip()
        base, calls = parse_chain(expr)

        # `n.e(0.02, param)` splits as base `n` plus a call `e(...)`, so fold
        # a leading range/default helper back into the base before resolving.
        # Register code spells the same call out in full as `m0.n.e(...)`.
        base_tail = base.strip().rsplit(".", 1)[-1]
        if calls and base_tail.isidentifier() and calls[0][0] in HELPERS:
            kind, args = calls[0]
            spec = self.eval_helper(kind, args)
            if spec is None:
                return None
            calls = calls[1:]
        else:
            spec = self.eval_base(base)
            if spec is None:
                return None
            spec = dict(spec)
        for method, args in calls:
            if method in METHOD_CONST:
                field, value = METHOD_CONST[method]
                spec[field] = value
                continue
            field = METHOD_FIELD.get(method)
            if field is None:
                continue
            if field == "range":
                rng = find_range(",".join(args)) or find_range(expr)
                if rng:
                    spec["min"], spec["max"] = rng
            elif field == "range_alt":
                rng = find_range(",".join(args))
                if rng:
                    spec.setdefault("min", rng[0])
                    spec.setdefault("max", rng[1])
            elif field == "options":
                opts = [self.resolve_value(a) for a in args]
                opts = [o for o in opts if o is not None]
                if opts:
                    spec["options"] = opts
            elif args:
                val = self.resolve_value(args[0])
                if val is not None:
                    spec[field] = val
            elif field == "gl_type":
                pass
        return spec

    def eval_helper(self, kind: str, args: list[str]) -> dict | None:
        """One of the static descriptor helpers, `i`/`j`/`k` included.

        jadx folds repeated call sites into synthetic helper classes, so a
        plain builder chain reappears as a static call on `A.f`:

            f.i(0.85, p)             ->  p.p(0.85).j()
            f.j(r, g, b, a, p)       ->  p.p(new colour(r, g, b, a))
            f.k(p, name, label, cat) ->  p.L(name).v(label).D(cat)

        Thirty-nine constructors set parameters only this way.  Dropping them
        left `cathodic-ray` on the registry's intensity of 1.0, and that makes
        `pow(10, (1 - intensity) * 20)` equal 1, which flattens its scanlines
        to a single white value.
        """
        if not args:
            return None

        if kind in ("k", "g"):
            # The descriptor comes first here; the rest are its labels.
            # `n.g` closes with a unit where `A.f.k` closes with a category.
            inner = self.eval_expr(args[0])
            names = [unquote(a) for a in args[1:]]
            if inner is None or len(names) != 3 or any(n is None for n in names):
                return None
            spec = dict(inner)
            last = "unit" if kind == "g" else "category"
            spec["name"], spec["label"], spec[last] = names
            return spec

        inner = self.eval_expr(args[-1])
        if inner is None:
            return None
        spec = dict(inner)
        nums = [as_number(a) for a in args[:-1]]

        if kind == "j":
            # A default colour, so every component has to be a number.
            if len(nums) == 4 and all(n is not None for n in nums):
                spec["default"] = [float(n) for n in nums]
            return spec

        nums = [n for n in nums if n is not None]
        if kind in ("d", "f") and len(nums) >= 2:
            spec["min"], spec["max"] = float(nums[0]), float(nums[1])
        elif kind == "e" and nums:
            # `n.e(s, p)` is `p.p(E1.n0(s))`: the default is a uniform scale
            # matrix, not the scalar.
            spec["default"] = matrices.build("n0", [nums[0]])
        elif kind == "i" and nums:
            spec["default"] = nums[0]
        # `t` widens a secondary soft range the UI does not use; it must not
        # replace the range `d` established.
        return spec

    # Descriptor factories in the registry itself:
    #   b(name) -> the named parameter, default 1.0
    #   a(name, i) -> the named parameter, default i
    # Parameters built through these otherwise lose their default and fall
    # back to the type's, which for `channelMultiplier` meant multiplying
    # every channel by zero.
    FACTORY_RE = re.compile(r"^(?:[\w.]+\.)?([ab])\((.*)\)$", re.S)

    def eval_factory(self, text: str) -> dict | None:
        m = self.FACTORY_RE.match(text.strip())
        if not m:
            return None
        args = split_args(m.group(2))
        if not args:
            return None
        name = unquote(args[0])
        if name is None:
            return None
        spec = {"name": name, "label": name}
        if m.group(1) == "b":
            spec["default"] = 1.0
        else:
            value = as_number(args[1]) if len(args) > 1 else None
            spec["default"] = 0 if value is None else value
        return spec

    def eval_base(self, base: str) -> dict | None:
        base = base.strip()
        factory = self.eval_factory(base)
        if factory is not None:
            return factory
        if base.startswith("new C0540c2("):
            open_idx = base.index("(")
            close = match_paren(base, open_idx)
            args = split_args(base[open_idx + 1 : close])
            return self.from_ctor(args)

        # Range/default helpers spelled out in full: `m0.n.e(0.02, p)`, and
        # the synthetic `A.f.i(0.85, p)`.
        m = re.match(r"^(?:\w+\.)?([defgijkt])\((.*)\)$", base, re.S)
        if m:
            spec = self.eval_helper(m.group(1), split_args(m.group(2)))
            if spec is not None:
                return spec

        # `AbstractC0565h2.f123` / `HalftoneKt.f456` / bare local
        if "." in base:
            owner, _, field = base.rpartition(".")
            scope = self.scopes.get(owner.split(".")[-1])
            found = scope.get(field) if scope is not None else self.env.get(field)
        else:
            found = self.env.get(base)
        return found if isinstance(found, dict) else None

    def from_ctor(self, args: list[str]) -> dict:
        """Positional ctor args.

        Slot 0 is the parameter name and slot 2 the default; the remaining
        slots differ between the real and the Kotlin default-args ctor, so
        range and label are recovered by value shape rather than position.
        """
        spec: dict = {}
        if args:
            name = unquote(args[0])
            if name:
                spec["name"] = name
        if len(args) > 2:
            val = self.resolve_value(args[2])
            if val is not None:
                spec["default"] = val
        joined = ",".join(args)
        rng = find_range(joined)
        if rng:
            spec["min"], spec["max"] = rng
        opts = find_options(joined)
        if opts:
            spec["choices"] = opts
        # Label: last string literal after the name slot.
        strings = [unquote(a) for a in args[1:]]
        strings = [s for s in strings if s]
        if strings:
            spec["label"] = strings[-1]
        return spec

    def run(self, required: bool = True) -> dict[str, dict]:
        m = re.search(r"\n    static \{\n(.*?)\n    \}\n", self.src, re.S)
        body = m.group(1) if m else ""
        if body:
            self.scan_consts(body)
            for stmt in self.statements(body):
                self.exec_stmt(stmt)

        # A companion may declare its descriptors as field initialisers rather
        # than inside a static block, and 14 of them do -- `HudKt` and
        # `CalloutsKt` state an `elements` bitmask of 255 that way, which is
        # every element switched on.  Read only from the static block, those
        # filters fell back to 0 and drew nothing at all.
        for stmt in self.field_initialisers():
            self.exec_stmt(stmt)

        if not m and not self.env:
            if required:
                raise SystemExit("static init block not found")
            return {}
        # Parameter groups are kept alongside individual descriptors so a
        # constructor can splice one in; only the named ones are exported.
        return {
            k: v
            for k, v in self.env.items()
            if (isinstance(v, dict) and v.get("name"))
            or (isinstance(v, list) and v)
        }

    FIELD_INIT_RE = re.compile(
        r"^\s*public static final [\w.$]+ (\w+)\s*=\s*", re.M
    )

    def field_initialisers(self) -> list[str]:
        """`public static final C0540c2 f12784a = new C0540c2(...);` as
        assignments, in declaration order."""
        out = []
        for m in self.FIELD_INIT_RE.finditer(self.src):
            end, depth, in_str, esc = m.end(), 0, False, False
            i = end
            while i < len(self.src):
                ch = self.src[i]
                if in_str:
                    if esc:
                        esc = False
                    elif ch == "\\":
                        esc = True
                    elif ch == '"':
                        in_str = False
                elif ch == '"':
                    in_str = True
                elif ch in "([{":
                    depth += 1
                elif ch in ")]}":
                    depth -= 1
                elif ch == ";" and depth == 0:
                    break
                i += 1
            out.append(f"{m.group(1)} = {self.src[end:i].strip()}")
        return out

    @staticmethod
    def statements(body: str) -> list[str]:
        out, depth, cur, in_str, esc = [], 0, [], False, False
        for ch in body:
            if in_str:
                cur.append(ch)
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == '"':
                    in_str = False
                continue
            if ch == '"':
                in_str = True
                cur.append(ch)
            elif ch in "([{":
                depth += 1
                cur.append(ch)
            elif ch in ")]}":
                depth -= 1
                cur.append(ch)
            elif ch == ";" and depth == 0:
                out.append("".join(cur).strip())
                cur = []
            else:
                cur.append(ch)
        return [s for s in out if s]

    def exec_stmt(self, stmt: str) -> None:
        # `C0540c2 var = expr` | `field = expr` | bare expr
        m = re.match(r"^(?:C0540c2\s+)?(\w+)\s*=\s*(.+)$", stmt, re.S)
        if not m:
            return
        target, expr = m.group(1), m.group(2)
        # eval_expr returns None for anything that does not bottom out in a
        # C0540c2 ctor or an already-known descriptor, so non-parameter
        # statements (type decls, unrelated locals) fall out naturally.
        spec = self.eval_expr(expr)
        if spec:
            self.env[target] = spec
            return
        # A shared group of parameters, held as a list for other constructors
        # to splice in.
        group = self.eval_list(expr)
        if group:
            self.env[target] = group


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "work/decompiled")
    src_file = root / "sources/V4/AbstractC0565h2.java"
    colors = load_colors(root)
    reg = Registry(src_file.read_text(), colors)
    print(f"loaded {len(colors)} named colour constants")
    specs = reg.run()
    out = Path("work/params.json")
    out.write_text(json.dumps(specs, indent=1, sort_keys=True))
    print(f"resolved {len(specs)} parameter fields -> {out}")
    for probe in ("f8029p1", "f7923M1", "f8050v2", "f7990f0"):
        print(f"  {probe}: {specs.get(probe)}")


if __name__ == "__main__":
    main()
