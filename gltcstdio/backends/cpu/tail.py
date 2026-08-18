"""The last operators: text styles, brushes, blur variants and generators.

These are the filters left after shader extraction and graph recovery. Some
depend on definitions the APK does not contain (`metal` chains `dehaze`, whose
class is an empty stub), some are interactive painting tools that need stroke
input the library has no way to receive, and the rest are small enough that
the app never bothered to give them a shader.

All are reimplemented from their parameter contracts; `fidelity` says so.
Pure language primitives -- `array`, `float-list`, `string-append`, `mapped`,
`load-image`, `load-video` -- are deliberately absent: they build values and
read files rather than transform an image, so they are not filters.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian
from .shapes import _font, _pil

# --------------------------------------------------------------- text styles

TEXT_BASE = [
    {"name": "text", "type": "string", "label": "Text", "default": "GLTCSTDIO", "widget": "text"},
    {"name": "size", "type": "float", "label": "Size", "default": 0.14, "min": 0.02, "max": 1.0, "widget": "slider"},
    {"name": "x", "type": "float", "label": "X", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "y", "type": "float", "label": "Y", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "color", "type": "vec4", "label": "Colour", "default": [1.0, 1.0, 1.0, 1.0], "widget": "color"},
]


def _text_layer(img, text, size, x, y, color, spacing=0.0):
    """Draw text onto a transparent layer over the image."""
    from PIL import Image, ImageDraw

    h, w = img.shape[:2]
    base = _pil(img).convert("RGBA")
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    font = _font(max(8, int(float(size) * min(h, w))))
    label = str(text) if text else " "
    if spacing:
        label = (" " * int(spacing)).join(label)
    box = d.textbbox((0, 0), label, font=font)
    px = float(x) * w - (box[2] - box[0]) / 2 - box[0]
    py = float(y) * h - (box[3] - box[1]) / 2 - box[1]
    d.text((px, py), label, font=font, fill=tuple(int(c * 255) for c in color))
    return np.array(Image.alpha_composite(base, layer)), np.array(layer)


@cpu_filter(
    "numbers",
    name="Numbers",
    category="text",
    fidelity="reimplemented",
    params=[
        {"name": "mode", "type": "int", "label": "Mode", "default": 0, "min": 0, "max": 4096,
         "widget": "int_slider"},
        {"name": "color", "type": "vec4", "label": "Color", "default": [1.0, 1.0, 1.0, 1.0],
         "widget": "color"},
        {"name": "size", "type": "float", "label": "Size", "default": 0.2, "min": 0.02,
         "max": 1.0, "widget": "slider"},
        {"name": "x", "type": "float", "label": "X", "default": 0.5, "min": 0.0, "max": 1.0,
         "widget": "slider"},
        {"name": "y", "type": "float", "label": "Y", "default": 0.5, "min": 0.0, "max": 1.0,
         "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def numbers(
    img: np.ndarray,
    mode: int = 0,
    color=(1.0, 1.0, 1.0, 1.0),
    size: float = 0.2,
    x: float = 0.5,
    y: float = 0.5,
) -> np.ndarray:
    """`NumbersText`: the numeric readout, drawn over the image.

    The app takes the value from a 0..4096 parameter it calls `mode` and a
    colour, both from `NumbersText`'s own constructor; the glyphs come from
    the same text layer the rest of the family uses.
    """
    out, _ = _text_layer(img, str(int(mode)), size, x, y, color)
    return out


@cpu_filter(
    "code-text",
    name="Code Text",
    category="text",
    fidelity="reimplemented",
    params=TEXT_BASE + [
        {"name": "lines", "type": "int", "label": "Lines", "default": 14, "min": 1, "max": 60, "widget": "int_slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def code_text(
    img: np.ndarray,
    text: str = "GLTCSTDIO",
    size: float = 0.03,
    x: float = 0.5,
    y: float = 0.5,
    color=(0.4, 1.0, 0.5, 1.0),
    lines: int = 14,
) -> np.ndarray:
    """Source-code-looking text laid over the image, as a terminal dump."""
    from PIL import Image, ImageDraw

    h, w = img.shape[:2]
    base = _pil(img).convert("RGBA")
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    font = _font(max(7, int(float(size) * min(h, w))))
    rng = np.random.default_rng(0)
    words = ["if", "for", "return", "vec4", "float", "x", "y", "z", "()", "{}", "0.5", "1.0", "=="]
    step = max(8, int(h / max(1, int(lines))))
    fill = tuple(int(c * 255) for c in color)
    for i in range(int(lines)):
        n = int(rng.integers(4, 12))
        line = " ".join(str(words[int(rng.integers(0, len(words)))]) for _ in range(n))
        d.text((int(0.04 * w), i * step), line, font=font, fill=fill)
    return np.array(Image.alpha_composite(base, layer))


@cpu_filter(
    "dna-text",
    name="DNA Text",
    category="text",
    fidelity="reimplemented",
    params=TEXT_BASE,
    presets=[{"name": "default", "params": {}}],
)
def dna_text(
    img: np.ndarray,
    text: str = "ACGT",
    size: float = 0.04,
    x: float = 0.5,
    y: float = 0.5,
    color=(0.5, 0.9, 1.0, 1.0),
) -> np.ndarray:
    """Base letters running along a double helix."""
    from PIL import Image, ImageDraw

    h, w = img.shape[:2]
    base = _pil(img).convert("RGBA")
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    font = _font(max(7, int(float(size) * min(h, w))))
    letters = str(text) or "ACGT"
    fill = tuple(int(c * 255) for c in color)
    n = 60
    for i in range(n):
        t = i / n
        yy = t * h
        phase = t * np.pi * 6.0
        for sign in (1, -1):
            xx = float(x) * w + sign * np.sin(phase) * w * 0.18
            d.text((xx, yy), letters[i % len(letters)], font=font, fill=fill)
    return np.array(Image.alpha_composite(base, layer))


@cpu_filter(
    "alien-text",
    name="Alien Text",
    category="text",
    fidelity="reimplemented",
    params=TEXT_BASE,
    presets=[{"name": "default", "params": {}}],
)
def alien_text(
    img: np.ndarray,
    text: str = "GLTCSTDIO",
    size: float = 0.12,
    x: float = 0.5,
    y: float = 0.5,
    color=(0.7, 1.0, 0.4, 1.0),
) -> np.ndarray:
    """Glyph-like marks rather than letters, spaced as writing."""
    from PIL import Image, ImageDraw

    h, w = img.shape[:2]
    base = _pil(img).convert("RGBA")
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    rng = np.random.default_rng(abs(hash(str(text))) % (2**32))
    fill = tuple(int(c * 255) for c in color)
    s = float(size) * min(h, w)
    n = max(1, len(str(text)))
    for i in range(n):
        cx = float(x) * w + (i - n / 2) * s * 0.9
        cy = float(y) * h
        for _ in range(int(rng.integers(2, 5))):
            a = rng.random(4)
            d.line(
                [
                    (cx + (a[0] - 0.5) * s, cy + (a[1] - 0.5) * s),
                    (cx + (a[2] - 0.5) * s, cy + (a[3] - 0.5) * s),
                ],
                fill=fill,
                width=max(1, int(s * 0.08)),
            )
    return np.array(Image.alpha_composite(base, layer))


@cpu_filter(
    "vhs-text",
    name="VHS Text",
    category="text",
    fidelity="reimplemented",
    params=TEXT_BASE + [
        {"name": "bleed", "type": "float", "label": "Bleed", "default": 0.35, "min": 0.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def vhs_text(
    img: np.ndarray,
    text: str = "PLAY",
    size: float = 0.12,
    x: float = 0.2,
    y: float = 0.1,
    color=(1.0, 1.0, 1.0, 1.0),
    bleed: float = 0.35,
) -> np.ndarray:
    """Tape-style caption: chroma bleed and a scanline comb."""
    out, layer = _text_layer(img, text, size, x, y, color)
    out = out.astype(np.float32)
    mask = layer[..., 3:4].astype(np.float32) / 255.0
    shift = max(1, int(float(bleed) * 8))
    glow = np.zeros_like(out[..., :3])
    glow[..., 0] = np.roll(mask[..., 0], shift, axis=1) * 255.0
    glow[..., 2] = np.roll(mask[..., 0], -shift, axis=1) * 255.0
    out[..., :3] = np.clip(out[..., :3] + glow * float(bleed), 0, 255)
    yy = np.arange(out.shape[0], dtype=np.float32)[:, None, None]
    out[..., :3] *= 0.85 + 0.15 * (np.cos(yy * np.pi) * 0.5 + 0.5)
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "photo-label",
    name="Photo Label",
    category="border",
    fidelity="reimplemented",
    params=TEXT_BASE + [
        {"name": "border", "type": "float", "label": "Border", "default": 0.06, "min": 0.0, "max": 0.3, "widget": "slider"},
        {"name": "colorBkg", "type": "vec4", "label": "Paper", "default": [1.0, 1.0, 1.0, 1.0], "widget": "color"},
        {"name": "randomSeed", "type": "float", "label": "Seed", "default": 7.0, "min": 0.0, "max": 100.0, "widget": "slider"},
        {"name": "smoothen", "type": "float", "label": "Smoothen", "default": 0.01, "min": 0.0, "max": 0.2, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {"randomSeed": 7.0, "smoothen": 0.01}}],
)
def photo_label(
    img: np.ndarray,
    text: str = "GLTCSTDIO",
    size: float = 0.07,
    x: float = 0.5,
    y: float = 0.93,
    color=(0.1, 0.1, 0.12, 1.0),
    border: float = 0.06,
    colorBkg=(1.0, 1.0, 1.0, 1.0),
    randomSeed: float = 7.0,
    smoothen: float = 0.01,
) -> np.ndarray:
    """A print border with a caption under the image."""
    from PIL import Image

    h, w = img.shape[:2]
    b = int(float(border) * min(h, w))
    bottom = int(b * 3)
    canvas = np.empty((h + b + bottom, w + 2 * b, 4), np.float32)
    canvas[...] = np.asarray(colorBkg, np.float32) * 255.0
    inner = img.astype(np.float32)
    if smoothen:
        inner = gaussian(inner, float(smoothen) * min(h, w))
    canvas[b : b + h, b : b + w] = inner
    out = np.clip(canvas, 0, 255).astype(np.uint8)
    out, _ = _text_layer(out, text, size, x, 1.0 - bottom / (2.0 * out.shape[0]), color)
    return np.array(Image.fromarray(out).resize((w, h), Image.LANCZOS))


# ------------------------------------------------------------------ brushes


BRUSH_PARAMS = [
    {"name": "count", "type": "int", "label": "Strokes", "default": 40, "min": 1, "max": 400, "widget": "int_slider"},
    {"name": "size", "type": "float", "label": "Size", "default": 0.06, "min": 0.005, "max": 0.4, "widget": "slider"},
    {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
    {"name": "color", "type": "vec4", "label": "Colour", "default": [1.0, 1.0, 1.0, 1.0], "widget": "color"},
]


def _brush(img, count, size, seed, color, style):
    """Lay down strokes the way the app's canvas tools do.

    The originals paint where the user drags; with no stroke input the marks
    are scattered over the image instead, so the look is reproduced even
    though the placement cannot be.
    """
    h, w = img.shape[:2]
    rng = np.random.default_rng(int(seed) & 0xFFFF)
    out = img.astype(np.float32).copy()
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    r = float(size) * min(h, w) * 0.5
    col = np.asarray(color, np.float32) * 255.0

    for _ in range(max(1, int(count))):
        cx, cy = rng.random() * w, rng.random() * h
        d = np.hypot(xx - cx, yy - cy)
        if style == "circle":
            out[d <= r] = col
        elif style == "smooth":
            k = np.clip(1.0 - d / max(r, 1e-6), 0, 1)[..., None] ** 2
            out = out * (1 - k) + col * k
        elif style == "spray":
            n = int(r * r * 0.5)
            ax = np.clip(cx + rng.normal(0, r * 0.5, n), 0, w - 1).astype(np.int32)
            ay = np.clip(cy + rng.normal(0, r * 0.5, n), 0, h - 1).astype(np.int32)
            out[ay, ax] = col
        elif style == "glitch":
            y0 = int(np.clip(cy - r, 0, h - 1))
            y1 = int(np.clip(cy + r, 0, h))
            shift = int(rng.integers(-int(r * 2), int(r * 2) + 1))
            out[y0:y1] = np.roll(out[y0:y1], shift, axis=1)
    return np.clip(out, 0, 255).astype(np.uint8)


def _register_brush(fid: str, name: str, style: str) -> None:
    @cpu_filter(
        fid,
        name=name,
        category="draw",
        fidelity="reimplemented",
        params=BRUSH_PARAMS,
        presets=[{"name": "default", "params": {}}],
    )
    def run(
        img: np.ndarray,
        count: int = 40,
        size: float = 0.06,
        randomSeed: float = 0.0,
        color=(1.0, 1.0, 1.0, 1.0),
    ) -> np.ndarray:
        return _brush(img, count, size, randomSeed, color, style)


_register_brush("canvas-circle-brush", "Canvas Circle Brush", "circle")
_register_brush("canvas-smooth-circle-brush", "Canvas Smooth Circle Brush", "smooth")
_register_brush("canvas-spray-brush", "Canvas Spray Brush", "spray")
_register_brush("canvas-glitch-brush", "Canvas Glitch Brush", "glitch")


# ------------------------------------------------------------ blur variants


def _directional_blur(img, radius, horizontal, hardness=0.0):
    """One-pass blur along a single axis, as the app's h/v passes do."""
    h, w = img.shape[:2]
    sigma = max(1e-3, float(radius) * min(h, w))
    n = max(1, int(sigma * 3))
    x = np.arange(-n, n + 1, dtype=np.float32)
    k = np.exp(-(x**2) / (2 * sigma * sigma))
    k /= k.sum()
    from .gaussian_blur import _convolve1d

    acc = _convolve1d(img.astype(np.float32), k, 1 if horizontal else 0)
    if hardness:
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
        r = np.hypot(xx - w / 2, yy - h / 2) / (0.5 * min(h, w))
        t = np.clip((r - float(hardness)) / max(1e-6, 1.0 - float(hardness)), 0, 1)[..., None]
        acc = img.astype(np.float32) * (1 - t) + acc * t
    return np.clip(acc, 0, 255).astype(np.uint8)


