"""Pixel sort.

The inner kernels were readable in the decompiled source and are reproduced
here:

  * the sort key is `r + g + b` over 0..765 (`PixelSort.w`);
  * sorting is a counting sort over 766 buckets (`PixelSort.y`), which is
    stable and therefore keeps equal-key pixels in their original order;
  * "interpolate" mode replaces a run with a linear ramp between its
    lowest-key and highest-key pixel (`PixelSort.x`).

The span-selection logic sat in a method jadx could not decompile, so runs are
cut on the intensity threshold that the app's `intensity` parameter implies.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter

MODE_SORT, MODE_INTERPOLATE = 0, 1


def _rotate_indices(shape: tuple[int, int], angle: float):
    """Row indices for scanning an image along an arbitrary angle."""
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w]
    # Project onto the scan direction; each distinct projection is one run.
    proj = xx * np.cos(angle) + yy * np.sin(angle)
    order = np.argsort(proj.ravel(), kind="stable")
    return order


def _counting_sort_runs(keys: np.ndarray, pixels: np.ndarray, mask: np.ndarray):
    """Sort each masked run of a 1-D line by key, stably."""
    out = pixels.copy()
    n = len(keys)
    start = 0
    while start < n:
        if not mask[start]:
            start += 1
            continue
        end = start
        while end < n and mask[end]:
            end += 1
        if end - start > 1:
            seg = np.argsort(keys[start:end], kind="stable")
            out[start:end] = pixels[start:end][seg]
        start = end
    return out


def _interpolate_runs(keys: np.ndarray, pixels: np.ndarray, mask: np.ndarray):
    """Replace each run with a ramp between its darkest and brightest pixel."""
    out = pixels.copy()
    n = len(keys)
    start = 0
    while start < n:
        if not mask[start]:
            start += 1
            continue
        end = start
        while end < n and mask[end]:
            end += 1
        length = end - start
        if length > 1:
            seg_keys = keys[start:end]
            lo = pixels[start:end][int(np.argmin(seg_keys))]
            hi = pixels[start:end][int(np.argmax(seg_keys))]
            t = np.linspace(0.0, 1.0, length, dtype=np.float32)[:, None]
            out[start:end] = lo[None, :] * (1.0 - t) + hi[None, :] * t
        start = end
    return out


@cpu_filter(
    "pixel-sort",
    name="Pixel Sort",
    category="alchemy",
    fidelity="recovered",
    params=[
        {
            "name": "mode",
            "type": "int",
            "label": "Mode",
            "default": 0,
            "min": 0,
            "max": 1,
            "widget": "select",
            "choices": [
                {"value": 0, "label": "Sort"},
                {"value": 1, "label": "Interpolate"},
            ],
        },
        {
            "name": "intensity",
            "type": "float",
            "label": "Intensity",
            "default": 0.25,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
        {
            "name": "angle",
            "type": "float",
            "label": "Angle",
            "default": 0.0,
            "min": -3.141592653589793,
            "max": 3.141592653589793,
            "widget": "slider",
        },
        {
            "name": "boundary",
            "type": "int",
            "label": "Boundary",
            "default": 0,
            "min": 0,
            "max": 2,
            "widget": "select",
            "choices": [
                {"value": 0, "label": "Threshold"},
                {"value": 1, "label": "Dark"},
                {"value": 2, "label": "Bright"},
            ],
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "interpolate", "params": {"mode": 1, "intensity": 0.25}},
        {"name": "diagonal", "params": {"angle": 0.7853981633974483}},
        {"name": "strong", "params": {"intensity": 0.6}},
    ],
)
def pixel_sort(
    img: np.ndarray,
    mode: int = 0,
    intensity: float = 0.25,
    angle: float = 0.0,
    boundary: int = 0,
) -> np.ndarray:
    h, w = img.shape[:2]
    rgb = img[..., :3].astype(np.int32)
    key = rgb.sum(axis=2)  # r + g + b, matching PixelSort.w

    # Runs are the stretches whose key falls inside the selected band; the
    # width of that band is what `intensity` controls.
    lo = 765.0 * (1.0 - intensity) * 0.5
    hi = 765.0 - lo
    if boundary == 1:
        mask = key >= lo
    elif boundary == 2:
        mask = key <= hi
    else:
        mask = (key >= lo) & (key <= hi)

    out = img.astype(np.float32).copy()
    fn = _interpolate_runs if mode == MODE_INTERPOLATE else _counting_sort_runs

    # Horizontal and vertical scans are exact; other angles are approximated by
    # whichever axis the angle is closer to, then run along that axis.
    a = float(angle) % np.pi
    vertical = np.pi * 0.25 <= a < np.pi * 0.75

    if vertical:
        for x in range(w):
            out[:, x] = fn(key[:, x], out[:, x], mask[:, x])
    else:
        for y in range(h):
            out[y] = fn(key[y], out[y], mask[y])

    return np.clip(out, 0, 255).astype(np.uint8)
