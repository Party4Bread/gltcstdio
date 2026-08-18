"""Circle mosaic.

Reimplemented from the app's parameter contract (`minRadius`, `thickness`,
`borderColor`, recovered from its presets).  Circles are packed largest-first
where the image is flat and smallest where it has detail, then filled with the
mean colour underneath and outlined.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian


def _detail(img: np.ndarray) -> np.ndarray:
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    blurred = gaussian(g[..., None], 2.0)[..., 0]
    return np.abs(g - blurred)


@cpu_filter(
    "circle-mosaic",
    name="Circle Mosaic",
    category="mosaic",
    fidelity="reimplemented",
    params=[
        {
            "name": "minRadius",
            "type": "float",
            "label": "Min Radius",
            "default": 0.01,
            "min": 0.001,
            "max": 0.1,
            "widget": "slider",
        },
        {
            "name": "maxRadius",
            "type": "float",
            "label": "Max Radius",
            "default": 0.06,
            "min": 0.005,
            "max": 0.3,
            "widget": "slider",
        },
        {
            "name": "thickness",
            "type": "float",
            "label": "Thickness",
            "default": 0.0,
            "min": 0.0,
            "max": 0.5,
            "widget": "slider",
        },
        {
            "name": "borderColor",
            "type": "vec4",
            "label": "Border",
            "default": [0.0, 0.0, 0.0, 1.0],
            "widget": "color",
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "fine", "params": {"minRadius": 0.005}},
        {"name": "very fine", "params": {"minRadius": 0.0025}},
        {"name": "bubbly", "params": {"thickness": 0.05}},
    ],
)
def circle_mosaic(
    img: np.ndarray,
    minRadius: float = 0.01,
    maxRadius: float = 0.06,
    thickness: float = 0.0,
    borderColor=(0.0, 0.0, 0.0, 1.0),
) -> np.ndarray:
    h, w = img.shape[:2]
    scale = min(h, w)
    r_min = max(1.0, minRadius * scale)
    r_max = max(r_min + 1.0, maxRadius * scale)

    detail = _detail(img)
    out = np.zeros((h, w, 4), np.float32)
    occupied = np.zeros((h, w), bool)

    rows = np.arange(h, dtype=np.float32)[:, None]
    cols = np.arange(w, dtype=np.float32)[None, :]
    rng = np.random.default_rng(0)

    # Largest first, so big circles claim the flat regions and small ones fill
    # in around detail.
    radius = r_max
    while radius >= r_min:
        step = max(1, int(radius))
        for cy in range(int(radius), h, step):
            for cx in range(int(radius), w, step):
                if occupied[cy, cx]:
                    continue
                # Detail suppresses large circles.
                local = detail[
                    max(0, cy - step) : cy + step, max(0, cx - step) : cx + step
                ]
                if local.size and local.mean() > 0.04 and radius > r_min:
                    continue
                jitter = rng.uniform(-0.15, 0.15, 2) * radius
                py, px = cy + jitter[0], cx + jitter[1]
                # Only the circle's bounding box: every pixel of the disc is
                # inside it, so the result is the same as testing the whole
                # image, which is what made this the slowest filter in the
                # bank -- one full-size distance field per candidate circle.
                y0, y1 = max(0, int(py - radius)), min(h, int(py + radius) + 2)
                x0, x1 = max(0, int(px - radius)), min(w, int(px + radius) + 2)
                if y0 >= y1 or x0 >= x1:
                    continue
                box = (slice(y0, y1), slice(x0, x1))
                d2 = (rows[y0:y1] - py) ** 2 + (cols[:, x0:x1] - px) ** 2
                disc = d2 <= radius * radius
                seen = occupied[box]
                if seen[disc].any():
                    continue
                out_box = out[box]
                out_box[disc] = img[box][disc].mean(axis=0)
                if thickness > 0:
                    inner = radius * (1.0 - float(thickness))
                    out_box[disc & (d2 > inner * inner)] = (
                        np.asarray(borderColor, np.float32) * 255.0
                    )
                seen |= disc
        radius *= 0.6

    out[~occupied] = img[~occupied]
    return np.clip(out, 0, 255).astype(np.uint8)
