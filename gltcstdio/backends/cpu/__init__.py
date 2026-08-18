"""CPU filters implemented with numpy.

Fidelity note
-------------
The app runs these on the CPU through an obfuscated dispatch table rather than
readable per-filter methods, so most could not be decompiled into a faithful
port.  Each filter below records how close it is to the original:

  "recovered"      the inner kernels were readable in the decompiled source and
                   are reproduced (pixel-sort's counting sort, for instance)
  "reimplemented"  the parameter contract comes from the app -- names, ranges
                   and presets -- but the algorithm is a fresh implementation
                   of the named technique, so output will not match pixel for
                   pixel

`Filter.fidelity` carries this through to the bank and the editor.
"""

from __future__ import annotations

from typing import Callable

import numpy as np

# name -> (function, param specs, presets, fidelity, category)
REGISTRY: dict[str, dict] = {}


def cpu_filter(
    fid: str,
    *,
    name: str,
    category: str,
    fidelity: str,
    params: list[dict],
    presets: list[dict] | None = None,
):
    """Register a CPU filter and describe its parameters like a shader would."""

    def wrap(fn: Callable) -> Callable:
        REGISTRY[fid] = {
            "id": fid,
            "name": name,
            "category": category,
            "backend": "cpu",
            "fidelity": fidelity,
            "params": params,
            "presets": presets or [],
            "fn": fn,
        }
        return fn

    return wrap


def f32(img: np.ndarray) -> np.ndarray:
    return img.astype(np.float32) / 255.0


def u8(img: np.ndarray) -> np.ndarray:
    return np.clip(img * 255.0 + 0.5, 0, 255).astype(np.uint8)


def luma(rgb: np.ndarray) -> np.ndarray:
    return rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722


from . import (  # noqa: E402,F401  (import for side effects: registration)
    breaks,
    circle_mosaic,
    contour,
    delaunay,
    gaussian_blur,
    light,
    one_line,
    painterly,
    pixel_sort,
    remainder,
    shapes,
    solids,
    tail,
)
