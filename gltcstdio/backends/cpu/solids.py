"""Raymarched solids: spheroids, a Mobius torus, a wire mesh, a fractal solid.

Reimplemented from the app's parameter contracts (`radius`, `refractionIndex`,
`fresnelStrength`, `colorMaterial`, `colorFog`, `thickness`, `rezolution`).
Each marches a signed-distance field and shades the hit, using the source
image as the environment the surface reflects and refracts -- which is how the
originals put the photograph back into the render.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter

MAX_STEPS = 48
MAX_DIST = 12.0
SURF = 0.002


def _rays(h: int, w: int, zoom: float = 1.6):
    """Camera rays through each pixel of an h x w image."""
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    aspect = w / max(h, 1)
    u = (xx / max(w - 1, 1) * 2.0 - 1.0) * aspect
    v = yy / max(h - 1, 1) * 2.0 - 1.0
    d = np.stack([u, v, np.full_like(u, zoom)], axis=-1)
    return d / np.linalg.norm(d, axis=-1, keepdims=True)


def _env(image: np.ndarray, dirs: np.ndarray) -> np.ndarray:
    """Sample the source image as an environment map for a ray direction."""
    h, w = image.shape[:2]
    x = dirs[..., 0]
    y = dirs[..., 1]
    z = dirs[..., 2]
    u = 0.5 + np.arctan2(x, z) / (2.0 * np.pi)
    v = 0.5 - np.arcsin(np.clip(y, -1.0, 1.0)) / np.pi
    xi = np.clip((u * (w - 1)).astype(np.int32), 0, w - 1)
    yi = np.clip((v * (h - 1)).astype(np.int32), 0, h - 1)
    return image[yi, xi, :3].astype(np.float32)


def _march(sdf, ro, rd):
    """March until the field says we are at the surface, or we give up."""
    t = np.zeros(rd.shape[:2], np.float32)
    hit = np.zeros(rd.shape[:2], bool)
    for _ in range(MAX_STEPS):
        p = ro + rd * t[..., None]
        d = sdf(p)
        t = np.where(hit, t, t + np.maximum(d, SURF * 0.5))
        hit |= (d < SURF) & (t < MAX_DIST)
        if hit.all():
            break
    return t, hit & (t < MAX_DIST)


def _normal(sdf, p):
    e = 0.002
    ex = np.zeros_like(p)
    ex[..., 0] = e
    ey = np.zeros_like(p)
    ey[..., 1] = e
    ez = np.zeros_like(p)
    ez[..., 2] = e
    n = np.stack(
        [
            sdf(p + ex) - sdf(p - ex),
            sdf(p + ey) - sdf(p - ey),
            sdf(p + ez) - sdf(p - ez),
        ],
        axis=-1,
    )
    return n / (np.linalg.norm(n, axis=-1, keepdims=True) + 1e-9)


def _shade(image, p, n, rd, hit, material, fog, fresnel_strength):
    """Fresnel-weighted mix of a reflected and a refracted environment sample."""
    cos_i = np.clip(-(n * rd).sum(axis=-1), 0.0, 1.0)
    fres = (1.0 - cos_i) ** 5
    fres = np.clip(fres * float(fresnel_strength), 0.0, 1.0)

    refl = rd - 2.0 * (n * rd).sum(axis=-1, keepdims=True) * n
    refr = rd * 0.85 + n * 0.15

    col = _env(image, refl) * fres[..., None] + _env(image, refr) * (
        1.0 - fres[..., None]
    )
    col *= np.asarray(material, np.float32)[:3]

    # Distance fog towards the background colour.
    out = np.where(hit[..., None], col, np.asarray(fog, np.float32)[:3] * 255.0)
    return out


SOLID_PARAMS = [
    {"name": "radius", "type": "float", "label": "Radius", "default": 0.6, "min": 0.1, "max": 1.5, "widget": "slider"},
    {"name": "fresnelStrength", "type": "float", "label": "Fresnel", "default": 0.7, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "refractionIndex", "type": "float", "label": "Refraction", "default": 1.4, "min": 1.0, "max": 2.5, "widget": "slider"},
    {
        "name": "colorMaterial",
        "type": "vec4",
        "label": "Material",
        "default": [1.0, 1.0, 1.0, 1.0],
        "widget": "color",
    },
    {
        "name": "colorFog",
        "type": "vec4",
        "label": "Fog",
        "default": [0.05, 0.06, 0.08, 1.0],
        "widget": "color",
    },
]


@cpu_filter(
    "infinite-spheroids",
    name="Infinite Spheroids",
    category="geometry",
    fidelity="reimplemented",
    params=SOLID_PARAMS
    + [
        {"name": "spacing", "type": "float", "label": "Spacing", "default": 2.0, "min": 1.0, "max": 5.0, "widget": "slider"}
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "dense", "params": {"spacing": 1.4, "radius": 0.5}},
    ],
)
def infinite_spheroids(
    img: np.ndarray,
    radius: float = 0.6,
    fresnelStrength: float = 0.7,
    refractionIndex: float = 1.4,
    colorMaterial=(1.0, 1.0, 1.0, 1.0),
    colorFog=(0.05, 0.06, 0.08, 1.0),
    spacing: float = 2.0,
) -> np.ndarray:
    h, w = img.shape[:2]
    rd = _rays(h, w)
    ro = np.zeros_like(rd)
    ro[..., 2] = -3.0
    s = float(spacing)

    def sdf(p):
        # Repeat space to get an endless lattice of spheres.
        q = np.mod(p + s * 0.5, s) - s * 0.5
        return np.linalg.norm(q, axis=-1) - float(radius)

    t, hit = _march(sdf, ro, rd)
    p = ro + rd * t[..., None]
    n = _normal(sdf, p)
    out = _shade(img, p, n, rd, hit, colorMaterial, colorFog, fresnelStrength)
    return np.clip(
        np.dstack([out, np.full((h, w, 1), 255.0, np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "mobius-torus",
    name="Mobius Torus",
    category="geometry",
    fidelity="reimplemented",
    params=SOLID_PARAMS
    + [
        {"name": "roundness", "type": "float", "label": "Roundness", "default": 0.3, "min": 0.05, "max": 0.8, "widget": "slider"},
        {"name": "count", "type": "int", "label": "Twists", "default": 1, "min": 1, "max": 6, "widget": "int_slider"},
    ],
    presets=[{"name": "default", "params": {}}],
)
def mobius_torus(
    img: np.ndarray,
    radius: float = 0.9,
    fresnelStrength: float = 0.7,
    refractionIndex: float = 1.4,
    colorMaterial=(1.0, 1.0, 1.0, 1.0),
    colorFog=(0.05, 0.06, 0.08, 1.0),
    roundness: float = 0.3,
    count: int = 1,
) -> np.ndarray:
    h, w = img.shape[:2]
    rd = _rays(h, w)
    ro = np.zeros_like(rd)
    ro[..., 2] = -3.2
    R, r = float(radius), float(roundness)
    twists = max(1, int(count))

    def sdf(p):
        x, y, z = p[..., 0], p[..., 1], p[..., 2]
        # Torus coordinates, with the tube cross-section rotated as it goes
        # round -- the Mobius twist.
        ang = np.arctan2(z, x)
        rad = np.hypot(x, z) - R
        c, s = np.cos(ang * twists * 0.5), np.sin(ang * twists * 0.5)
        u = rad * c + y * s
        v = -rad * s + y * c
        return np.maximum(np.abs(u) - r, np.abs(v) - r * 0.25)

    t, hit = _march(sdf, ro, rd)
    p = ro + rd * t[..., None]
    n = _normal(sdf, p)
    out = _shade(img, p, n, rd, hit, colorMaterial, colorFog, fresnelStrength)
    return np.clip(
        np.dstack([out, np.full((h, w, 1), 255.0, np.float32)]), 0, 255
    ).astype(np.uint8)


@cpu_filter(
    "fractal-solid-simplified-gl",
    name="Fractal Solid",
    category="fractal",
    fidelity="reimplemented",
    params=SOLID_PARAMS
    + [
        {"name": "iterations", "type": "int", "label": "Iterations", "default": 4, "min": 1, "max": 8, "widget": "int_slider"}
    ],
    presets=[{"name": "default", "params": {}}],
)
def fractal_solid(
    img: np.ndarray,
    radius: float = 1.0,
    fresnelStrength: float = 0.7,
    refractionIndex: float = 1.4,
    colorMaterial=(1.0, 1.0, 1.0, 1.0),
    colorFog=(0.05, 0.06, 0.08, 1.0),
    iterations: int = 4,
) -> np.ndarray:
    h, w = img.shape[:2]
    rd = _rays(h, w)
    ro = np.zeros_like(rd)
    ro[..., 2] = -3.5
    it = max(1, int(iterations))

    def sdf(p):
        # Folded box: the classic cheap 3D fractal.
        q = p.copy()
        scale = 1.0
        for _ in range(it):
            q = np.abs(q)
            q = q * 2.0 - float(radius)
            scale *= 2.0
        d = np.linalg.norm(q, axis=-1) - float(radius)
        return d / scale

    t, hit = _march(sdf, ro, rd)
    p = ro + rd * t[..., None]
    n = _normal(sdf, p)
    out = _shade(img, p, n, rd, hit, colorMaterial, colorFog, fresnelStrength)
    return np.clip(
        np.dstack([out, np.full((h, w, 1), 255.0, np.float32)]), 0, 255
    ).astype(np.uint8)


def _wire_overlay(img, rezolution, thickness, color_lines, glow, elevate):
    """A wireframe grid whose height follows image luminance."""
    from . import luma
    from .gaussian_blur import gaussian

    h, w = img.shape[:2]
    n = max(2, int(rezolution))
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    g = gaussian(g[..., None], 1.5)[..., 0]

    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    # Displace the grid coordinates by the height field, then draw the lines.
    shift = (g - 0.5) * float(elevate) * min(h, w)
    u = (xx / max(w, 1)) * n
    v = ((yy + shift) / max(h, 1)) * n
    du = np.minimum(u % 1.0, 1.0 - u % 1.0)
    dv = np.minimum(v % 1.0, 1.0 - v % 1.0)
    line = np.minimum(du, dv)
    t = max(1e-3, float(thickness))
    mask = np.clip(1.0 - line / t, 0.0, 1.0)
    if glow:
        mask = np.clip(mask + gaussian(mask[..., None], 2.0)[..., 0] * float(glow), 0, 1)

    col = np.asarray(color_lines, np.float32)[:3] * 255.0
    out = img[..., :3].astype(np.float32) * (1.0 - mask[..., None]) + col * mask[..., None]
    return np.clip(
        np.dstack([out, img[..., 3:4].astype(np.float32)]), 0, 255
    ).astype(np.uint8)


WIRE_PARAMS = [
    {"name": "rezolution", "type": "int", "label": "Resolution", "default": 24, "min": 2, "max": 120, "widget": "int_slider"},
    {"name": "thickness", "type": "float", "label": "Thickness", "default": 0.08, "min": 0.005, "max": 0.5, "widget": "slider"},
    {"name": "glow", "type": "float", "label": "Glow", "default": 0.0, "min": 0.0, "max": 1.0, "widget": "slider"},
    {"name": "elevation", "type": "float", "label": "Elevation", "default": 0.05, "min": 0.0, "max": 0.5, "widget": "slider"},
    {
        "name": "colorLines",
        "type": "vec4",
        "label": "Lines",
        "default": [1.0, 1.0, 1.0, 1.0],
        "widget": "color",
    },
]


@cpu_filter(
    "mesh-gl",
    name="Mesh",
    category="geometry",
    fidelity="reimplemented",
    params=WIRE_PARAMS,
    presets=[{"name": "default", "params": {}}],
)
def mesh_gl(
    img: np.ndarray,
    rezolution: int = 24,
    thickness: float = 0.08,
    glow: float = 0.0,
    elevation: float = 0.05,
    colorLines=(1.0, 1.0, 1.0, 1.0),
) -> np.ndarray:
    return _wire_overlay(img, rezolution, thickness, colorLines, glow, elevation)


@cpu_filter(
    "height-map-wireframe-3-gl",
    name="Height Map Wireframe",
    category="perspective",
    fidelity="reimplemented",
    params=WIRE_PARAMS,
    presets=[
        {"name": "default", "params": {"elevation": 0.12, "rezolution": 40}},
    ],
)
def height_map_wireframe_3(
    img: np.ndarray,
    rezolution: int = 40,
    thickness: float = 0.08,
    glow: float = 0.0,
    elevation: float = 0.12,
    colorLines=(1.0, 1.0, 1.0, 1.0),
) -> np.ndarray:
    return _wire_overlay(img, rezolution, thickness, colorLines, glow, elevation)
