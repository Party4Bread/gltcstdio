"""Single-stroke line drawing.

Reimplemented from the app's parameter contract (`count`, `thickness`,
`lineStyle`, recovered from its presets) and from the helper classes that did
survive decompilation -- `FloydSteinbergDithering`, `OneLineRenderer`,
`Point`, `Segment` -- which show the approach: dither the image to points whose
density tracks darkness, then join those points into one continuous stroke.

The stroke is ordered by a nearest-neighbour tour, which is what produces the
characteristic single wandering line.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma


def _floyd_steinberg_points(g: np.ndarray, count: int, seed: int) -> np.ndarray:
    """Error-diffusion dither, returning the coordinates that turned black."""
    h, w = g.shape
    # Scale so roughly `count` cells fire.
    target = np.clip(count / float(h * w), 1e-6, 1.0)
    darkness = 1.0 - g
    if darkness.sum() > 0:
        darkness = darkness * (target * h * w / darkness.sum())
    buf = np.clip(darkness, 0.0, 1.0).astype(np.float32).copy()

    pts = []
    for y in range(h):
        for x in range(w):
            old = buf[y, x]
            new = 1.0 if old > 0.5 else 0.0
            if new > 0.5:
                pts.append((x, y))
            err = old - new
            if x + 1 < w:
                buf[y, x + 1] += err * 7 / 16
            if y + 1 < h:
                if x > 0:
                    buf[y + 1, x - 1] += err * 3 / 16
                buf[y + 1, x] += err * 5 / 16
                if x + 1 < w:
                    buf[y + 1, x + 1] += err * 1 / 16
    return np.array(pts, np.float32) if pts else np.zeros((0, 2), np.float32)


def _nearest_neighbour_tour(pts: np.ndarray) -> np.ndarray:
    """Greedy tour, giving one continuous stroke through every point."""
    n = len(pts)
    if n < 2:
        return pts
    remaining = np.ones(n, bool)
    order = [0]
    remaining[0] = False
    cur = pts[0]
    for _ in range(n - 1):
        idx = np.flatnonzero(remaining)
        d = ((pts[idx] - cur) ** 2).sum(axis=1)
        nxt = idx[int(np.argmin(d))]
        order.append(nxt)
        remaining[nxt] = False
        cur = pts[nxt]
    return pts[order]


def _draw_polyline(canvas: np.ndarray, pts: np.ndarray, thickness: float, colour):
    """Rasterise a polyline with a simple distance-to-segment test."""
    h, w = canvas.shape[:2]
    r = max(0.5, thickness)
    col = np.asarray(colour, np.float32)
    for i in range(len(pts) - 1):
        p0, p1 = pts[i], pts[i + 1]
        x0 = max(0, int(min(p0[0], p1[0]) - r - 1))
        x1 = min(w, int(max(p0[0], p1[0]) + r + 2))
        y0 = max(0, int(min(p0[1], p1[1]) - r - 1))
        y1 = min(h, int(max(p0[1], p1[1]) + r + 2))
        if x1 <= x0 or y1 <= y0:
            continue
        yy, xx = np.mgrid[y0:y1, x0:x1]
        d = p1 - p0
        seg2 = float(d @ d)
        if seg2 < 1e-9:
            t = np.zeros_like(xx, np.float32)
        else:
            t = np.clip(((xx - p0[0]) * d[0] + (yy - p0[1]) * d[1]) / seg2, 0.0, 1.0)
        px, py = p0[0] + t * d[0], p0[1] + t * d[1]
        dist = np.hypot(xx - px, yy - py)
        hit = dist <= r
        if hit.any():
            canvas[y0:y1, x0:x1][hit] = col


@cpu_filter(
    "one-line",
    name="One Line",
    category="alchemy",
    fidelity="reimplemented",
    params=[
        {
            "name": "count",
            "type": "int",
            "label": "Count",
            "default": 1500,
            "min": 100,
            "max": 4000,
            "widget": "int_slider",
        },
        {
            "name": "thickness",
            "type": "float",
            "label": "Thickness",
            "default": 0.08,
            "min": 0.01,
            "max": 0.5,
            "widget": "slider",
        },
        {
            "name": "colorStroke",
            "type": "vec4",
            "label": "Stroke",
            "default": [0.0, 0.0, 0.0, 1.0],
            "widget": "color",
        },
        {
            "name": "colorBkg",
            "type": "vec4",
            "label": "Background",
            "default": [1.0, 1.0, 1.0, 1.0],
            "widget": "color",
        },
    ],
    presets=[
        {"name": "default", "params": {}},
        {"name": "dense", "params": {"count": 3000, "thickness": 0.05}},
    ],
)
def one_line(
    img: np.ndarray,
    count: int = 1500,
    thickness: float = 0.08,
    colorStroke=(0.0, 0.0, 0.0, 1.0),
    colorBkg=(1.0, 1.0, 1.0, 1.0),
) -> np.ndarray:
    h, w = img.shape[:2]
    g = luma(img[..., :3].astype(np.float32) / 255.0)

    # Dither on a reduced grid: the stroke should follow tone, not pixels.
    step = max(1, int(np.sqrt(h * w / max(1, int(count) * 4))))
    small = g[::step, ::step]
    pts = _floyd_steinberg_points(small, int(count), 0)
    if len(pts) > int(count):
        sel = np.linspace(0, len(pts) - 1, int(count)).astype(int)
        pts = pts[sel]
    pts = pts * step

    out = np.empty((h, w, 4), np.float32)
    out[...] = np.asarray(colorBkg, np.float32) * 255.0
    if len(pts) >= 2:
        tour = _nearest_neighbour_tour(pts)
        _draw_polyline(
            out, tour, float(thickness) * step, np.asarray(colorStroke) * 255.0
        )
    return np.clip(out, 0, 255).astype(np.uint8)
