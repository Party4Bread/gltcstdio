"""Export the bank in the form the Rust crate consumes.

The Python renderer builds a GL 3.3 shader with loose `uniform` declarations
and lets moderngl find each one by name.  WebGPU has neither: every binding is
numbered, and everything that is not a texture lives in one uniform buffer.
So the same body is wrapped in a different header here:

    layout(binding = 0, std140) uniform Params { vec4 U[N]; ... };
    layout(binding = 1) uniform sampler samp;
    layout(binding = 2) uniform texture2D t_source;
    #define u_source     sampler2D(t_source, samp)
    #define u_intensity  (U[3].x)
    #define u_modelTransform (mat3(U[4].xyz, U[5].xyz, U[6].xyz))

Every uniform gets whole `vec4` slots, so the buffer layout is the same under
std140 and WGSL and needs no per-type alignment rules on either side.  The
manifest records which slot holds what and where its value comes from, which
is all the Rust runtime needs to fill the buffer.

`sampler2D` is spelled the Vulkan way -- a separate `texture2D` and `sampler`
combined at the use site -- because that is the only form naga's GLSL frontend
accepts, and naga is what turns these into WGSL.
"""

from __future__ import annotations

import json
import re
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from gltcstdio.backends import gl as glmod  # noqa: E402
from gltcstdio.bank import load_bank  # noqa: E402
from gltcstdio.params import Filter, array_spec  # noqa: E402

sys.path.insert(0, str(Path(__file__).resolve().parent))
from template_shader import statements  # noqa: E402

OUT = Path("rust/crates/gltcstdio/assets")

# Shaders a browser refuses that native wgpu accepts.  WebGPU requires an
# implicit-derivative sample to sit in uniform control flow and these call one
# inside a conditional or a loop, so their lookups take an explicit level
# instead.  The list is measured rather than guessed -- see the file's own
# comment for how to regenerate it.
_UNIFORMITY = json.loads(Path("tools/webgpu_uniformity.json").read_text())
EXPLICIT_LOD = set(_UNIFORMITY["explicit_lod"])
# The same rule applies to `dFdx`/`dFdy`; two filters take a gradient inside a
# conditional, and for those the declarations that feed it are lifted out.
HOIST_DERIVATIVES = set(_UNIFORMITY["derivative"])
WORLD = glmod.WORLD
ASPECT = glmod.ASPECT

# How many `vec4` slots a uniform of each type takes.
SLOTS = {"float": 1, "int": 1, "bool": 1, "vec2": 1, "vec3": 1, "vec4": 1,
         "mat3": 3, "mat4": 4}

# How the body reads a uniform back out of its slots.
def accessor(ty: str, slot: int) -> str:
    if ty in ("float",):
        return f"(U[{slot}].x)"
    if ty == "int":
        return f"(int(U[{slot}].x))"
    if ty == "bool":
        return f"(U[{slot}].x != 0.0)"
    if ty == "vec2":
        return f"(U[{slot}].xy)"
    if ty == "vec3":
        return f"(U[{slot}].xyz)"
    if ty == "vec4":
        return f"(U[{slot}])"
    if ty == "mat3":
        return "(mat3({0}, {1}, {2}))".format(
            *[f"U[{slot + i}].xyz" for i in range(3)]
        )
    if ty == "mat4":
        return "(mat4({0}, {1}, {2}, {3}))".format(
            *[f"U[{slot + i}]" for i in range(4)]
        )
    raise ValueError(f"no accessor for {ty}")


def index_suffix(elem: str) -> tuple[str, str]:
    """(declared element type, swizzle) for an array of `elem`."""
    return {
        "float": ("vec4", ".x"),
        "int": ("ivec4", ".x"),
        "vec2": ("vec4", ".xy"),
        "vec3": ("vec4", ".xyz"),
        "vec4": ("vec4", ""),
    }[elem]


def rewrite_indexed(text: str, name: str, suffix: str) -> str:
    """`name[expr]` -> `name[expr]<suffix>`, brackets matched properly."""
    if not suffix:
        return text
    out, i = [], 0
    pattern = re.compile(rf"\b{re.escape(name)}\s*\[")
    while True:
        m = pattern.search(text, i)
        if not m:
            out.append(text[i:])
            return "".join(out)
        depth, j = 0, m.end() - 1
        while j < len(text):
            if text[j] == "[":
                depth += 1
            elif text[j] == "]":
                depth -= 1
                if depth == 0:
                    break
            j += 1
        out.append(text[i : j + 1])
        out.append(suffix)
        i = j + 1


