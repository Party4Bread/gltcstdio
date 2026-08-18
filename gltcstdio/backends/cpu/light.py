"""Bloom, CRT contrast, gloss and the blur test variants.

Reimplemented from the app's parameter contracts.  These are all tone
operations built on the shared separable Gaussian.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian


@cpu_filter(
    "bloom-simple",
    name="Bloom Simple",
    category="light",
    fidelity="reimplemented",
    params=[
        {
            "name": "intensity",
            "type": "float",
            "label": "Intensity",
            "default": 0.5,
            "min": 0.0,
            "max": 2.0,
            "widget": "slider",
        },
        {
            "name": "threshold",
            "type": "float",
            "label": "Threshold",
            "default": 0.6,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
        {
            "name": "radius",
            "type": "float",
            "label": "Radius",
            "default": 0.03,
            "min": 0.0,
            "max": 0.2,
            "widget": "slider",
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "glow", "params": {"intensity": 1.2, "radius": 0.08}},
    ],
)
def bloom_simple(
    img: np.ndarray,
    intensity: float = 0.5,
    threshold: float = 0.6,
    radius: float = 0.03,
) -> np.ndarray:
    """Blur what is brighter than the threshold and add it back."""
    rgb = img[..., :3].astype(np.float32)
    l = luma(rgb / 255.0)
    mask = np.clip((l - float(threshold)) / max(1e-6, 1.0 - float(threshold)), 0, 1)
    highlights = rgb * mask[..., None]
    sigma = float(radius) * min(img.shape[:2])
    glow = gaussian(highlights, sigma) if sigma > 0 else highlights
    out = rgb + glow * float(intensity)
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "crt-contrast-gl",
    name="CRT Contrast",
    category="retro",
    fidelity="reimplemented",
    params=[
        {
            "name": "intensity",
            "type": "float",
            "label": "Intensity",
            "default": 0.5,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
        {
            "name": "radius",
            "type": "float",
            "label": "Radius",
            "default": 0.02,
            "min": 0.0,
            "max": 0.2,
            "widget": "slider",
        },
        {
            "name": "scanlines",
            "type": "float",
            "label": "Scanlines",
            "default": 0.35,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
    ],
    presets=[
        {"name": "default", "params": {"intensity": 0.5, "radius": 0.02}},
        {"name": "heavy", "params": {"intensity": 1.0, "scanlines": 0.8}},
    ],
)
def crt_contrast(
    img: np.ndarray,
    intensity: float = 0.5,
    radius: float = 0.02,
    scanlines: float = 0.35,
) -> np.ndarray:
    """Local-contrast lift plus scanlines and a vignette, as a CRT shows."""
    h, w = img.shape[:2]
    rgb = img[..., :3].astype(np.float32)
    sigma = max(1e-3, float(radius) * min(h, w))
    local = gaussian(rgb, sigma)
    # Unsharp mask: push each pixel away from its neighbourhood mean.
    out = rgb + (rgb - local) * (float(intensity) * 2.0)

    yy = np.arange(h, dtype=np.float32)[:, None, None]
    out *= 1.0 - float(scanlines) * 0.5 * (1.0 + np.cos(yy * np.pi))

    yy2, xx2 = np.mgrid[0:h, 0:w].astype(np.float32)
    cx, cy = (w - 1) / 2.0, (h - 1) / 2.0
    r = np.hypot((xx2 - cx) / max(cx, 1), (yy2 - cy) / max(cy, 1))
    out *= np.clip(1.15 - 0.35 * r**2, 0.0, 1.0)[..., None]

    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "gloss-texture",
    name="Gloss Texture",
    category="texture",
    fidelity="reimplemented",
    params=[
        {
            "name": "sourceColor",
            "type": "vec4",
            "label": "Material",
            "default": [0.85, 0.85, 0.9, 1.0],
            "widget": "color",
        },
        {
            "name": "ambientColor",
            "type": "vec4",
            "label": "Ambient",
            "default": [0.15, 0.15, 0.2, 1.0],
            "widget": "color",
        },
        {
            "name": "shininess",
            "type": "float",
            "label": "Shininess",
            "default": 0.5,
            "min": 0.0,
            "max": 1.0,
            "widget": "slider",
        },
    ],
    presets=[{"name": "default", "params": {}}],
)
def gloss_texture(
    img: np.ndarray,
    sourceColor=(0.85, 0.85, 0.9, 1.0),
    ambientColor=(0.15, 0.15, 0.2, 1.0),
    shininess: float = 0.5,
) -> np.ndarray:
    """Light the image as a relief: luminance becomes height, then shade it."""
    h, w = img.shape[:2]
    height = gaussian(luma(img[..., :3].astype(np.float32) / 255.0)[..., None], 1.5)[..., 0]

    gx = np.zeros_like(height)
    gy = np.zeros_like(height)
    gx[:, 1:-1] = (height[:, 2:] - height[:, :-2]) * 0.5
    gy[1:-1, :] = (height[2:, :] - height[:-2, :]) * 0.5

    scale = min(h, w) * 0.05
    nx, ny, nz = -gx * scale, -gy * scale, np.ones_like(height)
    n = np.sqrt(nx * nx + ny * ny + nz * nz)
    nx, ny, nz = nx / n, ny / n, nz / n

    light = np.array([0.4, -0.6, 0.7], np.float32)
    light /= np.linalg.norm(light)
    diffuse = np.clip(nx * light[0] + ny * light[1] + nz * light[2], 0, 1)
    spec = diffuse ** (1.0 + float(shininess) * 60.0)

    mat = np.asarray(sourceColor, np.float32)[:3] * 255.0
    amb = np.asarray(ambientColor, np.float32)[:3] * 255.0
    out = amb + mat * diffuse[..., None] * 0.7 + 255.0 * spec[..., None] * float(shininess)
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


def _register_blur_variant(fid: str, name: str) -> None:
    @cpu_filter(
        fid,
        name=name,
        category="blur",
        fidelity="reimplemented",
        params=[
            {
                "name": "radius",
                "type": "float",
                "label": "Radius",
                "default": 0.02,
                "min": 0.0,
                "max": 0.25,
                "widget": "slider",
            }
        ],
        presets=[{"name": "default", "params": {}}],
    )
    def run(img: np.ndarray, radius: float = 0.02) -> np.ndarray:
        sigma = float(radius) * min(img.shape[:2])
        return np.clip(gaussian(img, sigma), 0, 255).astype(np.uint8)


# The app ships two development variants of its blur alongside the real one.
_register_blur_variant("gaussian-blur-test", "Gaussian Blur Test")
_register_blur_variant("gaussian-blur-test-raw", "Gaussian Blur Test Raw")
