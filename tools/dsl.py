"""Parser and evaluator for the pap2 preset DSL.

Presets are stored as small S-expressions naming the filter, its inputs and
its overridden parameters:

    (halftone source1 :style 1 :color1 (rgba 0.0 0.0 0.0 0.0))
    (halftone source1 (mat3-scale-uniform 0.06))

Everything is evaluated at build time, so the runtime never sees the DSL --
only plain parameter dictionaries.
"""

from __future__ import annotations

import math

SOURCE_NAMES = {"source", "source1", "source2", "source3", "mask", "pattern"}


class Sym(str):
    """A bare symbol, distinct from a string value."""


def tokenize(text: str) -> list[str]:
    out: list[str] = []
    i = 0
    while i < len(text):
        ch = text[i]
        if ch in "()":
            out.append(ch)
            i += 1
        elif ch.isspace():
            i += 1
        elif ch == '"':
            j = i + 1
            buf = ['"']
            while j < len(text) and text[j] != '"':
                if text[j] == "\\":
                    buf.append(text[j : j + 2])
                    j += 2
                    continue
                buf.append(text[j])
                j += 1
            buf.append('"')
            out.append("".join(buf))
            i = j + 1
        else:
            j = i
            while j < len(text) and not text[j].isspace() and text[j] not in "()":
                j += 1
            out.append(text[i:j])
            i = j
    return out


def parse(text: str):
    tokens = tokenize(text)
    pos = 0

    def walk():
        nonlocal pos
        if pos >= len(tokens):
            raise ValueError("unexpected end of expression")
        tok = tokens[pos]
        pos += 1
        if tok == "(":
            items = []
            while pos < len(tokens) and tokens[pos] != ")":
                items.append(walk())
            if pos >= len(tokens):
                raise ValueError("unbalanced expression")
            pos += 1  # consume ')'
            return items
        if tok == ")":
            raise ValueError("unexpected ')'")
        return atom(tok)

    tree = walk()
    return tree


def atom(tok: str):
    if tok.startswith('"'):
        return tok[1:-1]
    try:
        if any(c in tok for c in ".eE") and tok not in ("-", "+"):
            return float(tok)
        return int(tok)
    except ValueError:
        pass
    if tok == "true":
        return True
    if tok == "false":
        return False
    return Sym(tok)


# ---------------------------------------------------------------- constructors


def _mat3(a, b, c, d, e, f):
    """Row-major 3x3 affine matrix from the 2x3 components."""
    return [[a, b, c], [d, e, f], [0.0, 0.0, 1.0]]


def c_rgba(*args):
    vals = [float(a) for a in args]
    while len(vals) < 4:
        vals.append(1.0 if len(vals) == 3 else 0.0)
    return vals[:4]


def c_vec(n):
    def build(*args):
        vals = [float(a) for a in args]
        while len(vals) < n:
            vals.append(vals[-1] if vals else 0.0)
        return vals[:n]

    return build


def c_scale_uniform(s=1.0):
    s = float(s)
    return _mat3(s, 0.0, 0.0, 0.0, s, 0.0)


def c_scale(sx=1.0, sy=None):
    sx = float(sx)
    sy = float(sy) if sy is not None else sx
    return _mat3(sx, 0.0, 0.0, 0.0, sy, 0.0)


def c_rotate(a=0.0):
    a = float(a)
    ca, sa = math.cos(a), math.sin(a)
    return _mat3(ca, -sa, 0.0, sa, ca, 0.0)


def c_scale_rotate(sx=1.0, sy=1.0, a=0.0):
    sx, sy, a = float(sx), float(sy), float(a)
    ca, sa = math.cos(a), math.sin(a)
    # rotation applied after scaling
    return _mat3(ca * sx, -sa * sy, 0.0, sa * sx, ca * sy, 0.0)


