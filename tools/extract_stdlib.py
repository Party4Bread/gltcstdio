"""Extract the pap2 GLSL support library from b5/AbstractC0919h.java.

The library ships as plain Java string literals holding GLSL source.  The app
injects only the functions a given shader actually references, so the library
also contains dead and malformed entries (half-edited functions, one literal
that is Kotlin rather than GLSL) which never reach a real compile there.

We want a single always-injectable blob instead, so every chunk is compiled in
isolation against a real GL context and the ones that fail are dropped.  What
survives is guaranteed to compile as a unit.

Prototypes for all surviving functions precede the bodies, so call order inside
the library never matters.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

GLSL_TYPES = r"(?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234](?:x[234])?|sampler\w*)"
FUNC_RE = re.compile(rf"^\s*({GLSL_TYPES})\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*\{{", re.M)
STR_LIT_RE = re.compile(r'"((?:[^"\\]|\\.)*)"', re.S)
DEFINE_RE = re.compile(r"^\s*#define\s+\w+\s+\S+", re.M)

RESERVED = {"if", "for", "while", "switch", "return", "else", "do"}

VERT = """#version 330 core
in vec2 a_pos;
out vec2 v_uv;
void main(){ v_uv = a_pos*0.5+0.5; gl_Position = vec4(a_pos,0,1); }
"""


def decode(lit: str) -> str:
    out, i = [], 0
    while i < len(lit):
        ch = lit[i]
        if ch == "\\" and i + 1 < len(lit):
            nxt = lit[i + 1]
            mapping = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\", "'": "'"}
            if nxt in mapping:
                out.append(mapping[nxt])
                i += 2
                continue
            if nxt == "u":
                out.append(chr(int(lit[i + 2 : i + 6], 16)))
                i += 6
                continue
        out.append(ch)
        i += 1
    return "".join(out)


def func_re_with_structs(struct_names: list[str]) -> re.Pattern:
    """Function regex that also accepts struct return types.

    `HexTile hexTile(vec2 uv)` is a function like any other, but its return
    type is declared in the library rather than built into GLSL.
    """
    if not struct_names:
        return FUNC_RE
    extra = "|".join(re.escape(n) for n in sorted(struct_names, key=len, reverse=True))
    return re.compile(
        rf"^\s*({GLSL_TYPES}|{extra})\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*\{{", re.M
    )


def signatures(chunk: str, func_re: re.Pattern | None = None) -> list[tuple[str, str, str]]:
    found = []
    for m in (func_re or FUNC_RE).finditer(chunk):
        ret, name, params = m.group(1), m.group(2), m.group(3)
        if name in RESERVED or ":" in params:  # `x: Float` is leaked Kotlin
            continue
        found.append((ret, name, " ".join(params.split())))
    return found


STRUCT_RE = re.compile(r"^\s*struct\s+(\w+)\s*\{", re.M)


def collect(src: str) -> tuple[list[str], list[str], list[str]]:
    """Return (#define lines, struct chunks, function chunks) in source order.

    Struct declarations carry no function, but filters that use them (the
    glass-tile family reads `HexTile`) will not compile without them.
    """
    texts = [decode(m.group(1)) for m in STR_LIT_RE.finditer(src)]

    defines: list[str] = []
    structs: list[str] = []
    seen: set[str] = set()
    seen_structs: set[str] = set()

    # First pass: #defines and struct declarations.  Struct names are needed
    # before functions can be recognised, because several library functions
    # return a struct (`HexTile hexTile(vec2 uv)`).
    for text in texts:
        for d in DEFINE_RE.findall(text):
            d = d.strip()
            if d not in defines:
                defines.append(d)
        names = STRUCT_RE.findall(text)
        if names and not FUNC_RE.search(text):
            key = text.strip()
            if all(n not in seen_structs for n in names) and key not in seen:
                seen.add(key)
                seen_structs.update(names)
                structs.append(key)

    func_re = func_re_with_structs(sorted(seen_structs))

    chunks: list[str] = []
    for text in texts:
        if not func_re.search(text):
            continue
        key = text.strip()
        if key in seen:
            continue
        seen.add(key)
        chunks.append(key)
    return defines, structs, chunks


def make_ctx():
    os.environ.pop("DISPLAY", None)
    os.environ.pop("WAYLAND_DISPLAY", None)
    import moderngl

    return moderngl.create_context(standalone=True, require=330, backend="egl")


def compiles(ctx, preamble: str, protos: list[str], body: str) -> tuple[bool, str]:
    frag = "\n".join(
        [
            "#version 330 core",
            "precision highp float;",
            "in vec2 v_uv;",
            "out vec4 fragColor;",
            preamble,
            *protos,
            body,
            "void main(){ fragColor = vec4(0.0); }",
        ]
    )
    try:
        ctx.program(vertex_shader=VERT, fragment_shader=frag)
        return True, ""
    except Exception as exc:  # moderngl raises a generic Error on link/compile
        return False, str(exc)


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "work/decompiled")
    src = (root / "sources/b5/AbstractC0919h.java").read_text()
    defines, structs, chunks = collect(src)
    # Structs must precede the prototypes that mention them.
    preamble = "\n".join(defines + [""] + structs)
    struct_names = [n for s_ in structs for n in STRUCT_RE.findall(s_)]
    func_re = func_re_with_structs(struct_names)

    ctx = make_ctx()

    # Prototypes for every candidate, so cross-references resolve while a
    # chunk is validated on its own.
    all_protos: list[str] = []
    proto_of: dict[str, str] = {}
    for chunk in chunks:
        for ret, name, params in signatures(chunk, func_re):
            if name not in proto_of:
                proto_of[name] = f"{ret} {name}({params});"
    all_protos = [proto_of[n] for n in sorted(proto_of)]

    kept: list[str] = []
    kept_names: set[str] = set()
    dropped: list[tuple[str, str]] = []
    for chunk in chunks:
        sigs = signatures(chunk, func_re)
        names = [s[1] for s in sigs]
        if not names:
            dropped.append((chunk.splitlines()[0][:60], "no valid signature"))
            continue
        if any(n in kept_names for n in names):
            dropped.append((", ".join(names), "duplicate definition"))
            continue
        ok, err = compiles(ctx, preamble, all_protos, chunk)
        if not ok:
            first = next(
                (l.strip() for l in err.splitlines() if "error" in l.lower()), "?"
            )
            dropped.append((", ".join(names), first[:90]))
            continue
        kept.append(chunk)
        kept_names.update(names)

    final_protos = [proto_of[n] for n in sorted(kept_names)]
    parts = [
        "// gltcstdio GLSL support library.",
        "// Every function below was verified to compile against GL 3.3.",
        "// Prototypes precede bodies so intra-library call order is irrelevant.",
        "",
        preamble,
        "",
        "// ---- prototypes ----",
        *final_protos,
        "",
        "// ---- bodies ----",
        *kept,
        "",
    ]
    blob = "\n".join(parts)

    ok, err = compiles(ctx, "", [], blob.replace("#version 330 core", ""))
    if not ok:
        print("FATAL: assembled stdlib does not compile", file=sys.stderr)
        print(err[:2000], file=sys.stderr)
        raise SystemExit(1)

    out_dir = Path("gltcstdio/data/glsl")
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / "stdlib.glsl"
    out.write_text(blob)

    print(f"{len(defines)} defines, {len(structs)} structs, {len(kept)} chunks, {len(kept_names)} functions -> {out}")
    print(f"dropped {len(dropped)} chunks:")
    for name, why in dropped:
        print(f"  - {name}: {why}")


if __name__ == "__main__":
    main()
