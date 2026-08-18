"""Extract preset definitions from every effect class.

Presets appear as `new s8("display name", "(op source1 :key value ...)", ...)`.
The wrapper classes under `*/legacy/` and the `Preset*` / `*GL` classes are
pure preset carriers -- they add no new shader -- so they are harvested too and
attached to whichever filter their expression names.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from dsl import Unsupported, parse_preset  # noqa: E402

S8_RE = re.compile(r'new s8\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*"((?:[^"\\]|\\.)*)"', re.S)
# The fractals register their presets as bare name/expression pairs instead:
#   c.M(z.Q(new h("0", "(monkelbrot-orbits :transformOrbit (mat3 ...))"), ...))
# `monkelbrot-orbits` has no usable state without one -- its default orbit
# transform sends the iteration straight to infinity for every pixel, and the
# app never shows it without a preset applied.
PAIR_RE = re.compile(r'new h\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*"(\((?:[^"\\]|\\.)*)"', re.S)


def unescape(text: str) -> str:
    return (
        text.replace('\\"', '"')
        .replace("\\n", "\n")
        .replace("\\t", "\t")
        .replace("\\\\", "\\")
    )


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "work/decompiled")
    eff = next((root / "sources").glob("**/pap2/effects"))

    presets: dict[str, list[dict]] = {}
    stats = {"total": 0, "ok": 0, "unsupported": 0, "malformed": 0}
    unsupported_forms: dict[str, int] = {}
    seen: set[tuple[str, str]] = set()

    for path in sorted(eff.rglob("*.java")):
        src = path.read_text()
        for m in [*S8_RE.finditer(src), *PAIR_RE.finditer(src)]:
            name = unescape(m.group(1))
            expr = unescape(m.group(2))
            if not expr.startswith("("):
                continue
            stats["total"] += 1
            try:
                op, params, sources, positional = parse_preset(expr)
            except Unsupported as exc:
                stats["unsupported"] += 1
                unsupported_forms[str(exc)] = unsupported_forms.get(str(exc), 0) + 1
                continue
            except (ValueError, IndexError):
                stats["malformed"] += 1
                continue

            key = (op, name)
            if key in seen:
                continue
            seen.add(key)
            stats["ok"] += 1
            presets.setdefault(op, []).append(
                {
                    "name": name,
                    "params": params,
                    "sources": sources,
                    "positional": positional,
                    "expr": expr,
                    "from": path.stem,
                }
            )

    out = Path("work/presets.json")
    out.write_text(json.dumps(presets, indent=1))
    print(f"{stats['ok']} presets across {len(presets)} operators -> {out}")
    print(f"  parsed={stats['total']} unsupported={stats['unsupported']} malformed={stats['malformed']}")
    if unsupported_forms:
        top = sorted(unsupported_forms.items(), key=lambda kv: -kv[1])[:10]
        print("  unsupported forms:", top)


if __name__ == "__main__":
    main()
