"""Recover per-filter parameter overrides from each effect class.

A filter's own constructor restates its parameters, frequently narrowing the
range or changing the default relative to the shared registry:

    private Halftone() {
        super(source.N(),
              n.e(0.02, modelTransform),                 // default 0.02
              n.d(-3.0, 3.0, intensity).p(1.0),          // range and default
              smoothen, color1, color2,
              HalftoneKt.sampling, HalftoneKt.style);    // filter-local params
    }

The companion `<Name>Kt` class holds parameters that exist only for this
filter, including their labelled enum choices.  Neither source is visible to
the shared registry, so defaults extracted without them are frequently wrong
(a `saturation` of 0.0 collapses `duotone` to black, for instance).

Arguments are matched to shader parameters by name, not position: the
constructor order and the GLSL signature order differ.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from extract_params import Registry, load_colors  # noqa: E402
from javaexpr import match_paren, split_args  # noqa: E402
from smali_ctor import register_statements, super_args_from_registers  # noqa: E402

CTOR_RE = re.compile(r"\n    (?:private|public|protected)\s+(\w+)\s*\(\s*\)\s*\{(.*?)\n    \}", re.S)
SUPER_RE = re.compile(r"\bsuper\s*\(", re.S)


def resolve_scope(path: Path, colors, scopes) -> dict[str, dict]:
    """Resolve the static fields of a companion `*Kt` class."""
    reg = Registry(path.read_text(), colors, scopes)
    try:
        return reg.run(required=False)
    except Exception:  # noqa: BLE001 - a companion we cannot read is not fatal
        return {}


def super_args(src: str) -> list[str] | None:
    m = CTOR_RE.search(src)
    if not m:
        return None
    body = m.group(2)
    s = SUPER_RE.search(body)
    if not s:
        return None
    open_idx = s.end() - 1
    close = match_paren(body, open_idx)
    if close == -1:
        return None
    return split_args(body[open_idx + 1 : close])


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "work/decompiled")
    eff = next((root / "sources").glob("**/pap2/effects"))
    colors = load_colors(root)

    # Shared registry first; filter-local scopes resolve against it.
    global_reg = Registry((root / "sources/V4/AbstractC0565h2.java").read_text(), colors)
    global_env = global_reg.run()
    scopes: dict[str, dict] = {"AbstractC0565h2": global_env}

    # Companion classes holding filter-local parameters.
    for path in sorted(eff.rglob("*Kt.java")):
        scopes[path.stem] = resolve_scope(path, colors, scopes)

    shaders = json.loads(Path("work/shaders.json").read_text())
    by_class = {rec["class"]: fid for fid, rec in shaders.items()}
    # A filter's GLSL is often held by the companion `FooKt` while the
    # constructor that states its parameters is on `Foo`.  Without the alias
    # the constructor is never read: `charts` kept a `precizion` of 1 against
    # the app's 3, and rendered a single black cell.
    for fid, rec in shaders.items():
        name = rec["class"]
        if name.endswith("Kt"):
            by_class.setdefault(name.removesuffix("Kt"), fid)

    out: dict[str, dict] = {}
    stats = {"classes": 0, "with_ctor": 0, "params": 0, "from_registers": 0}
    for path in sorted(eff.rglob("*.java")):
        fid = by_class.get(path.stem)
        if fid is None:
            continue
        stats["classes"] += 1
        src = path.read_text()
        args = super_args(src)
        seed: list[str] = []
        if not args:
            # jadx could not decompile this constructor; read the register
            # dump it emitted instead.
            args = super_args_from_registers(src)
            if args:
                seed = register_statements(src)
                stats["from_registers"] += 1
        if not args:
            continue
        stats["with_ctor"] += 1

        reg = Registry(src, colors, scopes)
        reg.run(required=False)  # seed any locals this class defines
        reg.env.update(scopes.get(path.stem + "Kt", {}))
        for stmt in seed:
            target, _, expr = stmt.partition(" = ")
            target = target.strip()
            try:
                before = reg.env.get(target)
                reg.exec_stmt(stmt)
                if reg.env.get(target) is not before:
                    continue
                # Not a descriptor assignment, so the register now holds a
                # plain value -- a colour, a number, a transform -- which a
                # later builder call passes back by register (`.p(r4)`).
                # Registers are reused, so any descriptor previously held
                # there has to go with it, or the stale one wins.
                value = reg.resolve_value(expr)
                if value is not None:
                    reg.consts[target] = value
                    reg.env.pop(target, None)
            except Exception:  # noqa: BLE001 - a bad line must not stop the rest
                pass

        overrides: dict[str, dict] = {}
        for arg in args:
            try:
                spec = reg.eval_expr(arg)
            except Exception:  # noqa: BLE001
                spec = None
            if not spec or not spec.get("name"):
                # The argument may be a whole list of descriptors rather than
                # one: the orbit fractals concatenate a shared group onto
                # their own parameters and pass the result as a single list.
                try:
                    group = reg.eval_list(arg)
                except Exception:  # noqa: BLE001
                    group = None
                for member in group or []:
                    overrides[member["name"]] = member
                    stats["params"] += 1
                continue
            overrides[spec["name"]] = spec
            stats["params"] += 1
        if overrides:
            out[fid] = overrides

    dest = Path("work/filter_params.json")
    # Some recovered specs carry maps with mixed int/str keys, which sorting
    # cannot order; stringify keys so the artifact stays JSON-clean.
    def clean(o):
        if isinstance(o, dict):
            return {str(k): clean(v) for k, v in o.items()}
        if isinstance(o, list):
            return [clean(v) for v in o]
        return o

    dest.write_text(json.dumps(clean(out), indent=1, sort_keys=True))
    print(f"{len(out)} filters with per-filter overrides -> {dest}")
    print(f"  scanned {stats['classes']} classes, {stats['with_ctor']} had a super() call")
    print(f"  {stats['from_registers']} recovered from undecompilable constructors")
    print(f"  {stats['params']} parameter descriptors resolved")
    print(f"  {len(scopes) - 1} companion scopes")
    h = out.get("halftone", {})
    print("  halftone:", {k: v for k, v in h.items()})


if __name__ == "__main__":
    main()
