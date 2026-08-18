"""Text, pointers, splashes and the remaining procedural overlays.

Reimplemented from the app's parameter contracts.  Text and shapes are drawn
with Pillow so the package needs no font machinery of its own.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian


def _pil(img: np.ndarray):
    from PIL import Image

    return Image.fromarray(img)


def _font(size: int):
    from PIL import ImageFont

    for name in (
        "DejaVuSans-Bold.ttf",
        "DejaVuSans.ttf",
        "LiberationSans-Bold.ttf",
        "Arial.ttf",
    ):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


TEXT_PARAMS = [
    {
        "name": "text",
        "type": "string",
        "label": "Text",
        "default": "GLTCSTDIO",
        "widget": "text",
    },
    {
        "name": "size",
        "type": "float",
        "label": "Size",
        "default": 0.18,
        "min": 0.02,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "x",
        "type": "float",
        "label": "X",
        "default": 0.5,
        "min": 0.0,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "y",
        "type": "float",
        "label": "Y",
        "default": 0.5,
        "min": 0.0,
        "max": 1.0,
        "widget": "slider",
    },
    {
        "name": "color",
        "type": "vec4",
        "label": "Colour",
        "default": [1.0, 1.0, 1.0, 1.0],
        "widget": "color",
    },
]


def _draw_text(img, text, size, x, y, color, shadow=None):
    from PIL import ImageDraw

    h, w = img.shape[:2]
    base = _pil(img).convert("RGBA")
    layer = _pil(np.zeros_like(img)).convert("RGBA")
    d = ImageDraw.Draw(layer)
    font = _font(max(8, int(float(size) * min(h, w))))
    label = str(text) if text else " "
    box = d.textbbox((0, 0), label, font=font)
    tw, th = box[2] - box[0], box[3] - box[1]
    px = float(x) * w - tw / 2 - box[0]
    py = float(y) * h - th / 2 - box[1]

    if shadow is not None:
        off, scol = shadow
        d.text(
            (px + off, py + off),
            label,
            font=font,
            fill=tuple(int(c * 255) for c in scol),
        )
    d.text((px, py), label, font=font, fill=tuple(int(c * 255) for c in color))

    from PIL import Image

    return np.array(Image.alpha_composite(base, layer))


@cpu_filter(
    "text",
    name="Text",
    category="text",
    fidelity="reimplemented",
    params=TEXT_PARAMS,
    presets=[
        {"name": "default", "params": {}},
        {"name": "corner", "params": {"x": 0.2, "y": 0.85, "size": 0.08}},
    ],
)
def text(
    img: np.ndarray,
    text: str = "GLTCSTDIO",
    size: float = 0.18,
    x: float = 0.5,
    y: float = 0.5,
    color=(1.0, 1.0, 1.0, 1.0),
) -> np.ndarray:
    return _draw_text(img, text, size, x, y, color)


@cpu_filter(
    "shadowed-text",
    name="Shadowed Text",
    category="text",
    fidelity="reimplemented",
    params=TEXT_PARAMS
    + [
        {
            "name": "colorShadow",
            "type": "vec4",
            "label": "Shadow",
            "default": [0.0, 0.0, 0.0, 0.6],
            "widget": "color",
        },
        {
            "name": "offset",
            "type": "float",
            "label": "Offset",
            "default": 0.01,
            "min": 0.0,
            "max": 0.1,
            "widget": "slider",
        },
    ],
    presets=[{"name": "default", "params": {}}],
)
def shadowed_text(
    img: np.ndarray,
    text: str = "GLTCSTDIO",
    size: float = 0.18,
    x: float = 0.5,
    y: float = 0.5,
    color=(1.0, 1.0, 1.0, 1.0),
    colorShadow=(0.0, 0.0, 0.0, 0.6),
    offset: float = 0.01,
) -> np.ndarray:
    off = float(offset) * min(img.shape[:2])
    return _draw_text(img, text, size, x, y, color, shadow=(off, colorShadow))


@cpu_filter(
    "pointer",
    name="Pointer",
    category="shape",
    fidelity="reimplemented",
    params=[
        {"name": "x", "type": "float", "label": "X", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "y", "type": "float", "label": "Y", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "angle", "type": "float", "label": "Angle", "default": 0.0, "min": -3.14159, "max": 3.14159, "widget": "slider"},
        {"name": "size", "type": "float", "label": "Size", "default": 0.2, "min": 0.02, "max": 1.0, "widget": "slider"},
        {
            "name": "color",
            "type": "vec4",
            "label": "Colour",
            "default": [1.0, 0.2, 0.2, 1.0],
            "widget": "color",
        },
    ],
    presets=[{"name": "default", "params": {}}],
)
def pointer(
    img: np.ndarray,
    x: float = 0.5,
    y: float = 0.5,
    angle: float = 0.0,
    size: float = 0.2,
    color=(1.0, 0.2, 0.2, 1.0),
) -> np.ndarray:
    """An arrow drawn over the image."""
    from PIL import Image, ImageDraw

    h, w = img.shape[:2]
    base = _pil(img).convert("RGBA")
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    L = float(size) * min(h, w)
    cx, cy = float(x) * w, float(y) * h
    ca, sa = np.cos(angle), np.sin(angle)

    def pt(u, v):
        return (cx + (u * ca - v * sa) * L, cy + (u * sa + v * ca) * L)

    shaft = [pt(-0.5, -0.08), pt(0.2, -0.08), pt(0.2, 0.08), pt(-0.5, 0.08)]
    head = [pt(0.2, -0.28), pt(0.55, 0.0), pt(0.2, 0.28)]
    fill = tuple(int(c * 255) for c in color)
    d.polygon(shaft, fill=fill)
    d.polygon(head, fill=fill)
    return np.array(Image.alpha_composite(base, layer))


@cpu_filter(
    "gyro-rings",
    name="Gyro Rings",
    category="shape",
    fidelity="reimplemented",
    params=[
        {"name": "angle", "type": "float", "label": "Angle", "default": 0.0, "min": -3.14159, "max": 3.14159, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Rings", "default": 5, "min": 1, "max": 20, "widget": "int_slider"},
        {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.02, "min": 0.002, "max": 0.1, "widget": "slider"},
        {
            "name": "color",
            "type": "vec4",
            "label": "Colour",
            "default": [1.0, 1.0, 1.0, 1.0],
            "widget": "color",
        },
    ],
    presets=[{"name": "default", "params": {}}],
)
def gyro_rings(
    img: np.ndarray,
    angle: float = 0.0,
    count: int = 5,
    thickness: float = 0.02,
    color=(1.0, 1.0, 1.0, 1.0),
) -> np.ndarray:
    """Nested rings, each tilted a little more than the last."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cx, cy = (w - 1) / 2.0, (h - 1) / 2.0
    out = img.astype(np.float32).copy()
    line = np.asarray(color, np.float32) * 255.0
    t = max(1.0, float(thickness) * min(h, w))

    for i in range(max(1, int(count))):
        a = float(angle) + i * np.pi / max(1, int(count))
        # A tilted circle projects to an ellipse.
        squash = 0.25 + 0.75 * abs(np.cos(a))
        ca, sa = np.cos(a), np.sin(a)
        u = (xx - cx) * ca + (yy - cy) * sa
        v = (-(xx - cx) * sa + (yy - cy) * ca) / max(squash, 1e-3)
        r = np.hypot(u, v)
        radius = min(h, w) * 0.45 * (1.0 - i / (max(1, int(count)) + 1))
        out[np.abs(r - radius) < t] = line
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "splash",
    name="Splash",
    category="generate",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Drops", "default": 24, "min": 1, "max": 200, "widget": "int_slider"},
        {"name": "seed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "heavy", "params": {"intensity": 1.0, "count": 90}},
    ],
)
def splash(
    img: np.ndarray, intensity: float = 0.5, count: int = 24, seed: float = 0.0
) -> np.ndarray:
    """Radial smears from scattered centres, as a thrown liquid leaves."""
    h, w = img.shape[:2]
    rng = np.random.default_rng(int(seed) & 0xFFFF)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    dx = np.zeros((h, w), np.float32)
    dy = np.zeros((h, w), np.float32)

    for _ in range(max(1, int(count))):
        sx, sy = rng.random() * w, rng.random() * h
        rad = (0.05 + rng.random() * 0.2) * min(h, w)
        ux, uy = xx - sx, yy - sy
        d = np.hypot(ux, uy) + 1e-6
        fall = np.clip(1.0 - d / rad, 0.0, 1.0) ** 2
        dx += ux / d * fall * rad * 0.5
        dy += uy / d * fall * rad * 0.5

    k = float(intensity)
    sxi = np.clip(np.round(xx + dx * k), 0, w - 1).astype(np.int32)
    syi = np.clip(np.round(yy + dy * k), 0, h - 1).astype(np.int32)
    return img[syi, sxi]


