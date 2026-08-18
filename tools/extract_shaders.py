"""Extract per-filter GLSL and parameter signatures from the effect classes.

Each shader effect class carries:

  * an operator name, registered via `model.S(this, "halftone")` and used by
    the preset DSL -- this is the filter's stable id;
  * one main GLSL function whose name equals that operator name;
  * zero or more helper GLSL functions used only by that filter.

The main function's signature is authoritative for parameter names and types:

    vec4 halftone(vec2 uv, vec2 outPos, float smoothen, float intensity,
                  mat3 modelTransform, vec4 color1, vec4 color2,
                  int sampling, int style)

`uv` and `outPos` are supplied by the runtime; everything after them is a
configurable parameter.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from extract_stdlib import FUNC_RE, STR_LIT_RE, decode  # noqa: E402
import raymarcher  # noqa: E402
from template_shader import (  # noqa: E402
    CLASS_SOURCES,
    assemble,
    assemble_any,
    assemble_helpers,
)

# Shaders recovered straight from dex bytecode by tools/dex_shaders.py, for
# the filters whose pieces the decompiler cannot show.
_DEX_PATH = Path("work/dex_shaders.json")
DEX_SHADERS: dict[str, str] = (
    json.loads(_DEX_PATH.read_text()) if _DEX_PATH.exists() else {}
)

OPNAME_RE = re.compile(r"\.S\(\s*this\s*,\s*\"([^\"]+)\"\s*\)")
# Two more ways a class names the operator it registers.  `Sharpen` passes it
# to its own constructor and the ray-marcher primitives all do the same, while
# a handful register through `u` rather than `v`; between them these name 37
# operators nothing else was picking up.
SUPER_NAME_RE = re.compile(r"super\(\s*\"([a-z][a-z0-9-]*)\"\s*,")
PRESET_HEAD_RE = re.compile(r'new s8\(\s*"[^"]*"\s*,\s*"\(([a-zA-Z0-9_\-]+)')

# Parameters the runtime provides rather than the user.
IMPLICIT = {"uv", "outPos", "outpos", "pos", "fragCoord"}


def split_params(params: str) -> list[tuple[str, str]]:
    out = []
    for raw in params.split(","):
        raw = raw.strip()
        if not raw:
            continue
        toks = raw.split()
        if len(toks) < 2:
            continue
        # drop qualifiers such as `in`, `out`, `const`
        toks = [t for t in toks if t not in ("in", "out", "inout", "const", "highp", "mediump", "lowp")]
        if len(toks) < 2:
            continue
        out.append((toks[-2], toks[-1]))
    return out


STRUCT_RE = re.compile(r"^\s*struct\s+\w+\s*\{", re.M)
DEFINE_RE = re.compile(r"^\s*#define\s+\w+", re.M)
CONST_RE = re.compile(
    r"^\s*const\s+(?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234])\s+\w+", re.M
)


def is_glsl(text: str) -> bool:
    """A literal worth keeping: a function, struct, #define or const block.

    Structs and #defines carry no function definition but the filters that use
    them will not compile without them.
    """
    return bool(
        FUNC_RE.search(text)
        or STRUCT_RE.search(text)
        or DEFINE_RE.search(text)
        or CONST_RE.search(text)
    )


def strip_comments(text: str) -> str:
    """GLSL with `//` and `/* */` comments blanked out."""
    return re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S)


# A slot the recovery left empty: a call whose last argument is missing, a
# comparison or an initialiser with nothing on the right, a bare `return`.
EMPTY_SLOT = re.compile(
    r",\s*\)|[<>]\s*\)|=\s*[;)]|\breturn\s*;|=\s*\n\s*(?=return\b)"
)


def has_empty_slot(text: str) -> bool:
    """Whether a value the app splices in is missing from `text`."""
    return bool(EMPTY_SLOT.search(strip_comments(text)))


# What may legitimately precede the first definition in a recovered shader.
_PREFIX_OK = re.compile(r"^(?:\s|#\w[^\n]*|const\b[^;]*;|struct\b[^;]*;)*$")


def has_stray_prefix(text: str) -> bool:
    """Whether loose text sits in front of the shader's first definition.

    Reading the bytecode in instruction order picks up literals a generator
    passes to its helper methods before it builds the shader itself, and they
    land ahead of the first function -- `tiled-streak` began with the four
    direction vectors its neighbour lookup is generated from.
    """
    stripped = strip_comments(text)
    m = FUNC_RE.search(stripped)
    return m is not None and not _PREFIX_OK.fullmatch(stripped[: m.start()])


def balanced(text: str) -> bool:
    """Braces balance, so the literal is a whole translation unit fragment.

    Several filters build their shader from a Kotlin string template that
    interleaves literals with generated code; those literals are fragments and
    cannot be compiled on their own.

    Commented-out code is skipped.  `circuit` and `random-color-dispersion`
    both keep an earlier version of a loop behind `//`, braces and all, and
    counting those made two complete shaders look like fragments.
    """
    depth = 0
    for ch in strip_comments(text):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


# `p.D0(template, "XXX", "vec2(d, 0.0)")` is String.replace: the blur family
# keeps one template and substitutes the sweep direction into it.
REPLACE_CALL = re.compile(r"\bD0\s*\(")


def substitutions(src: str) -> dict[str, list[str]]:
    """Template -> replaced variants, for literals passed through D0()."""
    from javaexpr import match_paren, split_args

    out: dict[str, list[str]] = {}
    for m in REPLACE_CALL.finditer(src):
        open_idx = src.index("(", m.end() - 1)
        close = match_paren(src, open_idx)
        if close == -1:
            continue
        args = split_args(src[open_idx + 1 : close])
        if len(args) != 3:
            continue
        parts = []
        for a in args:
            lit = STR_LIT_RE.fullmatch(a.strip())
            if lit is None:
                break
            parts.append(decode(lit.group(1)))
        if len(parts) != 3:
            continue
        template, old, new = parts
        if not is_glsl(template) or not old:
            continue
        out.setdefault(template.strip(), []).append(template.replace(old, new).strip())
    return out


def glsl_chunks(src: str) -> list[str]:
    subs = substitutions(src)
    chunks, seen = [], set()
    for m in STR_LIT_RE.finditer(src):
        text = decode(m.group(1)).strip()
        if not is_glsl(text):
            continue
        # A template is never used raw; only its substituted forms are.
        for variant in subs.get(text, [text]):
            if variant in seen:
                continue
            seen.add(variant)
            chunks.append(variant)
    return chunks


def defined_names(chunk: str) -> list[str]:
    return [m.group(2) for m in FUNC_RE.finditer(chunk)]


def op_name(src: str) -> str | None:
    m = OPNAME_RE.search(src)
    if m:
        return m.group(1)
    m = SUPER_NAME_RE.search(src)
    if m:
        return m.group(1)
    m = PRESET_HEAD_RE.search(src)
    if m:
        return m.group(1)
    return None


def _entry_point(chunks: list[str]) -> str | None:
    """The chunk defining the filter's entry point, chosen by shape.

    Every filter is invoked as `f(pos, outPos, ...)` with two implicit vec2
    coordinates first, and the entry point is never called from the filter's
    own helpers.
    """
    candidates = []
    for chunk in chunks:
        m = FUNC_RE.search(chunk)
        if not m or m.group(1) != "vec4":
            continue
        typed = split_params(m.group(3))
        if len(typed) < 2:
            continue
        if typed[0][0] != "vec2" or typed[1][0] != "vec2":
            continue
        if typed[1][1] not in IMPLICIT:
            continue
        candidates.append((m.group(2), chunk))
    if not candidates:
        return None

    called_elsewhere = set()
    for name, chunk in candidates:
        for other in chunks:
            if other is chunk:
                continue
            if re.search(rf"\b{re.escape(name)}\s*\(", other):
                called_elsewhere.add(name)
    free = [(n, c) for n, c in candidates if n not in called_elsewhere]
    pool = free or candidates
    # Prefer the longest: the entry point carries the filter's whole body.
    return max(pool, key=lambda nc: len(nc[1]))[1]


def extract_file(path: Path) -> dict | None:
    src = path.read_text()
    op = op_name(src)
    chunks = glsl_chunks(src)
    if not chunks:
        return None

    # An abstract class that registers no operator name is not a filter.
    # `RayMarcherOld` calls `model.S(this, null)`, nothing extends it, and the
    # entry it produced -- named after its `rayMarcher` function -- was for a
    # shader the app never compiles.
    if op is None and re.search(r"^public abstract class\b", src, re.M):
        return None

    main_chunk = None
    helpers = []
    seen_defs: set[str] = set()
    for chunk in chunks:
        names = defined_names(chunk)
        if op and op in names and main_chunk is None:
            main_chunk = chunk
            seen_defs.update(names)
        elif names and seen_defs.intersection(names):
            # A later literal redefining an already-defined function is an
            # alternative version the app selects between; keep the first.
            continue
        else:
            helpers.append(chunk)
            seen_defs.update(names)

    if main_chunk is None:
        # No operator name recorded, or the main function is named
        # differently; fall back to the chunk whose function name matches the
        # class name case-insensitively.
        stem = path.stem.lower()
        for chunk in list(helpers):
            if any(n.lower() == stem for n in defined_names(chunk)):
                main_chunk = chunk
                helpers.remove(chunk)
                op = op or defined_names(chunk)[0]
                break

    if main_chunk is None:
        # Some filters name their entry point after the technique rather than
        # the operator (`block-corrupt` is implemented by `blockBW`).  Pick it
        # out structurally instead: the engine calls every filter as
        # f(pos, outPos, ...), and the entry point is the one nothing else
        # calls.
        main_chunk = _entry_point(helpers)
        if main_chunk is not None:
            helpers.remove(main_chunk)

    if main_chunk is None:
        return None

    m = FUNC_RE.search(main_chunk)
    ret, fname, params = m.group(1), m.group(2), m.group(3)
    typed = split_params(params)
    # The engine builds each call as `f(<coord>, v_OutCoordinate, <rest>)` and
    # takes the uniforms from `subList(2, ...)`, so the first two parameters
    # are the implicit coordinates by position -- whatever they are named.
    # `fourCornerGradient(vec2 u, vec2 outPos, ...)` calls its first `u`, and
    # binding that as a uniform leaves the filter with no coordinate at all.
    def _implicit(index: int, name: str, gl_type: str) -> bool:
        if index < 2 and gl_type == "vec2":
            return True
        return name in IMPLICIT

    signature = [
        {"name": n, "gl_type": t, "implicit": _implicit(i, n, t)}
        for i, (t, n) in enumerate(typed)
    ]
    sig_params = [
        {"name": e["name"], "gl_type": e["gl_type"]}
        for e in signature
        if not e["implicit"]
    ]
    implicit = [e["name"] for e in signature if e["implicit"]]

    # Category is the first directory under effects/, so that
    # effects/glitch/legacy/Foo.java stays in "glitch" rather than "legacy".
    parts = path.parts
    idx = parts.index("effects")
    category = parts[idx + 1] if idx + 1 < len(parts) - 1 else "misc"

    # A main function whose braces do not balance was cut out of a Kotlin
    # string template and is only part of the real shader.  Re-run the
    # template assembly to recover the whole thing.
    truncated = not balanced(main_chunk)
    # An argument the recovery could not resolve leaves a hole -- a call ending
    # in a comma, an initialiser with nothing after the `=`.  The text balances
    # and looks whole, so it has to be checked for separately.
    holed = has_empty_slot(main_chunk) or has_stray_prefix(main_chunk)
    if truncated or holed:
        # A previous dex pass may already have recovered this one verbatim.
        dex_rec = DEX_SHADERS.get(op or fname)
        rebuilt = None
        if dex_rec:
            rebuilt = dex_rec["main"] if isinstance(dex_rec, dict) else dex_rec
            if (has_empty_slot(rebuilt) or has_stray_prefix(rebuilt)) and not truncated:
                # No better than what is already here.
                rebuilt = None
            elif isinstance(dex_rec, dict) and dex_rec.get("helpers"):
                # Helpers recovered alongside replace the partial ones jadx
                # produced for this class.
                helpers = list(dex_rec["helpers"])
        if not rebuilt or has_empty_slot(rebuilt) or has_stray_prefix(rebuilt):
            # The bytecode reads a field once and keeps it in a register, so a
            # value spliced in more than once survives only the first time.
            # Running the Java template instead resolves every occurrence.
            from_template = assemble(src, fname)
            if (
                from_template
                and not has_empty_slot(from_template)
                and not has_stray_prefix(from_template)
            ):
                rebuilt = from_template
        if rebuilt:
            main_chunk = rebuilt
            truncated = False
            # The rebuilt text carries its own helpers, so drop the fragments
            # that were harvested as separate literals.
            helpers = [h for h in helpers if h not in rebuilt]
            m = FUNC_RE.search(main_chunk)
            if m:
                ret, fname, params = m.group(1), m.group(2), m.group(3)
                typed = split_params(params)
                signature = [
                    {"name": n, "gl_type": t, "implicit": n in IMPLICIT}
                    for t, n in typed
                ]
                sig_params = [
                    {"name": n, "gl_type": t} for t, n in typed if n not in IMPLICIT
                ]
                implicit = [n for t, n in typed if n in IMPLICIT]

    # The helper list a class builds is what the app actually compiles, and it
    # carries pieces no literal holds on its own: the constants
    # `HyperbolicSquare` declares, and the signatures the ray marchers splice
    # their extra arguments into.  Where it and the scraped literals define the
    # same function, it wins.
    built_helpers = list(dict.fromkeys(h.strip() for h in assemble_helpers(src)))
    if built_helpers:
        defined = {n for h in built_helpers for n in defined_names(h)}
        helpers = [
            h for h in helpers if not defined.intersection(defined_names(h))
        ] + built_helpers

    return {
        "id": op or fname,
        "function": fname,
        "truncated": truncated,
        "return_type": ret,
        "class": path.stem,
        "category": category,
        "legacy": "legacy" in path.parts,
        "implicit": implicit,
        "signature": signature,
        "params": sig_params,
        "main": main_chunk,
        "helpers": helpers,
        "source_path": str(path),
    }


CLASS_REF_RE = re.compile(r"\b([A-Z]\w+)\.f\d")


def _referenced_field(src: str, cls: str) -> str | None:
    """The single field of `cls` this source names, if there is exactly one."""
    names = set(re.findall(rf"\b{re.escape(cls)}\.(\w+)", src))
    return next(iter(names)) if len(names) == 1 else None


def _base_class(name: str, by_class: dict) -> str | None:
    """Resolve a referenced class to one that owns a shader.

    Wrappers often point at a filter through its companion, e.g.
    `LocusKt.b(env, GlitchMirrorFreeClonesKt.f12608a, ...)`.
    """
    if name in by_class:
        return name
    if name.endswith("Kt") and name[:-2] in by_class:
        return name[:-2]
    return None


# `env.v("height-map", <expr>)` registers an operator; `descriptor.v("axes")`
# only sets a display label.  Matching both turned 39 parameter labels --
# `red`, `size`, `angle`, `axes`, `p`, `q`, `r` -- into filters of their own,
# each a duplicate of whatever class happened to declare the parameter.  The
# trailing comma is what tells the two apart.
DERIVED_RE = re.compile(r"\.[uv]\(\s*\"([a-z][a-z0-9-]*)\"\s*,")

# `env.v("height-map", AbstractC1963b.R(env, this, "sourceElevation", <param>,
# ...))` does not register the raw shader under a second name: R rebuilds it as
# a graph whose named input is fed by `gaussian-blur2(source, radius=<param>)`,
# and adds the parameter that controls the blur.  Without this the two names
# are the same filter and the control is missing.  `T` is `R` fixed to
# `source2` and a `smoothen` of 0.01; `S` spells its parameter out inline.
WRAPPED_RE = re.compile(
    r'\.[uv]\(\s*"([a-z][a-z0-9-]*)"\s*,\s*AbstractC1963b\.([RST])\('
    r'\s*\w+\s*,\s*this\s*(?:,\s*"([^"]+)"\s*,\s*'
    r'(?:(\w+)\.A\("[^"]*"\)|"([^"]+)"\s*,\s*([0-9.]+)d))?'
)
# The name of the descriptor the wrappers build on, when one is not given.
BASE_PARAM_NAME = "blur"


def _descriptors(src: str) -> dict:
    """Local parameter descriptors in one class, by variable name."""
    out = {}
    for m in re.finditer(r"C0540c2\s+(\w+)\s*=\s*([^;]+);", src):
        var, expr = m.group(1), m.group(2)
        name = re.search(r'\.L\("([^"]*)"\)', expr)
        label = re.search(r'\.D\("([^"]*)"\)', expr) or re.search(r'\.v\("([^"]*)"\)', expr)
        default = re.search(r"\.p\(Double\.valueOf\(([0-9.]+)d\)\)", expr)
        out[var] = {
            "name": name.group(1) if name else BASE_PARAM_NAME,
            "label": label.group(1) if label else None,
            "default": float(default.group(1)) if default else 0.0,
        }
    return out


# `env.v("shards-gl", LocusKt.b(env, this, <pinned>, ...))` is the other
# wrapper a class registers itself through.  It does not rename the shader, it
# blends it: `locusBlend(source, effect = <shader>(source, ...))` confined to a
# region.  Most reach the bank through the curated-look extraction; the ones a
# class builds around its own shader arrive here instead, and without this they
# are the shader again under a second name.
LOCUS_RE = re.compile(
    r'\.[uv]\(\s*"([a-z][a-z0-9-]*)"\s*,\s*LocusKt\.b\(\s*\w+\s*,\s*'
    r'(this|[\w.]+)\s*,'
)
# `f.v("locusMode", new C0542d(6))` pins one of the blend's own parameters.
PINNED_RE = re.compile(r'\.v\(\s*"(\w+)"\s*,\s*new C0542d\(\s*([0-9.]+)d?\s*\)')


def locus_in(src: str, name: str, by_class: dict | None = None) -> dict | None:
    """The locus blend a class registers `name` through.

    The shader blended is usually the class's own, but a preset class blends
    another class's -- `PresetPixelColorShift` blends
    `PixelateWithOrderedDithering` with the locus pinned to mode 6.
    """
    from javaexpr import match_paren, split_args

    for m in LOCUS_RE.finditer(src):
        found, target = m.group(1), m.group(2)
        if found != name:
            continue
        # The pinned map is an argument in its own right and carries commas of
        # its own, so the call is split on balanced parentheses rather than by
        # counting them.
        call = src.index("LocusKt.b(", m.start())
        inside = match_paren(src, src.index("(", call))
        args = split_args(src[src.index("(", call) + 1 : inside]) if inside != -1 else []
        pinned = args[2] if len(args) > 2 else ""
        base = None
        if target != "this":
            # The shader blended may sit in a Kotlin file class -- `MirrorKt`,
            # `HexKaleidoscopeKt` -- which holds no filter of its own.  The
            # entry has already resolved which filter it aliases by then, so
            # fall back to that rather than refusing the blend.
            base = (by_class or {}).get(target.split(".")[0])
        fixed = {}
        for pm in PINNED_RE.finditer(pinned):
            raw = pm.group(2)
            fixed[pm.group(1)] = float(raw) if "." in raw else int(raw)
        out = {"pinned": fixed}
        if base:
            out["base"] = base
        return out
    return None


# `P7 = AbstractC1963b.P(env, ColorPickAngular.f12441k, ...)` re-parameterises
# another class's shader.  Read as an alias of the class it sits in, the entry
# came out as a copy of an unrelated filter; the shader it names is the one it
# is built from.
REBASE_RE = re.compile(
    r"(?:(\w+)\s*=\s*|\.[uv]\(\s*\"([a-z][a-z0-9-]*)\"\s*,\s*)"
    r"(?:LocusKt\.b|AbstractC1963b\.[PRST])\(\s*\w+\s*,\s*(\w+)\."
)


def rebased_on(src: str, name: str, by_class: dict) -> str | None:
    """The filter whose shader `name` is built from, when it is another's."""
    held = {}
    for m in REBASE_RE.finditer(src):
        var, direct, cls = m.groups()
        base = by_class.get(cls)
        if base is None:
            continue
        if direct == name:
            return base
        if var:
            held[var] = base
    for m in re.finditer(r'\.[uv]\(\s*"([a-z][a-z0-9-]*)"\s*,\s*([A-Za-z_]\w*)\s*\)', src):
        if m.group(1) == name and m.group(2) in held:
            return held[m.group(2)]
    return None


