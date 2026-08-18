"""Run the full extraction pipeline end to end.

    uv run python tools/build_all.py [path/to/decompiled]

The bank is built twice on purpose: the first build produces something the
sweep can execute, and the second folds the sweep's verdicts back in so that
`supported` reflects what actually compiles and renders rather than what the
metadata predicts.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent
DECOMPILED = sys.argv[1] if len(sys.argv) > 1 else "work/decompiled"

STEPS = [
    ("parameter registry", ["extract_params.py", DECOMPILED]),
    ("GLSL support library", ["extract_stdlib.py", DECOMPILED]),
    ("filter shaders", ["extract_shaders.py", DECOMPILED]),
    # Shaders the decompiler could not show are read from the dex itself,
    # then the extraction is repeated so it picks them up.
    ("dex shader recovery", ["dex_shaders.py"]),
    ("filter shaders (with dex)", ["extract_shaders.py", DECOMPILED]),
    ("per-filter overrides", ["extract_filter_params.py", DECOMPILED]),
    # Constructors jadx skipped entirely are read straight from the dex.
    ("per-filter overrides (dex)", ["dex_ctor_params.py"]),
    ("presets", ["extract_presets.py", DECOMPILED]),
    ("curated looks (filter graphs)", ["extract_graphs.py", DECOMPILED]),
    ("bank (first pass)", ["build_bank.py"]),
    # Helpers, structs and defines a filter calls but does not carry are
    # looked up in the dex-wide index and appended to its GLSL.
    ("helper resolution", ["resolve_helpers.py"]),
    ("shader source selection", ["pick_shader.py"]),
    ("compile/render sweep", ["sweep.py"]),
    ("bank (with sweep verdicts)", ["build_bank.py"]),
    # build_bank rewrites the .glsl files, so the patches are re-applied.
    ("helper resolution", ["resolve_helpers.py"]),
    ("shader source selection", ["pick_shader.py"]),
    ("verification sweep", ["sweep.py"]),
]


def main() -> int:
    if not Path(DECOMPILED).exists():
        print(f"decompiled sources not found at {DECOMPILED}", file=sys.stderr)
        return 1
    for label, cmd in STEPS:
        print(f"\n=== {label} ===", flush=True)
        r = subprocess.run([sys.executable, str(ROOT / cmd[0]), *cmd[1:]])
        if r.returncode != 0:
            print(f"step failed: {label}", file=sys.stderr)
            return r.returncode
    print("\nbank built and verified.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
