"""Breaks and displacement filters.

Reimplemented from the parameter contracts the app's presets reveal
(`distortion`, `dampening`, `perturbation`, `variability`, `randomSeed`).
Each of these warps the image along a family of curves -- concentric circles,
concentric squares, stripes, spirals -- by displacing every pixel along the
local normal of that family, with the displacement modulated per band.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter

COMMON_PARAMS = [
    {
        "name": "distortion",
        "type": "float",
        "label": "Distortion",
        "default": 0.15,
        "min": 0.0,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "dampening",
        "type": "float",
        "label": "Dampening",
        "default": 0.5,
        "min": 0.0,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "perturbation",
        "type": "float",
        "label": "Perturbation",
        "default": 0.2,
        "min": 0.0,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "variability",
        "type": "float",
        "label": "Variability",
        "default": 0.5,
        "min": 0.0,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "count",
        "type": "int",
        "label": "Count",
        "default": 12,
        "min": 2,
        "max": 80,
        "widget": "int_slider",
    },
    {
        "name": "randomSeed",
        "type": "float",
        "label": "Seed",
        "default": 0.0,
        "min": 0.0,
        "max": 100.0,
        "widget": "slider",
    },
]


def _sample(img: np.ndarray, x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Nearest-neighbour lookup, clamped at the edges."""
    h, w = img.shape[:2]
    xi = np.clip(np.round(x).astype(np.int32), 0, w - 1)
    yi = np.clip(np.round(y).astype(np.int32), 0, h - 1)
    return img[yi, xi]


def _band_offsets(count: int, variability: float, seed: float) -> np.ndarray:
    rng = np.random.default_rng(int(seed) & 0xFFFF)
    return (rng.random(max(1, count) + 2) - 0.5) * 2.0 * float(variability)


def _warp(
    img: np.ndarray,
    band: np.ndarray,
    dir_x: np.ndarray,
    dir_y: np.ndarray,
    distortion: float,
    dampening: float,
    perturbation: float,
    variability: float,
    count: int,
    seed: float,
) -> np.ndarray:
    """Displace each pixel along (dir_x, dir_y) by a per-band amount.

    `band` is a continuous coordinate across the curve family; its integer part
    picks the band and the fractional part fades the displacement out towards
    the band edges, which is what keeps the pieces looking broken rather than
    smeared.
    """
    h, w = img.shape[:2]
    scale = min(h, w)

    idx = np.floor(band).astype(np.int32)
    frac = band - idx
    offsets = _band_offsets(count, variability, seed)
    per_band = offsets[np.clip(idx, 0, len(offsets) - 1)]

    # Dampening pulls outer bands back towards their original position.
    falloff = 1.0 - float(dampening) * np.clip(np.abs(band) / max(count, 1), 0.0, 1.0)
    # Perturbation adds a wobble within each band.
    wobble = 1.0 + float(perturbation) * np.sin(frac * np.pi * 2.0)

    amount = float(distortion) * scale * per_band * falloff * wobble

    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    return _sample(img, xx + dir_x * amount, yy + dir_y * amount)


def _polar(shape):
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cx, cy = (w - 1) / 2.0, (h - 1) / 2.0
    dx, dy = xx - cx, yy - cy
    r = np.hypot(dx, dy)
    safe = np.where(r < 1e-6, 1.0, r)
    return dx, dy, r, dx / safe, dy / safe


def _concentric_circles(img, count, **kw):
    _dx, _dy, r, nx, ny = _polar(img.shape[:2])
    scale = min(img.shape[:2]) * 0.5
    band = r / max(scale, 1.0) * max(count, 1)
    return _warp(img, band, nx, ny, count=count, **kw)


def _concentric_squares(img, count, **kw):
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cx, cy = (w - 1) / 2.0, (h - 1) / 2.0
    dx, dy = xx - cx, yy - cy
    # Chebyshev distance gives square rings.
    d = np.maximum(np.abs(dx), np.abs(dy))
    on_x = np.abs(dx) >= np.abs(dy)
    nx = np.where(on_x, np.sign(dx), 0.0).astype(np.float32)
    ny = np.where(on_x, 0.0, np.sign(dy)).astype(np.float32)
    band = d / max(min(h, w) * 0.5, 1.0) * max(count, 1)
    return _warp(img, band, nx, ny, count=count, **kw)


