"""Recover the ray-marcher family, whose shader lives in an abstract base.

Twelve operators -- `cube`, `sphere`, `torus`, `cube-spheres`,
`infinite-cylinders` and their siblings -- are subclasses of `RayMarcher`.
None of them carries GLSL.  The base assembles the whole marcher from string
fragments and reads three things from the subclass:

  * `I(env)`   the signed distance function, e.g.
                   `float sdf(vec3 p, float roundness) { ... }`
  * a lazy field holding that function's parameters after the first, taken
    from its own text -- the bytecode literally searches for `,` and `)` and
    slices between them, giving `", float roundness"`;
  * a second lazy field holding the same names as an argument list,
    `",roundness"`, which the base splices into every `sdf(...)` call it
    generates.

So the whole family is recoverable: derive those three from the subclass's
distance function and run the base's own assembly with them bound.
"""

from __future__ import annotations

import re
from pathlib import Path

from javaexpr import split_args
from template_shader import (
    STR_LIT,
    TemplateEvaluator,
    Unevaluable,
    decode,
    statements,
    trim_indent,
)

# The base reads its per-subclass pieces through these exact expressions.
PARAM_FIELD = "(String) this.f12677m.getValue()"
PARAM_FIELD_BARE = "this.f12677m.getValue()"
# `float D = 1 / <field>`, and the field is 1.0 for every subclass.
DISTANCE_SCALE = "1 / this.f12676l"

SDF_RETURN = re.compile(r'return\s+("(?:[^"\\]|\\.)*")\s*;', re.S)
HELPER_LIST = re.compile(r"\bn\.X\((.*)\)\s*;", re.S)


def sdf_source(sub_src: str) -> str | None:
    """The distance function a subclass supplies through `I(env)`."""
    m = re.search(r"public\s+(?:final\s+)?String\s+I\s*\([^)]*\)\s*\{(.*?)\n    \}", sub_src, re.S)
    if not m:
        return None
    lit = SDF_RETURN.search(m.group(1))
    if not lit:
        return None
    text = decode(lit.group(1)[1:-1])
    return text if "sdf" in text else None


def sdf_extras(sdf: str) -> tuple[str, str]:
    """(parameter list, argument list) after the distance function's first.

    Sliced exactly as the app does: from the first comma to the closing
    parenthesis of the signature.
    """
    head = sdf.split("\n", 1)[0]
    comma, close = head.find(","), head.find(")")
    if not (0 <= comma < close):
        return "", ""
    params = head[comma:close]
    args = "".join(
        "," + part.strip().split()[-1] for part in params.split(",") if part.strip()
    )
    return params, args


LOCAL_ALIAS = re.compile(r"\b\w+\s+(\w+)\s*=\s*this\.(f\d+\w*)\s*;")


def _evaluator(base_src: str, params: str, args: str, sdf: str) -> TemplateEvaluator:
    overrides = {
        PARAM_FIELD: params,
        PARAM_FIELD_BARE: params,
        DISTANCE_SCALE: "1.0",
    }
    # A method may bind the lazy field to a local first -- `m mVar =
    # this.f12677m;` -- and read it through that.  Without following the
    # alias the normal function came out with no extra parameter while every
    # call to it passed one.
    field = PARAM_FIELD_BARE.split(".getValue")[0]
    # The field itself, for `m mVar = this.f12677m;` -- reading it is what
    # the helper method does before taking its value.
    overrides[field] = params
    for m in LOCAL_ALIAS.finditer(base_src):
        if f"this.{m.group(2)}" == field:
            overrides[f"{m.group(1)}.getValue()"] = params
            overrides[f"(String) {m.group(1)}.getValue()"] = params
    ev = TemplateEvaluator(base_src, overrides=overrides)
    # `J()` yields the argument list and `I(env)` the distance function.
    ev.methods["J"] = ([], "return " + _quote(args) + ";")
    ev.methods["I"] = (["env"], "return " + _quote(sdf) + ";")
    return ev