_GL_TYPE = (
    r"(?:void|bool|int|uint|float|double|[ibud]?vec[234]"
    r"|mat[234](?:x[234])?|[A-Z]\w*)(?:\s*\[\s*\w*\s*\])?"
)
DEF_RE = re.compile(rf"^[ \t]*{_GL_TYPE}\s+(\w+)\s*\(([^;{{]*)\)\s*\{{", re.M)
PROTO_RE = re.compile(rf"^[ \t]*{_GL_TYPE}\s+\w+\s*\([^;{{]*\)\s*;[ \t]*$", re.M)
DEFINE_RE = re.compile(r"^[ \t]*#define[ \t]+(\w+)", re.M)


def _match_brace(text: str, start: int) -> int:
    """The `}` closing the `{` at `start`, ignoring commented-out braces.

    Several library functions keep an earlier version of a block behind `//`,
    and counting those ended a function early -- which then swallowed the
    definitions after it, so a filter came out calling helpers that were no
    longer there.
    """
    depth, i, n = 0, start, len(text)
    while i < n:
        ch = text[i]
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i)
            i = n if j == -1 else j
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i)
            i = n if j == -1 else j + 2
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def order_functions(text: str, roots: set[str]) -> str:
    """The same code, pruned to what `roots` reach and sorted callees-first.

    naga's validator walks the function arena in order and refuses a call to
    something it has not seen, and the GLSL frontend keeps source order, so a
    library written with prototypes up front does not survive translation.
    Prototypes are dropped along the way: once the order is right they are
    redundant, and a repeated one is an error of its own.

    Pruning matters more here than in the GL backend: the driver discards
    unreachable functions itself, but WGSL is shipped as text, and carrying
    the whole 200-function library in each of 532 shaders came to 104 MB.
    """
    text = PROTO_RE.sub("", text)

    # Split into function definitions and everything else, in order.
    funcs: dict[str, str] = {}
    order: list[str] = []
    rest: list[str] = []
    i = 0
    while True:
        m = DEF_RE.search(text, i)
        if not m:
            rest.append(text[i:])
            break
        end = _match_brace(text, text.index("{", m.end() - 1))
        if end == -1:
            rest.append(text[i:])
            break
        rest.append(text[i : m.start()])
        name = m.group(1)
        chunk = text[m.start() : end + 1]
        if name in funcs:
            # A later definition of the same name is an overload; keep both
            # under a key that cannot collide.
            funcs[f"{name}#{len(order)}"] = chunk
            order.append(f"{name}#{len(order)}")
        else:
            funcs[name] = chunk
            order.append(name)
        i = end + 1

    defined = {k.split("#")[0] for k in order}
    calls: dict[str, set[str]] = {}
    for key in order:
        body = funcs[key]
        own = key.split("#")[0]
        calls[key] = {
            n
            for n in re.findall(r"\b(\w+)\s*\(", body)
            if n in defined and n != own
        }

    # Depth-first, emitting callees first.  A cycle would be illegal GLSL.
    emitted: list[str] = []
    state: dict[str, int] = {}
    by_name: dict[str, list[str]] = {}
    for key in order:
        by_name.setdefault(key.split("#")[0], []).append(key)

    def visit(key: str) -> None:
        if state.get(key):
            return
        state[key] = 1
        for callee in sorted(calls.get(key, ())):
            for k in by_name.get(callee, ()):
                if k != key:
                    visit(k)
        state[key] = 2
        emitted.append(key)

    sys.setrecursionlimit(10000)
    for name in sorted(roots):
        for key in by_name.get(name, ()):
            visit(key)

    return "\n".join(rest) + "\n\n" + "\n\n".join(funcs[k] for k in emitted)


ARRAY_DECL_RE = re.compile(
    r"^([ \t]*)(float|int|uint|bool|[ibu]?vec[234]|mat[234])[ \t]+"
    r"([A-Za-z_]\w*\s*\[[^;]*)\;",
    re.M,
)


