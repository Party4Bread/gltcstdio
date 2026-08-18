"""Uniforms the engine computes in Java rather than reading from a parameter.

Most filters take their uniforms straight from the parameter spec, but a few
have the app build an array on the CPU each frame.  `metaballs-gl` is one: its
shader declares `vec4[32] spheres, int spheres_size` and the app fills both
from `count`, `radius`, `regularity` and `randomSeed`.  Extracted without
that step the array stayed all zeros, `spheres_size` stayed 0, and the ray
march hit nothing at all.

Everything here is ported from the APK, the seeded generator included -- the
positions are jittered by Kotlin's XorWow `Random(i)`, which is short enough
to reproduce exactly, so the output matches the app rather than merely moving.
"""

from __future__ import annotations

import math

__all__ = ["DERIVED", "metaball_spheres", "raymarch_spheres"]

MAX_SPHERES = 32
# `AbstractC3132C.C(count, 0, 27)` clamps the count before the layout switch.
MAX_COUNT = 27


class XorWow:
    """Kotlin's `Random(seed)`, as `k6.e` implements it.

    `A.g.e(i)` builds it as `k6.e(i, i >> 31)`, and the constructor discards
    the first 64 steps.
    """

    __slots__ = ("x", "y", "z", "w", "v", "d")

    MASK = 0xFFFFFFFF

    def __init__(self, seed: int) -> None:
        lo = seed & self.MASK
        hi = (seed >> 31) & self.MASK
        self.x, self.y = lo, hi
        self.z, self.w = 0, 0
        self.v = (~seed) & self.MASK
        self.d = ((seed << 10) ^ (hi >> 4)) & self.MASK
        for _ in range(64):
            self.next_int()

    def next_int(self) -> int:
        x = self.x
        t = (x ^ (x >> 2)) & self.MASK
        self.x, self.y, self.z = self.y, self.z, self.w
        v = self.v
        self.w = v
        v = ((t ^ ((t << 1) & self.MASK)) ^ v) ^ ((v << 4) & self.MASK)
        self.v = v & self.MASK
        self.d = (self.d + 362437) & self.MASK
        out = (self.v + self.d) & self.MASK
        return out - (1 << 32) if out >= (1 << 31) else out

    def bits(self, count: int) -> int:
        """`d.a(bits)`: the top `count` bits of the next draw."""
        return (self.next_int() & self.MASK) >> (32 - count)

    def next_double(self) -> float:
        """`d.b()`."""
        return ((self.bits(26) << 27) + self.bits(27)) / 9.007199254740992e15

    def next_float(self) -> float:
        """`d.d()`."""
        return self.bits(24) / 1.6777216e7


def _ring(n: int, z: float, radius: float, phase: float) -> list[tuple]:
    """`Metaballs3D.H`: `n` points on a circle at height `z`."""
    out = []
    for i in range(n):
        a = (i * 2.0 * math.pi) / n + phase
        out.append((math.cos(a) * radius, math.sin(a) * radius, z))
    return out