def _flatten(args) -> list[float]:
    """GLSL matrix constructors accept scalars or column vectors."""
    out: list[float] = []
    for a in args:
        if isinstance(a, (list, tuple)):
            out.extend(float(x) for x in a)
        else:
            out.append(float(a))
    return out


def c_mat3(*args):
    """Raw GLSL mat3(...): nine values in column-major order.

    Stored row-major so that tf(m, u) == m @ [u, 1].
    """
    v = _flatten(args)
    while len(v) < 9:
        v.append(0.0)
    return [[v[0], v[3], v[6]], [v[1], v[4], v[7]], [v[2], v[5], v[8]]]


def c_mat4(*args):
    v = _flatten(args)
    while len(v) < 16:
        v.append(0.0)
    return [[v[c * 4 + r] for c in range(4)] for r in range(4)]


def _product(*args):
    out = 1.0
    for a in args:
        out *= float(a)
    return out


def _quotient(*args):
    out = float(args[0])
    for a in args[1:]:
        d = float(a)
        out = out / d if d else 0.0
    return out


def c_lt2d(translation, scaling, rotation):
    """`lt2d(t, s, r)` -- the DSL's usual way of writing a mat3.

    `d5.C1212d.c()` builds it from the columns

        (s.x*cos, s.x*sin, 0)   (-sin*s.y, cos*s.y, 0)   (t.x, t.y, 1)

    so it scales, rotates and then translates.  Dropping the form cost
    `schema4-boxes` both of its transforms, and without the 0.064 scale on its
    streak stage the pattern is fifteen times too large to show anything.
    """
    cos, sin = math.cos(float(rotation)), math.sin(float(rotation))
    sx, sy = float(scaling[0]), float(scaling[1])
    tx, ty = float(translation[0]), float(translation[1])
    return [
        [sx * cos, -sin * sy, tx],
        [sx * sin, cos * sy, ty],
        [0.0, 0.0, 1.0],
    ]