def wrapper_in(src: str, name: str) -> dict | None:
    """The blur wrapper a class registers `name` through, if it does.

    The call is either inline -- `env.v("height-map", AbstractC1963b.R(...))`
    -- or held in a local first, as `S4 = AbstractC1963b.S(...)` followed by
    `env.v("contour", S4)`.  Both forms are the same registration.
    """
    descriptors = _descriptors(src)

    def spec(kind, inp, var, pname, pdefault):
        if kind == "T":
            return {"input": "source2",
                    "param": {"name": "smoothen", "label": "Smooth", "default": 0.01}}
        if kind == "S":
            return {"input": inp,
                    "param": {"name": pname, "label": None, "default": float(pdefault)}}
        param = descriptors.get(var)
        return {"input": inp, "param": param} if param and inp else None

    # Wrappers held in a local, by variable name.
    held = {}
    for m in re.finditer(
        r"(\w+)\s*=\s*AbstractC1963b\.([RST])\(\s*\w+\s*,\s*this\s*"
        r'(?:,\s*"([^"]+)"\s*,\s*(?:(\w+)\.A\("[^"]*"\)|"([^"]+)"\s*,\s*([0-9.]+)d))?',
        src,
    ):
        var, kind, inp, dvar, pname, pdefault = m.groups()
        got = spec(kind, inp, dvar, pname, pdefault)
        if got:
            held[var] = got

    for m in re.finditer(r'\.[uv]\(\s*"([a-z][a-z0-9-]*)"\s*,\s*([A-Za-z_]\w*)\s*\)', src):
        if m.group(1) == name and m.group(2) in held:
            return held[m.group(2)]

    for m in WRAPPED_RE.finditer(src):
        found, kind, inp, var, pname, pdefault = m.groups()
        if found == name:
            return spec(kind, inp, var, pname, pdefault)
    return None