def split_array_declarators(text: str) -> str:
    """`float em[4], en[4];` -> one declaration each.

    naga's GLSL frontend gives the second declarator of such a statement the
    wrong type, so `en[i]` came out as the whole array and `hyperbolic-square`
    failed to validate on an add between an array and a float.
    """

    def one(m: re.Match) -> str:
        indent, ty, rest = m.group(1), m.group(2), m.group(3)
        parts = [p.strip() for p in split_top_commas(rest) if p.strip()]
        if len(parts) < 2:
            return m.group(0)
        return "\n".join(f"{indent}{ty} {p};" for p in parts)

    return ARRAY_DECL_RE.sub(one, text)


CONST_INT_RE = re.compile(r"\bconst\s+int\s+(\w+)\s*=\s*(-?\d+)\s*;")


def inline_const_array_sizes(text: str) -> str:
    """Put the value of a `const int` into any array size that names it.

    An array length has to be a literal for naga; `contour-sort-lum` sizes its
    histogram `int[N] buckets` from a local `const int N = 256`.
    """
    for name, value in CONST_INT_RE.findall(text):
        text = re.sub(rf"\[\s*{re.escape(name)}\s*\]", f"[{value}]", text)
    return text


def split_top_commas(text: str) -> list[str]:
    """Split on commas that are not inside brackets or parentheses."""
    out, depth, cur = [], 0, []
    for ch in text:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            out.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    out.append("".join(cur))
    return out


ARRAY_PARAM_RE = re.compile(r"\[\s*\w+\s*\]")


def strip_array_params(text: str, uniforms: dict[str, str]) -> str:
    """Drop array-typed function parameters, reading the uniform instead.

    naga's GLSL frontend cannot give a function an array parameter, and four
    filters pass one straight from a uniform -- `menger-sponge` hands its
    eleven shape parameters down, `truchet` its tile table.  Since the value
    is the uniform either way, the parameter is removed from the definitions
    and the calls, and its uses point at the uniform.

    `uniforms` maps a parameter name to the swizzle its element needs.
    """
    drops: dict[str, list[int]] = {}
    names: set[str] = set()

    # Pass one: find the definitions and which of their parameters to drop.
    for m in DEF_RE.finditer(text):
        params = split_top_commas(m.group(2))
        indices = [
            i
            for i, p in enumerate(params)
            if ARRAY_PARAM_RE.search(p) and p.strip().split()[-1] in uniforms
        ]
        if indices:
            drops[m.group(1)] = indices
            names.update(params[i].strip().split()[-1] for i in indices)
    if not drops:
        return text

    # Pass two: rewrite every call and definition of those functions.
    for fname, indices in drops.items():
        keep = lambda args: [a for i, a in enumerate(args) if i not in indices]  # noqa: E731
        out, i = [], 0
        pattern = re.compile(rf"\b{re.escape(fname)}\s*\(")
        while True:
            m = pattern.search(text, i)
            if not m:
                out.append(text[i:])
                break
            close = _match_paren(text, m.end() - 1)
            if close == -1:
                out.append(text[i:])
                break
            args = split_top_commas(text[m.end() : close])
            out.append(text[i : m.end()])
            out.append(", ".join(a.strip() for a in keep(args)))
            out.append(")")
            i = close + 1
        text = "".join(out)

    # Pass three: point the uses at the uniform.  `palette.length()` has to go
    # too -- the array is a uniform now, and its size is known here anyway.
    for name in names:
        suffix, length = uniforms[name]
        text = re.sub(
            rf"\b{re.escape(name)}\s*\.\s*length\s*\(\s*\)", str(length), text
        )
        text = re.sub(rf"\b{re.escape(name)}\s*\[", f"{glmod._uniform(name)}[", text)
        text = rewrite_indexed(text, glmod._uniform(name), suffix)
    return text


STRUCT_RE = re.compile(r"\bstruct\s+(\w+)\s*\{([^}]*)\}\s*;", re.S)


