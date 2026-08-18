"""Configurable image filters, chainable into graphs.

    from gltcstdio import apply, list_filters

    img = apply("halftone", "photo.jpg", style=1, intensity=0.8)
    img = apply("halftone", "photo.jpg", preset="hex dots")
    img.save("out.png")

GL-backed filters run the app's original GLSL unmodified on a headless
context.  CPU-backed filters are numpy implementations; check
`get_filter(id).fidelity` to see how closely one tracks the original.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

import numpy as np

from .bank import Bank, load_bank
from .params import Filter, ParamError, ParamSpec, Preset

__all__ = [
    "apply",
    "list_filters",
    "get_filter",
    "categories",
    "load_bank",
    "Bank",
    "Filter",
    "ParamSpec",
    "ParamError",
    "Preset",
]

def _gl():
    from .backends.gl import get_renderer

    return get_renderer()


def _as_array(image) -> np.ndarray:
    """Accept a path, a PIL image or an array; return HxWx4 uint8 RGBA."""
    if isinstance(image, np.ndarray):
        arr = image
    else:
        from PIL import Image

        if isinstance(image, (str, Path)):
            arr = np.array(Image.open(image).convert("RGBA"))
        else:
            arr = np.array(image.convert("RGBA"))
    if arr.ndim == 2:
        arr = np.stack([arr] * 3 + [np.full_like(arr, 255)], axis=-1)
    if arr.shape[2] == 3:
        arr = np.dstack([arr, np.full(arr.shape[:2], 255, arr.dtype)])
    return np.ascontiguousarray(arr.astype(np.uint8))


def _render_node(filter_id: str, image, params: dict, inputs: dict):
    """Render one node of a graph with whichever backend owns that filter."""
    spec = get_filter(filter_id)
    known = spec.param_map
    values = spec.resolve(**{k: v for k, v in params.items() if k in known})
    if spec.backend == "graph":
        # A look can use another look as a stage.
        return _render_graph(spec, image, values)
    if spec.backend == "cpu":
        from .backends.cpu import REGISTRY

        return REGISTRY[filter_id]["fn"](image, **values)
    return _gl().render(filter_id, image, values=values, inputs=inputs)


def _render_graph(f: Filter, image, values: dict):
    from .graph import render_graph

    return render_graph(f.graph, image, _render_node, overrides=values)


def get_filter(filter_id: str) -> Filter:
    """Look up one filter's specification."""
    return load_bank().get(filter_id)


def list_filters(
    category: str | None = None,
    supported_only: bool = True,
    backend: str | None = None,
) -> list[Filter]:
    """All filters, optionally narrowed by category or backend."""
    return load_bank().list(
        category=category, supported_only=supported_only, backend=backend
    )


def categories() -> list[str]:
    return load_bank().categories


def apply(
    filter_id: str,
    image,
    preset: str | None = None,
    size: tuple[int, int] | None = None,
    inputs: dict | None = None,
    **params: Any,
):
    """Apply a filter to an image and return a PIL image.

    `params` override the filter's defaults and any preset; unknown names
    raise ParamError rather than being silently ignored.

    Some filters read more than one image -- check `get_filter(id).extra_inputs`
    -- and `inputs` supplies them by name::

        apply("bloom-combine", photo, inputs={"source2": mask})

    Anything not supplied falls back to the primary image.
    """
    from PIL import Image

    f = get_filter(filter_id)

    # 47 filters have a parameter of their own called `size`, and this
    # function's own `size` argument was swallowing it -- `dithering-pattern`
    # has no other parameter, so none of it was reachable.  The output size is
    # a (width, height) pair, so anything else is meant for the filter.
    if size is not None and "size" in f.param_map:
        if not (isinstance(size, (tuple, list)) and len(size) == 2):
            params["size"] = size
            size = None

    arr = _as_array(image)
    values = f.resolve(preset=preset, **params)

    if f.backend == "graph":
        out = _render_graph(f, arr, values)
        if size is not None:
            return Image.fromarray(out).resize(size, Image.LANCZOS)
        return Image.fromarray(out)

    if f.backend == "cpu":
        from .backends.cpu import REGISTRY

        fn = REGISTRY[filter_id]["fn"]
        out = fn(arr, **values)
        if size is not None:
            return Image.fromarray(out).resize(size, Image.LANCZOS)
        return Image.fromarray(out)

    extra = {k: _as_array(v) for k, v in (inputs or {}).items()}
    out = _gl().render(filter_id, arr, values=values, size=size, inputs=extra)
    return Image.fromarray(out)