def find_derived(paths: list[Path], results: dict) -> dict:
    """Operators a class registers in addition to its own.

    A class often exposes a second, wrapped operator alongside its primary one
    -- `HeightMap` registers `height-map-raw` through `S(this, ...)` and
    `height-map` through `env.v("height-map", ...)`.  Both run the same shader,
    so the derived name is an alias with its own presets.
    """
    by_class = {rec["class"]: fid for fid, rec in results.items()}
    derived = {}
    for path in paths:
        base_id = by_class.get(path.stem)
        src = path.read_text()
        if base_id is None:
            # The wrapper may live in a class of its own and point at another.
            refs = {
                m for m in CLASS_REF_RE.findall(src) if m in by_class and m != path.stem
            }
            if len(refs) != 1:
                continue
            base_id = by_class[next(iter(refs))]
        base = results[base_id]
        base_params = {p["name"] for p in base.get("params", [])}
        for name in DERIVED_RE.findall(src):
            if name in results or name in derived or name == base_id:
                continue
            # A parameter with a default reads exactly like an operator:
            # `OutrunSunGL` registers `q7.v("outrun-sun-gl", ...)` on the
            # environment and declares `f.v("glow", <default>)` on the
            # descriptor, and only the receiver tells them apart.  A name that
            # is already a parameter of the very shader it would duplicate is
            # the declaration, not a second operator -- which is what `glow`,
            # `mode`, `phase2` and `style` were, each a copy of its own filter
            # with the presets missing.
            if name in base_params and path.stem == base["class"]:
                continue
            # The shader this name is built from is the one its registration
            # passes, which is not always the class the call sits in.
            on = rebased_on(src, name, by_class) or base_id
            built_from = results[on]
            entry = {
                **{k: v for k, v in built_from.items() if k != "id"},
                "id": name,
                "class": path.stem,
                "alias_of": on,
                "legacy": "legacy" in path.parts,
                "source_path": str(path),
            }
            wrapper = wrapper_in(src, name)
            if wrapper is not None:
                entry["wrapper"] = wrapper
            locus = locus_in(src, name, by_class)
            if locus is not None:
                entry["locus"] = locus
                if locus.get("base"):
                    entry["alias_of"] = locus["base"]
            derived[name] = entry
    return derived


