"""The app's transform builders, as they are written in the APK.

Filter constructors rarely spell a transform out.  They call one of seven
static builders and sometimes multiply the results:

    E1.u0(0.0, -0.1)                     translate
    E1.u0(0.0, 0.0).b(E1.n0(0.2))        translate, then uniform scale

Missing these cost `rgb-spike` every one of its four transforms.  They fell
back to the type default, and a `mat3` default of zero makes
`normalize(modelTransform[1].xy)` a division by zero, so the whole filter
came out blank.

`E2.e` (mat3) and `E2.f` (mat4) hold their components as columns -- the
accessor rejects an index outside 0..2 with "column must be in 0..2".  The
bank stores matrices row-major, so everything here is transposed on the way
out and `mul` is an ordinary row-major product.
"""

from __future__ import annotations

import math

__all__ = ["BUILDERS", "MULTIPLY_METHODS", "columns_to_rows", "mul"]


def columns_to_rows(cols: list[list[float]]) -> list[list[float]]:
    return [[float(c[r]) for c in cols] for r in range(len(cols))]


def mul(a: list[list[float]], b: list[list[float]]) -> list[list[float]]:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def _rotate(angle: float) -> list[list[float]]:
    """`E1.k0`: rotation about the origin."""
    c, s = math.cos(angle), math.sin(angle)
    return columns_to_rows([[c, s, 0.0], [-s, c, 0.0], [0.0, 0.0, 1.0]])


def _half_turn() -> list[list[float]]:
    """`E1.m0`: the fixed half turn, both axes negated."""
    return columns_to_rows([[-1.0, 0.0, 0.0], [-0.0, -1.0, 0.0], [0.0, 0.0, 1.0]])


def _scale(s: float) -> list[list[float]]:
    """`E1.n0`: uniform scale."""
    return columns_to_rows([[s, 0.0, 0.0], [0.0, s, 0.0], [0.0, 0.0, 1.0]])


def _scale2(sx: float, sy: float) -> list[list[float]]:
    """`E1.o0`: scale per axis."""
    return columns_to_rows([[sx, 0.0, 0.0], [0.0, sy, 0.0], [0.0, 0.0, 1.0]])


def _translate(x: float, y: float) -> list[list[float]]:
    """`E1.t0` and `E1.u0`: translation, from a vec2 or from two numbers."""
    return columns_to_rows([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [float(x), float(y), 1.0]])


def _rotate3(rx: float, ry: float, rz: float) -> list[list[float]]:
    """`E1.l0`: the three axis rotations, composed Z then Y then X.

    The Y factor is reproduced as the app writes it, which is with `-sin(rx)`
    where `-sin(ry)` would make it a rotation -- `neg-float v7, v8` in the
    bytecode negates the register holding the first angle's sine.  Copying the
    app is the point of the bank, so the quirk stays.
    """
    cx, sx = math.cos(rx), math.sin(rx)
    cy, sy = math.cos(ry), math.sin(ry)
    cz, sz = math.cos(rz), math.sin(rz)
    rot_z = columns_to_rows(
        [[cz, sz, 0.0, 0.0], [-sz, cz, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]]
    )
    rot_y = columns_to_rows(
        [[cy, 0.0, sy, 0.0], [0.0, 1.0, 0.0, 0.0], [-sx, 0.0, cy, 0.0], [0.0, 0.0, 0.0, 1.0]]
    )
    rot_x = columns_to_rows(
        [[1.0, 0.0, 0.0, 0.0], [0.0, cx, sx, 0.0], [0.0, -sx, cx, 0.0], [0.0, 0.0, 0.0, 1.0]]
    )
    return mul(mul(rot_z, rot_y), rot_x)


def _translate_vec(t) -> list[list[float]] | None:
    if isinstance(t, (list, tuple)) and len(t) >= 2:
        return _translate(t[0], t[1])
    return None


# Builder name -> (arity, function).  An arity of 1 with a vector argument is
# `t0`, which takes the translation as a single vec2.
BUILDERS = {
    "k0": (1, _rotate),
    "l0": (3, _rotate3),
    "m0": (0, _half_turn),
    "n0": (1, _scale),
    "o0": (2, _scale2),
    "t0": (1, _translate_vec),
    "u0": (2, _translate),
}

# `E2.e.b(m)` and `E2.f.c(m)` are both the matrix product.
MULTIPLY_METHODS = {"b", "c"}


def build(name: str, values: list) -> list[list[float]] | None:
    """Apply a builder by name, or None if the arguments do not fit."""
    entry = BUILDERS.get(name)
    if entry is None:
        return None
    arity, fn = entry
    if len(values) != arity:
        return None
    if name == "t0":
        return fn(values[0])
    if any(not isinstance(v, (int, float)) for v in values):
        return None
    return fn(*(float(v) for v in values))
