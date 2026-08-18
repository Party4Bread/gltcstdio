"""Assemble the shipped filter bank from the intermediate extraction outputs.

Joins:
  work/shaders.json  -- GLSL and authoritative parameter names/types
  work/params.json   -- ranges, defaults and display labels, keyed by name
  work/presets.json  -- evaluated preset parameter dictionaries

into gltcstdio/data/bank.json plus one .glsl file per filter.

Where the registry has no entry for a parameter, a type-appropriate default is
synthesised so the UI always has something sane to render.  Such parameters are
marked `"inferred": true` rather than silently presented as extracted fact.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from gltcstdio.graph import (  # noqa: E402
    PRIMARY_INPUTS,
    bound_targets,
    forwarded_filters,
    graph_filters,
    graph_params,
)

BANK_VERSION = 1

VECTOR_WIDTH = {"vec2": 2, "vec3": 3, "vec4": 4}

# `__curveLut__texelFetch__(c)` / `__source2__(p)` -- how a shader names the
# images it samples.
SAMPLER_RE = re.compile(r"__(\w+?)__(?:texelFetch__)?\s*\(")

# Shader entry point -> the parameters its filter reads from the environment
# to build a uniform in Java, with the defaults the app reads them at.  These
# are not in the GLSL signature, so nothing else would surface them; see
# `gltcstdio/backends/derived.py` for the matching generator.
DRIVING_PARAMS = {
    "metaballs3d": [
        {"name": "count", "gl_type": "int", "default": 6, "min": 1, "max": 27},
        {"name": "radius", "gl_type": "float", "default": 0.7, "min": 0.0, "max": 2.0},
        {"name": "regularity", "gl_type": "float", "default": 0.0, "min": 0.0, "max": 1.0},
        {"name": "randomSeed", "gl_type": "float", "default": 0.0, "min": 0.0, "max": 100.0},
    ],
}
DRIVING_PARAMS["metaballsGl"] = DRIVING_PARAMS["metaballs3d"]
DRIVING_PARAMS["spheres"] = [
    {"name": "count", "gl_type": "int", "default": 8, "min": 1, "max": 32},
    {"name": "radius", "gl_type": "float", "default": 0.3, "min": 0.0, "max": 2.0},
    {"name": "regularity", "gl_type": "float", "default": 1.0, "min": 0.0, "max": 1.0},
    {"name": "randomSeed", "gl_type": "float", "default": 0.0, "min": 0.0, "max": 100.0},
]
DRIVING_PARAMS["spheresGl"] = DRIVING_PARAMS["spheres"]

TYPE_DEFAULTS: dict[str, dict] = {
    "float": {"default": 0.0, "min": 0.0, "max": 1.0},
    "int": {"default": 0, "min": 0, "max": 8},
    "bool": {"default": False},
    "vec2": {"default": [0.0, 0.0], "min": -1.0, "max": 1.0},
    "vec3": {"default": [0.0, 0.0, 0.0], "min": 0.0, "max": 1.0},
    "vec4": {"default": [0.0, 0.0, 0.0, 1.0]},
    "mat3": {"default": [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]},
    "mat4": {"default": [[1.0 if i == j else 0.0 for j in range(4)] for i in range(4)]},
}

# vec4 parameters whose name marks them as colours get a colour widget.
COLOR_HINT = re.compile(r"colou?r|tint|bkg|background|fg|foreground", re.I)

# Uniforms the engine supplies from the image and the bound inputs rather than
# from user configuration:
#   <input>Dim         vec2  pixel dimensions of that input
#   <input>_specified  int   1 when that input is bound, 0 otherwise
#   *aspectRatio       float derived from the image
# Exposing these as sliders would both clutter the UI and break the shaders,
# which depend on them holding true values.
RUNTIME_UNIFORM = re.compile(
    r"(?:^|.)(?:Dim|_specified)$|^(?:aspectRatio|outAspectRatio|pixelAspectRatio)$"
)


def is_runtime_uniform(name: str) -> bool:
    return bool(
        name.endswith("Dim")
        or name.endswith("_specified")
        or name in ("aspectRatio", "outAspectRatio", "pixelAspectRatio")
    )


def prettify(name: str) -> str:
    spaced = re.sub(r"(?<!^)(?=[A-Z])", " ", name)
    return spaced[:1].upper() + spaced[1:]


def widget_for(gl_type: str, name: str, spec: dict) -> str:
    if gl_type == "vec4":
        return "color" if COLOR_HINT.search(name) else "vec4"
    if gl_type == "bool":
        return "checkbox"
    if gl_type == "int":
        return "select" if spec.get("choices") or spec.get("options") else "int_slider"
    if gl_type == "float":
        return "slider"
    if gl_type == "mat3":
        return "transform"
    return gl_type


# `channels` is one packed integer holding six per-channel weights, one
# base-9 digit each, mapped through the app's own scale.  Filters expose the
# six as `channels_red`, `channels_green` and so on, so the packed default has
# to be decoded or every channel falls back to zero -- which multiplies the
# image away entirely.
CHANNEL_ORDER = ("red", "green", "blue", "hue", "saturation", "luminance")
PACKED_CHANNELS_DEFAULT = 398580


def _channel_weight(digit: int) -> float:
    step = digit - 4
    if step == 0:
        return 0.0
    return 2.0 ** (step - 2) if step > 0 else -(2.0 ** (-step - 2))


def decode_channels(packed: int) -> dict[str, float]:
    """The six channel weights a packed `channels` value stands for."""
    out: dict[str, float] = {}
    value = int(packed)
    for name in CHANNEL_ORDER:
        out[name] = _channel_weight(value % 9)
        value //= 9
    return out


def decode_channel_indices(packed: int) -> dict[str, int]:
    """The six channel selectors a packed `channels` value stands for.

    `ChannelSwapKt.a(int)` reads the same base-9 digits `channelMultiplier`
    uses, but without the weight scale: the digit names the channel to take.
    """
    out: dict[str, int] = {}
    value = int(packed)
    for name in CHANNEL_ORDER:
        out[name] = value % 9
        value //= 9
    return out


def scale_matrix(s: float, n: int = 3) -> list[list[float]]:
    """A scalar default on a matrix parameter means a uniform scale."""
    return [
        [float(s) if i == j and i < n - 1 else (1.0 if i == j else 0.0) for j in range(n)]
        for i in range(n)
    ]


def build_param(
    entry: dict,
    registry: dict[str, dict],
    preset_values: list,
    override: dict | None = None,
) -> dict:
    name = entry["name"]
    gl_type = entry["gl_type"]
    # The filter's own constructor wins over the shared registry: it is where
    # ranges are narrowed and defaults corrected for this specific filter.
    reg = {**registry.get(name, {}), **(override or {})}
    base = dict(TYPE_DEFAULTS.get(gl_type, {}))

    spec: dict = {
        "name": name,
        "type": gl_type,
        "label": reg.get("label") or prettify(name),
    }

    # "inferred" means neither the registry nor the filter described this
    # parameter, so range and default come from the type rather than the app.
    inferred = name not in registry and not override

    rd = reg.get("default")
    # A recovered default only counts if it fits the parameter's type; the
    # bytecode reader can pick up a neighbouring register's value, and a
    # string where a colour belongs would otherwise be taken at face value.
    if isinstance(rd, str) and gl_type != "string":
        rd = None
    if (
        isinstance(rd, list)
        and gl_type not in VECTOR_WIDTH
        and not gl_type.startswith("mat")
        and not gl_type.endswith("]")
    ):
        rd = None
    if isinstance(rd, (int, float)) and gl_type in VECTOR_WIDTH:
        rd = None
    if isinstance(rd, (int, float)) and gl_type in ("mat3", "mat4"):
        spec["default"] = scale_matrix(rd, 3 if gl_type == "mat3" else 4)
    elif isinstance(rd, (int, float, bool)) and gl_type in ("float", "int", "bool"):
        spec["default"] = rd
    elif isinstance(rd, list) and gl_type in ("mat3", "mat4"):
        # A matrix default assembled from its rows.  These carry the camera
        # placement for the 3D filters -- `wireframe` translates -1 in z, and
        # without it the camera sits on the surface it is marching towards and
        # every ray misses, leaving a flat image.
        n = 3 if gl_type == "mat3" else 4
        rows = [r for r in rd if isinstance(r, (list, tuple)) and len(r) == n]
        if len(rows) == n and all(isinstance(x, (int, float)) for r in rows for x in r):
            spec["default"] = [[float(x) for x in r] for r in rows]
    elif isinstance(rd, list) and gl_type in VECTOR_WIDTH:
        width = VECTOR_WIDTH[gl_type]
        vals = [float(x) for x in rd][:width]
        while len(vals) < width:
            vals.append(1.0 if width == 4 and len(vals) == 3 else 0.0)
        spec["default"] = vals
    if "default" not in spec:
        arr = re.match(r"^(\w+)\[(\d+)\]$", gl_type)
        if arr:
            elem, length = arr.group(1), int(arr.group(2))
            entries = rd if isinstance(rd, list) and rd else None
            if entries and all(isinstance(e, (list, tuple)) for e in entries):
                # The app sizes the array to the palette it was given, while
                # the GLSL declares a fixed 64.  Cycling the recovered entries
                # over the whole array leaves the nearest-colour search with
                # exactly the palette the app had -- `palette-posterize-lp`
                # otherwise searches 62 slots of transparent black and returns
                # it for every pixel.
                spec["default"] = [
                    [float(x) for x in entries[i % len(entries)]] for i in range(length)
                ]
            else:
                # Nothing recovered: an all-zero array is the neutral start.
                unit = TYPE_DEFAULTS.get(elem, {}).get("default", 0.0)
                spec["default"] = [unit for _ in range(length)]
            spec["widget"] = "array"
        else:
            spec["default"] = base.get("default")

    if gl_type in ("float", "int", "vec2", "vec3"):
        if "min" in reg and "max" in reg:
            # Guard the order: an inverted range would clamp every value to
            # one end.
            lo, hi = reg["min"], reg["max"]
            spec["min"], spec["max"] = (lo, hi) if lo <= hi else (hi, lo)
        elif "min" in base:
            spec["min"], spec["max"] = base["min"], base["max"]

    # An int parameter switching between shader branches is an enum; recover
    # its range from the values presets actually use plus any switch cases.
    if gl_type == "int":
        observed = {v for v in preset_values if isinstance(v, int)}
        if observed:
            spec["max"] = max(spec.get("max", 0), max(observed))
            spec["min"] = min(spec.get("min", 0), min(observed))

    # Labelled enum choices, e.g. style {0: "Dots", 1: "Hex Dots", ...}.
    if reg.get("choices"):
        spec["choices"] = reg["choices"]
        values = [c["value"] for c in reg["choices"]]
        spec["min"], spec["max"] = min(values), max(values)
    elif reg.get("options"):
        spec["options"] = reg["options"]
    if reg.get("step"):
        spec["step"] = reg["step"]

    # A default outside its own range is always an extraction error, and it
    # is not a harmless one: values are clamped on the way in, so the filter
    # never runs at the setting the app ships.  `mirror` took a generic int
    # range starting at 1 while its `mode` default is 0, and rendered in
    # horizontal-translate mode instead of plain mirroring.  The default is
    # the more trustworthy of the two, so the range gives way.
    default = spec.get("default")
    if isinstance(default, (int, float)) and not isinstance(default, bool):
        if "min" in spec and default < spec["min"]:
            spec["min"] = default
        if "max" in spec and default > spec["max"]:
            spec["max"] = default

    spec["widget"] = widget_for(gl_type, name, spec)
    if inferred:
        spec["inferred"] = True
    return spec


def value_shape(v) -> str | None:
    """Classify an evaluated DSL value so it can be matched to a parameter."""
    if isinstance(v, bool):
        return "bool"
    if isinstance(v, int):
        return "int"
    if isinstance(v, float):
        return "float"
    if isinstance(v, list):
        if v and isinstance(v[0], list):
            return f"mat{len(v)}"
        return f"vec{len(v)}"
    return None


def assign_positional(preset: dict, params: list[dict]) -> dict:
    """Bind a preset's positional arguments to parameters by type.

    `(halftone source1 (mat3-scale-uniform 0.06))` passes the transform
    positionally; the only mat3 parameter is the one it means.
    """
    out = dict(preset.get("params", {}))
    # `:channels (six-color-float-channels :red 3.0 ...)` evaluates to the six
    # weights; the shader takes them one per parameter.  Without the expansion
    # the whole binding was dropped and `preset-channel-reflect1` ran with
    # every channel at 1.0, which is an exact no-op.
    for name, value in list(out.items()):
        if isinstance(value, dict) and all(
            k.startswith("channels_") for k in value
        ):
            del out[name]
            out.update(value)

    positional = preset.get("positional") or []
    if not positional:
        return out
    for value in positional:
        shape = value_shape(value)
        if shape is None:
            continue
        candidates = [
            p
            for p in params
            if p["type"] == shape and p["name"] not in out and not p.get("engine")
        ]
        if len(candidates) == 1:
            out[candidates[0]["name"]] = value
    return out


def switch_cases(main: str, param: str) -> int | None:
    """Highest `case N:` inside a `switch (param)` block, if any."""
    m = re.search(rf"switch\s*\(\s*{re.escape(param)}\s*\)\s*\{{", main)
    if not m:
        return None
    depth, i = 0, m.end() - 1
    while i < len(main):
        if main[i] == "{":
            depth += 1
        elif main[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    block = main[m.end() : i]
    cases = [int(x) for x in re.findall(r"case\s+(\d+)\s*:", block)]
    if not cases:
        return None
    top = max(cases)
    # A `default:` branch is a further selectable mode beyond the last case.
    if re.search(r"\bdefault\s*:", block):
        top += 1
    return top


def gaussian_blur2_spec() -> dict:
    """`gaussian-blur2` as the app defines it.

    `effects/blur/GaussianBlur.java` registers

        (lambda ((param source :type image)
                 (param radius :type double :standardRange (0 1) :default 0.05))
          (gaussian-blurh (gaussian-blurv source radius) radius))

    so it is a graph over two shaders that were recovered, not a filter in its
    own right.  It had been reimplemented on the CPU as a plain separable
    Gaussian, which is neither of those shaders: they accumulate in squared
    space and walk down the mip chain as the radius grows.  It was also the
    slowest thing in the bank -- 200 ms at radius 0.02 and 1.6 s at 0.12 on a
    900x900 image, against 3.8 ms for the app's pair, whose cost does not grow
    with the radius at all.  That reached well past this one entry: the 21
    blur wrappers and every chain built on them route through it.
    """
    return {
        "id": "gaussian-blur2",
        "name": "Gaussian Blur",
        "category": "blur",
        "backend": "graph",
        "fidelity": "extracted",
        "supported": True,
        "inputs": 1,
        "extra_inputs": [],
        "chain": ["gaussian-blurh", "gaussian-blurv"],
        "graph": {
            "filter": "gaussian-blurh",
            "params": {"radius": {"bind": "radius"}},
            "inputs": {
                "source": {
                    "filter": "gaussian-blurv",
                    "params": {"radius": {"bind": "radius"}},
                    "inputs": {"source": {"input": "source"}},
                }
            },
        },
        "params": [
            {
                "name": "radius",
                "type": "float",
                "label": "Radius",
                "default": 0.05,
                "min": 0.0,
                "max": 1.0,
                "widget": "slider",
            }
        ],
        "presets": [],
    }


def unsharp_mask_specs() -> dict:
    """`sharpen`, `dehaze` and `metal` as the app registers them.

    `UnsharpMask.h` registers, under whatever name its subclass passes up,

        (linear-blend source (gaussian-blur2 source blurRadius)
                      :intensity (neg intensity))

    and `Sharpen` and `Dehaze` supply that name and their own parameter list
    through `super(...)`.  An unsharp mask is a blend towards the blur run
    backwards, which is what the negation is for: `linear-blend` in its
    default mode returns `mix(source, blur, intensity)`, so a negative
    intensity extrapolates away from the blur instead of towards it.

    `Metal.java` then registers

        (dehaze :source (gradient-displacement :source1 source1 :source2 source1
                            :modelTransform transform :intensity crunch)
                :intensity contrast :blurRadius 0.10)

    `:source2 source1` is the app feeding the displacement port from the image
    itself, which is what the shader does anyway when that port is unbound --
    `displacement_specified` selects between them -- so the graph leaves it
    unwired rather than uploading the same picture twice.

    All three were reimplemented on the CPU around a separable Gaussian.  At
    the size the editor previews at that blur runs 541 taps a pixel, which is
    why they were three of the five slowest filters in the bank; as the app
    builds them they are two shader passes.  `sharpen` was already extracted
    as this graph but with none of the bindings, so its only knob did nothing
    -- `tools/verify.py` has been reporting it.
    """
    def unsharp(name, label, params):
        return {
            "id": name,
            "name": label,
            "category": "texture",
            "backend": "graph",
            "fidelity": "extracted",
            "supported": True,
            "inputs": 1,
            "extra_inputs": [],
            "chain": ["linear-blend", "gaussian-blur2"],
            "graph": {
                "filter": "linear-blend",
                "params": {"intensity": {"bind": "intensity", "neg": True}},
                "inputs": {
                    "source1": {"input": "source"},
                    "source2": {
                        "filter": "gaussian-blur2",
                        "params": {"radius": {"bind": "blurRadius"}},
                        "inputs": {"source": {"input": "source"}},
                    },
                },
            },
            "params": params,
            "presets": [],
        }

    def knob(name, label, default, lo, hi):
        return {"name": name, "type": "float", "label": label,
                "default": default, "min": lo, "max": hi, "widget": "slider"}

    return {
        # Sharpen.java: intensity 0..1 default 0.5, blurRadius 0..0.1 default 0.001
        "sharpen": unsharp("sharpen", "Sharpen", [
            knob("intensity", "Intensity", 0.5, 0.0, 1.0),
            knob("blurRadius", "Blur radius", 0.001, 0.0, 0.1),
        ]),
        # Dehaze.java: intensity 0..1 default 0.5, blurRadius 0.05..1 default 0.1
        "dehaze": unsharp("dehaze", "Dehaze", [
            knob("intensity", "Intensity", 0.5, 0.0, 1.0),
            knob("blurRadius", "Blur radius", 0.1, 0.05, 1.0),
        ]),
        "metal": {
            "id": "metal",
            "name": "Metal",
            "category": "art",
            "backend": "graph",
            "fidelity": "extracted",
            "supported": True,
            "inputs": 1,
            "extra_inputs": [],
            "chain": ["dehaze", "gradient-displacement"],
            "graph": {
                "filter": "dehaze",
                "params": {"intensity": {"bind": "contrast"}, "blurRadius": 0.10},
                "inputs": {
                    "source": {
                        "filter": "gradient-displacement",
                        "params": {"intensity": {"bind": "crunch"}},
                        "inputs": {"source1": {"input": "source"}},
                    }
                },
            },
            "params": [
                knob("crunch", "Crunch", 0.5, 0.0, 1.0),
                knob("contrast", "Contrast", 0.6, 0.0, 1.0),
            ],
            "presets": [],
        },
    }


def adopt_richer_graphs(filters: dict, graphs: dict) -> int:
    """Take the extractor's chain where it resolves more of one than is stored.

    A graph that stands on another graph could only be parsed once the one it
    stands on had been seen, and the pass that saw it did not replace what the
    earlier pass had written.  `glass-marble` was stored as its outermost
    `adjust` alone, `schema4-preset` had lost both of the graphs it blends,
    and `reverie` most of its chain.  With that fixed in
    `tools/extract_graphs.py`, this brings the fuller parse across.
    """
    def resolved(node):
        if not isinstance(node, dict) or "filter" not in node:
            return 0
        return 1 + sum(resolved(c) for c in (node.get("inputs") or {}).values())

    def names(node, acc):
        if isinstance(node, dict) and "filter" in node:
            acc.add(node["filter"])
            for c in (node.get("inputs") or {}).values():
                names(c, acc)
        return acc

    changed = 0
    for fid, f in filters.items():
        stored = f.get("graph")
        fresh = (graphs.get(fid) or {}).get("root")
        if not stored or not fresh:
            continue
        def settings(node):
            if not isinstance(node, dict) or "filter" not in node:
                return 0
            return len(node.get("params") or {}) + sum(
                settings(c) for c in (node.get("inputs") or {}).values()
            )

        def bindings(node):
            # Knobs wired to a control rather than frozen at a number.
            if not isinstance(node, dict) or "filter" not in node:
                return 0
            def holes(v):
                # A knob can sit inside a value as well as be one: three of
                # the nine cells of `preset-focus`'s locus matrix are knobs.
                if isinstance(v, dict):
                    return 1 if "bind" in v else 0
                if isinstance(v, list):
                    return sum(holes(x) for x in v)
                return 0

            here = sum(holes(v) for v in (node.get("params") or {}).values())
            return here + sum(bindings(c) for c in (node.get("inputs") or {}).values())

        def score(node):
            return resolved(node), settings(node), bindings(node)

        if score(fresh) <= score(stored):
            continue
        f["graph"] = fresh
        f["chain"] = sorted(names(fresh, set()))
        changed += 1
    return changed


CALL_SITE_RE = re.compile(r'\.[QN]\(\s*"\((?P<id>[a-z][a-z0-9-]*)\s+(?P<args>:[^"]*?)"\s*,')


def _call_args(text: str) -> dict:
    """`:name value` pairs from a call, values possibly parenthesised."""
    out, i = {}, 0
    while True:
        m = re.compile(r":([A-Za-z][A-Za-z0-9_]*)\s+").search(text, i)
        if not m:
            return out
        name, j = m.group(1), m.end()
        if j < len(text) and text[j] == "(":
            depth, k = 0, j
            while k < len(text):
                if text[k] == "(":
                    depth += 1
                elif text[k] == ")":
                    depth -= 1
                    if depth == 0:
                        break
                k += 1
            out[name], i = text[j : k + 1], k + 1
        else:
            k = re.compile(r"[\s)]").search(text, j)
            out[name] = text[j : k.start()] if k else text[j:]
            i = k.start() if k else len(text)


def call_site_defaults(filters: dict, sources: Path) -> int:
    """Give a lambda the values the app invokes it with.

    A lambda declares its knobs, usually by inheriting them from the filter it
    forwards to, and the app then calls it with values of its own:

        (white-infinite :source source1 :model3DTransform (mat4 ...))
        (triangle-op-art :source source1 :intensity 5.0 ...)

    The extraction kept the declaration and dropped the call, so these opened
    at whatever the inherited knob happened to default to.  Where that is a
    neutral value the filter does little or nothing: `triangle-op-art` sat at
    intensity 0 against the app's 5, `star-kaleidoscope` at 0 against 1.11,
    `etched-circles` at thickness 0 against 0.12.

    Only scalars and short vectors are taken, and only where the shape matches
    what is declared; a matrix wants the column-to-row turn that `mat4` needs
    and is left to the entry that knows it.
    """
    def numbers(t):
        return [float(x) for x in re.findall(r"-?\d+\.?\d*(?:[eE][-+]?\d+)?", t)]

    def flat(v):
        if isinstance(v, list):
            out = []
            for x in v:
                out.extend(flat(x))
            return out
        return [float(v)] if isinstance(v, (int, float)) else []

    changed = 0
    for path in sources.rglob("*.java"):
        text = path.read_text(errors="ignore")
        for m in CALL_SITE_RE.finditer(text):
            fid = m.group("id")
            if fid not in filters:
                continue
            declared = {p["name"]: p for p in filters[fid]["params"]}
            for name, raw in _call_args(m.group("args")).items():
                p = declared.get(name)
                if p is None or p.get("default") is None:
                    continue
                want, have = numbers(raw), flat(p["default"])
                if not want or len(want) != len(have) or want == have:
                    continue
                if len(want) > 4:
                    continue  # a matrix: see the docstring
                p["default"] = (
                    want[0]
                    if len(want) == 1 and not isinstance(p["default"], list)
                    else want
                )
                changed += 1
    return changed


def main() -> None:
    shaders = json.loads(Path("work/shaders.json").read_text())
    raw_params = json.loads(Path("work/params.json").read_text())
    presets = json.loads(Path("work/presets.json").read_text())

    # If a sweep has been run, its verdicts override static reasoning: a
    # filter that failed to compile is unsupported no matter what the
    # metadata suggests.  Run build -> sweep -> build to converge.
    sweep_path = Path("work/sweep.json")
    sweep = json.loads(sweep_path.read_text()) if sweep_path.exists() else {}

    fp_path = Path("work/filter_params.json")
    filter_params = json.loads(fp_path.read_text()) if fp_path.exists() else {}

    # Constructors jadx could not show at all are read from the dex; they take
    # precedence, being the same source read more directly.
    dc_path = Path("work/dex_ctor_params.json")
    if dc_path.exists():
        for fid, params in json.loads(dc_path.read_text()).items():
            merged = dict(filter_params.get(fid, {}))
            for name, spec in params.items():
                merged[name] = {**merged.get(name, {}), **spec}
            filter_params[fid] = merged

    # Several filters are thin wrappers that reuse another filter's shader
    # without restating its parameters -- `preset-extrusion` wraps
    # `Topography`, and `contour-gl` wraps `contour`.  Their own class has no
    # constructor to read, so without this they fall back to type defaults and
    # lose the camera placement or the transform the shader needs.  A shared
    # entry function is a shared parameter contract, so the overrides carry
    # across; where two filters on one function disagree about a parameter,
    # neither value is inherited.
    by_function: dict[str, list[dict]] = {}
    for fid, rec in shaders.items():
        fn = rec.get("function")
        if fn and filter_params.get(fid):
            by_function.setdefault(fn, []).append(filter_params[fid])
    inherited: dict[str, dict] = {}
    for fn, peers in by_function.items():
        shared: dict[str, dict] = {}
        for peer in peers:
            for pname, spec in peer.items():
                if pname not in shared:
                    shared[pname] = spec
                elif shared[pname] is not None and shared[pname].get(
                    "default"
                ) != spec.get("default"):
                    shared[pname] = None
        inherited[fn] = {k: v for k, v in shared.items() if v}
    wrappers = 0
    for fid, rec in shaders.items():
        if filter_params.get(fid):
            continue
        borrowed = inherited.get(rec.get("function"))
        if borrowed:
            filter_params[fid] = borrowed
            wrappers += 1
    print(f"  {wrappers} wrappers took their parameters from the shared shader")

    # Registry keyed by parameter name; prefer entries carrying a range.
    registry: dict[str, dict] = {}
    for spec in raw_params.values():
        name = spec.get("name")
        if not name:
            continue
        cur = registry.get(name)
        if cur is None or ("min" in spec and "min" not in cur):
            registry[name] = spec

    glsl_dir = Path("gltcstdio/data/glsl/filters")
    glsl_dir.mkdir(parents=True, exist_ok=True)
    for old in glsl_dir.glob("*.glsl"):
        old.unlink()

    filters = {}
    for fid, rec in sorted(shaders.items()):
        my_presets = presets.get(fid, [])
        params = []
        runtime = []
        # The generated call must reproduce the shader's argument order
        # exactly, so walk the declared signature and tag each argument as
        # implicit (runtime geometry), engine-supplied, or user-configurable.
        signature = []
        for entry in rec["signature"]:
            name, gl_type = entry["name"], entry["gl_type"]
            if entry["implicit"]:
                kind = "implicit"
            elif is_runtime_uniform(name):
                kind = "runtime"
                runtime.append({"name": name, "type": gl_type})
            else:
                kind = "param"
            signature.append({"name": name, "type": gl_type, "kind": kind})

        for entry in rec["params"]:
            if is_runtime_uniform(entry["name"]):
                continue
            vals = [p["params"].get(entry["name"]) for p in my_presets]
            vals = [v for v in vals if v is not None]
            override = filter_params.get(fid, {}).get(entry["name"])
            # Expand a packed `channels` value into the per-channel defaults.
            # The vignette composite carries four sub-parameters in one
            # descriptor; without unpacking it the app's hardness of 0.3 was
            # lost to the type default.
            if override is None and entry["name"].startswith("vignette_"):
                parts = registry.get("vignette", {}).get("default")
                if isinstance(parts, dict) and entry["name"] in parts:
                    override = {"name": entry["name"], "default": parts[entry["name"]]}
            if override is None and entry["name"].startswith("channels_"):
                packed = filter_params.get(fid, {}).get("channels", {}).get("default")
                if not isinstance(packed, int):
                    packed = PACKED_CHANNELS_DEFAULT
                # Both kinds of filter pack six base-9 digits into one
                # integer, but they mean different things.  A `float`
                # parameter is a multiplier and the digit maps through the
                # app's weight scale; an `int` is a channel selector and the
                # digit *is* the channel.  `channel-swap` packs 323847, which
                # as selectors is 0,1,2,3,4,5 -- each channel taking itself.
                if entry["gl_type"] == "int":
                    values = decode_channel_indices(packed)
                else:
                    values = decode_channels(packed)
                leaf = entry["name"].removeprefix("channels_")
                if leaf in values:
                    override = {"name": entry["name"], "default": values[leaf]}
            spec = build_param(entry, registry, vals, override)
            if entry["gl_type"] == "int":
                top = switch_cases(rec["main"], entry["name"])
                if top is not None:
                    # The switch enumerates the modes exactly, so it replaces
                    # the type-derived guess instead of widening it.
                    observed = [v for v in vals if isinstance(v, int)]
                    spec["max"] = max([top, *observed]) if observed else top
                    spec["min"] = 0
                    spec["widget"] = "select"
                    spec.pop("inferred", None)
            params.append(spec)

        # `AbstractC0918g.h` wraps every filter's call as
        #     f((inverse(viewTransform) * vec3(v_OutCoordinate, 1)).xy, ...)
        # so the view transform applies whether or not the shader declares it.
        # `xor-patterns` reads the raw coordinate and has no transform of its
        # own; the app's own preset zooms it purely through this parameter, so
        # leaving it off the filter made that unreachable.
        if not any(p["name"] == "viewTransform" for p in params):
            view = build_param(
                {"name": "viewTransform", "gl_type": "mat3"},
                registry,
                [],
                filter_params.get(fid, {}).get("viewTransform"),
            )
            # Flagged, because it is applied around the shader call rather
            # than passed into it: it is not one of the signature's arguments
            # and must not compete for a preset's positional value.
            view["engine"] = True
            params.append(view)

        # Some shaders take a uniform the app fills in Java from parameters
        # the shader itself never declares.  `metaballs3d` reads its sphere
        # count, radius, regularity and seed out of the environment and hands
        # the shader a finished array, so those four have to reach the bank or
        # there is no way to ask for anything but an empty scene.
        for entry in DRIVING_PARAMS.get(rec["function"], []):
            if any(p["name"] == entry["name"] for p in params):
                continue
            vals = [p["params"].get(entry["name"]) for p in my_presets]
            spec = build_param(
                entry,
                registry,
                [v for v in vals if v is not None],
                filter_params.get(fid, {}).get(entry["name"]),
            )
            spec["default"] = entry["default"]
            spec.pop("inferred", None)
            params.append(spec)

        source = "\n\n".join([*rec["helpers"], rec["main"]]) + "\n"
        (glsl_dir / f"{fid}.glsl").write_text(source)

        filters[fid] = {
            "id": fid,
            "name": prettify(rec["class"]),
            "category": rec["category"],
            "backend": "gl",
            "function": rec["function"],
            "implicit": rec["implicit"],
            "signature": signature,
            "runtime": runtime,
            "params": params,
            "presets": [
                {"name": p["name"], "params": assign_positional(p, params)}
                for p in my_presets
            ],
            "inputs": 1,
            "glsl": f"filters/{fid}.glsl",
            "source_class": rec["class"],
            "_truncated": rec.get("truncated", False),
        }

    # The engine uniforms name the inputs a shader reads, so they give the
    # true input count.  `source`/`source1` are the primary image; anything
    # else is an extra input the single-image v1 runtime cannot bind, so those
    # filters are flagged rather than silently rendered against a blank.
    # `outDim` describes the render target and the aspect-ratio uniforms are
    # derived from it, so neither names an image input.
    primary = {"source", "source1"}
    not_an_input = {"out", "aspectRatio", "outAspectRatio", "pixelAspectRatio"}
    for f in filters.values():
        inputs = set()
        for u in f["runtime"]:
            name = u["name"]
            if not name.endswith(("Dim", "_specified")):
                continue  # aspect ratios name no input at all
            base = name.removesuffix("Dim").removesuffix("_specified")
            if base:
                inputs.add(base)
        # A filter need not declare a dimension uniform for an image it reads:
        # `curves` samples its `curveLut` and `locusBlend` its `effect` with
        # nothing else naming them, so the images went unadvertised even
        # though the renderer binds them.  The sampler macros are the
        # authoritative list, and they are what the renderer reads too.
        source = shaders.get(f["id"], {})
        text = source.get("main", "") + "".join(source.get("helpers") or [])
        inputs |= set(SAMPLER_RE.findall(text))
        extra = sorted(inputs - primary - not_an_input)
        f["inputs"] = 1 + len(extra)

        # `AbstractC0565h2.f7997h.N()` -- 163 filters set their source to
        # mirrored repeat, and it decides what a filter sees once it samples
        # outside the image.  `mirror` translates its lookup a full width in
        # `mode` 1, so clamping made half its output the edge colour.
        wraps = {
            name: spec["wrap"]
            for name, spec in filter_params.get(f["id"], {}).items()
            if spec.get("wrap")
        }
        if wraps:
            f["wrap"] = wraps

        reasons = []
        if f.pop("_truncated", False):
            reasons.append(
                "shader is assembled from a code template in the app and only "
                "part of it is present in the decompiled source"
            )
        if extra:
            # Not a blocker: the runtime binds every declared input, falling
            # back to the primary image when the caller supplies only one.
            f["extra_inputs"] = extra

        verdict = sweep.get(f["id"], {})
        if verdict.get("status") in ("compile_error", "render_error"):
            reasons.append(f"{verdict['status']}: {verdict.get('error', '')[:120]}")
        elif verdict.get("status") == "flat":
            f["renders_flat"] = True

        f["supported"] = not reasons
        if reasons:
            f["unsupported_reason"] = "; ".join(reasons)

    # A CPU reimplementation exists for filters whose GLSL could not be
    # recovered at the time.  Several of those shaders are recoverable now, so
    # the sweep tests them even though the CPU version shadows them, and the
    # verdict decides which one ships: the app's own shader when it compiles
    # and actually transforms the image, the reimplementation otherwise.
    # `infinite-spheroids` is 927x faster this way, and extracted rather than
    # rewritten.
    from gltcstdio.backends.cpu import REGISTRY as _CPU

    prefer_gl = set()
    for fid, verdict in sweep.items():
        if fid not in _CPU:
            continue
        if verdict.get("status") == "ok" and not verdict.get("passthrough"):
            prefer_gl.add(fid)
        elif fid in filters:
            # Never swept before, so `supported` was whatever the metadata
            # guessed; 19 of them claimed to compile and do not.  A shader
            # that compiled and drew nothing is a different verdict and says
            # so: `mobius-torus` was recorded as failing to compile when it
            # had only rendered its input back at defaults that give its tube
            # no thickness.
            filters[fid]["supported"] = False
            filters[fid]["unsupported_reason"] = verdict.get("error") or (
                "shader renders its input unchanged at the defaults"
                if verdict.get("passthrough")
                else "shader does not compile"
            )
    # A shader that draws nothing at its defaults is not a broken shader.
    # `mobius-torus` is the app's own ray marcher, and its defaults give the
    # tube zero thickness -- `roundness` is 0.0 -- so the sweep saw its input
    # come back unchanged and kept the reimplementation.  The app presents
    # this filter through its three presets ("copper ring", "silver ring",
    # "gold ring"), all of which render, and which set `separation`,
    # `specular` and `model3DTransform` -- parameters the reimplementation
    # does not have, so they did nothing at all.  On top of that the shader is
    # 8 ms against 281 ms at 900x900.
    # `WhiteInfinite.java` declares its transform by inheritance, which is an
    # identity, and then invokes itself with a real one:
    #
    #   (white-infinite :source source1 :model3DTransform
    #      (mat4 (vec4 1 0 0 0) (vec4 0 1 0 0) (vec4 0 0 1 0) (vec4 0 0 -1 1)))
    #
    # The extractor kept the declaration and lost the call, so the look sat
    # its torus at the origin, inside the camera, and drew nothing.  It went
    # unnoticed while `mobius-torus` was a reimplementation that ignored the
    # transform.  `mat4` takes columns and the bank stores rows, which is
    # what puts the -1 at [2][3] -- where `mobius-torus`'s own presets keep
    # theirs.
    if "white-infinite" in filters:
        for p in filters["white-infinite"]["params"]:
            if p["name"] == "model3DTransform":
                p["default"] = [
                    [1.0, 0.0, 0.0, 0.0],
                    [0.0, 1.0, 0.0, 0.0],
                    [0.0, 0.0, 1.0, -1.0],
                    [0.0, 0.0, 0.0, 1.0],
                ]

    n_richer = adopt_richer_graphs(filters, graphs)
    if n_richer:
        print(f"  {n_richer} graphs took the fuller parse of their chain")

    prefer_gl.add("mobius-torus")
    if prefer_gl:
        for fid in prefer_gl:
            if fid in filters:
                filters[fid]["prefer_gl"] = True
                # Shipping a shader and calling it unsupported cannot both be
                # true, and `white-infinite` chains this one.
                filters[fid]["supported"] = True
                filters[fid].pop("unsupported_reason", None)
        print(f"  {len(prefer_gl)} shaders replace their CPU reimplementation")

    # `gaussian-blur2` is not a filter of the app's own: it is a lambda over
    # two shaders that are, and both were recovered.  See
    # `gaussian_blur2_spec` for what the app registers and what it replaces.
    if "gaussian-blurh" in filters and "gaussian-blurv" in filters:
        filters["gaussian-blur2"] = gaussian_blur2_spec()
        print("  gaussian-blur2 built from the app's own pair of shaders")

    # `sharpen`, `dehaze` and `metal` are lambdas the app builds out of
    # filters it already has; see `unsharp_mask_specs`.
    if all(k in filters for k in ("linear-blend", "gaussian-blur2", "gradient-displacement")):
        for fid, spec in unsharp_mask_specs().items():
            filters[fid] = spec
        # `linear-blend` mixes towards its second image, and an unsharp mask
        # is that mix run backwards, so the app's own lambda hands it a
        # negative intensity.  0..1 is the range of the control the app shows,
        # not of the operator behind it: values are clamped to the declared
        # range on the way in, which turned `sharpen` and `dehaze` into
        # passthroughs when they went through this node.
        for p in filters["linear-blend"]["params"]:
            if p["name"] == "intensity" and p.get("min", 0.0) == 0.0:
                p["min"] = -1.0
        print("  sharpen, dehaze and metal built from the app's own lambdas")

    # Last, so it corrects the entries written above as well: `metal`'s
    # contrast is 0.35 where the filter it inherits from defaults to 0.6.
    n_calls = call_site_defaults(filters, Path("work/decompiled/sources"))
    if n_calls:
        print(f"  {n_calls} defaults taken from the call the app makes")


    # Curated looks: several filters chained, rather than one shader.
    graphs_path = Path("work/graphs.json")
    graphs = json.loads(graphs_path.read_text()) if graphs_path.exists() else {}
    from gltcstdio.backends.cpu import REGISTRY as CPU_REGISTRY

    cpu_ids = set(CPU_REGISTRY)
    n_graphs = 0
    for gid, g in sorted(graphs.items()):
        if gid in filters:
            continue
        used = graph_filters(g["root"])
        # CPU filters live in code rather than this dict and override any
        # same-named shader entry at load time, so a node backed by one is
        # available even when its shader could not be recovered.
        def available(u: str) -> bool:
            if u in cpu_ids or u in graphs:
                return True
            return u in filters and filters[u]["supported"]

        if not all(available(u) for u in used):
            continue  # a graph is only as usable as the filters it chains
        # Knobs the lambda declares, whose defaults it inherits from the
        # filter it forwards them to.  `blob` passes both of its transforms
        # through by name and sets no literal of its own, so without these it
        # had no parameters at all.
        specs = []
        # Where a knob names no source of its own, the parameter it is passed
        # into describes it.
        targets = bound_targets(g["root"])
        for name, decl in (g.get("declared") or {}).items():
            if name in PRIMARY_INPUTS:
                continue
            source, param = (decl.get("inherit") or targets.get(name) or [None, None])
            inherited = None
            if source in filters:
                inherited = next(
                    (p for p in filters[source]["params"] if p["name"] == param), None
                )
            if decl.get("default") is not None:
                value = decl["default"]
                if inherited is not None:
                    spec = dict(inherited)
                else:
                    spec = build_param(
                        {"name": name, "gl_type": value_shape(value) or "float"},
                        registry,
                        [],
                        None,
                    )
                spec["default"] = value
                if isinstance(value, (int, float)) and not isinstance(value, bool):
                    if "min" in spec and value < spec["min"]:
                        spec["min"] = value
                    if "max" in spec and value > spec["max"]:
                        spec["max"] = value
            elif inherited is not None:
                spec = dict(inherited)
            else:
                continue
            spec["name"] = name
            if decl.get("label"):
                spec["label"] = decl["label"]
            spec.pop("inferred", None)
            specs.append(spec)

        gparams = graph_params(g["root"])
        for name, value in gparams.items():
            if any(s["name"] == name for s in specs):
                continue
            if isinstance(value, dict):
                continue  # unevaluated DSL expression
            entry = {"name": name, "gl_type": value_shape(value) or "float"}
            spec = build_param(entry, registry, [], filter_params.get(gid, {}).get(name))
            # The graph states the value itself, so it wins over anything the
            # registry guessed -- and the range has to make room for it, or
            # the graph's own value is clamped away on the way back in.
            # `schema4-boxes` binds `intensity` to -100 against a registry
            # range of 0..1, which turned its streaks off entirely.
            spec["default"] = value
            if isinstance(value, (int, float)) and not isinstance(value, bool):
                if "min" in spec and value < spec["min"]:
                    spec["min"] = value
                if "max" in spec and value > spec["max"]:
                    spec["max"] = value
            specs.append(spec)

        # Parameters the app's own presets address on the root filter but no
        # node sets a literal for.  `preset-channel-reflect1` is a bare
        # `channelMultiplier`, and its only meaningful state -- the six
        # channel weights and the locus transform -- arrives that way, so
        # without these the look renders as an exact no-op.
        root_params = {p["name"]: p for p in filters.get(used[0], {}).get("params", [])}
        addressed = {
            k
            for p in presets.get(gid, [])
            for k in assign_positional(p, specs)
        }
        for name in sorted(addressed):
            if name in root_params and not any(s["name"] == name for s in specs):
                specs.append(dict(root_params[name]))

        # A locus wrapper forwards the whole parameter list of the filter it
        # blends in, so those are the graph's knobs too.
        for target in forwarded_filters(g["root"]):
            for p in filters.get(target, {}).get("params", []):
                if p.get("engine") or any(s["name"] == p["name"] for s in specs):
                    continue
                specs.append(dict(p))

        filters[gid] = {
            "id": gid,
            "name": prettify(gid.removeprefix("preset-").replace("-", " ").title().replace(" ", "")),
            "category": "presets",
            "backend": "graph",
            "graph": g["root"],
            "chain": used,
            "params": specs,
            "presets": [
                {"name": p["name"], "params": assign_positional(p, specs)}
                for p in presets.get(gid, [])
            ],
            "supported": True,
            "inputs": 1,
            "fidelity": "extracted",
        }
        n_graphs += 1

    # A wrapped operator is not a second name for the same shader.  The app
    # registers `height-map-raw` for the shader itself and `height-map` for a
    # graph around it: one of its image inputs is fed by a blurred copy of the
    # source, and the blur radius becomes a parameter of its own.  Extracted as
    # an alias the two were identical and the control was missing, so the graph
    # is rebuilt here from the wrapper the class actually calls.
    #
    # `gaussian-blur2` at radius 0 returns its input unchanged, so routing
    # through it always is what the app's `radius == 0 ? source : blur(...)`
    # comes to.  The input keeps its own name inside the graph, which resolves
    # to a caller-supplied image when there is one and to the source otherwise
    # -- the same fallback the app's wrapper spells out.
    n_wrapped = 0
    for fid, rec in shaders.items():
        wrapper = rec.get("wrapper")
        raw = rec.get("alias_of")
        if not wrapper or fid not in filters or raw not in filters:
            continue
        f = filters[fid]
        spec = wrapper["param"]
        inp = wrapper["input"]
        if any(p["name"] == spec["name"] for p in f["params"]):
            continue  # the shader already owns that name; leave it alone

        f["backend"] = "graph"
        f["graph"] = {
            "filter": raw,
            "inputs": {
                inp: {
                    "filter": "gaussian-blur2",
                    "inputs": {"source": {"input": inp}},
                    "params": {"radius": {"bind": spec["name"]}},
                }
            },
        }
        f["params"] = list(f["params"]) + [
            {
                "name": spec["name"],
                "type": "float",
                "label": spec["label"] or spec["name"].capitalize(),
                "default": spec["default"],
                "min": 0.0,
                "max": max(0.25, spec["default"]),
                "widget": "slider",
            }
        ]
        # The input stays bindable.  The wrapper only drops it from the list
        # the app shows; the binding survives, and four of the curated looks
        # feed an elevation map straight into one of these.  The graph reads
        # it by name, so a supplied image gets blurred and the source is used
        # when there is none -- which is what the app's own wrapper does.
        f.pop("glsl", None)
        # What the graph depends on, as every other graph filter records it.
        f["chain"] = [raw, "gaussian-blur2"]
        f["wrapped"] = raw
        n_wrapped += 1

    # The other wrapper a class registers around its own shader: a locus
    # blend, which confines the effect to a region instead of covering the
    # frame.  Built in the shape the curated-look extraction already produces
    # for the other thirty-seven -- `locusBlend(source, effect = <shader>)`,
    # with the effect node forwarding so the shader's own knobs stay reachable.
    n_locus = 0
    for fid, rec in shaders.items():
        locus = rec.get("locus")
        raw = rec.get("alias_of")
        if not locus or fid not in filters or raw not in filters:
            continue
        if "locusBlend" not in filters:
            break
        f = filters[fid]
        # A pinned value belongs to whichever filter declares it: `locusMode`
        # to the blend, `mode` and `style` to the shader being blended.  Put on
        # the wrong node it is dropped, which is how `block-corrupt-3` came to
        # render as mode 1 when the app pins it to 2.
        own = {p["name"] for p in filters["locusBlend"]["params"]}
        root = {"locusMode": {"bind": "locusMode"},
                "locusTransform": {"bind": "locusTransform"}}
        effect = {}
        for name, value in locus["pinned"].items():
            (root if name in own else effect)[name] = value
            # The filter opens at the value the app pins it to; it stays
            # settable, so nothing that was reachable stops being reachable.
            for spec in f["params"]:
                if spec["name"] == name:
                    spec["default"] = value
        f["backend"] = "graph"
        f["graph"] = {
            "filter": "locusBlend",
            "inputs": {
                "effect": {
                    "filter": raw,
                    "forward": True,
                    "inputs": {"source": {"input": "source"}},
                    "params": effect,
                },
                "source": {"input": "source"},
            },
            "params": root,
        }
        f["chain"] = [raw, "locusBlend"]
        f["wrapped"] = raw
        f.pop("glsl", None)
        n_locus += 1

    # A graph that binds a knob by name reaches nothing unless the filter
    # declares it.  Four locus blends bound `locusMode` and `locusTransform`
    # without declaring either, so the region the blend exists to confine could
    # not be placed.  The spec comes from the filter that owns the parameter.
    n_exposed = 0
    for f in filters.values():
        g = f.get("graph")
        if not g:
            continue
        owner = filters.get(g.get("filter"))
        if not owner:
            continue
        have = {p["name"] for p in f["params"]}
        for value in (g.get("params") or {}).values():
            if not isinstance(value, dict) or "bind" not in value:
                continue
            name = value["bind"]
            if name in have:
                continue
            spec = next((p for p in owner["params"] if p["name"] == name), None)
            if spec is None or spec.get("engine"):
                continue
            f["params"].append(dict(spec))
            have.add(name)
            n_exposed += 1

    bank = {
        "version": BANK_VERSION,
        "source": "gltcstdio",
        "stdlib": "stdlib.glsl",
        "filters": filters,
    }
    out = Path("gltcstdio/data/bank.json")
    out.write_text(json.dumps(bank, indent=1))

    n_presets = sum(len(f["presets"]) for f in filters.values())
    n_params = sum(len(f["params"]) for f in filters.values())
    n_inferred = sum(
        1 for f in filters.values() for p in f["params"] if p.get("inferred")
    )
    n_single = sum(1 for f in filters.values() if f["supported"])
    n_runtime = sum(len(f.get("runtime", ())) for f in filters.values())
    print(f"bank v{BANK_VERSION}: {len(filters)} filters -> {out}")
    print(f"  {n_single} single-input, {len(filters) - n_single} need extra inputs")
    print(f"  {n_params} user parameters ({n_inferred} with inferred range/default)")
    print(f"  {n_runtime} engine-supplied uniforms")
    print(f"  {n_presets} presets")
    print(f"  {n_graphs} curated looks (filter graphs)")
    print(f"  {n_wrapped} filters rebuilt as their blur wrapper")
    print(f"  {n_locus} filters rebuilt as their locus blend")
    print(f"  {n_exposed} bound knobs given the control they reference")
    print(f"  {len(list(glsl_dir.glob('*.glsl')))} glsl files -> {glsl_dir}")


if __name__ == "__main__":
    main()
