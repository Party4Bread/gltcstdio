"""Headless OpenGL backend.

Assembles a complete fragment shader from the extracted GLSL and renders one
filter over one image.

The app's shaders call their inputs through placeholder macros -- `__source__`
for a normal sample and `__name__texelFetch__` for an unfiltered lookup --
which the engine rewrites per node in its render graph.  We rewrite them to
plain sampler reads here.

GL contexts are not thread-safe.  A `Renderer` owns one context and must be
used from the thread that created it; the editor's own server pins one to a worker.
"""

from __future__ import annotations

import os
import re
from pathlib import Path

import numpy as np

from ..bank import Bank, load_bank
from ..params import Filter, array_spec
from .derived import DERIVED

GL_VERSION = "#version 330 core"

VERTEX = """#version 330 core
in vec2 a_pos;
out vec2 v_uv;
void main() {
    v_uv = a_pos * 0.5 + 0.5;
    gl_Position = vec4(a_pos, 0.0, 1.0);
}
"""

# `__name__texelFetch__(...)` must be matched before the plain `__name__` form.
TEXEL_RE = re.compile(r"__([A-Za-z0-9]+)__texelFetch__")
SAMPLE_RE = re.compile(r"__([A-Za-z0-9]+)__")

# Placeholder names that resolve to the single input image.
PRIMARY = {"source", "source1"}

# The engine works in a world coordinate rather than the texture's [0,1], and
# the APK says exactly which one.  Its vertex shader passes the attribute
# through untouched:
#
#     v_OutCoordinate = a_OutCoordinate;
#     gl_Position     = a_Position;
#
# and the draw call fills both from one quad, `a_Position` spanning the clip
# cube corner to corner and `a_OutCoordinate` taking its x scaled by the
# output aspect ratio:
#
#     c(-1, -1, 1, 1, positionAttr, outCoordAttr, aspect)
#     fArr2[i*2]     = fArr[i*3] * aspect      // out coordinate x
#     fArr2[i*2 + 1] = fArr[i*3 + 1]           // out coordinate y
#
# So the coordinate spans two units in y and two aspect-scaled units in x.
# The source macros below divide the aspect back out and map to [0, 1], which
# is the diagonal `<source>Transform` the engine uploads, so sampling is
# unaffected and `identity` stays pixel-for-pixel.
WORLD = 2.0
# Always present, so the macros can undo the aspect whatever the filter reads.
ASPECT = "u_worldAspect"

# GL_MIRRORED_REPEAT in the shader, for the inputs the app sets it on.
MIRROR_WRAP = (
    "vec2 __mirror_wrap__(vec2 c) {\n"
    "    return 1.0 - abs(mod(c, 2.0) - 1.0);\n"
    "}"
)


class ShaderError(RuntimeError):
    """A filter's shader failed to compile or link."""


def _uniform(name: str) -> str:
    return f"u_{name}"


