"""Filters whose shader source could not be recovered intact.

For these the app builds its GLSL at render time from pieces that are not in
the APK as text -- generated functions, substituted constants such as
`MAX_POLY_SIDES`, and values interpolated between literals.  Extraction
therefore cannot reproduce them, so they are reimplemented here from the
parameter contract the app does expose (names, types, ranges and presets).

Output will not match the app pixel for pixel; `fidelity` says so.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian
from .solids import _env, _march, _normal, _rays, _shade

# ---------------------------------------------------------------- utilities


def _grid(shape):
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    return yy, xx


def _uv(shape, transform=None):
    """Centred coordinates, optionally through a mat3 model transform."""
    h, w = shape
    yy, xx = _grid((h, w))
    u = (xx / max(w - 1, 1) - 0.5) * 2.0
    v = (yy / max(h - 1, 1) - 0.5) * 2.0
    if transform is not None:
        m = np.asarray(transform, np.float32)
        s = m[0][0] if m[0][0] else 1.0
        u, v = u / s, v / s
    return u, v


def _sample(img, x, y):
    h, w = img.shape[:2]
    xi = np.clip(np.round(x).astype(np.int32), 0, w - 1)
    yi = np.clip(np.round(y).astype(np.int32), 0, h - 1)
    return img[yi, xi]


def _rgba(out, alpha_from=None):
    if out.shape[2] == 3:
        a = (
            alpha_from[..., 3:4].astype(np.float32)
            if alpha_from is not None
            else np.full(out.shape[:2] + (1,), 255.0, np.float32)
        )
        out = np.dstack([out, a])
    return np.clip(out, 0, 255).astype(np.uint8)


# ------------------------------------------------------------- dispersion


@cpu_filter(
    "random-color-dispersion",
    name="Random Color Dispersion",
    category="glitch",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
        {"name": "blockSize", "type": "float", "label": "Block", "default": 0.02, "min": 0.002, "max": 0.2, "widget": "slider"},
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "strong", "params": {"intensity": 1.0, "blockSize": 0.05}},
    ],
)
def random_color_dispersion(
    img: np.ndarray,
    intensity: float = 0.5,
    randomSeed: float = 0.0,
    blockSize: float = 0.02,
) -> np.ndarray:
    """Shift each colour channel by a per-block random offset."""
    h, w = img.shape[:2]
    cell = max(1, int(float(blockSize) * min(h, w)))
    rng = np.random.default_rng(int(randomSeed) & 0xFFFF)
    ny, nx = h // cell + 1, w // cell + 1
    yy, xx = _grid((h, w))
    bi = (yy // cell).astype(np.int32)
    bj = (xx // cell).astype(np.int32)

    out = img.astype(np.float32).copy()
    amp = float(intensity) * cell * 2.0
    for c in range(3):
        off = (rng.random((ny, nx, 2)).astype(np.float32) - 0.5) * 2.0 * amp
        dx, dy = off[bi, bj, 0], off[bi, bj, 1]
        out[..., c] = _sample(img, xx + dx, yy + dy)[..., c]
    return _rgba(out[..., :3], img)


@cpu_filter(
    "circuit",
    name="Circuit",
    category="generate",
    fidelity="reimplemented",
    params=[
        {"name": "color1", "type": "vec4", "label": "Trace", "default": [0.2, 0.9, 0.5, 1.0], "widget": "color"},
        {"name": "color2", "type": "vec4", "label": "Board", "default": [0.05, 0.1, 0.08, 1.0], "widget": "color"},
        {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
        {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.12, "min": 0.02, "max": 0.5, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Density", "default": 24, "min": 4, "max": 90, "widget": "int_slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def circuit(
    img: np.ndarray,
    color1=(0.2, 0.9, 0.5, 1.0),
    color2=(0.05, 0.1, 0.08, 1.0),
    randomSeed: float = 0.0,
    thickness: float = 0.12,
    count: int = 24,
) -> np.ndarray:
    """Axis-aligned traces on a board, routed by the image's own structure."""
    h, w = img.shape[:2]
    n = max(4, int(count))
    cell = max(2, min(h, w) // n)
    yy, xx = _grid((h, w))
    gi, gj = (yy // cell).astype(np.int32), (xx // cell).astype(np.int32)

    rng = np.random.default_rng(int(randomSeed) & 0xFFFF)
    horiz = rng.random((h // cell + 2, w // cell + 2)) < 0.5
    fy = (yy % cell) / cell - 0.5
    fx = (xx % cell) / cell - 0.5
    t = float(thickness) * 0.5
    on_h = np.abs(fy) < t
    on_v = np.abs(fx) < t
    trace = np.where(horiz[gi, gj], on_h, on_v)
    # Pads where a cell's brightness is high.
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    pads = (np.hypot(fx, fy) < t * 1.8) & (g > 0.6)

    out = np.empty((h, w, 3), np.float32)
    out[...] = np.asarray(color2, np.float32)[:3] * 255.0
    out[trace | pads] = np.asarray(color1, np.float32)[:3] * 255.0
    return _rgba(out, img)


@cpu_filter(
    "color-quantize",
    name="Color Quantize",
    category="color",
    fidelity="reimplemented",
    params=[
        {"name": "paletteStep", "type": "int", "label": "Levels", "default": 4, "min": 2, "max": 32, "widget": "int_slider"},
        {"name": "dithering", "type": "float", "label": "Dithering", "default": 0.3, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "gamma", "type": "float", "label": "Gamma", "default": 1.0, "min": 0.2, "max": 3.0, "widget": "slider"},
        {"name": "contrast", "type": "float", "label": "Contrast", "default": 0.0, "min": -1.0, "max": 1.0, "widget": "slider"},
        {"name": "saturation", "type": "float", "label": "Saturation", "default": 0.0, "min": -1.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "posterized", "params": {"paletteStep": 3, "dithering": 0.0}},
    ],
)
def color_quantize(
    img: np.ndarray,
    paletteStep: int = 4,
    dithering: float = 0.3,
    gamma: float = 1.0,
    contrast: float = 0.0,
    saturation: float = 0.0,
) -> np.ndarray:
    """Quantise to a small palette, with ordered dithering to hide banding."""
    rgb = img[..., :3].astype(np.float32) / 255.0
    rgb = np.clip(rgb, 0, 1) ** (1.0 / max(0.2, float(gamma)))
    rgb = np.clip((rgb - 0.5) * (1.0 + float(contrast)) + 0.5, 0, 1)
    mean = rgb.mean(axis=2, keepdims=True)
    rgb = np.clip(mean + (rgb - mean) * (1.0 + float(saturation)), 0, 1)

    levels = max(2, int(paletteStep))
    # 4x4 Bayer matrix.
    bayer = np.array(
        [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]], np.float32
    ) / 16.0 - 0.5
    h, w = img.shape[:2]
    tile = np.tile(bayer, (h // 4 + 1, w // 4 + 1))[:h, :w][..., None]
    rgb = rgb + tile * float(dithering) / (levels - 1)

    q = np.round(np.clip(rgb, 0, 1) * (levels - 1)) / (levels - 1)
    return _rgba(q * 255.0, img)


# ------------------------------------------------------------------ tiles


def _tile_streak(img, balance, variability, thickness, border, seed, transform):
    """Smear each tile along a random axis, outlined at the tile edge."""
    h, w = img.shape[:2]
    m = np.asarray(transform, np.float32)
    scale = m[0][0] if m[0][0] else 0.1
    cell = max(3, int(abs(scale) * min(h, w)))
    yy, xx = _grid((h, w))
    gi, gj = (yy // cell).astype(np.int32), (xx // cell).astype(np.int32)

    rng = np.random.default_rng(int(seed) & 0xFFFF)
    shape = (h // cell + 2, w // cell + 2)
    horiz = rng.random(shape) < (0.5 + (float(balance) - 0.5))
    amount = rng.random(shape).astype(np.float32) * float(variability) + (
        1.0 - float(variability)
    )

    # Streak towards the tile's leading edge.
    fy = (yy % cell).astype(np.float32)
    fx = (xx % cell).astype(np.float32)
    a = amount[gi, gj]
    sx = np.where(horiz[gi, gj], xx - fx * a, xx)
    sy = np.where(horiz[gi, gj], yy, yy - fy * a)
    out = _sample(img, sx, sy).astype(np.float32)

    t = float(thickness) * cell
    if t >= 1.0:
        edge = (fx < t) | (fy < t) | (fx > cell - t) | (fy > cell - t)
        out[edge] = np.asarray(border, np.float32) * 255.0
    return _rgba(out[..., :3], img)


TILE_PARAMS = [
    {"name": "balance", "type": "float", "label": "Balance", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "variability", "type": "float", "label": "Variability", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.0, "min": 0.0, "max": 0.4, "widget": "slider"},
    {"name": "borderColor", "type": "vec4", "label": "Border", "default": [0.0, 0.0, 0.0, 1.0], "widget": "color"},
    {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
    {"name": "modelTransform", "type": "mat3", "label": "Transform", "default": [[0.1, 0, 0], [0, 0.1, 0], [0, 0, 1]], "widget": "transform"},
]


def _register_tile(fid: str, name: str) -> None:
    @cpu_filter(
        fid,
        name=name,
        category="streak",
        fidelity="reimplemented",
        params=TILE_PARAMS,
        presets=[
            {"name": "default", "params": {}},
            {"name": "outlined", "params": {"thickness": 0.06}},
        ],
    )
    def run(
        img: np.ndarray,
        balance: float = 0.5,
        variability: float = 0.5,
        thickness: float = 0.0,
        borderColor=(0.0, 0.0, 0.0, 1.0),
        randomSeed: float = 0.0,
        modelTransform=((0.1, 0, 0), (0, 0.1, 0), (0, 0, 1)),
    ) -> np.ndarray:
        return _tile_streak(
            img, balance, variability, thickness, borderColor, randomSeed, modelTransform
        )


_register_tile("tiled-streak", "Tiled Streak")
_register_tile("streak-tiled-gl", "Streak Tiled")


@cpu_filter(
    "tiled-glitch",
    name="Tiled Glitch",
    category="glitch",
    fidelity="reimplemented",
    params=[
        {"name": "coverage", "type": "float", "label": "Coverage", "default": 0.4, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "levels", "type": "int", "label": "Levels", "default": 3, "min": 1, "max": 8, "widget": "int_slider"},
        {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
        {"name": "threshold", "type": "float", "label": "Threshold", "default": 0.5, "min": 0.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def tiled_glitch(
    img: np.ndarray,
    coverage: float = 0.4,
    levels: int = 3,
    randomSeed: float = 0.0,
    threshold: float = 0.5,
) -> np.ndarray:
    """Displace tiles at several sizes, coarsest first."""
    h, w = img.shape[:2]
    out = img.astype(np.float32).copy()
    rng = np.random.default_rng(int(randomSeed) & 0xFFFF)
    yy, xx = _grid((h, w))
    for level in range(max(1, int(levels))):
        cell = max(4, int(min(h, w) / (2 ** (level + 2))))
        shape = (h // cell + 2, w // cell + 2)
        hit = rng.random(shape) < float(coverage) / max(1, int(levels))
        shift = (rng.random(shape + (2,)).astype(np.float32) - 0.5) * 2.0 * cell
        gi, gj = (yy // cell).astype(np.int32), (xx // cell).astype(np.int32)
        mask = hit[gi, gj]
        sx = np.where(mask, xx + shift[gi, gj, 0], xx)
        sy = np.where(mask, yy + shift[gi, gj, 1], yy)
        out = _sample(out.astype(np.uint8), sx, sy).astype(np.float32)
    return _rgba(out[..., :3], img)


@cpu_filter(
    "square-mosaic",
    name="Square Mosaic",
    category="mosaic",
    fidelity="reimplemented",
    params=[
        {"name": "levels", "type": "int", "label": "Levels", "default": 4, "min": 1, "max": 8, "widget": "int_slider"},
        {"name": "threshold", "type": "float", "label": "Threshold", "default": 0.08, "min": 0.0, "max": 0.5, "widget": "slider"},
        {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.0, "min": 0.0, "max": 0.4, "widget": "slider"},
        {"name": "borderColor", "type": "vec4", "label": "Border", "default": [0.0, 0.0, 0.0, 1.0], "widget": "color"},
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "outlined", "params": {"thickness": 0.08}},
    ],
)
def square_mosaic(
    img: np.ndarray,
    levels: int = 4,
    threshold: float = 0.08,
    thickness: float = 0.0,
    borderColor=(0.0, 0.0, 0.0, 1.0),
) -> np.ndarray:
    """A quadtree: split a square only where it still holds detail."""
    h, w = img.shape[:2]
    out = img.astype(np.float32).copy()
    src = img[..., :3].astype(np.float32)
    size = max(h, w)
    border = np.asarray(borderColor, np.float32) * 255.0

    def split(y0, x0, s, depth):
        y1, x1 = min(y0 + s, h), min(x0 + s, w)
        if y0 >= h or x0 >= w:
            return
        block = src[y0:y1, x0:x1]
        if block.size == 0:
            return
        if depth < int(levels) and block.std() > float(threshold) * 255.0 and s > 2:
            half = s // 2
            for dy in (0, half):
                for dx in (0, half):
                    split(y0 + dy, x0 + dx, half, depth + 1)
            return
        out[y0:y1, x0:x1, :3] = block.reshape(-1, 3).mean(axis=0)
        t = max(0, int(float(thickness) * s))
        if t:
            out[y0 : min(y0 + t, h), x0:x1, :3] = border[:3]
            out[y0:y1, x0 : min(x0 + t, w), :3] = border[:3]

    split(0, 0, size, 0)
    return _rgba(out[..., :3], img)


@cpu_filter(
    "circle-list-painter",
    name="Circle List Painter",
    category="art",
    fidelity="reimplemented",
    params=[
        {"name": "count", "type": "int", "label": "Count", "default": 400, "min": 20, "max": 3000, "widget": "int_slider"},
        {"name": "padding", "type": "float", "label": "Padding", "default": 0.1, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.0, "min": 0.0, "max": 0.5, "widget": "slider"},
        {"name": "borderColor", "type": "vec4", "label": "Border", "default": [0.0, 0.0, 0.0, 1.0], "widget": "color"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def circle_list_painter(
    img: np.ndarray,
    count: int = 400,
    padding: float = 0.1,
    thickness: float = 0.0,
    borderColor=(0.0, 0.0, 0.0, 1.0),
) -> np.ndarray:
    """Paint the image as a list of circles, largest first."""
    h, w = img.shape[:2]
    rng = np.random.default_rng(0)
    out = img.astype(np.float32).copy()
    yy, xx = _grid((h, w))
    n = max(20, int(count))
    base = min(h, w) * 0.09
    border = np.asarray(borderColor, np.float32) * 255.0
    for i in range(n):
        r = base * (1.0 - i / n) ** 1.5 + 1.5
        cx, cy = rng.random() * w, rng.random() * h
        d2 = (xx - cx) ** 2 + (yy - cy) ** 2
        rr = r * (1.0 - float(padding) * 0.5)
        disc = d2 <= rr * rr
        if not disc.any():
            continue
        out[disc, :3] = img[disc, :3].mean(axis=0)
        if thickness > 0:
            inner = rr * (1.0 - float(thickness))
            out[disc & (d2 > inner * inner), :3] = border[:3]
    return _rgba(out[..., :3], img)


# --------------------------------------------------------------- fractals


def _orbit_fractal(img, iterate, iterations, color, offset, colorPower, scale, seed):
    """Colour each pixel by how close its orbit passes to the origin."""
    h, w = img.shape[:2]
    u, v = _uv((h, w))
    s = max(1e-6, abs(scale))
    z = np.stack([u / s, v / s], axis=-1).astype(np.float32)
    c = z.copy()
    trap = np.full((h, w), 1e9, np.float32)
    for _ in range(max(1, int(iterations))):
        z = iterate(z, c, seed)
        trap = np.minimum(trap, np.linalg.norm(z, axis=-1))
        z = np.clip(z, -1e6, 1e6)
    d = trap ** max(0.05, float(colorPower) + 0.2)
    k = np.clip(np.sin(d * 6.0 + float(offset) * 6.283) * 0.5 + 0.5, 0, 1)
    base = np.asarray(color, np.float32)[:3] * 255.0
    out = base * k[..., None] + img[..., :3].astype(np.float32) * (1.0 - k[..., None]) * 0.35
    return _rgba(out, img)


def _cmul(a, b):
    return np.stack(
        [a[..., 0] * b[..., 0] - a[..., 1] * b[..., 1],
         a[..., 0] * b[..., 1] + a[..., 1] * b[..., 0]],
        axis=-1,
    )


ORBIT_PARAMS = [
    {"name": "iterations", "type": "int", "label": "Iterations", "default": 24, "min": 1, "max": 120, "widget": "int_slider"},
    {"name": "color", "type": "vec4", "label": "Colour", "default": [0.4, 0.8, 1.0, 1.0], "widget": "color"},
    {"name": "offset", "type": "float", "label": "Offset", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "colorPower", "type": "float", "label": "Colour Power", "default": 0.5, "min": 0.0, "max": 2.0, "widget": "slider"},
    {"name": "scale", "type": "float", "label": "Scale", "default": 0.6, "min": 0.05, "max": 3.0, "widget": "slider"},
    {"name": "seed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 10.0, "widget": "slider"},
]


@cpu_filter(
    "collatz-orbits",
    name="Collatz Orbits",
    category="fractal",
    fidelity="reimplemented",
    params=ORBIT_PARAMS,
    presets=[{"name": "default", "params": {}}],
)
def collatz_orbits(
    img: np.ndarray,
    iterations: int = 24,
    color=(0.4, 0.8, 1.0, 1.0),
    offset: float = 0.0,
    colorPower: float = 0.5,
    scale: float = 0.6,
    seed: float = 0.0,
) -> np.ndarray:
    def step(z, c, s):
        # The complex Collatz map, smoothed over the reals.
        cos = np.cos(np.pi * z[..., 0])
        t = 0.25 * (2.0 + 7.0 * z - (2.0 + 5.0 * z) * cos[..., None])
        return t + c * 0.02 * float(s)

    return _orbit_fractal(img, step, iterations, color, offset, colorPower, scale, seed)


@cpu_filter(
    "evil-eye-orbits",
    name="Evil Eye Orbits",
    category="fractal",
    fidelity="reimplemented",
    params=ORBIT_PARAMS
    + [
        {"name": "julianess", "type": "float", "label": "Julianess", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"}
    ],
    presets=[{"name": "default", "params": {}}],
)
def evil_eye_orbits(
    img: np.ndarray,
    iterations: int = 24,
    color=(1.0, 0.6, 0.2, 1.0),
    offset: float = 0.0,
    colorPower: float = 0.5,
    scale: float = 0.6,
    seed: float = 0.0,
    julianess: float = 0.0,
) -> np.ndarray:
    jc = np.array([0.285 + 0.01 * float(seed), 0.01], np.float32)

    def step(z, c, s):
        zz = _cmul(z, z)
        target = c * (1.0 - float(julianess)) + jc * float(julianess)
        return zz + target

    return _orbit_fractal(img, step, iterations, color, offset, colorPower, scale, seed)


# -------------------------------------------------------------- hyperbolic


def _poincare(img, p, q, offset, thickness, vignetting):
    """Tile the Poincare disc with a {p,q} pattern, sampling the image."""
    h, w = img.shape[:2]
    u, v = _uv((h, w))
    r2 = u * u + v * v
    inside = r2 < 1.0
    # Repeated inversion in the fundamental polygon's mirrors approximates
    # the tiling without building the group explicitly.
    x, y = u.copy(), v.copy()
    ang = np.pi / max(2, int(p))
    for _ in range(max(2, int(q))):
        a = np.arctan2(y, x)
        a = np.abs(((a + ang) % (2 * ang)) - ang)
        rad = np.hypot(x, y)
        x, y = rad * np.cos(a), rad * np.sin(a)
        d2 = x * x + y * y
        far = d2 > 0.35
        inv = np.where(far, 0.35 / np.maximum(d2, 1e-6), 1.0)
        x, y = x * inv, y * inv

    sx = (x * 0.5 + 0.5 + float(offset)) * (w - 1)
    sy = (y * 0.5 + 0.5) * (h - 1)
    out = _sample(img, sx % w, sy % h).astype(np.float32)

    edge = np.abs(np.hypot(x, y) - 0.35) < float(thickness) * 0.5
    out[edge] = 255.0 - out[edge]
    out[~inside] = 0.0
    if vignetting:
        out *= np.clip(1.0 - float(vignetting) * r2, 0, 1)[..., None]
    return _rgba(out[..., :3], img)


HYPER_PARAMS = [
    {"name": "p", "type": "int", "label": "P", "default": 5, "min": 3, "max": 12, "widget": "int_slider"},
    {"name": "q", "type": "int", "label": "Q", "default": 4, "min": 3, "max": 12, "widget": "int_slider"},
    {"name": "offset", "type": "float", "label": "Offset", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.05, "min": 0.0, "max": 0.4, "widget": "slider"},
    {"name": "vignetting", "type": "float", "label": "Vignetting", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"},
]


def _register_hyper(fid: str, name: str) -> None:
    @cpu_filter(
        fid,
        name=name,
        category="mirror",
        fidelity="reimplemented",
        params=HYPER_PARAMS,
        presets=[
            {"name": "default", "params": {}},
            {"name": "dense", "params": {"p": 7, "q": 3}},
        ],
    )
    def run(
        img: np.ndarray,
        p: int = 5,
        q: int = 4,
        offset: float = 0.0,
        thickness: float = 0.05,
        vignetting: float = 0.0,
    ) -> np.ndarray:
        return _poincare(img, p, q, offset, thickness, vignetting)


_register_hyper("hyperbolic-square", "Hyperbolic Square")
_register_hyper("hyper-kaleidoscopeios", "Hyper Kaleidoscope")


@cpu_filter(
    "hyperbolic-lace",
    name="Hyperbolic Lace",
    category="fractal",
    fidelity="reimplemented",
    params=[
        {"name": "paramP", "type": "int", "label": "P", "default": 4, "min": 3, "max": 12, "widget": "int_slider"},
        {"name": "paramQ", "type": "int", "label": "Q", "default": 5, "min": 3, "max": 12, "widget": "int_slider"},
        {"name": "iterations", "type": "int", "label": "Iterations", "default": 8, "min": 1, "max": 24, "widget": "int_slider"},
        {"name": "color1", "type": "vec4", "label": "Colour 1", "default": [0.9, 0.9, 1.0, 1.0], "widget": "color"},
        {"name": "color2", "type": "vec4", "label": "Colour 2", "default": [0.1, 0.2, 0.5, 1.0], "widget": "color"},
        {"name": "glow", "type": "float", "label": "Glow", "default": 0.2, "min": 0.0, "max": 1.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def hyperbolic_lace(
    img: np.ndarray,
    paramP: int = 4,
    paramQ: int = 5,
    iterations: int = 8,
    color1=(0.9, 0.9, 1.0, 1.0),
    color2=(0.1, 0.2, 0.5, 1.0),
    glow: float = 0.2,
) -> np.ndarray:
    """Lace woven from repeated reflection inside the Poincare disc."""
    h, w = img.shape[:2]
    u, v = _uv((h, w))
    x, y = u.copy(), v.copy()
    ang = np.pi / max(3, int(paramP))
    acc = np.zeros((h, w), np.float32)
    for i in range(max(1, int(iterations))):
        a = np.abs(((np.arctan2(y, x) + ang) % (2 * ang)) - ang)
        rad = np.hypot(x, y)
        x, y = rad * np.cos(a), rad * np.sin(a)
        d2 = np.maximum(x * x + y * y, 1e-6)
        k = 0.5 / d2
        far = d2 > 0.5
        x = np.where(far, x * k, x)
        y = np.where(far, y * k, y)
        acc += np.exp(-8.0 * np.abs(np.hypot(x, y) - 0.5))
    acc /= max(1, int(iterations))
    acc = np.clip(acc * (1.0 + float(glow) * 3.0), 0, 1)
    c1 = np.asarray(color1, np.float32)[:3] * 255.0
    c2 = np.asarray(color2, np.float32)[:3] * 255.0
    out = c2 + (c1 - c2) * acc[..., None]
    out[u * u + v * v > 1.0] = 0.0
    return _rgba(out, img)


# ------------------------------------------------------------ ray marched


RM_PARAMS = [
    {"name": "iterations", "type": "int", "label": "Iterations", "default": 4, "min": 1, "max": 8, "widget": "int_slider"},
    {"name": "colorScheme", "type": "float", "label": "Colour", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "objectColor", "type": "vec4", "label": "Material", "default": [0.9, 0.9, 0.95, 1.0], "widget": "color"},
    {"name": "bkgColor", "type": "vec4", "label": "Background", "default": [0.04, 0.05, 0.07, 1.0], "widget": "color"},
    {"name": "fresnelStrength", "type": "float", "label": "Fresnel", "default": 0.6, "min": 0.0, "max": 1.0, "widget": "slider"},
]


def _render_sdf(img, sdf, material, bkg, fresnel, dist=3.4):
    h, w = img.shape[:2]
    rd = _rays(h, w)
    ro = np.zeros_like(rd)
    ro[..., 2] = -dist
    t, hit = _march(sdf, ro, rd)
    p = ro + rd * t[..., None]
    n = _normal(sdf, p)
    out = _shade(img, p, n, rd, hit, material, bkg, fresnel)
    return _rgba(out, None)


@cpu_filter(
    "menger-sponge",
    name="Menger Sponge",
    category="fractal",
    fidelity="reimplemented",
    params=RM_PARAMS,
    presets=[{"name": "default", "params": {}}],
)
def menger_sponge(
    img: np.ndarray,
    iterations: int = 4,
    colorScheme: float = 0.0,
    objectColor=(0.9, 0.9, 0.95, 1.0),
    bkgColor=(0.04, 0.05, 0.07, 1.0),
    fresnelStrength: float = 0.6,
) -> np.ndarray:
    it = max(1, int(iterations))

    def sdf(pt):
        q = np.abs(pt) - 1.0
        d = np.maximum(q[..., 0], np.maximum(q[..., 1], q[..., 2]))
        s = 1.0
        for _ in range(it):
            a = np.mod(pt * s, 2.0) - 1.0
            s *= 3.0
            r = np.abs(1.0 - 3.0 * np.abs(a))
            da = np.maximum(r[..., 0], r[..., 1])
            db = np.maximum(r[..., 1], r[..., 2])
            dc = np.maximum(r[..., 2], r[..., 0])
            c = (np.minimum(da, np.minimum(db, dc)) - 1.0) / s
            d = np.maximum(d, c)
        return d

    return _render_sdf(img, sdf, objectColor, bkgColor, fresnelStrength)


@cpu_filter(
    "fractal-solid-gl",
    name="Fractal Solid GL",
    category="fractal",
    fidelity="reimplemented",
    params=RM_PARAMS,
    presets=[{"name": "default", "params": {}}],
)
def fractal_solid_gl(
    img: np.ndarray,
    iterations: int = 4,
    colorScheme: float = 0.0,
    objectColor=(0.9, 0.9, 0.95, 1.0),
    bkgColor=(0.04, 0.05, 0.07, 1.0),
    fresnelStrength: float = 0.6,
) -> np.ndarray:
    it = max(1, int(iterations))

    def sdf(pt):
        q = pt.copy()
        scale = 1.0
        for _ in range(it):
            q = np.abs(q)
            q = q * 2.0 - 1.0
            scale *= 2.0
        return (np.linalg.norm(q, axis=-1) - 1.0) / scale

    return _render_sdf(img, sdf, objectColor, bkgColor, fresnelStrength)


@cpu_filter(
    "metaballs3d",
    name="Metaballs 3D",
    category="geometry",
    fidelity="reimplemented",
    params=[
        {"name": "count", "type": "int", "label": "Balls", "default": 6, "min": 2, "max": 20, "widget": "int_slider"},
        {"name": "radius", "type": "float", "label": "Radius", "default": 0.5, "min": 0.1, "max": 1.2, "widget": "slider"},
        {"name": "objectColor", "type": "vec4", "label": "Material", "default": [0.9, 0.95, 1.0, 1.0], "widget": "color"},
        {"name": "bkgColor", "type": "vec4", "label": "Background", "default": [0.03, 0.04, 0.06, 1.0], "widget": "color"},
        {"name": "fresnelStrength", "type": "float", "label": "Fresnel", "default": 0.7, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "randomSeed", "type": "float", "label": "Seed", "default": 0.0, "min": 0.0, "max": 100.0, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def metaballs3d(
    img: np.ndarray,
    count: int = 6,
    radius: float = 0.5,
    objectColor=(0.9, 0.95, 1.0, 1.0),
    bkgColor=(0.03, 0.04, 0.06, 1.0),
    fresnelStrength: float = 0.7,
    randomSeed: float = 0.0,
) -> np.ndarray:
    rng = np.random.default_rng(int(randomSeed) & 0xFFFF)
    centres = (rng.random((max(2, int(count)), 3)).astype(np.float32) - 0.5) * 2.2
    r = float(radius)

    def sdf(pt):
        # Smooth union of spheres, which is what makes them merge.
        d = None
        for c in centres:
            di = np.linalg.norm(pt - c, axis=-1) - r
            if d is None:
                d = di
            else:
                k = 0.45
                hh = np.clip(0.5 + 0.5 * (di - d) / k, 0.0, 1.0)
                d = di * (1 - hh) + d * hh - k * hh * (1.0 - hh)
        return d

    return _render_sdf(img, sdf, objectColor, bkgColor, fresnelStrength, dist=4.0)


@cpu_filter(
    "rayMarcher",
    name="Ray Marcher",
    category="geometry",
    fidelity="reimplemented",
    params=[
        {"name": "refractionIndex", "type": "float", "label": "Refraction", "default": 1.45, "min": 1.0, "max": 2.5, "widget": "slider"},
        {"name": "fresnelStrength", "type": "float", "label": "Fresnel", "default": 0.7, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "colorTransmission", "type": "vec4", "label": "Transmission", "default": [0.9, 0.95, 1.0, 1.0], "widget": "color"},
        {"name": "colorScheme", "type": "float", "label": "Colour", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "radius", "type": "float", "label": "Radius", "default": 0.9, "min": 0.2, "max": 1.5, "widget": "slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def ray_marcher(
    img: np.ndarray,
    refractionIndex: float = 1.45,
    fresnelStrength: float = 0.7,
    colorTransmission=(0.9, 0.95, 1.0, 1.0),
    colorScheme: float = 0.0,
    radius: float = 0.9,
) -> np.ndarray:
    """A rounded solid lit by the image, as the app's generic marcher does."""
    r = float(radius)

    def sdf(pt):
        q = np.abs(pt) - r * 0.6
        box = np.linalg.norm(np.maximum(q, 0.0), axis=-1) - r * 0.25
        sph = np.linalg.norm(pt, axis=-1) - r
        # Smooth intersection gives the rounded, jewel-like solid.
        k = 0.2
        hh = np.clip(0.5 - 0.5 * (sph - box) / k, 0.0, 1.0)
        return sph * (1 - hh) + box * hh + k * hh * (1.0 - hh)

    return _render_sdf(img, sdf, colorTransmission, (0.03, 0.04, 0.06, 1.0), fresnelStrength)


@cpu_filter(
    "wormhole",
    name="Wormhole",
    category="distort",
    fidelity="reimplemented",
    params=[
        {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.6, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Repeats", "default": 6, "min": 1, "max": 24, "widget": "int_slider"},
        {"name": "overlap", "type": "float", "label": "Overlap", "default": 0.3, "min": 0.0, "max": 1.0, "widget": "slider"},
        {"name": "color", "type": "vec4", "label": "Tint", "default": [1.0, 1.0, 1.0, 1.0], "widget": "color"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def wormhole(
    img: np.ndarray,
    intensity: float = 0.6,
    count: int = 6,
    overlap: float = 0.3,
    color=(1.0, 1.0, 1.0, 1.0),
) -> np.ndarray:
    """Tunnel coordinates: the image repeats away towards a vanishing point."""
    h, w = img.shape[:2]
    u, v = _uv((h, w))
    r = np.maximum(np.hypot(u, v), 1e-4)
    a = np.arctan2(v, u)
    # Depth grows as 1/r, which is what makes the tunnel recede.
    depth = 1.0 / r * float(intensity) + float(overlap)
    su = (a / (2 * np.pi) * float(count)) % 1.0
    sv = depth % 1.0
    out = _sample(img, su * (w - 1), sv * (h - 1)).astype(np.float32)
    shade = np.clip(r * 1.6, 0, 1)[..., None]
    out[..., :3] *= shade * np.asarray(color, np.float32)[:3]
    return _rgba(out[..., :3], img)


# ---------------------------------------------------------- elevation maps


ELEV_PARAMS = [
    {"name": "rezolution", "type": "int", "label": "Resolution", "default": 48, "min": 4, "max": 200, "widget": "int_slider"},
    {"name": "intensity", "type": "float", "label": "Intensity", "default": 0.4, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "specular", "type": "float", "label": "Specular", "default": 0.3, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "sourceColor", "type": "vec4", "label": "Material", "default": [1.0, 1.0, 1.0, 1.0], "widget": "color"},
    {"name": "ambientColor", "type": "vec4", "label": "Ambient", "default": [0.12, 0.14, 0.2, 1.0], "widget": "color"},
    {"name": "colorFog", "type": "vec4", "label": "Fog", "default": [0.04, 0.05, 0.08, 1.0], "widget": "color"},
]


def _elevation(img, rezolution, intensity, specular, source, ambient, fog, spherical, voxel=False):
    """Light the image as a height field, flat or wrapped onto a sphere."""
    h, w = img.shape[:2]
    n = max(4, int(rezolution))
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    g = gaussian(g[..., None], 1.2)[..., 0]

    if voxel:
        cell = max(1, min(h, w) // n)
        gy = (np.arange(h) // cell) * cell
        gx = (np.arange(w) // cell) * cell
        g = g[np.clip(gy, 0, h - 1)][:, np.clip(gx, 0, w - 1)]

    gx_ = np.zeros_like(g)
    gy_ = np.zeros_like(g)
    gx_[:, 1:-1] = (g[:, 2:] - g[:, :-2]) * 0.5
    gy_[1:-1, :] = (g[2:, :] - g[:-2, :]) * 0.5
    k = float(intensity) * min(h, w) * 0.08
    nx, ny, nz = -gx_ * k, -gy_ * k, np.ones_like(g)

    if spherical:
        u, v = _uv((h, w))
        r2 = u * u + v * v
        inside = r2 < 1.0
        nz = np.sqrt(np.clip(1.0 - r2, 0, 1))
        nx = nx + u
        ny = ny + v
    else:
        inside = np.ones(g.shape, bool)

    norm = np.sqrt(nx * nx + ny * ny + nz * nz) + 1e-9
    nx, ny, nz = nx / norm, ny / norm, nz / norm

    light = np.array([0.35, -0.55, 0.76], np.float32)
    light /= np.linalg.norm(light)
    diff = np.clip(nx * light[0] + ny * light[1] + nz * light[2], 0, 1)
    spec = diff ** (1.0 + float(specular) * 80.0)

    mat = np.asarray(source, np.float32)[:3] * 255.0
    amb = np.asarray(ambient, np.float32)[:3] * 255.0
    tex = img[..., :3].astype(np.float32)
    out = amb + tex * (mat / 255.0) * diff[..., None] + 255.0 * spec[..., None] * float(specular)
    out[~inside] = np.asarray(fog, np.float32)[:3] * 255.0
    return _rgba(out, img)


def _register_elev(fid: str, name: str, spherical: bool, voxel: bool = False) -> None:
    extra = (
        [{"name": "size", "type": "float", "label": "Size", "default": 0.5, "min": 0.05, "max": 1.0, "widget": "slider"}]
        if voxel
        else []
    )

    @cpu_filter(
        fid,
        name=name,
        category="perspective",
        fidelity="reimplemented",
        params=ELEV_PARAMS + extra,
        presets=[{"name": "default", "params": {}}],
    )
    def run(
        img: np.ndarray,
        rezolution: int = 48,
        intensity: float = 0.4,
        specular: float = 0.3,
        sourceColor=(1.0, 1.0, 1.0, 1.0),
        ambientColor=(0.12, 0.14, 0.2, 1.0),
        colorFog=(0.04, 0.05, 0.08, 1.0),
        size: float = 0.5,
    ) -> np.ndarray:
        return _elevation(
            img, rezolution, intensity, specular, sourceColor, ambientColor,
            colorFog, spherical, voxel,
        )


_register_elev("sphere-elevation-map", "Sphere Elevation Map", spherical=True)
_register_elev("sphere-elevation-map-raw", "Sphere Elevation Map Raw", spherical=True)
_register_elev("voxel-elevation-map", "Voxel Elevation Map", spherical=False, voxel=True)
