"""Recover shaders straight from dex bytecode.

Some filters assemble their GLSL from pieces the decompiler cannot show:

    D() = "\\n vec4 mandelbrotOrbits(...)"      <- const-string
        + OrbitsFractal.l                        <- a String field on the base
        + "\\n vec2 uv = tf(...)"                <- const-string
        + OrbitsFractal.m                        <- another base field
        + "\\n return outCol; }"                 <- const-string

jadx renders the field reads as `this.f12329l` and never shows their values,
because they are assigned in a constructor it also failed to decompile.  The
bytecode has all of it, so this module reads the dex directly:

  * every String field assigned from a const-string in any `<init>`/`<clinit>`
    is collected into a field table;
  * for each method, the const-strings and String-field reads are concatenated
    in instruction order, which is the order the StringBuilder appends them.

That reproduces the shader exactly, with no interpretation of the surrounding
Java.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

GLSL_FUNC = re.compile(
    r"^\s*(?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234](?:x[234])?|[A-Z]\w*)"
    r"\s+([A-Za-z_]\w*)\s*\([^)]*\)\s*\{",
    re.M,
)


def _quiet() -> None:
    try:
        from loguru import logger

        logger.remove()
    except Exception:  # noqa: BLE001 - logging setup must never be fatal
        pass


def _literal(ins) -> str | None:
    """The string a const-string instruction loads.

    Taken from the dex string pool rather than the disassembly text, so the
    shader source arrives byte-exact instead of re-escaped.
    """
    get_raw = getattr(ins, "get_raw_string", None)
    if get_raw is not None:
        return get_raw()
    return None


FIELD_REF = re.compile(r"(L[\w/$]+;)->(\w+)\s+Ljava/lang/String;")


def build_field_table(dex) -> dict[tuple[str, str], str]:
    """String fields whose value is a const-string assigned in a constructor."""
    table: dict[tuple[str, str], str] = {}
    for cls in dex.get_classes():
        for method in cls.get_methods():
            if method.get_name() not in ("<init>", "<clinit>"):
                continue
            code = method.get_code()
            if code is None:
                continue
            pending: str | None = None
            for ins in code.get_bc().get_instructions():
                name = ins.get_name()
                if name.startswith("const-string"):
                    pending = _literal(ins)
                elif name.startswith(("iput-object", "sput-object")):
                    m = FIELD_REF.search(ins.get_output())
                    if m and pending is not None and is_field_fragment(pending):
                        table.setdefault((m.group(1), m.group(2)), pending)
                    pending = None
                elif name.startswith(("invoke", "new-instance")):
                    # Any call may consume the pending literal.
                    pending = pending if name.startswith("invoke-virtual") else None
    return table


def is_field_fragment(text: str) -> bool:
    """Whether a constant a class holds in a field belongs in the shader.

    A field can hold a bare argument list rather than code -- `MengerSponge`
    keeps `"mode, colorGlow, thickness, ..."` and splices it into every
    `rayMarch(origin, dir, ...)` call it generates.  Requiring code punctuation
    dropped those and left the calls ending in a comma, so the rule here is
    only that the value is not one of the bare parameter names the null-check
    idiom passes (`AbstractC1809j.f(env, "env")`).
    """
    return bool(text) and not re.fullmatch(r"\w+", text)


def is_source_fragment(text: str) -> bool:
    """Whether a literal is shader source rather than an incidental string.

    The same method also loads bare labels -- `AbstractC1809j.f(env, "env")`
    is a null-check idiom -- and concatenating those corrupts the shader.
    Source always carries punctuation or newlines; labels never do.
    """
    if not text:
        return False
    return any(ch in text for ch in ";{}()=\n")


def method_text(method, table: dict[tuple[str, str], str]) -> str:
    """Concatenate a method's literals and String-field reads, in order."""
    code = method.get_code()
    if code is None:
        return ""
    parts: list[str] = []
    for ins in code.get_bc().get_instructions():
        name = ins.get_name()
        if name.startswith("const-string"):
            lit = _literal(ins)
            if lit and is_source_fragment(lit):
                parts.append(lit)
        elif name.startswith(("iget-object", "sget-object")):
            m = FIELD_REF.search(ins.get_output())
            if m:
                value = table.get((m.group(1), m.group(2)))
                if value:
                    parts.append(value)
    return "".join(parts)


def balanced(text: str) -> bool:
    """Braces balance, ignoring the ones inside commented-out code."""
    depth = 0
    for ch in re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def shader_for(dex, class_name: str, function: str, table) -> str | None:
    """The assembled GLSL defining `function`, from any method of the class."""
    want = re.compile(rf"\b\w+\s+{re.escape(function)}\s*\(")
    best = None
    for cls in dex.get_classes():
        if cls.get_name() != class_name:
            continue
        for method in cls.get_methods():
            text = method_text(method, table)
            if not text or not want.search(text):
                continue
            if not balanced(text):
                continue
            if best is None or len(text) > len(best):
                best = text
    return best


def superclass_of(cls) -> str | None:
    getter = getattr(cls, "get_superclassname", None)
    return getter() if getter else None


