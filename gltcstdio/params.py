"""Parameter specifications and value coercion."""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any

Scalar = float | int | bool | str
Value = Scalar | list


class ParamError(ValueError):
    """A parameter value could not be coerced to the shader's type."""


VECTOR_WIDTH = {"vec2": 2, "vec3": 3, "vec4": 4}

# `vec4[64]` / `int[16]`: a fixed-length uniform array.
ARRAY_TYPE = re.compile(r"^(\w+)\[(\d+)\]$")


def array_spec(gl_type: str) -> tuple[str, int] | None:
    m = ARRAY_TYPE.match(gl_type)
    if not m:
        return None
    return m.group(1), int(m.group(2))


@dataclass(frozen=True)
class ParamSpec:
    """One configurable input of a filter."""

    name: str
    type: str
    label: str
    default: Any = None
    min: float | None = None
    max: float | None = None
    step: float | None = None
    options: list | None = None
    # Labelled enum values, e.g. [{"value": 0, "label": "Dots"}, ...]
    choices: tuple[dict, ...] | None = None
    widget: str = "slider"
    inferred: bool = False
    # Applied by the engine around the shader call rather than passed into
    # it, so it is a real parameter but not a signature argument.
    engine: bool = False

    @classmethod
    def from_dict(cls, d: dict) -> "ParamSpec":
        return cls(
            name=d["name"],
            type=d["type"],
            label=d.get("label", d["name"]),
            default=d.get("default"),
            min=d.get("min"),
            max=d.get("max"),
            step=d.get("step"),
            options=d.get("options"),
            choices=tuple(d["choices"]) if d.get("choices") else None,
            widget=d.get("widget", "slider"),
            inferred=d.get("inferred", False),
            engine=d.get("engine", False),
        )

    # -- coercion -----------------------------------------------------------
    def coerce(self, value: Any) -> Value:
        """Convert a user value to the shader's type, clamping to range."""
        t = self.type
        arr = array_spec(t)
        if arr is not None:
            return self._coerce_array(value, *arr)
        try:
            if t == "float":
                return self._clamp(float(value))
            if t == "int":
                return int(self._clamp(int(value)))
            if t == "bool":
                return bool(value)
            if t == "string":
                return "" if value is None else str(value)
            if t in VECTOR_WIDTH:
                return self._coerce_vector(value, VECTOR_WIDTH[t])
            if t == "mat3":
                return self._coerce_matrix(value, 3)
            if t == "mat4":
                return self._coerce_matrix(value, 4)
        except (TypeError, ValueError) as exc:
            raise ParamError(
                f"{self.name}: cannot coerce {value!r} to {t} ({exc})"
            ) from exc
        raise ParamError(f"{self.name}: unsupported type {t}")

    def _coerce_array(self, value: Any, elem: str, length: int) -> list:
        """A fixed-length uniform array, padded or truncated to fit."""
        if value is None:
            value = []
        items = list(value)
        width = VECTOR_WIDTH.get(elem)
        out: list = []
        for item in items[:length]:
            if width:
                out.append(ParamSpec(self.name, elem, self.label)._coerce_vector(item, width))
            elif elem == "int":
                out.append(int(item))
            else:
                out.append(float(item))
        while len(out) < length:
            if width:
                out.append([0.0] * (width - 1) + [1.0] if width == 4 else [0.0] * width)
            else:
                out.append(0 if elem == "int" else 0.0)
        return out

    def _clamp(self, v: float) -> float:
        if self.min is not None and v < self.min:
            return self.min
        if self.max is not None and v > self.max:
            return self.max
        return v

    def _coerce_vector(self, value: Any, width: int) -> list[float]:
        if isinstance(value, (int, float)) and not isinstance(value, bool):
            return [float(value)] * width
        if isinstance(value, str):
            value = _parse_hex_color(value, width)
        seq = list(value)
        if len(seq) > width:
            raise ParamError(f"{self.name}: expected {width} components, got {len(seq)}")
        out = [float(x) for x in seq]
        while len(out) < width:
            # Alpha defaults to opaque; other components to zero.
            out.append(1.0 if width == 4 and len(out) == 3 else 0.0)
        return out

    def _coerce_matrix(self, value: Any, n: int) -> list[list[float]]:
        rows = list(value)
        if len(rows) == n * n and not isinstance(rows[0], (list, tuple)):
            rows = [rows[i * n : (i + 1) * n] for i in range(n)]
        if len(rows) != n:
            raise ParamError(f"{self.name}: expected a {n}x{n} matrix")
        out = []
        for r in rows:
            r = [float(x) for x in r]
            if len(r) != n:
                raise ParamError(f"{self.name}: expected a {n}x{n} matrix")
            out.append(r)
        return out