EXTENDS_RE = re.compile(r"\bclass\s+(\w+)\s+extends\s+([\w.]+)")


def find_subclass_filters(paths: list[Path], results: dict) -> dict:
    """Operators that are a parameterisation of another class's shader.

    `Sharpen extends UnsharpMask` and registers `sharpen` from its own
    constructor; the 14 `shape-*` operators and the ray-marcher primitives do
    the same.  They carry no GLSL, so the shader comes from the class they
    extend -- 37 registered operators were missing entirely without this.
    """
    by_class = {rec["class"]: fid for fid, rec in results.items()}
    parents, names = {}, {}
    for path in paths:
        src = path.read_text()
        m = EXTENDS_RE.search(src)
        if m:
            parents[m.group(1)] = m.group(2).rsplit(".", 1)[-1]
        op = op_name(src)
        if op:
            names[path.stem] = (op, path)

    by_name = {p.stem: p for p in paths}
    assembled: dict[str, dict | None] = {}

    def from_parent(parent: str, own_src: str, key: str) -> dict | None:
        """The shader an abstract base holds for its family.

        The base leaves holes for the subclass to fill -- `AbstractShape`
        calls `H()` where the shape's distance function goes, and
        `CircleShape` returns `d = sdDisk(u, 0.5);` from it.  Assembling with
        only the base's own empty implementations produced a shader with no
        shape in it at all, so the subclass's overrides are laid over the
        base's before the template is run.
        """
        if key in assembled:
            return assembled[key]
        assembled[key] = None
        parent_path = by_name.get(parent)
        if parent_path is not None:
            text = assemble_any(parent_path.read_text() + "\n" + own_src)
            if text:
                m = FUNC_RE.search(text)
                if m:
                    typed = split_params(m.group(3))
                    assembled[key] = {
                        "function": m.group(2),
                        "truncated": False,
                        "return_type": m.group(1),
                        "category": parent_path.parent.name,
                        "implicit": [n for t, n in typed if n in IMPLICIT],
                        "signature": [
                            {"name": n, "gl_type": t, "implicit": n in IMPLICIT}
                            for t, n in typed
                        ],
                        "params": [
                            {"name": n, "gl_type": t}
                            for t, n in typed
                            if n not in IMPLICIT
                        ],
                        "main": text,
                        "helpers": [],
                    }
        return assembled[key]

    out: dict[str, dict] = {}
    for cls, (op, path) in names.items():
        if op in results or op in out or cls in by_class:
            continue
        seen, parent = set(), parents.get(cls)
        while parent and parent not in seen:
            seen.add(parent)
            base_id = by_class.get(parent)
            if base_id:
                base = results[base_id]
                out[op] = {
                    **{k: v for k, v in base.items() if k != "id"},
                    "id": op,
                    "class": cls,
                    "alias_of": base_id,
                    "legacy": "legacy" in path.parts,
                    "source_path": str(path),
                }
                break
            # The ray marchers take their distance function from the
            # subclass, so the base is assembled per subclass rather than once.
            base_path = raymarcher.base_for(path, parents, by_name)
            if base_path is not None:
                built = raymarcher.recover(base_path.read_text(), path.read_text())
                if built:
                    m = FUNC_RE.search(built["main"])
                    if m:
                        typed = split_params(m.group(3))
                        out[op] = {
                            "id": op,
                            "function": m.group(2),
                            "truncated": False,
                            "return_type": m.group(1),
                            "class": cls,
                            "category": path.parent.name,
                            "legacy": "legacy" in path.parts,
                            "implicit": [n for t, n in typed if n in IMPLICIT],
                            "signature": [
                                {"name": n, "gl_type": t, "implicit": n in IMPLICIT}
                                for t, n in typed
                            ],
                            "params": [
                                {"name": n, "gl_type": t}
                                for t, n in typed
                                if n not in IMPLICIT
                            ],
                            "main": built["main"],
                            "helpers": built["helpers"],
                            "source_path": str(path),
                        }
                        break

            shared = from_parent(parent, path.read_text(), f"{parent}/{cls}")
            if shared:
                out[op] = {
                    **shared,
                    "id": op,
                    "class": cls,
                    "legacy": "legacy" in path.parts,
                    "source_path": str(path),
                }
                break
            parent = parents.get(parent)
    return out


