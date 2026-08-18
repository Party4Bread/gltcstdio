"""Pull in helper functions a filter calls but does not carry.

Several filters -- the ray marchers especially -- keep their helpers in a
shared class rather than their own, so recovering the entry point is not
enough: `sdf`, `rayMarch` and `getIntersectionD` are still undefined at
compile time.

`tools/dex_shaders.py` indexes every GLSL function in the dex by name, so the
missing ones can be looked up wherever they were defined and appended,
following each newly added function's own calls until nothing is left
dangling.  Anything the stdlib already provides is left alone.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

CALL_RE = re.compile(r"\b([A-Za-z_]\w*)\s*\(")
DEF_RE = re.compile(
    r"^\s*(?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234](?:x[234])?|[A-Z]\w*)"
    r"\s+([A-Za-z_]\w*)\s*\([^)]*\)\s*\{",
    re.M,
)

# GLSL built-ins and keywords a call-site regex would otherwise flag.
BUILTINS = {
    "if", "for", "while", "switch", "return", "else", "do",
    "abs", "acos", "all", "any", "asin", "atan", "ceil", "clamp", "cos",
    "cosh", "cross", "degrees", "distance", "dot", "equal", "exp", "exp2",
    "faceforward", "floor", "fract", "greaterThan", "greaterThanEqual",
    "inverse", "inversesqrt", "length", "lessThan", "lessThanEqual", "log",
    "log2", "matrixCompMult", "max", "min", "mix", "mod", "normalize", "not",
    "notEqual", "pow", "radians", "reflect", "refract", "round", "sign",
    "sin", "sinh", "smoothstep", "sqrt", "step", "tan", "tanh", "texture",
    "textureLod", "texelFetch", "textureSize", "transpose", "trunc",
    "dFdx", "dFdy", "fwidth", "isnan", "isinf", "determinant", "outerProduct",
    "bool", "int", "uint", "float", "double", "void", "struct", "discard",
    "vec2", "vec3", "vec4", "ivec2", "ivec3", "ivec4", "bvec2", "bvec3",
    "bvec4", "uvec2", "uvec3", "uvec4", "mat2", "mat3", "mat4", "mat2x2",
    "mat2x3", "mat2x4", "mat3x2", "mat3x3", "mat3x4", "mat4x2", "mat4x3",
    "mat4x4", "modf", "atomicAdd", "packHalf2x16", "unpackHalf2x16",
}


def defined_in(text: str) -> set[str]:
    return {m.group(1) for m in DEF_RE.finditer(text)}


def called_in(text: str) -> set[str]:
    # Strip line comments so commented-out calls do not pull in code.
    stripped = re.sub(r"//[^\n]*", "", text)
    return {m.group(1) for m in CALL_RE.finditer(stripped)} - BUILTINS


def resolve(body: str, index: dict[str, str], stdlib_names: set[str]) -> list[str]:
    """Extra chunks needed so every function `body` calls is defined."""
    have = defined_in(body) | stdlib_names
    extra: list[str] = []
    pending = called_in(body) - have
    guard = 0
    while pending and guard < 40:
        guard += 1
        name = sorted(pending)[0]
        pending.discard(name)
        chunk = index.get(name)
        if chunk is None:
            continue
        new_defs = defined_in(chunk)
        if name not in new_defs:
            continue
        if new_defs & have:
            # Would redefine something already present.
            continue
        extra.append(chunk)
        have |= new_defs
        pending |= called_in(chunk) - have
    return extra


def preamble_for(text_all: str, structs: dict, defines: dict,
                 stdlib_defines: set, stdlib_structs: set) -> list[str]:
    """Types and constants `text_all` uses but nothing declares."""
    head: list[str] = []
    for name, decl in defines.items():
        # Only screaming-case names: a #define for a short lowercase name
        # would rewrite an ordinary local and break the shader.
        if name in stdlib_defines or not re.fullmatch(r"[A-Z][A-Z0-9_]{2,}", name):
            continue
        if f"#define {name}" in text_all:
            continue
        # If the shader declares the name itself, defining it would rewrite
        # the declaration into a constant and break the parse.
        if re.search(
            r"\b(?:const\s+)?(?:int|uint|float|double|bool|[ibud]?vec[234]"
            rf"|mat[234](?:x[234])?)\s+{re.escape(name)}\b",
            text_all,
        ):
            continue
        if re.search(rf"\b{re.escape(name)}\b", text_all):
            head.append(decl)
    for name, decl in structs.items():
        if name in stdlib_structs or f"struct {name}" in text_all:
            continue
        if re.search(rf"\b{re.escape(name)}\s+[A-Za-z_]", text_all):
            head.append(decl)
    return head


def load_context() -> tuple[dict, dict, dict, set, set, set]:
    """(index, structs, defines, stdlib_names, stdlib_defines, stdlib_structs)"""
    index_path = Path("work/glsl_index.json")
    index = json.loads(index_path.read_text()) if index_path.exists() else {}
    pre_path = Path("work/glsl_preamble.json")
    preamble = json.loads(pre_path.read_text()) if pre_path.exists() else {}
    stdlib = Path("gltcstdio/data/glsl/stdlib.glsl").read_text()
    stdlib_names = defined_in(stdlib) | {
        m.group(1) for m in re.finditer(r"^\s*\w+\s+(\w+)\s*\([^)]*\)\s*;", stdlib, re.M)
    }
    return (
        index,
        preamble.get("structs", {}),
        preamble.get("defines", {}),
        stdlib_names,
        set(re.findall(r"^\s*#define\s+(\w+)", stdlib, re.M)),
        set(re.findall(r"^\s*struct\s+(\w+)", stdlib, re.M)),
    )


def complete(body: str) -> str:
    """`body` plus every helper, struct and define it needs to compile."""
    index, structs, defines, names, sdefs, sstructs = load_context()
    extra = resolve(body, index, names)
    head = preamble_for("\n".join(extra) + body, structs, defines, sdefs, sstructs)
    return _dedupe_definitions("\n\n".join([*head, *extra, body])) + "\n"


def main() -> None:
    index_path = Path("work/glsl_index.json")
    if not index_path.exists():
        print("no work/glsl_index.json; run tools/dex_shaders.py first")
        return
    index = json.loads(index_path.read_text())

    stdlib = Path("gltcstdio/data/glsl/stdlib.glsl").read_text()
    stdlib_names = defined_in(stdlib) | {
        m.group(1) for m in re.finditer(r"^\s*\w+\s+(\w+)\s*\([^)]*\)\s*;", stdlib, re.M)
    }

    pre_path = Path("work/glsl_preamble.json")
    preamble = json.loads(pre_path.read_text()) if pre_path.exists() else {}
    structs = preamble.get("structs", {})
    defines = preamble.get("defines", {})
    stdlib_defines = set(re.findall(r"^\s*#define\s+(\w+)", stdlib, re.M))
    stdlib_structs = set(re.findall(r"^\s*struct\s+(\w+)", stdlib, re.M))

    glsl_dir = Path("gltcstdio/data/glsl/filters")
    patched = added = pre_added = 0
    for path in sorted(glsl_dir.glob("*.glsl")):
        body = path.read_text()
        extra = resolve(body, index, stdlib_names)

        # Types and constants the filter uses but nothing declares.  Both are
        # cheap enough to add on demand rather than reason about precisely.
        head: list[str] = []
        text_all = "\n".join(extra) + body
        for name, decl in defines.items():
            # Only screaming-case names: a #define for a short lowercase name
            # would rewrite an ordinary local and break the shader.  Two
            # letters is enough -- the anti-aliasing factor is spelled `AA`,
            # and requiring three left `hyperbolic-lace` without it.
            if name in stdlib_defines or not re.fullmatch(r"[A-Z][A-Z0-9_]+", name):
                continue
            if f"#define {name}" in text_all:
                continue
            # If the shader declares the name itself, defining it would
            # rewrite the declaration into a constant and break the parse.
            if re.search(
                r"\b(?:const\s+)?(?:int|uint|float|double|bool|[ibud]?vec[234]"
                rf"|mat[234](?:x[234])?)\s+{re.escape(name)}\b",
                text_all,
            ):
                continue
            if re.search(rf"\b{re.escape(name)}\b", text_all):
                head.append(decl)
        for name, decl in structs.items():
            if name in stdlib_structs or f"struct {name}" in text_all:
                continue
            # Used as a type, i.e. followed by a declarator.
            if re.search(rf"\b{re.escape(name)}\s+[A-Za-z_]", text_all):
                head.append(decl)

        if not extra and not head:
            continue
        parts = head + extra + [body]
        path.write_text(_dedupe_definitions("\n\n".join(parts)))
        patched += 1
        added += len(extra)
        pre_added += len(head)
    print(
        f"patched {patched} filters: {added} helper functions, "
        f"{pre_added} structs/defines"
    )


SIG_RE = re.compile(
    r"^\s*(?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234](?:x[234])?|[A-Z]\w*)"
    r"\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*\{",
    re.M,
)


def _signature(name: str, params: str) -> tuple:
    """Name plus parameter types -- GLSL allows overloading on the latter."""
    types = []
    for raw in params.split(","):
        toks = [
            t
            for t in raw.split()
            if t not in ("in", "out", "inout", "const", "highp", "mediump", "lowp")
        ]
        if len(toks) >= 2:
            types.append(toks[-2])
    return (name, tuple(types))


def _dedupe_definitions(text: str) -> str:
    """Drop repeat definitions of one signature; GLSL rejects those."""
    seen: set[tuple] = set()
    out: list[str] = []
    pos = 0
    for m in SIG_RE.finditer(text):
        name = _signature(m.group(1), m.group(2))
        start = m.start()
        depth, i = 0, text.index("{", m.end() - 1)
        while i < len(text):
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        end = i + 1
        if name in seen:
            out.append(text[pos:start])
            pos = end
        else:
            seen.add(name)
    out.append(text[pos:])
    return "".join(out)


if __name__ == "__main__":
    main()