def expand_struct_constructors(text: str) -> str:
    """`p = S(a, b, ...);` -> one assignment per field.

    naga cannot compose a struct that has an array member, which is what
    `tiled-glitch` does with the per-level `int modeMap[4]`.  Assigning the
    fields one at a time is the same thing written out.
    """
    def field(decl: str) -> tuple[str, int | None]:
        """(name, element count) for one struct member."""
        token = decl.strip().split()[-1]
        m = re.match(r"(\w+)\[(\d+)\]", token)
        if m:
            return m.group(1), int(m.group(2))
        m = re.match(r"\w+\s*\[(\d+)\]", decl.strip())
        return token, int(m.group(1)) if m else None

    structs = {
        m.group(1): [field(f) for f in m.group(2).split(";") if f.strip()]
        for m in STRUCT_RE.finditer(text)
    }
    if not structs:
        return text
    names = "|".join(re.escape(n) for n in structs)
    pattern = re.compile(rf"([A-Za-z_][\w.\[\]]*)\s*=\s*({names})\s*\(")
    while True:
        m = pattern.search(text)
        if not m:
            return text
        close = _match_paren(text, m.end() - 1)
        semi = text.find(";", close)
        if close == -1 or semi == -1 or text[close + 1 : semi].strip():
            return text
        lhs, sname = m.group(1), m.group(2)
        args = [a.strip() for a in split_top_commas(text[m.end() : close])]
        fields = structs[sname]
        if len(args) != len(fields):
            return text
        parts = []
        for (fname, count), arg in zip(fields, args):
            if count is None:
                parts.append(f"{lhs}.{fname} = {arg};")
            else:
                # naga has no whole-array assignment either.
                parts.extend(
                    f"{lhs}.{fname}[{i}] = {arg}[{i}];" for i in range(count)
                )
        text = text[: m.start()] + " ".join(parts) + text[semi + 1 :]


DERIV_RE = re.compile(r"\bdFd[xy]\s*\(")
DECL_RE = re.compile(
    r"^\s*(?:float|int|uint|bool|[ibu]?vec[234]|mat[234])\s+(\w+)\s*=", re.S
)


def hoist_derivatives(text: str) -> str:
    """Lift a derivative out of the conditional it is taken in.

    WebGPU requires `dpdx`/`dpdy` in uniform control flow, and two filters
    compute a gradient inside an `if`.  Everything the gradient reads is
    already in scope above that `if`, so the declarations move up: the value
    is the same, it is simply computed whether or not the branch is taken --
    which is what the hardware does for a quad in any case.
    """
    pattern = re.compile(r"\bif\s*\(")
    at = 0
    while True:
        m = pattern.search(text, at)
        if not m:
            return text
        at = m.end()
        close = _match_paren(text, m.end() - 1)
        if close == -1:
            continue
        brace = text.find("{", close)
        if brace == -1 or text[close + 1 : brace].strip():
            continue
        end = _match_brace(text, brace)
        if end == -1:
            continue

        body = text[brace + 1 : end]
        parts = [st for st in statements(body)]
        wanted = {
            i for i, st in enumerate(parts) if DERIV_RE.search(st) and DECL_RE.match(st)
        }
        if not wanted:
            continue

        # Pull in the declarations those read, walking back through the block.
        changed = True
        while changed:
            changed = False
            names = set()
            for i in sorted(wanted):
                names.update(re.findall(r"\b\w+\b", parts[i]))
            for i, st in enumerate(parts):
                if i in wanted:
                    continue
                d = DECL_RE.match(st)
                if d and d.group(1) in names and i < max(wanted):
                    wanted.add(i)
                    changed = True

        lifted = [parts[i].strip() + ";" for i in sorted(wanted)]
        kept = [parts[i] for i in range(len(parts)) if i not in wanted and parts[i].strip()]
        indent = " " * (m.start() - text.rfind("\n", 0, m.start()) - 1)
        text = (
            text[: m.start()]
            + ("\n" + indent).join(lifted)
            + "\n"
            + indent
            + text[m.start() : brace + 1]
            + "".join(st + ";" for st in kept)
            + text[end:]
        )
        # A sibling branch declaring the same thing would now be a redefinition.
        for statement in lifted:
            tail = text[end:]
            text = text[:end] + tail.replace(statement.strip(), "", 1)
        at = m.start()


SWITCH_RE = re.compile(r"\bswitch\s*\(")
LABEL_RE = re.compile(r"\b(case\s+([^:]+?)|default)\s*:")