def c_lt3d(translation, scaling, rotation):
    """`lt3d(t, s, r)` -- the mat4 form, from `d5.C1213e.b()`.

    It is `T * S * R` with `R` the XYZ Euler rotation the method spells out
    row by row.  The angles pass through a degree round trip there
    (`* 57.29578` then `* 0.017453292`) that cancels, so they are radians.
    """
    tx, ty, tz = (float(x) for x in translation[:3])
    sx, sy, sz = (float(x) for x in scaling[:3])
    rx, ry, rz = (float(x) for x in rotation[:3])
    cx, cy, cz = math.cos(rx), math.cos(ry), math.cos(rz)
    snx, sny, snz = math.sin(rx), math.sin(ry), math.sin(rz)
    rot = [
        [cy * cz, snx * sny * cz - cx * snz, cx * sny * cz + snx * snz, 0.0],
        [cy * snz, snx * sny * snz + cx * cz, cx * sny * snz - snx * cz, 0.0],
        [-sny, snx * cy, cx * cy, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]
    scale = [
        [sx, 0.0, 0.0, 0.0],
        [0.0, sy, 0.0, 0.0],
        [0.0, 0.0, sz, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]
    move = [
        [1.0, 0.0, 0.0, tx],
        [0.0, 1.0, 0.0, ty],
        [0.0, 0.0, 1.0, tz],
        [0.0, 0.0, 0.0, 1.0],
    ]

    def mul(a, b):
        return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]

    return mul(mul(move, scale), rot)


CONSTRUCTORS = {
    "lt2d": c_lt2d,
    "lt3d": c_lt3d,
    "mat3": c_mat3,
    "mat4": c_mat4,
    "rgba": c_rgba,
    "vec2": c_vec(2),
    "vec3": c_vec(3),
    "vec4": c_vec(4),
    "mat3-scale-uniform": c_scale_uniform,
    "mat3-scale": c_scale,
    "mat3-rotate": c_rotate,
    "mat3-scale-rotate": c_scale_rotate,
    "+": lambda *a: sum(float(x) for x in a),
    "-": lambda *a: (float(a[0]) - sum(float(x) for x in a[1:])) if len(a) > 1 else -float(a[0]),
    "*": _product,
    "/": _quotient,
    "min": lambda *a: min(float(x) for x in a),
    "max": lambda *a: max(float(x) for x in a),
    "neg": lambda a: -float(a),
}


# The six per-channel weights, written as keyword arguments rather than
# positionally.  The engine packs them into one base-9 integer
# (`I(luminance)*59049 + ... + I(red)` in `V4.C0606p3`), which the bank
# already decodes; carrying the weights straight through skips that round
# trip, which cannot represent every value the presets use.
CHANNEL_FORMS = {"six-color-channels", "six-color-float-channels"}
CHANNEL_NAMES = ("red", "green", "blue", "hue", "saturation", "luminance")


def _channel_weights(args, env) -> dict:
    """`(six-color-float-channels :red 3.0 :green 0.0 ...)` -> the weights."""
    out = {name: 1.0 for name in CHANNEL_NAMES}
    i = 0
    while i < len(args) - 1:
        key = args[i]
        if isinstance(key, Sym) and str(key).startswith(":"):
            name = str(key)[1:]
            if name in out:
                value = evaluate(args[i + 1], env)
                if isinstance(value, (int, float)):
                    out[name] = float(value)
            i += 2
            continue
        i += 1
    return {f"channels_{k}": v for k, v in out.items()}


class Unsupported(Exception):
    """A DSL form we deliberately do not evaluate at build time."""


def evaluate(node, env: dict | None = None):
    """Evaluate a DSL form.

    `env` binds the free symbols a graph expression may reference -- its
    exposed parameters, e.g. `(mat3 (vec3 scale 0 0) ... (vec3 tx ty 1))`.
    """
    if isinstance(node, list):
        if not node:
            raise Unsupported("empty form")
        head = node[0]
        if not isinstance(head, Sym):
            raise Unsupported(f"non-symbol head {head!r}")
        if str(head) in CHANNEL_FORMS:
            return _channel_weights(node[1:], env)
        fn = CONSTRUCTORS.get(str(head))
        if fn is None:
            raise Unsupported(str(head))
        args = [evaluate(a, env) for a in node[1:]]
        return fn(*args)
    if isinstance(node, Sym):
        if env is not None and str(node) in env:
            return env[str(node)]
        raise Unsupported(f"symbol {node!r}")
    return node


def free_symbols(node, out: set | None = None) -> set:
    """Symbols an expression reads but does not construct."""
    out = set() if out is None else out
    if isinstance(node, list):
        for a in node[1:]:
            free_symbols(a, out)
    elif isinstance(node, Sym):
        out.add(str(node))
    return out


def parse_preset(expr: str) -> tuple[str, dict, list[str], list]:
    """Return (operator, params, sources, positional_values).

    Raises ValueError for malformed expressions and leaves unsupported
    parameter values out of `params` (reported via the caller).
    """
    tree = parse(expr)
    if not isinstance(tree, list) or not tree:
        raise ValueError("preset is not a form")
    op = str(tree[0])
    params: dict = {}
    sources: list[str] = []
    positional: list = []

    i = 1
    while i < len(tree):
        item = tree[i]
        if isinstance(item, Sym) and str(item).startswith(":"):
            key = str(item)[1:]
            if i + 1 >= len(tree):
                raise ValueError(f"keyword {key} has no value")
            value = tree[i + 1]
            # `:source2 source1` binds an input, not a parameter value.
            if isinstance(value, Sym) and str(value) in SOURCE_NAMES:
                sources.append(str(value))
            else:
                params[key] = evaluate(value)
            i += 2
            continue
        if isinstance(item, Sym) and str(item) in SOURCE_NAMES:
            sources.append(str(item))
            i += 1
            continue
        positional.append(evaluate(item))
        i += 1

    return op, params, sources, positional
