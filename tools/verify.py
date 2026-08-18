"""Check that every filter actually works, not merely that it returns.

Rendering without raising is a weak claim.  A filter is only working if its
output is a valid image, it changes the input, its parameters do something,
its presets differ from each other, it is deterministic, and it survives a
different image size.  Each of those is checked separately so a failure says
which property broke.
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent.parent))

from gltcstdio import apply, list_filters  # noqa: E402

# Filters that are meant to return their input untouched.
PASSTHROUGH = {"identity", "crop", "crop-old", "load-image", "image-view"}


def test_image(n: int = 128) -> np.ndarray:
    yy, xx = np.mgrid[0:n, 0:n]
    img = np.zeros((n, n, 4), np.uint8)
    img[..., 0] = (xx / n * 255).astype(np.uint8)
    img[..., 1] = (yy / n * 255).astype(np.uint8)
    img[..., 2] = (((xx // 16 + yy // 16) % 2) * 200 + 55).astype(np.uint8)
    img[..., 3] = 255
    r = np.hypot(xx - n / 2, yy - n / 2)
    img[r < n / 3] = [240, 210, 150, 255]
    img[r < n / 8] = [40, 60, 120, 255]
    return img


def arr(pil) -> np.ndarray:
    return np.array(pil.convert("RGBA"))


def sweep_value(p):
    """A parameter value clearly different from the default."""
    if p.type == "float":
        lo = p.min if p.min is not None else 0.0
        hi = p.max if p.max is not None else 1.0
        cur = float(p.default) if isinstance(p.default, (int, float)) else lo
        # Whichever end is further from where it sits now.
        return hi if abs(hi - cur) >= abs(cur - lo) else lo
    if p.type == "int":
        lo = int(p.min) if p.min is not None else 0
        hi = int(p.max) if p.max is not None else 1
        cur = int(p.default) if isinstance(p.default, (int, float)) else lo
        return hi if abs(hi - cur) >= abs(cur - lo) else lo
    if p.type == "bool":
        return not bool(p.default)
    if p.type == "vec4":
        d = p.default or [0, 0, 0, 1]
        return [1.0 - float(d[0]), 1.0 - float(d[1]), 1.0 - float(d[2]), 1.0]
    if p.type == "mat3":
        d = p.default
        s = float(d[0][0]) if isinstance(d, list) else 1.0
        s = s * 4.0 if s else 0.25
        return [[s, 0, 0], [0, s, 0], [0, 0, 1]]
    return None


def main() -> int:
    img = test_image(128)
    small = test_image(64)
    filters = list_filters()

    results: dict[str, dict] = {}
    t0 = time.time()

    for i, f in enumerate(filters):
        r: dict = {"backend": f.backend}
        try:
            out = arr(apply(f.id, img))
        except Exception as exc:  # noqa: BLE001
            r["render"] = f"{type(exc).__name__}: {exc}"
            results[f.id] = r
            continue

        # 1. a valid image of the right shape
        r["shape_ok"] = out.shape == img.shape
        r["dtype_ok"] = out.dtype == np.uint8
        r["finite"] = bool(np.isfinite(out.astype(np.float32)).all())

        # 2. does it change the image at all
        changed = float(np.abs(out.astype(int) - img.astype(int)).mean())
        r["changes_input"] = changed > 0.5 or f.id in PASSTHROUGH
        r["change"] = round(changed, 2)
        r["flat"] = len(np.unique(out.reshape(-1, 4), axis=0)) <= 1

        # 3. deterministic
        try:
            r["deterministic"] = bool(np.array_equal(out, arr(apply(f.id, img))))
        except Exception:  # noqa: BLE001
            r["deterministic"] = False

        # 4. survives another size
        try:
            o2 = arr(apply(f.id, small))
            r["size_ok"] = o2.shape == small.shape
        except Exception as exc:  # noqa: BLE001
            r["size_ok"] = False
            r["size_error"] = f"{type(exc).__name__}: {exc}"[:90]

        # 5. at least one parameter visibly does something
        responsive = None
        if f.params:
            responsive = False
            for p in f.params:
                v = sweep_value(p)
                if v is None:
                    continue
                try:
                    alt = arr(apply(f.id, img, **{p.name: v}))
                except Exception:  # noqa: BLE001
                    continue
                if np.abs(alt.astype(int) - out.astype(int)).mean() > 0.5:
                    responsive = True
                    r["responds_via"] = p.name
                    break
        r["param_responsive"] = responsive

        # 6. presets differ from one another
        if len(f.presets) > 1:
            seen = []
            for pr in f.presets[:4]:
                try:
                    seen.append(arr(apply(f.id, img, preset=pr.name)))
                except Exception:  # noqa: BLE001
                    pass
            distinct = len({a.tobytes() for a in seen})
            r["presets_distinct"] = distinct > 1 if len(seen) > 1 else None

        results[f.id] = r
        if (i + 1) % 100 == 0:
            print(f"  ... {i + 1}/{len(filters)}", flush=True)

    Path("work/verify.json").write_text(json.dumps(results, indent=1))

    # ---- report ----
    n = len(results)
    def count(pred):
        return sum(1 for r in results.values() if pred(r))

    render_fail = [k for k, r in results.items() if "render" in r]
    bad_shape = [k for k, r in results.items() if r.get("shape_ok") is False]
    bad_dtype = [k for k, r in results.items() if r.get("dtype_ok") is False]
    not_finite = [k for k, r in results.items() if r.get("finite") is False]
    no_change = [k for k, r in results.items() if r.get("changes_input") is False]
    nondet = [k for k, r in results.items() if r.get("deterministic") is False]
    size_bad = [k for k, r in results.items() if r.get("size_ok") is False]
    unresponsive = [
        k for k, r in results.items() if r.get("param_responsive") is False
    ]
    same_presets = [
        k for k, r in results.items() if r.get("presets_distinct") is False
    ]
    flat = [k for k, r in results.items() if r.get("flat")]

    print(f"\nverified {n} filters in {time.time() - t0:.0f}s\n")
    rows = [
        ("renders", n - len(render_fail), render_fail),
        ("correct shape", n - len(render_fail) - len(bad_shape), bad_shape),
        ("uint8 output", n - len(render_fail) - len(bad_dtype), bad_dtype),
        ("finite values", n - len(render_fail) - len(not_finite), not_finite),
        ("changes the image", n - len(render_fail) - len(no_change), no_change),
        ("deterministic", n - len(render_fail) - len(nondet), nondet),
        ("handles other sizes", n - len(render_fail) - len(size_bad), size_bad),
        ("a parameter responds", n - len(render_fail) - len(unresponsive), unresponsive),
        ("presets differ", n - len(render_fail) - len(same_presets), same_presets),
    ]
    for label, ok, bad in rows:
        mark = "ok " if not bad else "!! "
        print(f"  {mark}{label:24s} {ok}/{n - len(render_fail) if label != 'renders' else n}")
        if bad:
            print(f"      {len(bad)}: {', '.join(sorted(bad)[:12])}")

    print(f"\n  flat at defaults: {len(flat)} (checked separately below)")
    flat_responsive = [k for k in flat if results[k].get("param_responsive")]
    print(f"    of those, {len(flat_responsive)} respond to a parameter")
    dead = [
        k for k in flat
        if not results[k].get("param_responsive")
        and results[k].get("param_responsive") is not None
    ]
    if dead:
        print(f"    {len(dead)} flat AND unresponsive: {', '.join(sorted(dead)[:20])}")

    hard_fail = set(render_fail) | set(bad_shape) | set(bad_dtype) | set(not_finite)
    hard_fail |= set(nondet) | set(size_bad)
    print(f"\n  hard failures: {len(hard_fail)}")
    return 1 if hard_fail else 0


if __name__ == "__main__":
    sys.exit(main())
