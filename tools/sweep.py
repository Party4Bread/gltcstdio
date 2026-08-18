"""Compile and render every filter in the bank, reporting real coverage.

Writes work/sweep.json with a per-filter verdict so build_bank.py can mark
what actually works instead of shipping optimistic metadata.
"""

from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

import numpy as np

from gltcstdio.backends.gl import Renderer, ShaderError
from gltcstdio.params import Filter
from gltcstdio.bank import load_bank


def test_image(n: int = 64) -> np.ndarray:
    yy, xx = np.mgrid[0:n, 0:n]
    img = np.zeros((n, n, 4), np.uint8)
    img[..., 0] = (xx / n * 255).astype(np.uint8)
    img[..., 1] = (yy / n * 255).astype(np.uint8)
    img[..., 2] = (((xx // 8 + yy // 8) % 2) * 200 + 55).astype(np.uint8)
    img[..., 3] = 255
    return img


def main() -> None:
    bank = load_bank()

    # A CPU reimplementation shadows any shader of the same name, so those
    # shaders were never swept and kept whatever `supported` the metadata
    # guessed -- 19 of them say they compile and do not.  Put the extracted
    # entry back for the sweep so the verdict is about the shader itself.
    # Keyed on the CPU registry, not on which backend currently wins: once a
    # shader is preferred it stops looking shadowed, and deriving the verdict
    # from that would lose the flag on the next rebuild.
    from gltcstdio.backends.cpu import REGISTRY as CPU_REGISTRY

    shadowed = {}
    raw = json.loads(Path("gltcstdio/data/bank.json").read_text())
    for fid, spec in raw.get("filters", {}).items():
        if spec.get("backend") == "gl" and fid in CPU_REGISTRY:
            shadowed[fid] = Filter.from_dict(spec)
            bank._filters[fid] = shadowed[fid]
    if shadowed:
        print(f"{len(shadowed)} shaders with a CPU reimplementation, swept too")

    r = Renderer()
    img = test_image()
    source_rgba = np.dstack([img, np.full(img.shape[:2], 255, np.uint8)]) if img.shape[2] == 3 else img

    results = {}
    counts = Counter()
    for f in bank.list(supported_only=False):
        if f.backend != "gl":
            continue  # CPU filters have no shader to compile
        entry = {"id": f.id, "category": f.category}
        if f.id in shadowed:
            entry["shadowed"] = True
        try:
            r.program(f)
        except ShaderError as exc:
            entry["status"] = "compile_error"
            entry["error"] = _first_error(str(exc))
            counts["compile_error"] += 1
            results[f.id] = entry
            continue
        except Exception as exc:  # noqa: BLE001
            entry["status"] = "compile_error"
            entry["error"] = f"{type(exc).__name__}: {exc}"[:200]
            counts["compile_error"] += 1
            results[f.id] = entry
            continue

        try:
            out = r.render(f.id, img)
        except Exception as exc:  # noqa: BLE001
            entry["status"] = "render_error"
            entry["error"] = f"{type(exc).__name__}: {exc}"[:200]
            counts["render_error"] += 1
            results[f.id] = entry
            continue

        if f.id in shadowed:
            # A shadowed shader only earns the right to replace its CPU
            # reimplementation if it actually does something: two of the six
            # that compile hand the image straight back.
            entry["passthrough"] = bool(np.array_equal(out, source_rgba))

        flat = out.reshape(-1, 4)
        uniq = len(np.unique(flat, axis=0))
        entry["unique_colors"] = uniq
        entry["mean"] = [round(float(x), 1) for x in flat.mean(0)]
        entry["alpha_mean"] = round(float(flat[:, 3].mean()), 1)
        if uniq <= 1:
            # A single flat colour usually means the filter needs an input or
            # a transform this run did not supply; still worth shipping, but
            # not worth claiming as verified.
            entry["status"] = "flat"
            counts["flat"] += 1
        else:
            entry["status"] = "ok"
            counts["ok"] += 1
        results[f.id] = entry

    Path("work/sweep.json").write_text(json.dumps(results, indent=1))

    total = len(results)
    print(f"swept {total} filters")
    for k in ("ok", "flat", "compile_error", "render_error"):
        print(f"  {k:14s} {counts[k]:4d}  ({counts[k] / total * 100:.1f}%)")

    # The number that matters: of the filters the bank claims are supported,
    # how many actually compile and render?
    claimed = [f.id for f in bank.list(supported_only=True) if f.backend == "gl"]
    good = [i for i in claimed if results[i]["status"] in ("ok", "flat")]
    broken = [i for i in claimed if results[i]["status"] not in ("ok", "flat")]
    print(
        f"\nof {len(claimed)} filters marked supported: "
        f"{len(good)} render ({len(good) / max(len(claimed), 1) * 100:.1f}%), "
        f"{len(broken)} still fail"
    )
    if broken:
        print("  still failing:", ", ".join(sorted(broken)[:25]))

    errs = Counter(
        e["error"][:70] for e in results.values() if e["status"].endswith("error")
    )
    if errs:
        print("\ntop failure modes:")
        for msg, n in errs.most_common(12):
            print(f"  {n:3d}x {msg}")


def _first_error(text: str) -> str:
    for line in text.splitlines():
        if "error" in line.lower():
            return line.strip()[:200]
    return text[:200]


if __name__ == "__main__":
    sys.exit(main())