def rewrite_switch(text: str) -> str:
    """Turn `switch` into an if/else chain.

    WGSL has no fall-through and naga will not translate a case block it
    cannot prove terminates, which includes every case ending in `return` --
    so the library's `blend()`, and with it every shader, stopped there.  Only
    the shape the app actually uses is rewritten: each case ends in `break` or
    `return`, so no case runs on into the next and the chain is equivalent.
    """
    while True:
        m = SWITCH_RE.search(text)
        if not m:
            return text
        open_p = m.end() - 1
        close_p = _match_paren(text, open_p)
        brace = text.index("{", close_p)
        end = _match_brace(text, brace)
        if close_p == -1 or end == -1:
            return text
        selector = text[open_p + 1 : close_p].strip()
        # Comments are dropped first: a case whose trailing comment is an
        # earlier version of the same statement reads as if it fell through.
        body = re.sub(r"//[^\n]*", "", text[brace + 1 : end])

        groups = _switch_groups(body)
        if groups is None:
            # Not the simple shape; leave it and let translation report it.
            return text

        var = "_sw_sel"
        lines = [f"{{ int {var} = int({selector});"]
        for i, (labels, block) in enumerate(groups):
            block = _drop_case_break(block)
            if labels is None:
                lines.append(f"else {{ {block} }}")
            else:
                cond = " || ".join(f"{var} == int({v})" for v in labels)
                lines.append(f"{'if' if i == 0 else 'else if'} ({cond}) {{ {block} }}")
        lines.append("}")
        text = text[: m.start()] + "\n".join(lines) + text[end + 1 :]


def _drop_case_break(block: str) -> str:
    """Remove the `break` that ends a case, leaving any inside a loop alone.

    A case can be a braced block -- `halftone-rgb` writes `{ ...; break; }` --
    so the one to drop is the last `break` at the block's own nesting level,
    not simply the last one in the text.
    """
    block = block.strip()
    depth, last = 0, -1
    for m in re.finditer(r"[{}()\[\]]|\bfor\b|\bwhile\b|\bdo\b|\bbreak\s*;", block):
        tok = m.group(0)
        if tok in "{([":
            depth += 1
        elif tok in "})]":
            depth -= 1
        elif tok.startswith("break"):
            # Depth 1 is the case's own braces when it is written as a block.
            if depth <= (1 if block.startswith("{") else 0):
                last = m.start()
    if last < 0:
        return block
    after = re.sub(r"^\bbreak\s*;", "", block[last:])
    if after.strip(" \t\n\r}") != "":
        # Not the last statement -- a conditional `break` out of the switch,
        # which the chain cannot express; leave it and let naga object.
        return block
    return (block[:last] + after).strip()


def _switch_groups(body: str):
    """[(case values | None for default, statements)], or None if it falls through."""
    marks = []
    depth = 0
    i = 0
    while i < len(body):
        ch = body[i]
        if ch in "{([":
            depth += 1
        elif ch in "})]":
            depth -= 1
        elif depth == 0:
            m = LABEL_RE.match(body, i)
            if m:
                marks.append((m.start(), m.end(), None if m.group(1) == "default"
                              else m.group(2).strip()))
                i = m.end()
                continue
        i += 1
    if not marks:
        return None

    groups = []
    for idx, (start, end, value) in enumerate(marks):
        stop = marks[idx + 1][0] if idx + 1 < len(marks) else len(body)
        block = body[end:stop].strip()
        if not block:
            # An empty case shares the next one's block.
            groups.append((value, None))
            continue
        if not re.search(r"(?:\bbreak\s*;|\breturn\b[^;]*;|\})\s*$", block):
            return None
        groups.append((value, block))

    # Merge the empty cases into the group that follows them.
    merged = []
    pending: list[str] = []
    for value, block in groups:
        if block is None:
            pending.append(value)
            continue
        labels = None if value is None else pending + [value]
        if value is None and pending:
            return None
        merged.append((labels, block))
        pending = []
    if pending:
        return None
    return merged


def _match_paren(text: str, start: int) -> int:
    depth = 0
    for i in range(start, len(text)):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return i
    return -1


def dedupe_defines(text: str) -> str:
    """Drop a `#define` of a name already defined; naga's preprocessor errors.

    The library carries the engine prelude's constants and a filter may carry
    the same ones again, identically.
    """
    seen: set[str] = set()
    out = []
    for line in text.split("\n"):
        m = DEFINE_RE.match(line)
        if m:
            if m.group(1) in seen:
                continue
            seen.add(m.group(1))
        out.append(line)
    return "\n".join(out)


class Plan:
    """The uniform slots of one filter, and where each value comes from."""

    def __init__(self) -> None:
        self.slots: list[dict] = []
        self.defines: list[str] = []
        self.n = 0

    def add(self, ty: str, source: dict, define_as: str | None) -> int:
        slot = self.n
        self.n += SLOTS[ty]
        entry = dict(source)
        entry["slot"] = slot
        entry["ty"] = ty
        self.slots.append(entry)
        if define_as:
            self.defines.append(f"#define {define_as} {accessor(ty, slot)}")
        return slot