@cpu_filter(
    "streak-waves",
    name="Streak Waves",
    category="streak",
    fidelity="reimplemented",
    params=[
        {"name": "striation", "type": "float", "label": "Striation", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "length", "type": "float", "label": "Length", "default": 0.08, "min": 0.0, "max": 0.5, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Waves", "default": 6, "min": 1, "max": 40, "widget": "int_slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def streak_waves(
    img: np.ndarray, striation: float = 0.5, length: float = 0.08, count: int = 6
) -> np.ndarray:
    """Smear each row along a wave, so the streaks undulate."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    phase = yy / max(h, 1) * float(count) * 2.0 * np.pi
    amp = float(length) * w * (0.5 + 0.5 * float(striation))
    acc = np.zeros(img.shape, np.float32)
    taps = 7
    for i in range(taps):
        t = i / (taps - 1)
        off = np.sin(phase + t * np.pi) * amp * t
        sx = np.clip(np.round(xx + off), 0, w - 1).astype(np.int32)
        acc += img[yy.astype(np.int32), sx]
    return np.clip(acc / taps, 0, 255).astype(np.uint8)


@cpu_filter(
    "procedural-test-blend",
    name="Procedural Test Blend",
    category="test",
    fidelity="reimplemented",
    params=[
        {"name": "blend", "type": "float", "label": "Blend", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "scale", "type": "float", "label": "Scale", "default": 0.05, "min": 0.005, "max": 0.5, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def procedural_test_blend(
    img: np.ndarray, blend: float = 0.5, scale: float = 0.05
) -> np.ndarray:
    """A checker pattern blended over the image, as the app's test card does."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    cell = max(1, int(float(scale) * min(h, w)))
    checker = ((xx // cell + yy // cell) % 2).astype(np.float32)[..., None]
    pattern = checker * 255.0
    rgb = img[..., :3].astype(np.float32)
    out = rgb * (1.0 - float(blend)) + pattern * float(blend)
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)