def _quote(text: str) -> str:
    escaped = text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
    return f'"{escaped}"'


def helpers(base_src: str, ev: TemplateEvaluator, sdf: str) -> list[str]:
    """The distance function, the normal it induces, and the static helpers.

    The helper list is not a list of literals: `rayMarch` and the others that
    call the distance function are concatenated with the same parameter list
    the main shader uses, so each entry has to be evaluated rather than read.
    """
    # The assembled block comes first: it already carries the distance
    # function alongside the normal that differentiates it, and the standalone
    # copy is only the fallback for when assembly fails.
    out: list[str] = []
    m = re.search(r"public\s+List\s+z\s*\([^)]*\)\s*\{(.*?)\n    \}", base_src, re.S)
    if not m:
        return [sdf]
    body = m.group(1)
    # Split on statements, not on the word `return`: the normal function's own
    # text contains `return normalize(...)`, and cutting there left the
    # enclosing string literal unbalanced so nothing after it evaluated.
    stmts = [st.strip() for st in statements(body) if st.strip()]
    head = ";\n".join(st for st in stmts if not st.startswith("return")) + ";"
    tail = next((st for st in stmts if st.startswith("return")), "")

    # The normal function is built into a StringBuilder before the return.
    # The render environment contributes no text, so bind it to nothing.
    sig = re.search(r"public\s+List\s+z\s*\(([^)]*)\)", base_src)
    env: dict[str, str] = {
        p.strip().split()[-1]: "" for p in (sig.group(1).split(",") if sig else []) if p.strip()
    }
    try:
        out.append(ev.run(head + "\nreturn g7;", env, 0))
    except (Unevaluable, KeyError, ValueError, IndexError):
        pass

    out.append(sdf)
    listed = HELPER_LIST.search(tail)
    if listed:
        for arg in split_args(listed.group(1)):
            try:
                out.append(ev.expr(arg.strip(), env, 0))
            except (Unevaluable, KeyError, ValueError, IndexError):
                lit = STR_LIT.fullmatch(arg.strip())
                if lit:
                    out.append(decode(lit.group(1)))
    # One entry carries both the distance function and the normal that
    # differentiates it, and the distance function also arrives on its own.
    # Defining either twice is a link error, so where entries overlap the one
    # defining the most wins -- dropping the richer entry cost the marchers
    # their `normal` and left a stray one-argument version in its place.
    entries = [(h, _defined(h)) for h in out if h and h.strip()]
    order = sorted(
        range(len(entries)),
        key=lambda i: (-len(entries[i][1]), -len(entries[i][0])),
    )
    chosen, covered = set(), set()
    for i in order:
        names = entries[i][1]
        if names and names <= covered:
            continue
        covered |= names
        chosen.add(i)
    return [entries[i][0] for i in range(len(entries)) if i in chosen]


def _defined(text: str) -> set:
    """The GLSL functions a fragment defines."""
    return set(
        re.findall(r"\b(?:void|bool|int|float|vec[234]|mat[234])\s+(\w+)\s*\([^;]*\{", text)
    )


def recover(base_src: str, sub_src: str) -> dict | None:
    """The assembled shader for one ray-marcher subclass."""
    sdf = sdf_source(sub_src)
    if sdf is None:
        return None
    params, args = sdf_extras(sdf)
    ev = _evaluator(base_src, params, args, sdf)
    try:
        main = trim_indent(ev.call("D", [""]))
    except (Unevaluable, KeyError, ValueError, IndexError, RecursionError):
        return None
    if "vec4 rayMarcher" not in main:
        return None
    return {"main": main, "helpers": helpers(base_src, ev, sdf)}


def base_for(sub_path: Path, parents: dict, by_name: dict) -> Path | None:
    """The nearest ancestor whose source assembles a ray marcher."""
    seen, parent = set(), parents.get(sub_path.stem)
    while parent and parent not in seen:
        seen.add(parent)
        path = by_name.get(parent)
        if path is not None and "vec4 rayMarcher" in path.read_text():
            return path
        parent = parents.get(parent)
    return None
