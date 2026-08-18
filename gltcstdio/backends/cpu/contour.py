"""Luminance contour lines.

Reimplemented from the app's parameter contract (`count`, `colorStroke`,
`colorBkg`, recovered from its presets).  Luminance is quantised into `count`
bands and the boundaries between bands are stroked.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian


@cpu_filter(
    "contour",
    name="Contour",
    category="alchemy",
    fidelity="reimplemented",
    params=[
        {
            "name": "count",
            "type": "int",
            "label": "Count",
            "default": 30,
            "min": 2,
            "max": 100,
            "widget": "int_slider",
        },
        {
            "name": "smoothing",
            "type": "float",
            "label": "Smoothing",
            "default": 0.004,
            "min": 0.0,
            "max": 0.05,
            "widget": "slider",
        },
        {
            "name": "colorStroke",
            "type": "vec4",
            "label": "Stroke",
            "default": [1.0, 1.0, 1.0, 1.0],
            "widget": "color",
        },
        {
            "name": "colorBkg",
            "type": "vec4",
            "label": "Background",
            "default": [0.0, 0.0, 0.0, 1.0],
            "widget": "color",
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "transparent", "params": {"colorBkg": [0.0, 0.0, 0.0, 0.0]}},
        {"name": "fine", "params": {"count": 60}},
    ],
)
def contour(
    img: np.ndarray,
    count: int = 30,
    smoothing: float = 0.004,
    colorStroke=(1.0, 1.0, 1.0, 1.0),
    colorBkg=(0.0, 0.0, 0.0, 1.0),
) -> np.ndarray:
    h, w = img.shape[:2]
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    sigma = float(smoothing) * min(h, w)
    if sigma > 0:
        g = gaussian(g[..., None], sigma)[..., 0]

    bands = np.floor(g * max(2, int(count))).astype(np.int32)
    # A contour is where the band index changes between neighbours.
    edge = np.zeros((h, w), bool)
    edge[:, :-1] |= bands[:, :-1] != bands[:, 1:]
    edge[:-1, :] |= bands[:-1, :] != bands[1:, :]

    out = np.empty((h, w, 4), np.float32)
    out[...] = np.asarray(colorBkg, np.float32) * 255.0
    out[edge] = np.asarray(colorStroke, np.float32) * 255.0
    return np.clip(out, 0, 255).astype(np.uint8)