def build(
    f: Filter,
    renderer: glmod.Renderer,
    explicit_lod: bool = False,
    hoist: bool = False,
) -> tuple[str, dict]:
    """The WebGPU-flavoured GLSL for one filter, and its manifest entry.

    `explicit_lod` takes the mip level out of the driver's hands, which a
    browser needs wherever the filter samples inside a conditional.  It costs
    the mip filtering, so it is only used where it is required.
    """
    body = glmod._fix_array_return(
        glmod._fix_reversed_clamp(renderer.bank.glsl(f.id))
    )

    stdlib = renderer._stdlib
    for name, sig in glmod._defined_functions(body).items():
        if glmod._defined_functions(stdlib).get(name) == sig:
            stdlib = glmod._strip_function(stdlib, name)

    samplers = renderer._samplers(f)
    legacy = glmod._legacy_uniforms(body, [])
    legacy_samplers = [n for n, t in glmod.LEGACY_UNIFORMS.items()
                       if t == "sampler2D" and n in legacy]

    plan = Plan()
    textures: list[dict] = []
    macros: list[str] = []

    # -- textures --------------------------------------------------------
    for s in samplers:
        tex = f"t_{s}"
        textures.append({"name": s, "binding": 2 + len(textures)})
        plan.defines.append(f"#define {glmod._uniform(s)} sampler2D({tex}, samp)")
        macros.append(
            f"#define __{s}__texelFetch__(c) texelFetch({glmod._uniform(s)}, (c), 0)"
        )
        coord = f"(vec2((p).x / {ASPECT}, (p).y) / {WORLD} + 0.5)"
        if f.wrap.get(s) == "mirrored_repeat" or f.wrap.get("source") == "mirrored_repeat":
            coord = f"__mirror_wrap__{coord}"
        if explicit_lod:
            macros.append(
                f"#define __{s}__(p) textureLod({glmod._uniform(s)}, {coord}, 0.0)"
            )
        else:
            macros.append(f"#define __{s}__(p) texture({glmod._uniform(s)}, {coord})")
    for name in legacy_samplers:
        tex = f"t_legacy_{len(textures)}"
        textures.append({"name": "source", "binding": 2 + len(textures)})
        plan.defines.append(f"#define {name} sampler2D({tex}, samp)")

    # -- engine uniforms -------------------------------------------------
    plan.add("float", {"kind": "out_aspect"}, ASPECT)
    # The view transform is a real parameter on 520 filters -- `checkerboard`
    # zooms out ten-fold through it -- and only defaults to identity where the
    # filter does not declare one.  Binding it to identity unconditionally left
    # every procedural pattern rendering at the wrong scale.
    declares_view = any(p.name == "viewTransform" for p in f.params)
    plan.add(
        "mat3",
        {"kind": "param", "name": "viewTransform"} if declares_view
        else {"kind": "identity"},
        glmod._uniform("viewTransform"),
    )

    for u in f.runtime:
        name, ty = u["name"], u["type"]
        if name.endswith("_specified"):
            src = {"kind": "const", "value": [1.0]}
        elif name == "outDim":
            src = {"kind": "out_dim"}
        elif name.endswith("Dim"):
            src = {"kind": "input_dim", "input": name[: -len("Dim")]}
        elif name == "outAspectRatio":
            src = {"kind": "out_aspect"}
        elif name in ("aspectRatio", "pixelAspectRatio"):
            src = {"kind": "in_aspect"}
        else:
            src = {"kind": "const", "value": [0.0]}
        plan.add(ty, src, glmod._uniform(name))

    if "u_outDim" not in [d.split()[1] for d in plan.defines]:
        plan.add("vec2", {"kind": "out_dim"}, "u_outDim")

    for name, decl in legacy.items():
        ty = glmod.LEGACY_UNIFORMS[name]
        if ty == "sampler2D":
            continue
        src = {"vec2": {"kind": "in_dim"}, "mat3": {"kind": "identity"},
               "float": {"kind": "const", "value": [0.0]}}[ty]
        # `u_SourceTransform` is the one legacy matrix that is not identity.
        # The three shaders reading it -- `blur`, `gaussian-blurh` and
        # `gaussian-blurv` -- are handed a coordinate in world units and
        # sample with `texture(u_Source, u_SourceTransform * vec3(uv, 1))`,
        # so it carries the way back to texture space: the same map the
        # `__source__` macros apply everywhere else.
        if name == "u_SourceTransform":
            src = {"kind": "source_transform"}
        plan.add(ty, src, name)

    # -- parameters ------------------------------------------------------
    arrays: list[str] = []
    array_uniforms: dict[str, str] = {}
    for p in f.params:
        if p.name == "viewTransform":
            continue  # already bound as the engine slot above
        spec = array_spec(p.type)
        if spec is None:
            plan.add(p.type, {"kind": "param", "name": p.name},
                     glmod._uniform(p.name))
            continue
        elem, length = spec
        decl_ty, suffix = index_suffix(elem)
        array_uniforms[p.name] = (suffix, length)
        var = glmod._uniform(p.name)
        arrays.append(f"    {decl_ty} {var}[{length}];")
        plan.slots.append({
            "kind": "array_param", "name": p.name, "ty": p.type,
            "elem": elem, "length": length, "slot": -1,
            "array_index": len(arrays) - 1,
        })
        body = rewrite_indexed(body, var, suffix)

    # -- assemble --------------------------------------------------------
    args = []
    world_uv = f"((v_uv - 0.5) * {WORLD} * vec2({ASPECT}, 1.0))"
    uv_expr = f"(inverse({glmod._uniform('viewTransform')}) * vec3({world_uv}, 1.0)).xy"
    seen = 0
    for entry in f.signature_args():
        if entry["kind"] == "implicit":
            args.append(uv_expr if seen == 0 else world_uv)
            seen += 1
        elif entry["name"] in array_uniforms:
            # `strip_array_params` took this one out of the signature.
            continue
        else:
            args.append(glmod._uniform(entry["name"]))

    block = [f"    vec4 U[{max(1, plan.n)}];"] + arrays
    header = [
        "#version 450",
        "layout(location = 0) in vec2 v_uv;",
        "layout(location = 0) out vec4 fragColor;",
        "",
        "layout(binding = 0, std140) uniform Params {",
        *block,
        "};",
        "layout(binding = 1) uniform sampler samp;",
    ]
    for i, t in enumerate(textures):
        names = [f"t_{s}" for s in samplers] + [
            f"t_legacy_{len(samplers) + j}" for j in range(len(legacy_samplers))
        ]
        header.append(f"layout(binding = {t['binding']}) uniform texture2D {names[i]};")

    # naga wants every function defined before it is called and rejects a
    # repeated `#define`, neither of which GL cares about, so the library and
    # the filter body are merged and sorted rather than concatenated.
    # Anything a macro or a `#define` names is reachable too: `__source__`
    # expands to a call the body never spells out.
    roots = {f.function}
    for line in macros + plan.defines:
        roots.update(re.findall(r"\b(\w+)\s*\(", line))

    merged = "\n".join([
        glmod.MIRROR_WRAP,
        stdlib,
        glmod._drop_body_constants(body),
    ])
    if hoist:
        merged = hoist_derivatives(merged)
    merged = split_array_declarators(inline_const_array_sizes(merged))
    merged = strip_array_params(merged, array_uniforms)
    merged = expand_struct_constructors(merged)
    code = order_functions(rewrite_switch(merged), roots=roots)

    source = dedupe_defines("\n".join([
        *header,
        "",
        *plan.defines,
        "",
        *macros,
        "",
        *glmod._body_constants(body),
        "",
        code,
        "",
        "void main() {",
        f"    fragColor = {f.function}({', '.join(args)});",
        "}",
        "",
    ]))

    entry = {
        "slots": plan.slots,
        "vec4_count": max(1, plan.n),
        "textures": textures,
        "arrays": [a.strip() for a in arrays],
    }
    return source, entry


