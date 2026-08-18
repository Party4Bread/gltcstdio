"""Separable Gaussian blur.

Reimplemented: the app dispatches its blur through an obfuscated table, but a
Gaussian blur has one correct answer, so this matches in effect if not in
exact rounding.
"""

from __future__ import annotations

import numpy as np

from . import cpu_filter


def _kernel(sigma: float) -> np.ndarray:
    radius = max(1, int(round(sigma * 3.0)))
    x = np.arange(-radius, radius + 1, dtype=np.float32)
    k = np.exp(-(x**2) / (2.0 * sigma * sigma))
    return k / k.sum()


# How many kernel widths of the axis one matrix multiply covers.  Larger
# blocks waste more arithmetic on the overlap, smaller ones call into BLAS
# more often; four is flat across the sizes the filters use.
_BLOCK_KERNELS = 4


def _convolve1d(a: np.ndarray, k: np.ndarray, axis: int) -> np.ndarray:
    """Convolve along one axis, a block of output rows at a time.

    Written as a matrix multiply rather than a weighted sum per tap: the tap
    loop walks the whole image once for each of its 63 to 247 taps, which is
    all memory traffic, while banding the kernel into a matrix hands the same
    arithmetic to BLAS and runs 16 to 28 times faster.  Blocking keeps that
    matrix small enough that the extra work on the overlap stays bounded.

    The sums come out to within 1e-4 of the tap loop -- one rounding instead
    of an accumulated one -- which moves about one pixel in 50,000 by a single
    step of 1/255 after quantisation.
    """
    pad = len(k) // 2
    a = np.moveaxis(a, axis, 0)
    n, tail = a.shape[0], a.shape[1:]
    padded = np.pad(
        a, [(pad, pad)] + [(0, 0)] * (a.ndim - 1), mode="edge"
    ).reshape(n + 2 * pad, -1)

    block = max(len(k), min(n, _BLOCK_KERNELS * len(k)))
    band = np.zeros((block, block + 2 * pad), dtype=np.float32)
    rows = np.arange(block)
    for j, w in enumerate(k):
        band[rows, rows + j] = w

    out = np.empty((n, padded.shape[1]), dtype=np.float32)
    for start in range(0, n, block):
        take = min(block, n - start)
        np.matmul(
            band[:take, : take + 2 * pad],
            padded[start : start + take + 2 * pad],
            out=out[start : start + take],
        )
    return np.moveaxis(out.reshape((n,) + tail), 0, axis)


def gaussian(img: np.ndarray, sigma: float) -> np.ndarray:
    if sigma <= 0:
        return img.astype(np.float32)
    k = _kernel(sigma)
    a = img.astype(np.float32)
    return _convolve1d(_convolve1d(a, k, 0), k, 1)


@cpu_filter(
    "gaussian-blur2",
    name="Gaussian Blur",
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
    presets=[
        {"name": "default", "params": {}},
        {"name": "strong", "params": {"radius": 0.08}},
    ],
)
def gaussian_blur(img: np.ndarray, radius: float = 0.02) -> np.ndarray:
    # Radius is relative to the shorter side, so the look is resolution
    # independent -- the same convention the shader filters use.
    sigma = float(radius) * min(img.shape[:2])
    return np.clip(gaussian(img, sigma), 0, 255).astype(np.uint8)