GLSL_FIELD_RE = re.compile(
    r"public static final String (\w+)\s*=\s*(.+?);\s*$", re.M | re.S
)


def glsl_fields(src: str) -> dict[str, str]:
    """String fields of a class whose value is GLSL, keyed by field name.

    `GaussianBlur1PassHandVKt` holds the horizontal and vertical sweeps as two
    fields built from one template; the classes that expose them as separate
    filters each point at one of those fields, so an alias has to follow the
    field rather than just the class.
    """
    out: dict[str, str] = {}
    subs = substitutions(src)
    for m in GLSL_FIELD_RE.finditer(src):
        name, expr = m.group(1), m.group(2)
        lits = [decode(x.group(1)) for x in STR_LIT_RE.finditer(expr)]
        glsl = [t for t in lits if is_glsl(t)]
        if not glsl:
            continue
        text = glsl[0].strip()
        variants = subs.get(text)
        if variants:
            # The field is a substituted form; pick the one this expression
            # produces by re-applying its own replacement arguments.
            if len(lits) >= 3:
                text = text.replace(lits[-2], lits[-1]).strip()
            else:
                text = variants[0]
        out[name] = text
    return out


def find_aliases(paths: list[Path], results: dict) -> dict:
    """Classes that add presets on top of another class's shader.

    `ScanlinesGL` registers the operator `scanlines-gl` but owns no GLSL; it
    reuses `Scanlines`' shader with different parameters.  These are real,
    separately-named filters in the app, so they belong in the bank.
    """
    by_class = {rec["class"]: fid for fid, rec in results.items()}
    aliases = {}
    # GLSL fields per class, so an alias can pick the exact variant it names.
    field_cache: dict[str, dict[str, str]] = {}
    for p in paths:
        stem = p.stem
        if stem.endswith("Kt") or stem in by_class:
            fields = glsl_fields(p.read_text())
            if fields:
                field_cache[stem] = fields
    for path in paths:
        if path.stem in by_class:
            continue
        src = path.read_text()
        op = op_name(src)
        if not op or op in results or op in aliases:
            continue
        if glsl_chunks(src):
            continue  # owns GLSL but we failed to match it; not an alias
        refs = {
            r for r in map(lambda m: _base_class(m, by_class), CLASS_REF_RE.findall(src))
            if r is not None and r != path.stem
        }
        if len(refs) != 1:
            continue
        base_cls = next(iter(refs))
        base_id = by_class[base_cls]
        base = results[base_id]
        entry = {
            **{k: v for k, v in base.items() if k != "id"},
            "id": op,
            "class": path.stem,
            "alias_of": base_id,
            "legacy": "legacy" in path.parts,
            "source_path": str(path),
        }

        # If this class points at one particular GLSL field of the base, use
        # that field's source: sibling filters often share a template and
        # differ only in the value substituted into it.
        field = _referenced_field(src, base_cls)
        if field is not None:
            variant = field_cache.get(base_cls, {}).get(field)
            if variant and variant != base.get("main"):
                entry["main"] = variant

        # An alias registered through `LocusKt.b` is not the base shader under
        # a second name: it is that shader blended over a region, with the
        # region's own controls.  `HexCubePixelateGL` reads as a plain alias of
        # `HexCubePixelate` and is one of forty-four that were.
        locus = locus_in(src, op, by_class)
        if locus is not None:
            entry["locus"] = locus
            if locus.get("base"):
                entry["alias_of"] = locus["base"]
        aliases[op] = entry
    return aliases


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "work/decompiled")
    eff = next((root / "sources").glob("**/pap2/effects"))
    # Let the template evaluator follow a call into another operator's class.
    CLASS_SOURCES.update({p.stem: p for p in eff.rglob("*.java")})
    results, skipped = {}, []
    for path in sorted(eff.rglob("*.java")):
        try:
            rec = extract_file(path)
        except Exception as exc:  # noqa: BLE001 - report and continue
            skipped.append((path.name, f"{type(exc).__name__}: {exc}"))
            continue
        if rec is None:
            continue
        fid = rec["id"]
        if fid in results:
            # Prefer the non-legacy definition.
            if results[fid]["legacy"] and not rec["legacy"]:
                results[fid] = rec
            continue
        results[fid] = rec

    java_files = sorted(eff.rglob("*.java"))
    aliases = find_aliases(java_files, results)
    results.update(aliases)
    derived = find_derived(java_files, results)
    results.update(derived)
    inherited = find_subclass_filters(java_files, results)
    results.update(inherited)

    out = Path("work/shaders.json")
    out.write_text(json.dumps(results, indent=1))
    print(
        f"{len(results)} shader filters "
        f"({len(aliases)} aliases, {len(derived)} derived) -> {out}"
    )
    cats: dict[str, int] = {}
    for r in results.values():
        cats[r["category"]] = cats.get(r["category"], 0) + 1
    print("by category:", dict(sorted(cats.items(), key=lambda kv: -kv[1])))
    if skipped:
        print(f"skipped {len(skipped)}: {skipped[:5]}")


if __name__ == "__main__":
    main()