def helper_chunks(dex, by_name, class_name: str, exclude: str) -> list[str]:
    """Whole GLSL functions the class and its bases carry as literals.

    The entry point calls into these; they live either in the class's own
    helper-list method or in the base class's constructor, so walk the chain.
    """
    out: list[str] = []
    seen: set[str] = set()
    current = class_name
    for _ in range(6):
        cls = by_name.get(current)
        if cls is None:
            break
        for method in cls.get_methods():
            code = method.get_code()
            if code is None:
                continue
            for ins in code.get_bc().get_instructions():
                if not ins.get_name().startswith("const-string"):
                    continue
                lit = _literal(ins)
                if not lit or not GLSL_FUNC.search(lit) or not balanced(lit):
                    continue
                key = lit.strip()
                if key in seen or key in exclude:
                    continue
                seen.add(key)
                out.append(key)
        nxt = superclass_of(cls)
        if not nxt or nxt == current or "/pap2/" not in nxt:
            break
        current = nxt
    return out


def to_dex_name(java_path: str) -> str:
    """Convert a decompiled Java source path to its dex class descriptor."""
    p = Path(java_path)
    parts = list(p.parts)
    if "sources" in parts:
        parts = parts[parts.index("sources") + 1 :]
    parts[-1] = parts[-1].removesuffix(".java")
    return "L" + "/".join(parts) + ";"


def build_function_index(dex) -> dict[str, str]:
    """Every complete GLSL function the dex holds, keyed by function name.

    Helpers are not always reachable from the filter's own class or its
    bases -- several ray marchers keep theirs in a shared class -- so the
    index spans the whole dex and lets a missing name be resolved wherever it
    was defined.
    """
    index: dict[str, str] = {}
    for cls in dex.get_classes():
        for method in cls.get_methods():
            code = method.get_code()
            if code is None:
                continue
            for ins in code.get_bc().get_instructions():
                if not ins.get_name().startswith("const-string"):
                    continue
                lit = _literal(ins)
                if not lit or not balanced(lit):
                    continue
                for m in GLSL_FUNC.finditer(lit):
                    name = m.group(1)
                    if name in ("if", "for", "while", "switch", "else", "return"):
                        continue
                    # Prefer the shortest definition: the tightest chunk that
                    # defines the name, rather than a whole shader containing it.
                    prev = index.get(name)
                    if prev is None or len(lit) < len(prev):
                        index[name] = lit.strip()
    return index


STRUCT_DEF = re.compile(r"struct\s+(\w+)\s*\{[^}]*\}\s*;", re.S)
DEFINE_LINE = re.compile(r"^[ \t]*#define[ \t]+(\w+)[ \t]+[^\n]+$", re.M)


def build_preamble(dex) -> tuple[dict[str, str], dict[str, str]]:
    """Struct declarations and #defines the shaders rely on.

    A filter that uses `Ray` or `MAX_POLY_SIDES` will not compile without
    them, and they live in whichever class happened to declare them.
    """
    structs: dict[str, str] = {}
    defines: dict[str, str] = {}
    for cls in dex.get_classes():
        for method in cls.get_methods():
            code = method.get_code()
            if code is None:
                continue
            for ins in code.get_bc().get_instructions():
                if not ins.get_name().startswith("const-string"):
                    continue
                lit = _literal(ins)
                if not lit:
                    continue
                for m in STRUCT_DEF.finditer(lit):
                    structs.setdefault(m.group(1), m.group(0).strip())
                for m in DEFINE_LINE.finditer(lit):
                    defines.setdefault(m.group(1), m.group(0).strip())
    return structs, defines


def main() -> None:
    _quiet()
    from androguard.core.dex import DEX

    dex_path = sys.argv[1] if len(sys.argv) > 1 else "work/apk/classes.dex"
    shaders = json.loads(Path("work/shaders.json").read_text())
    out = Path("work/dex_shaders.json")
    # Filters already recovered no longer look truncated, so re-target them
    # too; otherwise a second run would drop what the first one found.
    previous = json.loads(out.read_text()) if out.exists() else {}
    targets = {
        fid: rec
        for fid, rec in shaders.items()
        if rec.get("truncated") or fid in previous
    }
    print(f"reading {dex_path} ...", flush=True)
    dex = DEX(Path(dex_path).read_bytes())
    table = build_field_table(dex)
    print(f"  {len(table)} string fields resolved")

    by_name = {c.get_name(): c for c in dex.get_classes()}

    recovered: dict[str, dict] = {}
    for fid, rec in targets.items():
        cls = to_dex_name(rec["source_path"])
        text = shader_for(dex, cls, rec["function"], table)
        if not text:
            continue
        # The entry point calls helpers the class keeps in other methods, and
        # inherits more from its base, so collect those too.
        recovered[fid] = {
            "main": text,
            "helpers": helper_chunks(dex, by_name, cls, exclude=text),
        }

    out.write_text(json.dumps(recovered, indent=1))
    index = build_function_index(dex)
    Path("work/glsl_index.json").write_text(json.dumps(index, indent=1))
    print(f"  {len(index)} GLSL functions indexed -> work/glsl_index.json")
    structs, defines = build_preamble(dex)
    Path("work/glsl_preamble.json").write_text(
        json.dumps({"structs": structs, "defines": defines}, indent=1)
    )
    print(f"  {len(structs)} structs, {len(defines)} defines -> work/glsl_preamble.json")
    print(f"recovered {len(recovered)}/{len(targets)} shaders -> {out}")
    for fid in sorted(recovered):
        r = recovered[fid]
        print(f"   {fid:30s} {len(r['main'])} chars, {len(r['helpers'])} helpers")


if __name__ == "__main__":
    main()
