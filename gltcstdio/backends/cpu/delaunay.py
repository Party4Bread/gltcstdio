"""Delaunay triangulation.

Reimplemented from the app's parameter contract (`count`, `outlineWidth`,
`outlinePresence`, recovered from its presets).  Points are drawn towards
image detail, triangulated, and each triangle flat-filled with the mean colour
of the pixels it covers.

Triangulation uses Bowyer-Watson, which is O(n^2) in the worst case but fine
at the point counts the presets use (200-500).
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter, luma
from .gaussian_blur import gaussian


def _sample_points(img: np.ndarray, count: int, seed: int = 0) -> np.ndarray:
    h, w = img.shape[:2]
    g = luma(img[..., :3].astype(np.float32) / 255.0)
    detail = np.abs(g - gaussian(g[..., None], 2.0)[..., 0])
    weight = detail + 0.02  # keep flat regions represented
    flat = weight.ravel() / weight.sum()

    rng = np.random.default_rng(seed)
    n_detail = max(0, count - 4)
    idx = rng.choice(flat.size, size=n_detail, replace=False, p=flat)
    pts = np.stack([idx % w, idx // w], axis=1).astype(np.float64)
    corners = np.array([[0, 0], [w - 1, 0], [0, h - 1], [w - 1, h - 1]], np.float64)
    return np.vstack([corners, pts])


def _circumcircle(a, b, c):
    ax, ay = a
    bx, by = b
    cx, cy = c
    d = 2.0 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(d) < 1e-12:
        return None
    a2, b2, c2 = ax * ax + ay * ay, bx * bx + by * by, cx * cx + cy * cy
    ux = (a2 * (by - cy) + b2 * (cy - ay) + c2 * (ay - by)) / d
    uy = (a2 * (cx - bx) + b2 * (ax - cx) + c2 * (bx - ax)) / d
    r2 = (ax - ux) ** 2 + (ay - uy) ** 2
    return ux, uy, r2


def _triangulate(points: np.ndarray) -> list[tuple[int, int, int]]:
    """Bowyer-Watson incremental Delaunay triangulation."""
    n = len(points)
    xs, ys = points[:, 0], points[:, 1]
    minx, maxx = xs.min(), xs.max()
    miny, maxy = ys.min(), ys.max()
    dx, dy = maxx - minx, maxy - miny
    dmax = max(dx, dy) * 10 + 10
    cx, cy = (minx + maxx) / 2, (miny + maxy) / 2

    # Super-triangle containing every point; its vertices are removed at the end.
    sup = np.array(
        [[cx - dmax, cy - dmax], [cx + dmax, cy - dmax], [cx, cy + dmax]], np.float64
    )
    pts = np.vstack([points, sup])
    tris = [(n, n + 1, n + 2)]

    for i in range(n):
        p = pts[i]
        bad = []
        for t in tris:
            cc = _circumcircle(pts[t[0]], pts[t[1]], pts[t[2]])
            if cc is None:
                continue
            ux, uy, r2 = cc
            if (p[0] - ux) ** 2 + (p[1] - uy) ** 2 <= r2:
                bad.append(t)
        # Edges on the boundary of the bad-triangle cavity appear exactly once.
        counts: dict[tuple[int, int], int] = {}
        for t in bad:
            for e in ((t[0], t[1]), (t[1], t[2]), (t[2], t[0])):
                k = (min(e), max(e))
                counts[k] = counts.get(k, 0) + 1
        boundary = [e for e, c in counts.items() if c == 1]
        bad_set = set(bad)
        tris = [t for t in tris if t not in bad_set]
        tris.extend((e[0], e[1], i) for e in boundary)

    return [t for t in tris if all(v < n for v in t)]


@cpu_filter(
    "delaunay-triangulate",
    name="Delaunay Triangulate",
    category="alchemy",
    fidelity="reimplemented",
    params=[
        {
            "name": "count",
            "type": "int",
            "label": "Count",
            "default": 200,
            "min": 20,
            "max": 1500,
            "widget": "int_slider",
        },
        {
            "name": "outlineWidth",
            "type": "float",
            "label": "Outline Width",
            "default": 0.0,
            "min": 0.0,
            "max": 60.0,
            "widget": "slider",
        },
        {
            "name": "outlinePresence",
            "type": "float",
            "label": "Outline",
            "default": 0.0,
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
        {"name": "default", "params": {}},
        {"name": "dense", "params": {"count": 500}},
        {"name": "outlined", "params": {"outlineWidth": 30.0, "outlinePresence": 0.1}},
    ],
)
def delaunay_triangulate(
    img: np.ndarray,
    count: int = 200,
    outlineWidth: float = 0.0,
    outlinePresence: float = 0.0,
    randomSeed: float = 0.0,
) -> np.ndarray:
    h, w = img.shape[:2]
    pts = _sample_points(img, int(count), seed=int(randomSeed))
    tris = _triangulate(pts)

    out = img.astype(np.float32).copy()
    yy, xx = np.mgrid[0:h, 0:w]

    for t in tris:
        a, b, c = pts[t[0]], pts[t[1]], pts[t[2]]
        x0 = max(0, int(min(a[0], b[0], c[0])))
        x1 = min(w, int(max(a[0], b[0], c[0])) + 1)
        y0 = max(0, int(min(a[1], b[1], c[1])))
        y1 = min(h, int(max(a[1], b[1], c[1])) + 1)
        if x1 <= x0 or y1 <= y0:
            continue
        sx, sy = xx[y0:y1, x0:x1], yy[y0:y1, x0:x1]
        # Barycentric sign test.
        d = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
        if abs(d) < 1e-9:
            continue
        l1 = ((b[1] - c[1]) * (sx - c[0]) + (c[0] - b[0]) * (sy - c[1])) / d
        l2 = ((c[1] - a[1]) * (sx - c[0]) + (a[0] - c[0]) * (sy - c[1])) / d
        l3 = 1.0 - l1 - l2
        inside = (l1 >= 0) & (l2 >= 0) & (l3 >= 0)
        if not inside.any():
            continue
        patch = img[y0:y1, x0:x1]
        out[y0:y1, x0:x1][inside] = patch[inside].mean(axis=0)

        if outlinePresence > 0 and outlineWidth > 0:
            edge_t = float(outlineWidth) / 1000.0
            edge = inside & (
                (l1 < edge_t) | (l2 < edge_t) | (l3 < edge_t)
            )
            if edge.any():
                dark = out[y0:y1, x0:x1][edge] * (1.0 - float(outlinePresence))
                out[y0:y1, x0:x1][edge] = dark

    out[..., 3] = img[..., 3]
    return np.clip(out, 0, 255).astype(np.uint8)
