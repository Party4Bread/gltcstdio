import numpy as np
import pytest


@pytest.fixture(scope="session")
def image() -> np.ndarray:
    """A test image with gradients, hard edges and a shape."""
    n = 96
    yy, xx = np.mgrid[0:n, 0:n]
    img = np.zeros((n, n, 4), np.uint8)
    img[..., 0] = (xx / n * 255).astype(np.uint8)
    img[..., 1] = (yy / n * 255).astype(np.uint8)
    img[..., 2] = (((xx // 12 + yy // 12) % 2) * 200 + 55).astype(np.uint8)
    img[..., 3] = 255
    r = np.hypot(xx - n / 2, yy - n / 2)
    img[r < n / 4] = [255, 240, 120, 255]
    return img


@pytest.fixture(scope="session")
def bank():
    from gltcstdio import load_bank

    return load_bank()


@pytest.fixture(scope="session")
def renderer():
    # The same shared renderer `apply()` uses: a second standalone context in
    # the process would fight this one for being current.
    from gltcstdio.backends.gl import get_renderer

    return get_renderer()