def _register_dir_blur(fid: str, name: str, horizontal: bool, lens: bool) -> None:
    params = [
        {"name": "radius", "type": "float", "label": "Radius", "default": 0.02, "min": 0.0, "max": 0.25, "widget": "slider"},
    ]
    if lens:
        params.append(
            {"name": "hardness", "type": "float", "label": "Hardness", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"}
        )

    @cpu_filter(
        fid,
        name=name,
        category="blur",
        fidelity="reimplemented",
        params=params,
        presets=[{"name": "default", "params": {}}],
    )
    def run(img: np.ndarray, radius: float = 0.02, hardness: float = 0.0) -> np.ndarray:
        return _directional_blur(img, radius, horizontal, hardness if lens else 0.0)


_register_dir_blur("gaussian-blurh-test", "Gaussian Blur H Test", True, False)
_register_dir_blur("gaussian-blurv-test", "Gaussian Blur V Test", False, False)
_register_dir_blur("lens-blurh", "Lens Blur H", True, True)
_register_dir_blur("lens-blurv", "Lens Blur V", False, True)


# -------------------------------------------------------------------- rest


@cpu_filter(
    "pixel-sort-raw",
    name="Pixel Sort Raw",
    category="alchemy",
    fidelity="recovered",
    params=[
        {"name": "mode", "type": "int", "label": "Mode", "default": 0, "min": 0, "max": 1, "widget": "select",
         "choices": [{"value": 0, "label": "Sort"}, {"value": 1, "label": "Interpolate"}]},
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.25, "min": 0.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def pixel_sort_raw(img: np.ndarray, mode: int = 0, intensity: float = 0.25) -> np.ndarray:
    """The unwrapped form of `pixel-sort`; the same recovered kernels."""
    from .pixel_sort import pixel_sort

    return pixel_sort(img, mode=mode, intensity=intensity)


@cpu_filter(
    "dehaze",
    name="Dehaze",
    category="texture",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "blurRadius", "type": "float", "label": "Blur Radius", "default": 0.1, "min": 0.0, "max": 0.4, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def dehaze(img: np.ndarray, intensity: float = 0.5, blurRadius: float = 0.1) -> np.ndarray:
    """Pull back the local haze: subtract a blurred estimate and restretch."""
    rgb = img[..., :3].astype(np.float32)
    veil = gaussian(rgb.min(axis=2, keepdims=True), float(blurRadius) * min(img.shape[:2]))
    out = (rgb - veil * float(intensity)) / max(1e-3, 1.0 - float(intensity) * 0.9)
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "saturated-square",
    name="Saturated Square",
    category="color",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.6, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "size", "type": "float", "label": "Size", "default": 0.6, "min": 0.05, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def saturated_square(img: np.ndarray, intensity: float = 0.6, size: float = 0.6) -> np.ndarray:
    """Saturation lifted inside a centred square, left alone outside."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    s = float(size) * 0.5
    inside = (np.abs(xx / w - 0.5) < s) & (np.abs(yy / h - 0.5) < s)
    rgb = img[..., :3].astype(np.float32)
    mean = rgb.mean(axis=2, keepdims=True)
    boosted = np.clip(mean + (rgb - mean) * (1.0 + float(intensity) * 2.0), 0, 255)
    out = np.where(inside[..., None], boosted, rgb)
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "flashback",
    name="Flashback",
    category="retro",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.6, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Echoes", "default": 5, "min": 1, "max": 20, "widget": "int_slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def flashback(img: np.ndarray, intensity: float = 0.6, count: int = 5) -> np.ndarray:
    """Ghosted echoes of the frame, fading and shrinking inwards."""
    from PIL import Image

    h, w = img.shape[:2]
    acc = img.astype(np.float32).copy()
    base = Image.fromarray(img)
    for i in range(1, max(1, int(count)) + 1):
        k = 1.0 - i / (int(count) + 1)
        s = 1.0 - 0.08 * i
        sw, sh = max(1, int(w * s)), max(1, int(h * s))
        small = np.array(base.resize((sw, sh), Image.LANCZOS)).astype(np.float32)
        ox, oy = (w - sw) // 2, (h - sh) // 2
        acc[oy : oy + sh, ox : ox + sw] += small * (k * float(intensity))
    return np.clip(acc / (1.0 + float(intensity) * 0.7), 0, 255).astype(np.uint8)


@cpu_filter(
    "ink-b",
    name="Ink B",
    category="art",
    fidelity="reimplemented",
    params=[
        {"name": "threshold", "type": "float", "label": "Threshold", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "smoothing", "type": "float", "label": "Smoothing", "default": 0.01, "min": 0.0, "max": 0.1, "widget": "slider"},
        {"name": "color", "type": "vec4", "label": "Ink", "default": [0.05, 0.05, 0.1, 1.0], "widget": "color"},
        {"name": "colorBkg", "type": "vec4", "label": "Paper", "default": [0.96, 0.95, 0.9, 1.0], "widget": "color"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def ink_b(
    img: np.ndarray,
    threshold: float = 0.5,
    smoothing: float = 0.01,
    color=(0.05, 0.05, 0.1, 1.0),
    colorBkg=(0.96, 0.95, 0.9, 1.0),
) -> np.ndarray:
    """Two-tone ink wash: smooth, then cut at a threshold."""
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    if smoothing:
        g = gaussian(g[..., None], float(smoothing) * min(img.shape[:2]))[..., 0]
    ink = g < float(threshold)
    out = np.empty(img.shape[:2] + (3,), np.float32)
    out[...] = np.asarray(colorBkg, np.float32)[:3] * 255.0
    out[ink] = np.asarray(color, np.float32)[:3] * 255.0
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "metal",
    name="Metal",
    category="art",
    fidelity="reimplemented",
    params=[
        {"name": "crunch", "type": "float", "label": "Crunch", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "contrast", "type": "float", "label": "Contrast", "default": 0.6, "min": 0.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def metal(img: np.ndarray, crunch: float = 0.5, contrast: float = 0.6) -> np.ndarray:
    """Brushed-metal relief: displace along the gradient, then dehaze."""
    h, w = img.shape[:2]
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    g = gaussian(g[..., None], 1.5)[..., 0]
    gx = np.zeros_like(g)
    gy = np.zeros_like(g)
    gx[:, 1:-1] = g[:, 2:] - g[:, :-2]
    gy[1:-1, :] = g[2:, :] - g[:-2, :]
    amp = float(crunch) * min(h, w) * 0.06
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    sx = np.clip(np.round(xx + gx * amp), 0, w - 1).astype(np.int32)
    sy = np.clip(np.round(yy + gy * amp), 0, h - 1).astype(np.int32)
    warped = img[sy, sx]
    return dehaze(warped, intensity=contrast, blurRadius=0.1)


@cpu_filter(
    "negative-mirror",
    name="Negative Mirror",
    category="mlpresets",
    fidelity="reimplemented",
    params=[
        {"name": "blend", "type": "float", "label": "Blend", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "axis", "type": "int", "label": "Axis", "default": 0, "min": 0, "max": 1, "widget": "select",
         "choices": [{"value": 0, "label": "Vertical"}, {"value": 1, "label": "Horizontal"}]},
    ],
    presets=[{"name": "default", "params": {}}],
)
def negative_mirror(img: np.ndarray, blend: float = 0.5, axis: int = 0) -> np.ndarray:
    """Blend the image with its inverted mirror."""
    flipped = img[:, ::-1] if int(axis) == 0 else img[::-1, :]
    inv = flipped.astype(np.float32).copy()
    inv[..., :3] = 255.0 - inv[..., :3]
    out = img.astype(np.float32) * (1.0 - float(blend)) + inv * float(blend)
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "hex-3d-tiling",
    name="Hex 3D Tiling",
    category="wonder",
    fidelity="reimplemented",
    params=[
        {"name": "count", "type": "int", "label": "Count", "default": 10, "min": 2, "max": 60, "widget": "int_slider"},
        {"name": "depth", "type": "float", "label": "Depth", "default": 0.35, "min": 0.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def hex_3d_tiling(img: np.ndarray, count: int = 10, depth: float = 0.35) -> np.ndarray:
    """Hexagons shaded as raised prisms, each filled from the image."""
    h, w = img.shape[:2]
    n = max(2, int(count))
    size = min(h, w) / n
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    # Axial hex coordinates.
    q = (xx * 2.0 / 3.0) / size
    r = (-xx / 3.0 + np.sqrt(3.0) / 3.0 * yy) / size
    qi, ri = np.round(q), np.round(r)
    fq, fr = q - qi, r - ri
    edge = np.maximum(np.abs(fq), np.abs(fr))

    cx = np.clip(((qi * 1.5) * size).astype(np.int32), 0, w - 1)
    cy = np.clip((((ri + qi * 0.5) * np.sqrt(3.0)) * size).astype(np.int32), 0, h - 1)
    out = img[cy, cx].astype(np.float32)
    # Shade by distance to the cell edge so each tile reads as a prism face.
    shade = 1.0 - float(depth) * np.clip(edge * 2.0, 0, 1)
    out[..., :3] *= shade[..., None]
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "random-tile-placer",
    name="Random Tile Placer",
    category="mosaic",
    fidelity="reimplemented",
    params=[
        {"name": "count", "type": "int", "label": "Tiles", "default": 60, "min": 1, "max": 400, "widget": "int_slider"},
        {"name": "size", "type": "float", "label": "Size", "default": 0.12, "min": 0.02, "max": 0.6, "widget": "slider"},
        {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def random_tile_placer(
    img: np.ndarray, count: int = 60, size: float = 0.12, randomSeed: float = 0.0
) -> np.ndarray:
    """Scatter copies of random crops back over the image."""
    h, w = img.shape[:2]
    rng = np.random.default_rng(int(randomSeed) & 0xFFFF)
    out = img.astype(np.float32).copy()
    s = max(2, int(float(size) * min(h, w)))
    for _ in range(max(1, int(count))):
        sy, sx = int(rng.integers(0, max(1, h - s))), int(rng.integers(0, max(1, w - s)))
        dy, dx = int(rng.integers(0, max(1, h - s))), int(rng.integers(0, max(1, w - s)))
        out[dy : dy + s, dx : dx + s] = img[sy : sy + s, sx : sx + s]
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "reflective-mesh-gl",
    name="Reflective Mesh",
    category="geometry",
    fidelity="reimplemented",
    params=[
        {"name": "rezolution", "type": "int", "label": "Resolution", "default": 20, "min": 2, "max": 100, "widget": "int_slider"},
        {"name": "reflectivity", "type": "float", "label": "Reflectivity", "default": 0.6, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.06, "min": 0.005, "max": 0.4, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def reflective_mesh(
    img: np.ndarray, rezolution: int = 20, reflectivity: float = 0.6, thickness: float = 0.06
) -> np.ndarray:
    """A faceted mesh whose cells mirror the image back at varying angles."""
    h, w = img.shape[:2]
    n = max(2, int(rezolution))
    cell = max(2, min(h, w) // n)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    fx = (xx % cell) / cell - 0.5
    fy = (yy % cell) / cell - 0.5
    # Each facet reflects a different part of the image.
    k = float(reflectivity) * cell * 4.0
    sx = np.clip(np.round(xx + fx * k), 0, w - 1).astype(np.int32)
    sy = np.clip(np.round(yy + fy * k), 0, h - 1).astype(np.int32)
    out = img[sy, sx].astype(np.float32)
    t = float(thickness) * 0.5
    edge = (np.abs(fx) > 0.5 - t) | (np.abs(fy) > 0.5 - t)
    out[edge] *= 0.55
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "preset-hacker",
    name="Hacker",
    category="presets",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.7, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "color", "type": "vec4", "label": "Phosphor", "default": [0.3, 1.0, 0.4, 1.0], "widget": "color"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def preset_hacker(
    img: np.ndarray, intensity: float = 0.7, color=(0.3, 1.0, 0.4, 1.0)
) -> np.ndarray:
    """Green phosphor terminal: monochrome, scanlined, with code overlaid."""
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    tint = np.asarray(color, np.float32)[:3] * 255.0
    out = g[..., None] * tint
    yy = np.arange(out.shape[0], dtype=np.float32)[:, None, None]
    out *= 0.75 + 0.25 * (np.cos(yy * np.pi) * 0.5 + 0.5)
    out = out * float(intensity) + img[..., :3].astype(np.float32) * (1.0 - float(intensity))
    framed = np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)
    return code_text(framed, size=0.028, color=tuple(np.asarray(color, np.float32)))


# ------------------------------------------------- generators and geometry


@cpu_filter(
    "dithering-pattern",
    name="Dithering Pattern",
    category="generate",
    fidelity="reimplemented",
    params=[
        {"name": "size", "type": "int", "label": "Matrix", "default": 4, "min": 2, "max": 8, "widget": "select",
         "choices": [{"value": 2, "label": "2x2"}, {"value": 4, "label": "4x4"}, {"value": 8, "label": "8x8"}]},
    ],
    presets=[{"name": "default", "params": {}}],
)
def dithering_pattern(img: np.ndarray, size: int = 4) -> np.ndarray:
    """The Bayer matrix the dithering filters use, as an image."""
    h, w = img.shape[:2]
    n = 2 if int(size) <= 2 else (8 if int(size) >= 8 else 4)
    m = np.array([[0, 2], [3, 1]], np.float32)
    while m.shape[0] < n:
        k = m.shape[0]
        m = np.block([[4 * m, 4 * m + 2], [4 * m + 3, 4 * m + 1]]) / 1.0
        if m.shape[0] >= n:
            break
    m = m / m.max() * 255.0
    tile = np.tile(m, (h // m.shape[0] + 1, w // m.shape[1] + 1))[:h, :w]
    out = np.dstack([tile] * 3 + [np.full((h, w), 255.0, np.float32)])
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "color-list-to-palette-image",
    name="Palette Image",
    category="color",
    fidelity="reimplemented",
    params=[
        {"name": "count", "type": "int", "label": "Colours", "default": 8, "min": 2, "max": 64, "widget": "int_slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def color_list_to_palette_image(img: np.ndarray, count: int = 8) -> np.ndarray:
    """The image's dominant colours laid out as a palette strip."""
    h, w = img.shape[:2]
    n = max(2, int(count))
    flat = img[..., :3].reshape(-1, 3).astype(np.float32)
    # Even quantisation is enough to pull out the palette without clustering.
    q = np.round(flat / 255.0 * 4) * (255.0 / 4)
    keys, counts = np.unique(q.astype(np.uint8), axis=0, return_counts=True)
    order = np.argsort(-counts)[:n]
    palette = keys[order].astype(np.float32)
    while len(palette) < n:
        palette = np.vstack([palette, palette[-1:]])
    idx = np.clip((np.arange(w) / w * n).astype(np.int32), 0, n - 1)
    row = palette[idx]
    out = np.repeat(row[None, :, :], h, axis=0)
    return np.clip(
        np.dstack([out, np.full((h, w, 1), 255.0, np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "image-view",
    name="Image View",
    category="basic",
    fidelity="reimplemented",
    params=[
        {"name": "scale", "type": "float", "label": "Scale", "default": 1.0, "min": 0.05, "max": 4.0, "widget": "slider"},
        {"name": "x", "type": "float", "label": "X", "default": 0.0, "min": -1.0, "max": 1.0, "widget": "slider"},
        {"name": "y", "type": "float", "label": "Y", "default": 0.0, "min": -1.0, "max": 1.0, "widget": "slider"},
        {"name": "borderColor", "type": "vec4", "label": "Border", "default": [0.0, 0.0, 0.0, 0.0], "widget": "color"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def image_view(
    img: np.ndarray,
    scale: float = 1.0,
    x: float = 0.0,
    y: float = 0.0,
    borderColor=(0.0, 0.0, 0.0, 0.0),
) -> np.ndarray:
    """Re-sample the image through a transform; outside it, the border shows."""
    h, w = img.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    s = max(1e-3, float(scale))
    u = (xx - w / 2) / s + w / 2 - float(x) * w
    v = (yy - h / 2) / s + h / 2 - float(y) * h
    inside = (u >= 0) & (u < w) & (v >= 0) & (v < h)
    ui = np.clip(u, 0, w - 1).astype(np.int32)
    vi = np.clip(v, 0, h - 1).astype(np.int32)
    out = img[vi, ui].astype(np.float32)
    out[~inside] = np.asarray(borderColor, np.float32) * 255.0
    return np.clip(out, 0, 255).astype(np.uint8)


@cpu_filter(
    "crop-and-resize-rel",
    name="Crop And Resize",
    category="basic",
    fidelity="reimplemented",
    params=[
        {"name": "left", "type": "float", "label": "Left", "default": 0.0, "min": 0.0, "max": 0.9, "widget": "slider"},
        {"name": "top", "type": "float", "label": "Top", "default": 0.0, "min": 0.0, "max": 0.9, "widget": "slider"},
        {"name": "right", "type": "float", "label": "Right", "default": 1.0, "min": 0.1, "max": 1.0, "widget": "slider"},
        {"name": "bottom", "type": "float", "label": "Bottom", "default": 1.0, "min": 0.1, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def crop_and_resize_rel(
    img: np.ndarray,
    left: float = 0.0,
    top: float = 0.0,
    right: float = 1.0,
    bottom: float = 1.0,
) -> np.ndarray:
    """Crop by relative bounds, then resize back to the original size."""
    from PIL import Image

    h, w = img.shape[:2]
    x0 = int(np.clip(left, 0, 1) * w)
    x1 = max(x0 + 1, int(np.clip(right, 0, 1) * w))
    y0 = int(np.clip(top, 0, 1) * h)
    y1 = max(y0 + 1, int(np.clip(bottom, 0, 1) * h))
    crop = img[y0:y1, x0:x1]
    return np.array(Image.fromarray(crop).resize((w, h), Image.LANCZOS))


@cpu_filter(
    "blend",
    name="Blend",
    category="combine",
    fidelity="reimplemented",
    params=[
        {"name": "amount", "type": "float", "label": "Amount", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "mode", "type": "int", "label": "Mode", "default": 0, "min": 0, "max": 4, "widget": "select",
         "choices": [
             {"value": 0, "label": "Normal"}, {"value": 1, "label": "Multiply"},
             {"value": 2, "label": "Screen"}, {"value": 3, "label": "Overlay"},
             {"value": 4, "label": "Difference"},
         ]},
    ],
    presets=[{"name": "default", "params": {}}],
)
def blend(img: np.ndarray, amount: float = 0.5, mode: int = 0) -> np.ndarray:
    """Blend the image with a flipped copy of itself.

    The app's `blend` takes two inputs; with one image the second is its
    mirror, which keeps the operator meaningful on a single source.
    """
    a = img[..., :3].astype(np.float32) / 255.0
    b = img[:, ::-1, :3].astype(np.float32) / 255.0
    m = int(mode)
    if m == 1:
        mixed = a * b
    elif m == 2:
        mixed = 1.0 - (1.0 - a) * (1.0 - b)
    elif m == 3:
        mixed = np.where(a < 0.5, 2 * a * b, 1.0 - 2 * (1.0 - a) * (1.0 - b))
    elif m == 4:
        mixed = np.abs(a - b)
    else:
        mixed = b
    out = (a * (1.0 - float(amount)) + mixed * float(amount)) * 255.0
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)