def _stripes(img, count, **kw):
    h, w = img.shape[:2]
    yy, _xx = np.mgrid[0:h, 0:w].astype(np.float32)
    band = yy / max(h, 1) * max(count, 1)
    nx = np.ones_like(yy, np.float32)
    ny = np.zeros_like(yy, np.float32)
    return _warp(img, band, nx, ny, count=count, **kw)


def _spiral(img, count, **kw):
    dx, dy, r, nx, ny = _polar(img.shape[:2])
    scale = min(img.shape[:2]) * 0.5
    angle = np.arctan2(dy, dx)
    # A spiral is a ring family whose band index also advances with angle.
    band = (r / max(scale, 1.0) + angle / (2.0 * np.pi)) * max(count, 1)
    # Displace tangentially rather than radially.
    return _warp(img, band, -ny, nx, count=count, **kw)


def _inline(img, count, **kw):
    h, w = img.shape[:2]
    _yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    band = xx / max(w, 1) * max(count, 1)
    nx = np.zeros_like(xx, np.float32)
    ny = np.ones_like(xx, np.float32)
    return _warp(img, band, nx, ny, count=count, **kw)


def _make(fid: str, name: str, fn, category: str = "breaks", presets=None):
    @cpu_filter(
        fid,
        name=name,
        category=category,
        fidelity="reimplemented",
        params=COMMON_PARAMS,
        presets=presets
        or [
            {"name": "default", "params": {}},
            {"name": "strong", "params": {"distortion": 0.4}},
            {"name": "fine", "params": {"count": 40, "distortion": 0.08}},
        ],
    )
    def run(
        img: np.ndarray,
        distortion: float = 0.15,
        dampening: float = 0.5,
        perturbation: float = 0.2,
        variability: float = 0.5,
        count: int = 12,
        randomSeed: float = 0.0,
        _fn=fn,
    ) -> np.ndarray:
        return _fn(
            img,
            count=int(count),
            distortion=distortion,
            dampening=dampening,
            perturbation=perturbation,
            variability=variability,
            seed=randomSeed,
        )

    return run


_make("concentric-circle-breaks-effect", "Concentric Circle Breaks", _concentric_circles)
_make("concentric-square-breaks-effect", "Concentric Square Breaks", _concentric_squares)
_make("stripe-breaks-effect", "Stripe Breaks", _stripes)
_make("spiral-breaks", "Spiral Breaks", _spiral)
_make("inline-breaks", "Inline Breaks", _inline)

# The displacement variants are the same warp without the per-band randomness,
# so the image slides smoothly along the curve family instead of shattering.
_make(
    "concentric-circle-displacement-gl",
    "Concentric Circle Displacement",
    _concentric_circles,
    category="distort",
    presets=[{"name": "default", "params": {"variability": 0.0, "perturbation": 0.6}}],
)
_make(
    "concentric-square-displacement-gl",
    "Concentric Square Displacement",
    _concentric_squares,
    category="distort",
    presets=[{"name": "default", "params": {"variability": 0.0, "perturbation": 0.6}}],
)
_make(
    "stripe-displacement-gl",
    "Stripe Displacement",
    _stripes,
    category="distort",
    presets=[{"name": "default", "params": {"variability": 0.0, "perturbation": 0.6}}],
)


@cpu_filter(
    "sine-spike",
    name="Sine Spike",
    category="distort",
    fidelity="reimplemented",
    params=[
        {
            "name": "power",
            "type": "float",
            "label": "Power",
            "default": 2.0,
            "min": 0.5,
            "max": 8.0,
            "widget": "slider",
        },
        {
            "name": "count",
            "type": "int",
            "label": "Count",
            "default": 8,
            "min": 1,
            "max": 40,
            "widget": "int_slider",
        },
        {
            "name": "amount",
            "type": "float",
            "label": "Amount",
            "default": 0.1,
            "min": 0.0,
            "max": 0.5,
            "widget": "slider",
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "sharp", "params": {"power": 6.0}},
    ],
)
def sine_spike(
    img: np.ndarray, power: float = 2.0, count: int = 8, amount: float = 0.1
) -> np.ndarray:
    """Displace along a sine raised to a power, which sharpens it into spikes."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    phase = xx / max(w, 1) * float(count) * 2.0 * np.pi
    s = np.sin(phase)
    spike = np.sign(s) * np.abs(s) ** float(power)
    return _sample(img, xx, yy + spike * float(amount) * h)