class Renderer:
    """Renders filters from a bank on a headless GL context."""

    def __init__(self, bank: Bank | None = None, backend: str = "egl"):
        self.bank = bank or load_bank()
        self._ctx = _make_context(backend)
        self._stdlib = self.bank.stdlib
        self._programs: dict[str, object] = {}
        self._quad = self._ctx.buffer(
            np.array([-1, -1, 3, -1, -1, 3], dtype="f4").tobytes()
        )
        # Allocating a framebuffer, a vertex array and the input textures is
        # most of the cost of a small render, and none of them depend on
        # anything but the sizes involved, so they are kept between calls.
        self._fbos: dict[tuple[int, int], object] = {}
        self._vaos: dict[int, object] = {}
        self._tex_pool: dict[tuple[int, int], list] = {}

    def _framebuffer(self, size: tuple[int, int]):
        fbo = self._fbos.get(size)
        if fbo is None:
            fbo = self._fbos[size] = self._ctx.simple_framebuffer(
                size, components=4
            )
        return fbo

    def _vertex_array(self, prog):
        vao = self._vaos.get(id(prog))
        if vao is None:
            vao = self._vaos[id(prog)] = self._ctx.vertex_array(
                prog, [(self._quad, "2f", "a_pos")]
            )
        return vao

    def _texture(self, arr: np.ndarray, taken: dict):
        """A texture holding `arr`, reused from the pool for its size.

        `taken` counts how many textures of each size this render has already
        claimed, so two different inputs never land on the same object.
        """
        if arr.dtype != np.uint8:
            arr = arr.astype(np.uint8)
        arr = np.ascontiguousarray(arr)
        th, tw = arr.shape[:2]
        pool = self._tex_pool.setdefault((tw, th), [])
        index = taken.get((tw, th), 0)
        taken[(tw, th)] = index + 1
        if index == len(pool):
            t = self._ctx.texture((tw, th), 4, arr.tobytes())
            t.repeat_x = t.repeat_y = False
            t.filter = (0x2703, 0x2601)  # LINEAR_MIPMAP_LINEAR, LINEAR
            pool.append(t)
        else:
            t = pool[index]
            t.write(arr.tobytes())
        t.build_mipmaps()
        return t

    # -- shader assembly ----------------------------------------------------
    def build_source(self, f: Filter) -> str:
        body = _fix_array_return(_fix_reversed_clamp(self.bank.glsl(f.id)))

        # A filter may ship its own version of a support-library function.
        # Two definitions of one name is a link error, so the filter's wins:
        # drop the library body and keep its prototype.
        # GLSL permits overloading, so only an identical parameter list is a
        # redefinition; a differing one is a legitimate overload to keep.
        stdlib = self._stdlib
        for name, sig in _defined_functions(body).items():
            if _defined_functions(stdlib).get(name) == sig:
                stdlib = _strip_function(stdlib, name)

        samplers = self._samplers(f)

        decls = [f"uniform float {ASPECT};"]
        decls += [f"uniform sampler2D {_uniform(s)};" for s in samplers]
        for u in f.runtime:
            decls.append(f"uniform {u['type']} {_uniform(u['name'])};")
        for p in f.params:
            arr = array_spec(p.type)
            if arr is not None:
                elem, length = arr
                decls.append(f"uniform {elem} {_uniform(p.name)}[{length}];")
            else:
                decls.append(f"uniform {p.type} {_uniform(p.name)};")

        macros = []
        for s in samplers:
            macros.append(
                f"#define __{s}__texelFetch__(c) texelFetch({_uniform(s)}, (c), 0)"
            )
            coord = f"(vec2((p).x / {ASPECT}, (p).y) / {WORLD} + 0.5)"
            if f.wrap.get(s) == "mirrored_repeat" or f.wrap.get("source") == "mirrored_repeat":
                # moderngl's textures only offer clamp or plain repeat, so the
                # app's mirrored repeat is folded into the lookup instead.
                coord = f"__mirror_wrap__{coord}"
            macros.append(f"#define __{s}__(p) texture({_uniform(s)}, {coord})")

        # The app calls each filter as
        #   f((inverse(viewTransform) * vec3(v_OutCoordinate,1)).xy,
        #     v_OutCoordinate, <parameters...>)
        # so both implicit arguments come from the same varying, and the first
        # is pre-multiplied by the inverse view transform when the filter
        # declares one.  The varying spans WORLD units rather than [0,1]; the
        # __source__ macros map back, so sampling is unaffected.
        # The engine wraps every filter, not only the ones that declare the
        # parameter, so the view transform is always applied.  `xor-patterns`
        # has no transform of its own and is zoomed entirely through this one.
        world_uv = f"((v_uv - 0.5) * {WORLD} * vec2({ASPECT}, 1.0))"
        uv_expr = f"(inverse({_uniform('viewTransform')}) * vec3({world_uv}, 1.0)).xy"

        # A few older "raw" shaders were written against the engine's earlier
        # uniform convention (u_Source, u_SourceDim, u_SourceTransform) rather
        # than the __source__ placeholder, so declare those on demand.
        legacy = _legacy_uniforms(body, decls)
        decls.extend(legacy.values())

        args = []
        seen_implicit = 0
        for entry in f.signature_args():
            if entry["kind"] == "implicit":
                # Both implicit arguments come from the same varying, and
                # which one gets the view transform is decided by position,
                # not by name -- the app writes the call as
                #   f((inverse(viewTransform) * vec3(v_OutCoordinate, 1)).xy,
                #     v_OutCoordinate, ...)
                # and most filters name that first argument `pos`, not `uv`.
                args.append(uv_expr if seen_implicit == 0 else world_uv)
                seen_implicit += 1
            else:
                args.append(_uniform(entry["name"]))

        call = f"{f.function}({', '.join(args)})"
        return "\n".join(
            [
                GL_VERSION,
                "precision highp float;",
                "in vec2 v_uv;",
                "out vec4 fragColor;",
                "",
                MIRROR_WRAP,
                "",
                *decls,
                "",
                stdlib,
                "",
                *macros,
                "",
                # A constant the filter declares can appear in a prototype's
                # parameter types -- the hyperbolic filters size their arrays
                # `vec2[MAX_POLY_SIDES]` -- so it has to be declared first.
                *_body_constants(body),
                "",
                *_body_prototypes(body),
                "",
                _drop_body_constants(body),
                "",
                "void main() {",
                f"    fragColor = {call};",
                "}",
                "",
            ]
        )

    def program(self, f: Filter):
        prog = self._programs.get(f.id)
        if prog is not None:
            return prog
        source = self.build_source(f)
        try:
            prog = self._ctx.program(vertex_shader=VERTEX, fragment_shader=source)
        except Exception as exc:  # moderngl raises a generic Error
            raise ShaderError(f"{f.id}: {exc}") from exc
        self._programs[f.id] = prog
        return prog

    # -- rendering ----------------------------------------------------------
    def render(
        self,
        filter_id: str,
        image: np.ndarray,
        values: dict | None = None,
        preset: str | None = None,
        size: tuple[int, int] | None = None,
        inputs: dict[str, np.ndarray] | None = None,
        **overrides,
    ) -> np.ndarray:
        """Render `image` (HxWx4 uint8) through a filter, returning HxWx4.

        `inputs` supplies the secondary images some filters read -- `source2`,
        `sourceBkg`, `sourceElevation`, `displacement` and friends.  Any input
        a filter wants but the caller did not provide falls back to the primary
        image, which keeps every filter renderable and is a sensible default
        for the combine-style filters that blend an image with itself.
        """
        f = self.bank.get(filter_id)
        if values is None:
            values = f.resolve(preset=preset, **overrides)

        h, w = image.shape[:2]
        out_w, out_h = size or (w, h)
        supplied = dict(inputs or {})

        prog = self.program(f)
        textures: dict[str, object] = {}
        dims: dict[str, tuple[int, int]] = {}
        taken: dict[tuple[int, int], int] = {}

        def texture_for(name: str):
            """One texture per distinct input, reusing the primary by default."""
            key = name if name in supplied else "__primary__"
            if key not in textures:
                arr = supplied.get(name, image)
                textures[key] = self._texture(arr, taken)
                dims[key] = (arr.shape[1], arr.shape[0])
            dims[name] = dims[key]
            return textures[key]

        unit = 0
        for name in self._samplers(f):
            uni = prog.get(_uniform(name), None)
            if uni is None:
                continue  # optimised out because the shader never samples it
            texture_for(name).use(unit)
            uni.value = unit
            unit += 1

        # Legacy-convention samplers all read the primary image.
        for name, gl_type in LEGACY_UNIFORMS.items():
            uni = prog.get(name, None)
            if uni is None:
                continue
            if gl_type == "sampler2D":
                texture_for("source").use(unit)
                uni.value = unit
                unit += 1
            elif gl_type == "vec2":
                uni.value = (float(w), float(h))
            elif gl_type == "float":
                uni.value = 0.0
            elif name == "u_SourceTransform":
                # Not identity.  The coordinate these shaders are handed spans
                # world units -- `(v_uv - 0.5) * WORLD * vec2(aspect, 1)` --
                # and they sample with `texture(u_Source, u_SourceTransform *
                # vec3(uv, 1))`, so this uniform is the way back to texture
                # space: the same map the `__source__` macros apply.  Left as
                # the identity they sampled at world coordinates directly,
                # which translates the image by half a frame instead of
                # blurring it, and `gaussian-blurv` at radius 0 came back a
                # mean 31/255 from its input rather than untouched.
                aspect = out_w / out_h if out_h else 1.0
                sx, sy = 1.0 / (WORLD * aspect), 1.0 / WORLD
                # Column-major, as GL takes a mat3.
                uni.value = (sx, 0.0, 0.0, 0.0, sy, 0.0, 0.5, 0.5, 1.0)
            elif gl_type == "mat3":
                uni.value = (1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)

        self._set_uniforms(
            prog, f, values, (w, h), (out_w, out_h), dims, set(supplied)
        )

        fbo = self._framebuffer((out_w, out_h))
        fbo.use()
        fbo.clear(0.0, 0.0, 0.0, 0.0)
        self._vertex_array(prog).render(mode=0x0004, vertices=3)  # GL_TRIANGLES

        data = fbo.read(components=4, dtype="f1")
        out = np.frombuffer(data, dtype=np.uint8).reshape(out_h, out_w, 4)
        # No vertical flip: the framebuffer's first row is its bottom, which is
        # where v_uv.y == 0 lands, and v == 0 samples the texture's first row --
        # the top of the source image.  The two inversions already cancel.
        return out.copy()

    def _samplers(self, f: Filter) -> list[str]:
        body = self.bank.glsl(f.id)
        return sorted(set(TEXEL_RE.findall(body)) | set(SAMPLE_RE.findall(body)))

    def _set_uniforms(
        self,
        prog,
        f: Filter,
        values: dict,
        in_dim,
        out_dim,
        dims: dict[str, tuple[int, int]] | None = None,
        supplied: set[str] | None = None,
    ) -> None:
        w, h = in_dim
        ow, oh = out_dim
        dims = dims or {}
        supplied = supplied or set()

        for u in f.runtime:
            name = u["name"]
            uni = prog.get(_uniform(name), None)
            if uni is None:
                continue
            if name.endswith("_specified"):
                # Every input is bound to something -- its own image when the
                # caller gave one, the primary image otherwise -- so the shader
                # may always read it.
                uni.value = 1
            elif name.endswith("Dim"):
                base = name.removesuffix("Dim")
                if base == "out":
                    uni.value = (float(ow), float(oh))
                else:
                    tw, th = dims.get(base, (w, h))
                    uni.value = (float(tw), float(th))
            elif name == "outAspectRatio":
                uni.value = ow / oh if oh else 1.0
            elif name in ("aspectRatio", "pixelAspectRatio"):
                uni.value = w / h if h else 1.0

        # The world coordinate's x is aspect-scaled, exactly as the engine
        # fills `a_OutCoordinate`.
        uni = prog.get(ASPECT, None)
        if uni is not None:
            uni.value = ow / oh if oh else 1.0

        # outDim is named for the output, not an input.
        uni = prog.get("u_outDim", None)
        if uni is not None:
            uni.value = (float(ow), float(oh))

        # A few filters have the app compute a uniform in Java from the other
        # parameters rather than read it from one; `metaballs-gl` builds its
        # sphere array that way and renders nothing without it.
        derive = DERIVED.get(f.function)
        computed = {}
        if derive is not None:
            settings = {p.name: values.get(p.name, p.default) for p in f.params}
            settings.update(values)
            computed = derive(settings)

        for p in f.params:
            uni = prog.get(_uniform(p.name), None)
            if uni is None:
                continue  # optimised out because the shader never reads it
            val = computed.get(p.name, values.get(p.name, p.default))
            packed = _pack(p.type, val)
            if array_spec(p.type) is not None:
                import array as _array

                elem = array_spec(p.type)[0]
                code = "i" if elem == "int" else "f"
                uni.write(_array.array(code, packed).tobytes())
            else:
                uni.value = packed

    def make_current(self) -> None:
        """Make this renderer's context the active one.

        Two standalone contexts in one process quietly fight over which is
        current, and the loser's renders come back stale.  Prefer
        `get_renderer()` so a process has only one; this is the guard for code
        that constructs its own anyway.
        """
        try:
            self._ctx.__enter__()
        except Exception:  # noqa: BLE001 - not all backends support this
            pass

    def release(self) -> None:
        for cache in (self._vaos, self._fbos):
            for obj in cache.values():
                obj.release()
            cache.clear()
        for pool in self._tex_pool.values():
            for t in pool:
                t.release()
        self._tex_pool.clear()
        for prog in self._programs.values():
            prog.release()
        self._programs.clear()
        self._quad.release()
        self._ctx.release()