def _parse_hex_color(text: str, width: int) -> list[float]:
    s = text.strip().lstrip("#")
    if len(s) not in (3, 4, 6, 8):
        raise ValueError(f"bad hex colour {text!r}")
    if len(s) in (3, 4):
        s = "".join(c * 2 for c in s)
    vals = [int(s[i : i + 2], 16) / 255.0 for i in range(0, len(s), 2)]
    while len(vals) < width:
        vals.append(1.0)
    return vals[:width]


@dataclass(frozen=True)
class Preset:
    name: str
    params: dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_dict(cls, d: dict) -> "Preset":
        return cls(name=d["name"], params=dict(d.get("params", {})))


@dataclass(frozen=True)
class Filter:
    """A single configurable filter."""

    id: str
    name: str
    category: str
    backend: str
    function: str
    params: tuple[ParamSpec, ...]
    presets: tuple[Preset, ...]
    runtime: tuple[dict, ...] = ()
    implicit: tuple[str, ...] = ()
    signature: tuple[dict, ...] = ()
    glsl_path: str | None = None
    supported: bool = True
    unsupported_reason: str | None = None
    inputs: int = 1
    # Named secondary images this filter reads, beyond the primary one.
    extra_inputs: tuple[str, ...] = ()
    # Input name -> texture wrap mode, where the app sets one.  Filters that
    # sample outside the image rely on it; the app's choice is mirrored
    # repeat, not the clamp a texture starts with.
    wrap: dict = field(default_factory=dict)
    # For backend="graph": the node tree, and the filters it chains.
    graph: dict | None = None
    chain: tuple[str, ...] = ()
    # The shader this filter is the app's blur wrapper around, if it is one:
    # the wrapper feeds one of that shader's inputs from a blurred copy of the
    # source and exposes the radius as a parameter of its own.
    wrapped: str | None = None
    # True when the extracted shader was verified to work and so ships in
    # place of a CPU reimplementation of the same name.
    prefer_gl: bool = False
    # How close this filter is to the app's own implementation. GL filters run
    # the extracted shader unmodified ("extracted"); CPU filters are either
    # "recovered" (kernels read from the decompiled source) or
    # "reimplemented" (parameter contract from the app, algorithm rewritten).
    fidelity: str = "extracted"

    @classmethod
    def from_dict(cls, d: dict) -> "Filter":
        return cls(
            id=d["id"],
            name=d.get("name", d["id"]),
            category=d.get("category", "misc"),
            backend=d.get("backend", "gl"),
            function=d.get("function", d["id"]),
            params=tuple(ParamSpec.from_dict(p) for p in d.get("params", [])),
            presets=tuple(Preset.from_dict(p) for p in d.get("presets", [])),
            runtime=tuple(d.get("runtime", [])),
            implicit=tuple(d.get("implicit", [])),
            signature=tuple(d.get("signature", [])),
            glsl_path=d.get("glsl"),
            supported=d.get("supported", True),
            unsupported_reason=d.get("unsupported_reason"),
            inputs=d.get("inputs", 1),
            extra_inputs=tuple(d.get("extra_inputs", [])),
            wrap=dict(d.get("wrap", {})),
            prefer_gl=d.get("prefer_gl", False),
            graph=d.get("graph"),
            chain=tuple(d.get("chain", [])),
            wrapped=d.get("wrapped"),
            fidelity=d.get("fidelity", "extracted"),
        )

    @property
    def param_map(self) -> dict[str, ParamSpec]:
        return {p.name: p for p in self.params}

    def signature_args(self) -> tuple[dict, ...]:
        """Shader arguments in declaration order.

        Falls back to implicit-then-parameter order for bank entries built
        before the signature was recorded.
        """
        if self.signature:
            return self.signature
        return tuple(
            [{"name": n, "kind": "implicit"} for n in self.implicit]
            + [{"name": p.name, "kind": "param"} for p in self.params]
        )

    def preset(self, name: str) -> Preset:
        for p in self.presets:
            if p.name == name:
                return p
        available = ", ".join(p.name for p in self.presets) or "none"
        raise KeyError(f"{self.id}: no preset {name!r} (available: {available})")

    def resolve(self, preset: str | None = None, **overrides) -> dict[str, Value]:
        """Merge defaults, an optional preset, and explicit overrides."""
        specs = self.param_map

        unknown = set(overrides) - set(specs)
        if unknown:
            known = ", ".join(sorted(specs))
            raise ParamError(
                f"{self.id}: unknown parameter(s) {sorted(unknown)}; known: {known}"
            )

        values: dict[str, Value] = {}
        for spec in self.params:
            values[spec.name] = spec.coerce(spec.default)

        if preset is not None:
            for name, raw in self.preset(preset).params.items():
                spec = specs.get(name)
                if spec is None:
                    continue  # preset touches a parameter this build dropped
                values[name] = spec.coerce(raw)

        for name, raw in overrides.items():
            values[name] = specs[name].coerce(raw)

        return values