FONT_PX = 64
FONT_FIRST, FONT_LAST = 32, 126


def export_font() -> dict:
    """Rasterise ASCII once so the text filters need no font machinery.

    The Python build draws text with whatever system font Pillow finds, so
    there is no exact glyph shape to match; one atlas rendered here at a fixed
    size, scaled at draw time, gives the crate the same letters with no
    dependency and no per-machine variation.
    """
    from PIL import Image, ImageDraw

    from gltcstdio.backends.cpu.shapes import _font

    font = _font(FONT_PX)
    glyphs = []
    blob = bytearray()
    for code in range(FONT_FIRST, FONT_LAST + 1):
        ch = chr(code)
        probe = ImageDraw.Draw(Image.new("L", (1, 1)))
        box = probe.textbbox((0, 0), ch, font=font)
        gw = max(1, box[2] - box[0])
        gh = max(1, box[3] - box[1])
        tile = Image.new("L", (gw, gh), 0)
        ImageDraw.Draw(tile).text((-box[0], -box[1]), ch, font=font, fill=255)
        glyphs.append({
            "code": code,
            "w": gw,
            "h": gh,
            # Ink bounds relative to the anchor the drawing uses, and the pen
            # advance kept as a float: rounding each one accumulates across a
            # word and pushes the later letters out of place.
            "left": box[0],
            "top": box[1],
            "advance": float(probe.textlength(ch, font=font)),
            "offset": len(blob),
        })
        blob.extend(tile.tobytes())

    (OUT / "font.bin").write_bytes(bytes(blob))
    return {"px": FONT_PX, "glyphs": glyphs}