# Engine uniforms from the older shader convention, with the type each holds.
LEGACY_UNIFORMS = {
    "u_Source": "sampler2D",
    "u_SourceDim": "vec2",
    "u_SourceTransform": "mat3",
    "u_InverseModelTransform": "mat3",
    "u_ModelTransform": "mat3",
    "u_Tex0": "sampler2D",
    "u_Tex1": "sampler2D",
    "u_Tex0Dim": "vec2",
    "u_Tex1Dim": "vec2",
    "u_Tex0Transform": "mat3",
    "u_Tex1Transform": "mat3",
    # Shadertoy-style names a couple of ported shaders still use.
    "iChannel0": "sampler2D",
    "iChannel1": "sampler2D",
    "iResolution": "vec2",
    "iTime": "float",
}

_IDENT_RE = re.compile(r"\b(?:u_[A-Za-z]\w*|iChannel\d|iResolution|iTime)\b")


def _legacy_uniforms(body: str, decls: list[str]) -> dict[str, str]:
    """Declarations for legacy uniforms a shader reads but nothing declares."""
    declared = {d.rsplit(" ", 1)[-1].rstrip(";") for d in decls}
    out: dict[str, str] = {}
    for name in sorted(set(_IDENT_RE.findall(body))):
        if name in declared or name in out:
            continue
        gl_type = LEGACY_UNIFORMS.get(name)
        if gl_type is None:
            continue
        out[name] = f"uniform {gl_type} {name};"
    return out


