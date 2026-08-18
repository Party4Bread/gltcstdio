"""The gltcstdio filter bank, in Rust.

The heavy lifting is the compiled extension; this layer only converts images
so callers can pass a numpy array, a PIL image, a path, or raw bytes.

    >>> import gltcstdio_rs as of
    >>> out = of.apply("halftone", "photo.jpg", intensity=0.8)
    >>> out.save("out.png")

`apply` returns whatever kind it was given: a PIL image for a PIL image or a
path, a numpy array for an array, an `Image` for an `Image`.
"""

from __future__ import annotations

from typing import Any

from ._native import (  # noqa: F401
    Image,
    Renderer,
    __version__,
    categories,
    cpu_filters,
    describe,
    list_filters,
)

__all__ = [
    "Image",
    "Renderer",
    "apply",
    "categories",
    "cpu_filters",
    "describe",
    "list_filters",
    "renderer",
    "to_image",
]

_SHARED: Renderer | None = None


def renderer() -> Renderer:
    """The process-wide renderer.

    Opening a GPU device is expensive and every pipeline built on it is
    cached, so one is shared rather than made per call.
    """
    global _SHARED
    if _SHARED is None:
        _SHARED = Renderer()
    return _SHARED


def to_image(source: Any) -> Image:
    """Anything image-shaped, as an `Image`.

    Accepts an `Image`, a numpy array of shape (h, w, 3 or 4), a PIL image,
    or a path to one.
    """
    if isinstance(source, Image):
        return source

    if isinstance(source, (str, bytes)) or hasattr(source, "__fspath__"):
        from PIL import Image as PILImage

        source = PILImage.open(source)

    if hasattr(source, "convert") and hasattr(source, "tobytes"):
        rgba = source.convert("RGBA")
        return Image(rgba.width, rgba.height, rgba.tobytes())

    if hasattr(source, "shape"):
        import numpy as np

        array = np.asarray(source)
        if array.ndim != 3 or array.shape[2] not in (3, 4):
            raise ValueError("expected an (h, w, 3) or (h, w, 4) array")
        if array.shape[2] == 3:
            alpha = np.full(array.shape[:2] + (1,), 255, np.uint8)
            array = np.dstack([array, alpha])
        array = np.ascontiguousarray(array.astype(np.uint8))
        return Image(array.shape[1], array.shape[0], array.tobytes())

    raise TypeError(f"cannot read an image from {type(source).__name__}")


def _like(source: Any, out: Image):
    """`out` in the same form `source` arrived as."""
    if isinstance(source, Image):
        return out
    if hasattr(source, "shape"):
        import numpy as np

        return np.frombuffer(out.data, np.uint8).reshape(out.height, out.width, 4)
    from PIL import Image as PILImage

    return PILImage.frombytes("RGBA", (out.width, out.height), out.data)


def apply(
    filter_id: str,
    source: Any,
    preset: str | None = None,
    inputs: dict[str, Any] | None = None,
    **params: Any,
):
    """Apply a filter, at its defaults unless `params` or `preset` say otherwise.

    `inputs` binds the secondary images a filter reads -- `source2`,
    `sourceBkg` and friends.  Anything a filter wants but the caller did not
    give falls back to the primary image.
    """
    image = to_image(source)
    bound = {k: to_image(v) for k, v in (inputs or {}).items()} or None
    out = renderer().apply(filter_id, image, params or None, preset, bound)
    return _like(source, out)