def param_json(p) -> dict:
    d = {"name": p.name, "type": p.type, "label": p.label, "default": p.default,
         "widget": p.widget}
    for key in ("min", "max", "step"):
        v = getattr(p, key)
        if v is not None:
            d[key] = v
    if p.options:
        d["options"] = list(p.options)
    if p.choices:
        d["choices"] = [dict(c) for c in p.choices]
    if p.engine:
        d["engine"] = True
    return d


def main() -> None:
    bank = load_bank()
    # Snapshot before the renderer is built: it shares this bank, and the
    # loop below swaps every shader entry back in so `build` can reach the
    # GLSL of a filter the CPU version otherwise serves.
    specs = sorted(bank.list(supported_only=False), key=lambda x: x.id)
    raw = json.loads(Path("gltcstdio/data/bank.json").read_text())["filters"]
    renderer = glmod.Renderer()
    for fid, spec in raw.items():
        if spec.get("backend") == "gl":
            renderer.bank._filters[fid] = Filter.from_dict(spec)

    glsl_dir = OUT / "glsl"
    web_dir = OUT / "glsl-web"
    for d in (glsl_dir, web_dir):
        if d.exists():
            shutil.rmtree(d)
        d.mkdir(parents=True)

    filters: dict[str, dict] = {}
    exported = skipped = 0
    for f in specs:
        entry = {
            "id": f.id,
            "name": f.name,
            "category": f.category,
            "backend": f.backend,
            "fidelity": f.fidelity,
            "params": [param_json(p) for p in f.params],
            "presets": [{"name": p.name, "params": dict(p.params)}
                        for p in f.presets],
            "inputs": f.inputs,
            "extra_inputs": list(f.extra_inputs),
        }
        if f.backend == "graph":
            entry["graph"] = f.graph
            # A wrapper is a filter, not a look someone assembled: an editor
            # opens it as one node with its own control rather than taking it
            # apart into the shader and the blur feeding it.
            if f.wrapped:
                entry["wrapped"] = f.wrapped
        elif f.backend == "gl":
            try:
                source, gpu = build(f, renderer)
            except Exception as exc:  # noqa: BLE001 - report and continue
                print(f"  skip {f.id}: {type(exc).__name__}: {exc}")
                skipped += 1
                continue
            (glsl_dir / f"{f.id}.frag").write_text(source)
            if f.id in EXPLICIT_LOD or f.id in HOIST_DERIVATIVES:
                web_source, _ = build(
                    f,
                    renderer,
                    explicit_lod=f.id in EXPLICIT_LOD,
                    hoist=f.id in HOIST_DERIVATIVES,
                )
                (web_dir / f"{f.id}.frag").write_text(web_source)
            entry["gpu"] = gpu
            exported += 1
        filters[f.id] = entry

    (OUT / "font.json").write_text(
        json.dumps(export_font(), separators=(",", ":"))
    )
    (OUT / "bank.json").write_text(
        json.dumps({"filters": filters}, separators=(",", ":"), sort_keys=True)
    )
    web = len(list(web_dir.glob("*.frag")))
    print(f"{len(filters)} filters, {exported} shaders exported, {skipped} skipped")
    print(f"  {web} also written for the web, sampling at an explicit level")
    print(f"  -> {OUT/'bank.json'} ({(OUT/'bank.json').stat().st_size/1e6:.1f} MB)")


if __name__ == "__main__":
    main()