_GL_TYPES = (
    r"(?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234](?:x[234])?)"
)
_DEF_RE = re.compile(rf"^\s*{_GL_TYPES}\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*\{{", re.M)


def _param_types(params: str) -> tuple[str, ...]:
    out = []
    for raw in params.split(","):
        toks = [
            t
            for t in raw.split()
            if t not in ("in", "out", "inout", "const", "highp", "mediump", "lowp")
        ]
        if len(toks) >= 2:
            out.append(toks[-2])
    return tuple(out)


_STRUCT_DEF_RE = re.compile(r"^\s*struct\s+(\w+)\s*\{", re.M)
_ANY_DEF_RE = re.compile(
    r"^[ \t]*((?:void|bool|int|uint|float|double|[ibud]?vec[234]|mat[234](?:x[234])?|[A-Z]\w*)"
    r"\s+[A-Za-z_]\w*\s*\([^)]*\))\s*\{",
    re.M,
)


_BODY_CONST_RE = re.compile(
    r"^const\s+(?:int|uint|float|bool)\s+([A-Za-z_]\w*)\s*=\s*[^;]+;", re.M
)


def _body_constants(body: str) -> list[str]:
    """Top-level `const` declarations, so they precede the prototypes.

    The declaration stays in the body as well; GLSL allows a constant to be
    declared once, so the copy here is the one that is kept and the original
    is blanked out.
    """
    return list(dict.fromkeys(m.group(0) for m in _BODY_CONST_RE.finditer(body)))


