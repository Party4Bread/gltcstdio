"""Painterly filters: knife painting, pastel, Saint-Remy, broken glass.

Reimplemented from the parameter contracts the presets reveal (`tolerance`,
`randomSeed`, `thickness`, `brightness`).  All four flatten the image into
regions and then re-render those regions with a different mark: flat facets for
the knife, soft blobs for pastel, swirling strokes for Saint-Remy, and shard
outlines for broken glass.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian


def _quantise(img: np.ndarray, tolerance: float, seed: float) -> np.ndarray:
    """Flatten to regions by quantising colour, coarser as tolerance rises."""
    levels = max(2, int(round(2 + (1.0 - float(tolerance)) * 22)))
    rng = np.random.default_rng(int(seed) & 0xFFFF)
    jitter = (rng.random(img.shape[:2] + (1,)).astype(np.float32) - 0.5) * (
        255.0 / levels * 0.5
    )
    a = img[..., :3].astype(np.float32) + jitter
    step = 255.0 / (levels - 1)
    return np.clip(np.round(a / step) * step, 0, 255)


def _sobel(g: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    gx = np.zeros_like(g)
    gy = np.zeros_like(g)
    gx[:, 1:-1] = g[:, 2:] - g[:, :-2]
    gy[1:-1, :] = g[2:, :] - g[:-2, :]
    return gx, gy


@cpu_filter(
    "knife-painting",
    name="Knife Painting",
    category="art",
    fidelity="reimplemented",
    params=[
        {
            "name": "tolerance",
            "type": "float",
            "label": "Tolerance",
            "default": 0.55,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
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
    ],
    presets=[
        {"name": "default", "params": {"tolerance": 0.55}},
        {"name": "broad", "params": {"tolerance": 0.85}},
    ],
)
def knife_painting(
    img: np.ndarray, tolerance: float = 0.55, randomSeed: float = 0.0
) -> np.ndarray:
    """Flat facets with a hard edge, as a palette knife leaves."""
    flat = _quantise(img, tolerance, randomSeed)
    # A light blur then re-quantise merges specks into broad strokes.
    flat = _quantise(
        np.dstack([gaussian(flat, 1.5), img[..., 3:4].astype(np.float32)]),
        tolerance,
        randomSeed,
    )
    out = np.dstack([flat, img[..., 3:4].astype(np.float32)])
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "pastel",
    name="Pastel",
    category="art",
    fidelity="reimplemented",
    params=[
        {
            "name": "tolerance",
            "type": "float",
            "label": "Tolerance",
            "default": 0.55,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
        {
            "name": "randomSeed",
            "type": "float",
            "label": "Seed",
            "default": 6.0,
            "min": 0.0,
            "max": 100.0,
            "widget": "slider",
        },
        {
            "name": "grain",
            "type": "float",
            "label": "Grain",
            "default": 0.25,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
    ],
    presets=[
        {"name": "default", "params": {"tolerance": 0.55, "randomSeed": 6.0}},
        {"name": "soft", "params": {"tolerance": 0.8, "grain": 0.1}},
    ],
)
def pastel(
    img: np.ndarray,
    tolerance: float = 0.55,
    randomSeed: float = 6.0,
    grain: float = 0.25,
) -> np.ndarray:
    """Soft chalky blocks: quantised colour, lifted towards white, grained."""
    flat = _quantise(img, tolerance, randomSeed)
    flat = gaussian(flat, 1.2)
    # Chalk sits lighter and less saturated than the source.
    mean = flat.mean(axis=2, keepdims=True)
    flat = flat * 0.72 + mean * 0.10 + 255.0 * 0.18

    rng = np.random.default_rng((int(randomSeed) & 0xFFFF) + 1)
    noise = (rng.random(img.shape[:2] + (1,)).astype(np.float32) - 0.5) * (
        60.0 * float(grain)
    )
    out = np.dstack([flat + noise, img[..., 3:4].astype(np.float32)])
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "saint-remy",
    name="Saint Remy",
    category="art",
    fidelity="reimplemented",
    params=[
        {
            "name": "intensity",
            "type": "float",
            "label": "Intensity",
            "default": 0.6,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
        {
            "name": "thickness",
            "type": "float",
            "label": "Thickness",
            "default": 0.25,
            "min": 0.02,
            "max": 1.0,
            "widget": "slider",
        },
        {
            "name": "brightness",
            "type": "float",
            "label": "Brightness",
            "default": 0.0,
            "min": -1.0,
            "max": 1.0,
            "widget": "slider",
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "swirly", "params": {"intensity": 1.0, "thickness": 0.5}},
    ],
)
def saint_remy(
    img: np.ndarray,
    intensity: float = 0.6,
    thickness: float = 0.25,
    brightness: float = 0.0,
) -> np.ndarray:
    """Strokes that follow the image gradient, as in the Starry Night manner."""
    h, w = img.shape[:2]
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    g = gaussian(g[..., None], 2.0)[..., 0]
    gx, gy = _sobel(g)
    # Flow along the isophotes -- perpendicular to the gradient.
    mag = np.hypot(gx, gy) + 1e-6
    fx, fy = -gy / mag, gx / mag

    step = max(1.0, float(thickness) * min(h, w) * 0.03)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    acc = np.zeros(img.shape[:2] + (3,), np.float32)
    taps = 5
    for i in range(-taps, taps + 1):
        sx = np.clip(np.round(xx + fx * i * step), 0, w - 1).astype(np.int32)
        sy = np.clip(np.round(yy + fy * i * step), 0, h - 1).astype(np.int32)
        acc += img[sy, sx, :3]
    acc /= 2 * taps + 1

    out = img[..., :3].astype(np.float32) * (1.0 - intensity) + acc * intensity
    out = out * (1.0 + float(brightness))
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "broken-glass",
    name="Broken Glass",
    category="breaks",
    fidelity="reimplemented",
    params=[
        {
            "name": "count",
            "type": "int",
            "label": "Shards",
            "default": 24,
            "min": 3,
            "max": 200,
            "widget": "int_slider",
        },
        {
            "name": "displacement",
            "type": "float",
            "label": "Displacement",
            "default": 0.02,
            "min": 0.0,
            "max": 0.2,
            "widget": "slider",
        },
        {
            "name": "colorLines",
            "type": "vec4",
            "label": "Cracks",
            "default": [1.0, 1.0, 1.0, 1.0],
            "widget": "color",
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
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "shattered", "params": {"count": 80, "displacement": 0.05}},
    ],
)
def broken_glass(
    img: np.ndarray,
    count: int = 24,
    displacement: float = 0.02,
    colorLines=(1.0, 1.0, 1.0, 1.0),
    randomSeed: float = 0.0,
) -> np.ndarray:
    """Voronoi shards, each nudged off its seat, with lit cracks between."""
    h, w = img.shape[:2]
    rng = np.random.default_rng(int(randomSeed) & 0xFFFF)
    n = max(3, int(count))
    sites = np.stack(
        [rng.random(n) * w, rng.random(n) * h], axis=1
    ).astype(np.float32)

    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    # Nearest and second-nearest site: the gap between them marks the crack.
    d = np.stack(
        [np.hypot(xx - sx, yy - sy) for sx, sy in sites], axis=0
    )
    order = np.argsort(d, axis=0)
    nearest = order[0]
    d0 = np.take_along_axis(d, order[:1], axis=0)[0]
    d1 = np.take_along_axis(d, order[1:2], axis=0)[0]

    shift = (rng.random((n, 2)).astype(np.float32) - 0.5) * 2.0
    shift *= float(displacement) * min(h, w)
    sx = np.clip(np.round(xx + shift[nearest, 0]), 0, w - 1).astype(np.int32)
    sy = np.clip(np.round(yy + shift[nearest, 1]), 0, h - 1).astype(np.int32)
    out = img[sy, sx].astype(np.float32)

    crack = (d1 - d0) < max(1.0, min(h, w) * 0.004)
    out[crack] = np.asarray(colorLines, np.float32) * 255.0
    return np.clip(out, 0, 255).astype(np.uint8)