def _layout(count: int) -> list[tuple]:
    """The polyhedron the app arranges `count` spheres on."""
    half = 0.5
    root3 = math.sqrt(3.0)
    root2_2 = math.sqrt(2.0) / 2.0
    h = root3 / 2.0
    t3 = root3 / 3.0
    t23 = root3 * 2.0 / 3.0
    s72 = math.sin(1.2566370614359172)

    if count <= 0:
        return []
    if count == 1:
        return [(0.0, 0.0, 0.0)]
    if count == 2:
        return [(-1.0, 0.0, 0.0), (1.0, 0.0, 0.0)]
    if count == 3:
        return [(-1.0, -t3, 0.0), (1.0, -t3, 0.0), (0.0, t23, 0.0)]
    if count == 4:
        return [
            (-1.0, -t3, -half), (1.0, -t3, -half),
            (0.0, t23, -half), (0.0, 0.0, 1.0),
        ]
    if count == 5:
        k = 2.0 / 3.0
        return [
            (-k, -t3 * k, 0.0), (k, -t3 * k, 0.0), (0.0, t23 * k, 0.0),
            (0.0, 0.0, -1.0), (0.0, 0.0, 1.0),
        ]
    axes = [
        (-1.0, 0.0, 0.0), (1.0, 0.0, 0.0),
        (0.0, -1.0, 0.0), (0.0, 1.0, 0.0),
        (0.0, 0.0, -1.0), (0.0, 0.0, 1.0),
    ]
    if count == 6:
        return axes
    if count == 7:
        return [(0.0, 0.0, 0.0)] + axes
    cube = [
        (x, y, z)
        for z in (-root2_2, root2_2)
        for y in (-root2_2, root2_2)
        for x in (-root2_2, root2_2)
    ]
    if count == 8:
        return cube
    if count == 9:
        return [(0.0, 0.0, 0.0)] + cube
    poles = [(0.0, 0.0, -1.0), (0.0, 0.0, 1.0)]
    centre = [(0.0, 0.0, 0.0)]
    if count in (10, 11):
        rings = _ring(4, -half, h, 0.0) + _ring(4, half, h, 0.0)
        return (centre if count == 11 else []) + poles + rings
    if count in (12, 13):
        rings = _ring(5, -s72 / 2.0, s72, 0.0) + _ring(
            5, s72 / 2.0, s72, math.sin(0.6283185307179586)
        )
        return (centre if count == 13 else []) + poles + rings
    if count in (14, 15):
        rings = _ring(6, -0.5, 1.0, 0.0) + _ring(6, half, 1.0, 0.0)
        return (centre if count == 15 else []) + poles + rings

    # A spiral over the sphere for everything larger.
    step = 2.0 * math.pi / math.sqrt(count)
    last = count - 1
    delta = (math.pi - step) / last
    out = [(0.0, 0.0, -1.0)]
    for i in range(1, last):
        polar = 0.5 * step + i * delta
        r = math.sin(polar)
        azimuth = i * step
        out.append((math.cos(azimuth) * r, math.sin(azimuth) * r, math.cos(polar)))
    out.append((0.0, 0.0, 1.0))
    return out


def _spheres(values: dict, defaults: dict, limit: int, scale_of) -> dict:
    """`spheres` and `spheres_size`, as the ray marchers build them.

    `Metaballs3D` and `Spheres` share this generator down to the seeded
    jitter; they differ only in how the count bounds the layout and in the
    formula turning `radius` into a sphere size.
    """
    count = int(values.get("count", defaults["count"]))
    radius = float(values.get("radius", defaults["radius"]))
    regularity = float(values.get("regularity", defaults["regularity"]))
    seed = float(values.get("randomSeed", defaults["randomSeed"]))

    n = max(0, min(count, limit))
    scale = float(scale_of(n, radius)) if n else 0.0
    spread = 1.0 - regularity
    jitter = spread * 0.5

    sizes = XorWow(0)
    packed = []
    for i, (x, y, z) in enumerate(_layout(n)):
        rnd = XorWow(i)
        dx = math.sin((rnd.next_double() + 1.0) * seed + rnd.next_double() * math.tau) * jitter
        dy = math.sin((rnd.next_double() + 1.0) * seed + rnd.next_double() * math.tau) * jitter
        dz = math.sin((rnd.next_double() + 1.0) * seed + rnd.next_double() * math.tau) * jitter
        r = ((sizes.next_float() - 0.5) * spread + 1.1) * scale * 0.1
        packed.append([x + dx, y + dy, z + dz, r])

    while len(packed) < MAX_SPHERES:
        packed.append([0.0, 0.0, 0.0, 1.0])
    return {"spheres": packed[:MAX_SPHERES], "spheres_size": len(_layout(n))}


METABALL_DEFAULTS = {"count": 6, "radius": 0.7, "regularity": 0.0, "randomSeed": 0.0}
RAYMARCH_DEFAULTS = {"count": 8, "radius": 0.3, "regularity": 1.0, "randomSeed": 0.0}


def metaball_spheres(values: dict) -> dict:
    """`Metaballs3D`: `pow(count, 0.25) * radius * 100 * 0.1`, count 0..27."""
    return _spheres(
        values, METABALL_DEFAULTS, MAX_COUNT,
        lambda n, r: math.pow(n, 0.25) * r * 100.0 * 0.1,
    )


def raymarch_spheres(values: dict) -> dict:
    """`Spheres`: `radius * 100 / pow(count, 0.33) * 0.2`, count 0..32."""
    return _spheres(
        values, RAYMARCH_DEFAULTS, MAX_SPHERES,
        lambda n, r: (r * 100.0 / math.pow(n, 0.33)) * 0.2,
    )


# Shader entry point -> the uniforms its filter computes rather than reads.
DERIVED = {
    "metaballs3d": metaball_spheres,
    "metaballsGl": metaball_spheres,
    "spheres": raymarch_spheres,
    "spheresGl": raymarch_spheres,
}