def _drop_body_constants(body: str) -> str:
    """The body with the constants `_body_constants` hoisted removed."""
    return _BODY_CONST_RE.sub("", body)


def _body_prototypes(body: str) -> list[str]:
    """Forward declarations for every function the filter defines.

    A filter's helpers are emitted in whatever order they were recovered, and
    one may call another defined further down; prototypes make that legal
    without reordering anything.
    """
    structs = set(_STRUCT_DEF_RE.findall(body))
    protos, seen = [], set()
    for m in _ANY_DEF_RE.finditer(body):
        sig = " ".join(m.group(1).split())
        name = sig.split("(", 1)[0].split()[-1]
        ret = sig.split()[0]
        if name in seen or name in ("if", "for", "while", "switch", "else"):
            continue
        # A struct return type must already be declared; it is, since struct
        # definitions stay inside the body above their users.
        if ret in structs:
            continue
        seen.add(name)
        protos.append(sig + ";")
    return protos


def _defined_functions(text: str) -> dict[str, tuple[str, ...]]:
    """Function name -> parameter type list, for redefinition checks."""
    return {m.group(1): _param_types(m.group(2)) for m in _DEF_RE.finditer(text)}


def _strip_function(text: str, name: str) -> str:
    """Remove a function definition, leaving any prototype in place."""
    m = re.search(rf"^[ \t]*{_GL_TYPES}\s+{re.escape(name)}\s*\([^)]*\)\s*\{{", text, re.M)
    if not m:
        return text
    depth, i = 0, m.end() - 1
    while i < len(text):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    return text[: m.start()] + text[i + 1 :]


_NUMBER_RE = re.compile(r"^[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?$")


def _split_top(text: str) -> list[str]:
    """Split a call's argument list on the commas that are not nested."""
    args, depth, start = [], 0, 0
    for i, ch in enumerate(text):
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
        elif ch == "," and depth == 0:
            args.append(text[start:i])
            start = i + 1
    args.append(text[start:])
    return args


_ARRAY_RETURN_RE = re.compile(
    rf"^([ \t]*)({_GL_TYPES})\s+(\w+)\s*\(([^)]*)\)\s*\[\s*(\w+)\s*\]\s*(?=\{{)",
    re.M,
)


def _fix_array_return(text: str) -> str:
    """Move an array size from after the parameter list onto the return type.

    The app compiles against GLSL ES 1.00, where a function returning an array
    is written `vec2 f(...)[12]`.  Core 3.30 spells the same declaration
    `vec2[12] f(...)`, and the old form made the parser drop the definition --
    `hyper-kaleidoscopeios` then reported its own `invert` as not a function.
    """
    return _ARRAY_RETURN_RE.sub(r"\1\2[\5] \3(\4) ", text)


def _fix_reversed_clamp(text: str) -> str:
    """Reorder the app's `clamp(lo, hi, x)` calls into GLSL's `clamp(x, lo, hi)`.

    58 of the extracted shaders call clamp with the bounds first, which is
    another language's argument order -- GLSL's builtin is
    `clamp(x, minVal, maxVal)`, so those calls read as x=lo, minVal=hi,
    maxVal=x.  The spec leaves the result undefined when minVal > maxVal, and
    this driver resolves it to a constant: `cathodic-ray` returns solid white
    on every pixel instead of its scanlines.  The app's own GLES driver
    evidently resolves it the other way, which is why the app looks right.

    Only the unambiguous shape is touched -- two numeric literals in
    non-decreasing order followed by a non-literal.  A correctly written
    `clamp(x, 0.0, 1.0)` has an expression first and is left alone.
    """
    out, i = [], 0
    while True:
        m = re.compile(r"\bclamp\s*\(").search(text, i)
        if not m:
            out.append(text[i:])
            return "".join(out)
        depth, j = 1, m.end()
        while j < len(text) and depth:
            depth += (text[j] == "(") - (text[j] == ")")
            j += 1
        args = [a.strip() for a in _split_top(text[m.end() : j - 1])]
        out.append(text[i : m.start()])
        rewritten = None
        if len(args) == 3 and not _NUMBER_RE.match(args[2]):
            if _NUMBER_RE.match(args[0]) and _NUMBER_RE.match(args[1]):
                if float(args[0]) <= float(args[1]):
                    rewritten = f"clamp({args[2]}, {args[0]}, {args[1]})"
        out.append(rewritten if rewritten else text[m.start() : j])
        i = j


def _pack(gl_type: str, value):
    arr = array_spec(gl_type)
    if arr is not None:
        # moderngl writes array uniforms from one flat sequence.
        elem, _length = arr
        flat: list = []
        for item in value:
            if isinstance(item, (list, tuple)):
                flat.extend(float(x) for x in item)
            elif elem == "int":
                flat.append(int(item))
            else:
                flat.append(float(item))
        return flat
    if gl_type in ("float",):
        return float(value)
    if gl_type == "int":
        return int(value)
    if gl_type == "bool":
        return bool(value)
    if gl_type in ("vec2", "vec3", "vec4"):
        return tuple(float(x) for x in value)
    if gl_type in ("mat3", "mat4"):
        # Stored row-major; GL expects column-major.
        rows = value
        n = len(rows)
        return tuple(float(rows[r][c]) for c in range(n) for r in range(n))
    raise ValueError(f"cannot pack {gl_type}")


_shared: "Renderer | None" = None


def get_renderer(bank: Bank | None = None) -> Renderer:
    """The process-wide renderer.

    A GL context belongs to one thread and only one context is current at a
    time, so sharing a single renderer is both cheaper (programs stay
    compiled) and safer than letting each caller make its own.
    """
    global _shared
    if _shared is None:
        _shared = Renderer(bank)
    return _shared


def _make_context(backend: str):
    import moderngl

    # A standalone context must not try to open the user's X display.
    saved = {k: os.environ.pop(k, None) for k in ("DISPLAY", "WAYLAND_DISPLAY")}
    try:
        try:
            return moderngl.create_context(standalone=True, require=330, backend=backend)
        except Exception:
            return moderngl.create_context(standalone=True, require=330)
    finally:
        for k, v in saved.items():
            if v is not None:
                os.environ[k] = v
