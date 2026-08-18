"""Extract the app's curated looks, which are filter graphs rather than filters.

The `preset-*` operators are not shaders.  Each one wires several existing
filters together and exposes a handful of parameters, and the decompiled form
is readable:

    q7.v("preset-game-boy", ... new C0558g0(
            new C0542d(RandomColorDispersion.f12219k), null,
            z.V(new h("source", new C0558g0(
                    new C0542d(PixelateWithOrderedDithering.f12724k), null,
                    z.V(new h("source", new P0("source")),
                        new h("palette", ...)), 2)),
                ...), 2))

So the graph is recovered as JSON and executed at runtime by rendering nodes
depth-first and feeding each result into its parent:

    {"filter": "random-color-dispersion",
     "inputs": {"source": {"filter": "pixelate-with-ordered-dithering",
                           "inputs": {"source": {"input": "source"}},
                           "params": {...}}},
     "params": {...}}
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

sys.path.insert(0, str(Path(__file__).parent))
import dsl  # noqa: E402
from extract_params import Registry, load_colors  # noqa: E402
from javaexpr import match_paren, split_args  # noqa: E402

# `new K0(<parameter list>, <root node>, ...)` -- the list declares the knobs
# the look exposes, exactly as a filter constructor declares its own.
K0_CALL = re.compile(r"\bnew\s+(?:[\w.]+\.)?K0\s*\(")

# `q7.v("preset-game-boy", <expr>)`, and a handful register through `u`
# instead -- `bloom`, `lens-blur`, `soft-focus`, `eraser` and
# `posterize-source-colors` are all defined that way and were invisible.
REGISTER_RE = re.compile(r'\b[uv]\(\s*"([a-z][a-z0-9-]*)"\s*,')

NODE_CLASS = "C0558g0"      # a graph node: filter + bindings
CONST_CLASS = "C0542d"      # a constant
INPUT_CLASS = "P0"          # the graph's own input
PAIR_CLASS = "h"            # a ("name", value) binding
DSL_CALL = re.compile(r'\bq0\(\s*"((?:[^"\\]|\\.)*)"\s*\)')

NUM_RE = re.compile(r"^-?\d+(?:\.\d+)?(?:[dDfFL])?$")
CLASS_REF_RE = re.compile(r"^([A-Z]\w+)\.\w+$")


class Unparsed(Exception):
    """A construct this extractor does not model."""


def unquote(tok: str) -> str | None:
    tok = tok.strip()
    if len(tok) >= 2 and tok[0] == '"' and tok[-1] == '"':
        return tok[1:-1].encode().decode("unicode_escape")
    return None


def as_number(tok: str):
    tok = tok.strip()
    m = re.match(r"^(?:Double|Integer|Float|Long)\.valueOf\((.*)\)$", tok, re.S)
    if m:
        tok = m.group(1).strip()
    if not NUM_RE.match(tok):
        return None
    tok = re.sub(r"[dDfFL]$", "", tok)
    return float(tok) if "." in tok else int(tok)


def call_args(text: str, cls: str) -> list[str] | None:
    """Arguments of `new <cls>(...)` if `text` is exactly that call."""
    text = text.strip()
    m = re.match(rf"^new\s+(?:[\w.]+\.)?{cls}\s*\(", text)
    if not m:
        return None
    open_idx = text.index("(", m.end() - 1)
    close = match_paren(text, open_idx)
    if close != len(text) - 1:
        return None
    return split_args(text[open_idx + 1 : close])


def find_pairs(text: str) -> list[tuple[str, str]]:
    """This node's own `new h("name", value)` bindings.

    A pair nested inside another pair's value belongs to that child node, not
    to this one.  Taking every pair at any depth gave `preset-iridize4` its
    effect stage's `mode` and `intensity` as if they were the outer filter's.
    """
    pairs = []
    consumed = 0  # end offset of the last binding taken at this level
    for m in re.finditer(rf"new\s+(?:[\w.]+\.)?{PAIR_CLASS}\s*\(", text):
        if m.start() < consumed:
            continue
        open_idx = text.index("(", m.end() - 1)
        close = match_paren(text, open_idx)
        if close == -1:
            continue
        consumed = close
        args = split_args(text[open_idx + 1 : close])
        if len(args) != 2:
            continue
        name = unquote(args[0])
        if name is None:
            continue
        pairs.append((name, args[1]))
    return pairs


LOCAL_CONST_RE = re.compile(
    rf"\b(\w+)\s*=\s*(new\s+(?:[\w.]+\.)?{CONST_CLASS}\s*\([^;]*?\))\s*;"
)


# `n.Y(<child>, ...)` -- a node's positional children, as opposed to the
# `z.V(new h(name, value), ...)` list that holds its own bindings.
CHILD_LIST_RE = re.compile(r"^[\w.]*\bY\s*\(")

NODE_ASSIGN_RE = re.compile(rf"\b(\w+)\s*=\s*(new\s+(?:[\w.]+\.)?{NODE_CLASS}\s*\()")

# `linkedHashMap.put("mode", new C0542d(Double.valueOf(1830.0d)));`
MAP_PUT_RE = re.compile(
    r'\b(\w+)\.put\(\s*"((?:[^"\\]|\\.)*)"\s*,\s*'
)
MAP_NEW_RE = re.compile(r"\b(\w+)\s*=\s*new\s+(?:Linked)?HashMap\s*\(")

# `Object obj2 = AbstractC1963b.T(q7, IridizeModes.f12235k).f7616a;`
CLOSURE_LOCAL_RE = re.compile(
    r"\b(\w+)\s*=\s*[\w.]*\b[ST]\(\s*\w+\s*,\s*([A-Za-z_]\w*(?:\.\w+)?)\s*[,)]"
)

# `Object obj2 = S4.f7616a;` -- the closure is reached through a field.
FIELD_UNWRAP_RE = re.compile(r"\b(\w+)\s*=\s*(\w+)\.f\d+\w*\s*;")

# `C0587m c0587m = (C0587m) obj2;` -- a cast alias for a closure local.
CAST_ALIAS_RE = re.compile(r"\b(\w+)\s*=\s*\(\s*[\w.]+\s*\)\s*(\w+)\s*;")

# `IridizeModes iridizeModes = IridizeModes.f12235k;`
FILTER_LOCAL_RE = re.compile(r"\b([A-Z]\w+)\s+(\w+)\s*=\s*([A-Z]\w+\.\w+)\s*;")


def find_map_locals(src: str) -> dict[str, list]:
    """Bindings a local map collects through `.put("name", value)` calls.

    The `preset-iridize*` family fills its effect node's parameters this way
    instead of writing them as a literal list, so a node that names such a map
    looked like a node with no bindings at all.
    """
    out: dict[str, list] = {}
    events = [(m.start(), "reset", m.group(1), None) for m in MAP_NEW_RE.finditer(src)]
    for m in MAP_PUT_RE.finditer(src):
        open_idx = src.rindex("(", m.start(), m.end())
        close = match_paren(src, open_idx)
        if close == -1:
            continue
        args = split_args(src[open_idx + 1 : close])
        if len(args) != 2:
            continue
        events.append((m.start(), "put", m.group(1), (m.group(2), args[1])))
    for _, kind, var, payload in sorted(events, key=lambda e: e[0]):
        # A fresh map discards whatever the previous one of that name held;
        # a file registering a dozen looks reuses the same variable for each.
        if kind == "reset":
            out[var] = []
        else:
            out.setdefault(var, []).append(payload)
    return out


def find_node_locals(src: str) -> dict[str, str]:
    """Locals holding a graph node, keyed by variable name."""
    out: dict[str, str] = {}
    for m in NODE_ASSIGN_RE.finditer(src):
        open_idx = src.index("(", m.start(2))
        close = match_paren(src, open_idx)
        if close == -1:
            continue
        out[m.group(1)] = src[m.start(2) : close + 1]
    return out


# `public static final X f12608a = h0(SmoothKaleidoscope.f12607k, "...")`
# in a companion class: the field stands for another filter.
FIELD_ALIAS_RE = re.compile(
    r"public static final \w+ (f\d+\w*)\s*=\s*[\w.]*\(?\s*([A-Z]\w+)\.\w+"
)


def build_field_aliases(paths, class_to_id: dict) -> dict:
    """(CompanionClass, field) -> operator id of the filter it stands for."""
    out: dict[tuple[str, str], str] = {}
    for path in paths:
        if not path.stem.endswith("Kt"):
            continue
        for m in FIELD_ALIAS_RE.finditer(path.read_text()):
            target = class_to_id.get(m.group(2))
            if target:
                out[(path.stem, m.group(1))] = target
    return out


class GraphParser:
    def __init__(self, class_to_id: dict[str, str], known_ids: set | None = None):
        self.class_to_id = class_to_id
        # Operator ids, for nodes that name their filter by id rather than class.
        self.known_ids = known_ids or set(class_to_id.values())
        # Locals holding a filter constant, filled in per file.
        self.locals: dict[str, str] = {}
        self.node_locals: dict[str, str] = {}
        # (CompanionClass, field) -> operator, for indirection through a
        # companion that holds several filters.
        self.field_aliases: dict[tuple[str, str], str] = {}
        # Locals holding a filter as a closure, `Object obj2 =
        # AbstractC1963b.T(q7, IridizeModes.f12235k).f7616a;`
        self.closures: dict[str, str] = {}
        # Locals holding a binding map filled by `.put(...)` rather than
        # written as a `z.V(new h(...), ...)` literal.
        self.map_locals: dict[str, list] = {}
        # Interpreter for the descriptor expressions a `K0` list holds.
        self.registry: Registry | None = None
        # The knobs the operator being read declares, so an expression that
        # mentions one keeps the reference instead of a guess.
        self.knobs: set[str] = set()

    def load_locals(self, src: str) -> None:
        self.locals = {m.group(1): m.group(2) for m in LOCAL_CONST_RE.finditer(src)}
        self.closures = {
            m.group(1): m.group(2) for m in CLOSURE_LOCAL_RE.finditer(src)
        }
        # A closure is often re-bound through a cast before use, so follow
        # those aliases; `iridize-gl` reaches its effect filter that way.
        for _ in range(3):
            for pattern in (CAST_ALIAS_RE, FIELD_UNWRAP_RE):
                for m in pattern.finditer(src):
                    target = self.closures.get(m.group(2))
                    if target is not None:
                        self.closures.setdefault(m.group(1), target)
        self.map_locals = find_map_locals(src)
        for m in FILTER_LOCAL_RE.finditer(src):
            self.locals.setdefault(m.group(2), m.group(3))
        # Graphs are often assembled into a local first and only referenced by
        # name in the registration, so those have to be resolvable too.
        self.node_locals = find_node_locals(src)

    def node(self, text: str, depth: int = 0) -> dict:
        if depth > 12:
            raise Unparsed("graph too deep")
        args = call_args(text, NODE_CLASS)
        if args is None:
            raise Unparsed("not a node")
        if len(args) < 2:
            raise Unparsed("node has too few arguments")

        filter_id = self.filter_ref(args[0])

        inputs: dict[str, dict] = {}
        params: dict = {}

        # A node may carry both lists at once:
        #   C0558g0("watercolor-gl", n.Y(<child node>), z.V(<its bindings>))
        # Scanning them together let the child's own bindings be read as this
        # node's, and the child was then never parsed at all -- which is how
        # `preset-pointillism` lost the `cells` stage feeding its watercolour.
        child_list = [a for a in args[1:] if CHILD_LIST_RE.match(a.strip())]
        binding_src = [a for a in args[1:] if a not in child_list]

        # Named bindings, `z.V(new h("source", ...), ...)`, or a local map
        # the surrounding method filled with `.put(...)`.
        rest = " ".join(binding_src) if child_list else " ".join(args[1:])
        bindings = find_pairs(rest)
        if not bindings:
            for token in (a.strip() for a in args[1:]):
                if token in self.map_locals:
                    bindings = self.map_locals[token]
                    break
        for name, raw in bindings:
            try:
                child = self.node(raw, depth + 1)
            except Unparsed:
                pass
            else:
                inputs[name] = child
                continue
            weights = self.channel_weights(raw)
            if weights is not None:
                params.update(weights)
                continue
            value = self.value(raw)
            if isinstance(value, dict) and "input" in value:
                # `P0(x)` names one of the graph's own inputs.  Only the
                # images among those are inputs; the rest are parameter
                # references the caller supplies, and treating
                # `P0("locusTransform")` as an image left the knob unreachable.
                images = IMAGE_INPUTS.get(filter_id) or ["source"]
                if name in images or name in ("source", "source1"):
                    # A reference to one of the operator's own knobs is not an
                    # image: `preset-troubled-waves` came out reading its
                    # source from `intensity`, which no caller ever supplies,
                    # so it rendered from a blank.
                    if value.get("input") in self.knobs:
                        value = {"input": "source"}
                    inputs[name] = value
                else:
                    params[name] = {"bind": value["input"]}
            elif isinstance(value, dict) and "filter" in value:
                # A filter produces an image, so it can only be feeding an
                # input: `preset-mondrian` builds its palette with
                # `color-list-to-palette-image`, and `palette` is an image
                # port. Left among the parameters it reached nothing.
                inputs[name] = value
            elif value is not None:
                params[name] = value

        if filter_id == "locusBlend" and "effect" in inputs:
            # `LocusKt.b` hands the effect stage the whole parameter list of
            # the filter it blends in, building the map by iterating that
            # list rather than writing it out, so there is nothing to read.
            effect = inputs["effect"]
            effect["forward"] = True
            effect.setdefault("inputs", {}).setdefault("source", {"input": "source"})

        if child_list or not inputs:
            # The other node form lists its children positionally, e.g.
            # `C0558g0("emphasize-palette", n.Y(<child>, ...))`; the first is
            # the image flowing through.
            for raw in self.positional_children(" ".join(child_list) if child_list else rest):
                try:
                    child = self.node(raw, depth + 1)
                except Unparsed:
                    value = self.value(raw)
                    if isinstance(value, dict) and "input" in value:
                        _bind_positional_input(inputs, filter_id, value)
                    continue
                # A combine filter takes more than one image, so keep going
                # until every input it samples is bound.
                _bind_positional_input(inputs, filter_id, child)
                if len(inputs) >= len(IMAGE_INPUTS.get(filter_id) or ["source"]):
                    break

        return {"filter": filter_id, "inputs": inputs, "params": params}

    @staticmethod
    def positional_children(text: str) -> list[str]:
        """Top-level `new C0558g0(...)` / `new P0(...)` terms inside a list."""
        out = []
        for cls in (NODE_CLASS, INPUT_CLASS):
            for m in re.finditer(rf"new\s+(?:[\w.]+\.)?{cls}\s*\(", text):
                open_idx = text.index("(", m.end() - 1)
                close = match_paren(text, open_idx)
                if close != -1:
                    out.append(text[m.start() : close + 1])
        return out

    # The six per-channel weights are their own little operator rather than a
    # plain value, and each component may be a bound knob:
    #   h("channels", C0558g0(C0542d(MakeSixColorFloatChannels), z.V(
    #       h("red", C0542d(1.0)), ..., h("hue", P0("hueMul")), ...)))
    # Dropped, `preset-color-reflector` had three knobs that reached nothing.
    CHANNEL_MAKERS = ("MakeSixColorFloatChannels", "MakeSixColorChannels")

    def channel_weights(self, raw: str) -> dict | None:
        args = call_args(raw, NODE_CLASS)
        if not args:
            return None
        inner = call_args(args[0].strip(), CONST_CLASS)
        target = (inner[0] if inner else args[0]).strip()
        if not any(target.startswith(m + ".") or target == m for m in self.CHANNEL_MAKERS):
            return None
        out: dict = {}
        for name, value_raw in find_pairs(" ".join(args[1:])):
            value = self.value(value_raw)
            if isinstance(value, dict) and "input" in value:
                out[f"channels_{name}"] = {"bind": value["input"]}
            elif isinstance(value, (int, float)):
                out[f"channels_{name}"] = float(value)
        return out or None

    def filter_ref(self, text: str) -> str:
        # In the operator slot a `P0("name")` is a reference to that operator,
        # not to one of the graph's inputs.  `lens-blur` names both of its
        # stages this way.
        named = call_args(text, INPUT_CLASS)
        if named and len(named) == 1:
            op = unquote(named[0])
            if op in self.known_ids:
                return op

        args = call_args(text, CONST_CLASS)
        inner = args[0].strip() if args else text.strip()

        # `new C0542d((C0587m) obj2)` -- the filter arrives as a closure held
        # in a local.  The `preset-iridize*` family builds its effect branch
        # this way, and failing to resolve it dropped the branch entirely,
        # leaving a `locusBlend` of the image with itself.
        cast = re.match(r"^\(\s*[\w.]+\s*\)\s*(\w+)$", inner)
        if cast:
            inner = cast.group(1)
        if inner in self.closures:
            inner = self.closures[inner]

        # Some nodes name their filter by operator id rather than class.
        op = unquote(inner)
        if op is not None:
            if op in self.known_ids:
                return op
            raise Unparsed(f'filter reference "{op}"')

        # Others hold it in a local, `C0542d c0542d3 = new C0542d(Foo.f1);`
        if inner in self.locals:
            inner = self.locals[inner]
            args2 = call_args(inner, CONST_CLASS)
            if args2:
                inner = args2[0].strip()

        m = re.match(r"^([A-Z]\w+)\.(\w+)$", inner)
        if m and (m.group(1), m.group(2)) in self.field_aliases:
            return self.field_aliases[(m.group(1), m.group(2))]

        m = CLASS_REF_RE.match(inner)
        if not m:
            raise Unparsed(f"filter reference {inner[:40]}")
        cls = m.group(1)
        resolved = self.resolve_class(cls)
        if resolved is None:
            raise Unparsed(f"unknown filter class {cls}")
        return resolved

    def resolve_class(self, cls: str) -> str | None:
        """Map a referenced class to an operator id.

        Nodes reach a filter three ways: the class itself, its `*Kt`
        companion, or -- for filters implemented outside the shader bank -- by
        a name that matches the operator's kebab-case id.
        """
        if cls in self.class_to_id:
            return self.class_to_id[cls]
        if cls.endswith("Kt") and cls[:-2] in self.class_to_id:
            return self.class_to_id[cls[:-2]]
        for candidate in (cls, cls[:-2] if cls.endswith("Kt") else cls):
            kebab = re.sub(r"(?<!^)(?=[A-Z])", "-", candidate).lower()
            kebab = kebab.replace("-g-l", "-gl").replace("g-l", "gl")
            if kebab in self.known_ids:
                return kebab
        return None

    # Neutral values for the symbols graph expressions expose.  Offsets sit at
    # the origin and scales at unity, which is what the app shows before the
    # user drags the corresponding on-canvas handle.
    SYMBOL_DEFAULTS = {"tx": 0.0, "ty": 0.0, "tz": 0.0, "x": 0.0, "y": 0.0}

    def symbol_value(self, name: str) -> float:
        if name in self.SYMBOL_DEFAULTS:
            return self.SYMBOL_DEFAULTS[name]
        low = name.lower()
        if "scale" in low or "size" in low or "zoom" in low:
            return 1.0
        if "angle" in low or "rot" in low or "offset" in low or "shift" in low:
            return 0.0
        return 0.0

    def dsl_value(self, expr: str):
        """An embedded expression as a value, with the knobs left open.

        `preset-focus` sets its locus with

            (mat3 (vec3 locusScale 0.0 0.0) (vec3 0.0 locusScale 0.0)
                  (vec3 tx ty 1.0))

        and `symbol_value` answers for any name it is asked about -- 1.0 for
        one that reads like a scale, 0.0 otherwise -- so those three knobs
        were replaced by guesses and the matrix came out the identity.  Every
        control the app draws on the canvas for this family moved nothing.
        A knob keeps its place instead, as a hole the renderer fills.
        """
        try:
            tree = dsl.parse(expr)
        except Exception:  # noqa: BLE001 - an unparsed expression is dropped
            return {"expr": expr}
        # The expression may be a filter rather than a value: `preset-chop`
        # builds its palette with `(color-list-to-palette-image
        # (make-color-list (rgba ...) ...))`, and `palette` is an image input
        # on the filter it feeds. Evaluated as a number it failed and was
        # stored as unreadable text.
        node = _dsl_node(tree, self.known_ids, 0, None, self.knobs)
        if node is not None:
            return node
        env, holes = {}, {}
        for name in dsl.free_symbols(tree):
            if name in self.knobs:
                # Spaced by multiplication: at this magnitude a float has
                # no room for `+ 1`, so every marker came back the same knob.
                marker = _HOLE_BASE * (len(holes) + 1)
                env[name], holes[marker] = marker, name
            else:
                env[name] = self.symbol_value(name)
        try:
            value = dsl.evaluate(tree, env)
        except Exception:  # noqa: BLE001
            return {"expr": expr}
        if not holes:
            return value
        filled = _fill_holes(value, holes)
        # A knob that went through arithmetic leaves no marker to find, only a
        # wild number; that is not a value to ship, so the guess stands.
        return value if filled is None else filled

    def value(self, text: str):
        text = text.strip()

        args = call_args(text, INPUT_CLASS)
        if args is not None:
            name = unquote(args[0]) or "source"
            return {"input": name}

        m = DSL_CALL.search(text)
        if m:
            # A parameter written as a DSL expression over the graph's exposed
            # parameters, e.g. "(mat3 (vec3 scale 0 0) ... (vec3 tx ty 1))".
            # Evaluate it now so the runtime never sees the DSL; free symbols
            # take a neutral value chosen from what they name.
            return self.dsl_value(m.group(1))

        args = call_args(text, CONST_CLASS)
        if args is not None:
            inner = args[0].strip()
            n = as_number(inner)
            if n is not None:
                return n
            s = unquote(inner)
            if s is not None:
                return s
            if inner in ("Boolean.TRUE", "true"):
                return True
            if inner in ("Boolean.FALSE", "false"):
                return False
            return None

        n = as_number(text)
        if n is not None:
            return n
        return None


# `LocusKt.b(env, Coral.f12402k, z.T(new h("intensity", ...), ...), ...)`
# is the other registration form: one filter with parameter overrides, wrapped
# in a region mask.  The mask defaults to the whole image, so the graph is a
# single node.
LOCUS_CALL = re.compile(r"\bLocusKt\.\w+\s*\(")


def locus_node(body: str, parser: GraphParser) -> dict | None:
    m = LOCUS_CALL.search(body)
    if not m:
        return None
    open_idx = body.index("(", m.end() - 1)
    close = match_paren(body, open_idx)
    if close == -1:
        return None
    args = split_args(body[open_idx + 1 : close])
    if len(args) < 2:
        return None

    try:
        filter_id = parser.filter_ref(args[1])
    except Unparsed:
        return None

    pinned: dict = {}
    for name, raw in find_pairs(" ".join(args[2:])):
        value = parser.value(raw)
        if value is not None and not (isinstance(value, dict) and "input" in value):
            pinned[name] = value

    # `LocusKt.b` does not wrap the filter, it blends it:
    #
    #   LocusBlend(source   = source,
    #              effect   = <wrapped>(source = source, ...its own parameters),
    #              locusMode, locusTransform)
    #
    # Returning the wrapped filter alone dropped the blend and every knob it
    # forwards, so `emphasize-palette-gl` was a bare `emphasize-palette` at
    # defaults with nothing to adjust.
    effect = {
        "filter": filter_id,
        "inputs": {"source": {"input": "source"}},
        "params": {k: v for k, v in pinned.items() if not k.startswith("locus")},
        # The wrapper forwards the whole parameter list of what it wraps.
        "forward": True,
    }
    locus = {k: v for k, v in pinned.items() if k.startswith("locus")}
    return {
        "filter": "locusBlend",
        "inputs": {"source": {"input": "source"}, "effect": effect},
        "params": locus,
    }


# Some looks are written as a DSL expression instead of a node tree:
#   (rgb-spike (adjust source :saturation -1.0) :mode 1 :power 0.0)
# The nested call is the input to the outer one, so it maps onto a graph
# directly.
DSL_EXPR = re.compile(r'\bq0\(\s*"((?:[^"\\]|\\.)*)"\s*\)')


def dsl_to_graph(
    expr: str, known_ids: set, depth: int = 0, bound: set | None = None
) -> dict | None:
    """Turn a nested preset expression into a graph node."""
    if depth > 10:
        return None
    try:
        tree = dsl.parse(expr)
    except Exception:  # noqa: BLE001
        return None
    return _dsl_node(tree, known_ids, depth, None, bound)


# Filter id -> the image inputs its shader samples, in declaration order.
# Filled from the shaders before any graph is read.
IMAGE_INPUTS: dict[str, list[str]] = {}
SAMPLER_RE = re.compile(r"__(\w+)__(?:texelFetch__)?\s*\(")


# Filter id -> its parameter names in signature order, for the calls that
# pass arguments positionally.
PARAM_ORDER: dict[str, list[str]] = {}

# Filter id -> the order a lambda declares its own knobs in.  A shader's
# positional order is its own and does not follow the GLSL signature, which is
# why positional knobs are otherwise left alone; a lambda writes the order
# down, so a call like `(gaussian-blur2 source blurRadius)` can be read.
LAMBDA_PARAM_ORDER: dict[str, list[str]] = {}


def load_param_order(shaders: dict) -> None:
    PARAM_ORDER.clear()
    for fid, rec in shaders.items():
        PARAM_ORDER[fid] = [p["name"] for p in rec.get("params", [])]


def load_image_inputs(shaders: dict) -> None:
    """Record which images each filter samples, in the order they appear."""
    IMAGE_INPUTS.clear()
    for fid, rec in shaders.items():
        text = rec.get("main", "") + "".join(rec.get("helpers") or [])
        seen: list[str] = []
        for name in SAMPLER_RE.findall(text):
            if name not in seen:
                seen.append(name)
        if seen:
            IMAGE_INPUTS[fid] = seen


def _mapped_value(value, env):
    """The base value of a `(mapped :value V :map <image>)` argument.

    The engine modulates the parameter across the image with the map it
    renders.  Nothing here reproduces that, but `V` is the value being
    modulated, and taking it keeps the effect rather than dropping the whole
    argument -- `candyland` is an `adjust` whose only setting arrives this way.
    """
    if not isinstance(value, list) or not value or str(value[0]) != "mapped":
        return None
    for i in range(1, len(value) - 1):
        key = value[i]
        if isinstance(key, dsl.Sym) and str(key) == ":value":
            try:
                return dsl.evaluate(value[i + 1], env or {})
            except Exception:  # noqa: BLE001
                return None
    return None


# Stand-ins for a knob inside an expression, far from any real setting so a
# survivor is unmistakable.
_HOLE_BASE = 1e30


def _fill_holes(value, holes: dict):
    """`value` with each marker put back as the knob it stood for.

    Returns None if a marker was consumed by arithmetic rather than landing
    somewhere whole, which means the expression cannot be represented this way.
    """
    if isinstance(value, list):
        out = []
        for item in value:
            filled = _fill_holes(item, holes)
            if filled is None:
                return None
            out.append(filled)
        return out
    if isinstance(value, (int, float)):
        if value in holes:
            return {"bind": holes[value]}
        return None if abs(value) >= _HOLE_BASE / 2 else value
    return value


def _resolved(node) -> int:
    """How many filter nodes a parse managed to resolve."""
    if not isinstance(node, dict) or "filter" not in node:
        return 0
    return 1 + sum(_resolved(c) for c in (node.get("inputs") or {}).values())


def _negated_bind(value, bound) -> dict | None:
    """`(neg knob)` where `knob` is one the caller supplies."""
    if not isinstance(value, list) or len(value) != 2:
        return None
    if str(value[0]) != "neg" or not isinstance(value[1], dsl.Sym):
        return None
    name = str(value[1])
    return {"bind": name, "neg": True} if bound and name in bound else None


def _expr_with_holes(value, env, bound):
    """An expression mentioning the lambda's knobs, as a value with holes.

    Returns None when it mentions none of them, or when one is consumed by
    arithmetic and leaves nothing to put back.
    """
    if not isinstance(value, list) or not bound:
        return None
    try:
        free = dsl.free_symbols(value)
    except Exception:  # noqa: BLE001
        return None
    knobs = [s for s in free if s in bound]
    if not knobs:
        return None
    holes, scope = {}, dict(env or {})
    for name in free:
        if name in bound:
            marker = _HOLE_BASE * (len(holes) + 1)
            scope[name], holes[marker] = marker, name
        elif name not in scope:
            return None
    try:
        evaluated = dsl.evaluate(value, scope)
    except Exception:  # noqa: BLE001
        return None
    return _fill_holes(evaluated, holes)


def _struct_fields(value, env, bound) -> dict | None:
    """`(make-vignette :intensity 0.35 :color (rgba ...))` as its fields.

    The app groups several of a filter's knobs behind one struct argument and
    the filter declares them flattened -- `adjust` has `vignette_intensity`,
    `vignette_hardness`, `vignette_color` and `vignette_transform`. Without
    this the whole struct failed to evaluate and every one of them was lost.
    """
    if not isinstance(value, list) or not value:
        return None
    if not str(value[0]).startswith("make-"):
        return None
    out: dict = {}
    i = 1
    while i + 1 < len(value) + 1 and i < len(value):
        key = value[i]
        if not (isinstance(key, dsl.Sym) and str(key).startswith(":")):
            i += 1
            continue
        if i + 1 >= len(value):
            break
        name, raw = str(key)[1:], value[i + 1]
        if isinstance(raw, dsl.Sym):
            # The knob wins over its own default here too, as it does for a
            # plain argument: a default says where the control starts.
            if bound and str(raw) in bound:
                out[name] = {"bind": str(raw)}
            elif env and str(raw) in env:
                out[name] = env[str(raw)]
        else:
            try:
                out[name] = dsl.evaluate(raw, env or {})
            except Exception:  # noqa: BLE001
                pass
        i += 2
    return out or None


def _bind_positional_input(inputs: dict, op: str, node: dict) -> None:
    """Attach a positional image argument to the next free image input.

    `schema6-preset` reads `(linear-blend source1 (lum-grad ...) ...)`, where
    the second argument is a whole subgraph.  Binding every positional image
    to `source` kept only the first, so the filter blended the image with
    itself and returned a flat result.
    """
    for name in IMAGE_INPUTS.get(op) or ["source"]:
        if name not in inputs:
            inputs[name] = node
            return


def _dsl_node(
    tree,
    known_ids: set,
    depth: int,
    env: dict | None = None,
    bound: set | None = None,
) -> dict | None:
    if not isinstance(tree, list) or not tree:
        return None
    op = str(tree[0])
    if op in TRANSPARENT_OPS:
        # Pass through to whatever it wraps.
        for i in range(1, len(tree)):
            item = tree[i]
            if isinstance(item, list):
                inner = _dsl_node(item, known_ids, depth + 1, env, bound)
                if inner is not None:
                    return inner
        return None
    if op not in known_ids:
        return None

    inputs: dict[str, dict] = {}
    params: dict = {}
    # Which positional slot the next unnamed argument fills.
    slot = 0
    i = 1
    while i < len(tree):
        item = tree[i]
        if isinstance(item, dsl.Sym) and str(item).startswith(":"):
            key = str(item)[1:]
            if i + 1 >= len(tree):
                break
            value = tree[i + 1]
            child = _dsl_node(value, known_ids, depth + 1, env, bound) if isinstance(value, list) else None
            if child is not None:
                inputs[key] = child
            elif isinstance(value, dsl.Sym):
                if str(value) in dsl.SOURCE_NAMES:
                    inputs[key] = {"input": "source"}
                elif bound and str(value) in bound:
                    # A lambda knob passed straight through; the value comes
                    # from the caller, so record which knob feeds this slot.
                    # This has to win over the defaults below: a knob that
                    # declares one was being baked in as that literal, which
                    # left the control connected to nothing -- `disco-planet`
                    # passes `:intensity innerIntensity` and moved its slider
                    # for no effect at all.
                    params[key] = {"bind": str(value)}
                elif env and str(value) in env:
                    params[key] = env[str(value)]
            else:
                negated = _negated_bind(value, bound)
                if negated is not None:
                    # `:intensity (neg intensity)` -- an unsharp mask is a
                    # blend towards the blur run backwards, and the sign has
                    # to travel with the binding.
                    params[key] = negated
                    i += 2
                    continue
                held = _expr_with_holes(value, env, bound)
                if held is not None:
                    # The same as the Java-registered path: an expression that
                    # mentions one of the lambda's own knobs keeps a hole
                    # where the knob goes rather than a stand-in number.
                    params[key] = held
                    i += 2
                    continue
                try:
                    params[key] = dsl.evaluate(value, env or {})
                except Exception:  # noqa: BLE001
                    fields = _struct_fields(value, env, bound)
                    if fields is not None:
                        # `:vignette (make-vignette :intensity 0.35 ...)` is a
                        # struct the filter takes apart. `adjust` calls the
                        # pieces `vignette_intensity` and friends; the
                        # `vignette` filter calls them `intensity` and
                        # `hardness`, so the target's own list decides.
                        known = set(PARAM_ORDER.get(op) or ())
                        for field, fval in fields.items():
                            prefixed = f"{key}_{field}"
                            if prefixed not in known and field in known:
                                params[field] = fval
                            else:
                                params[prefixed] = fval
                        i += 2
                        continue
                    base = _mapped_value(value, env)
                    if base is not None:
                        params[key] = base
            i += 2
            continue

        if isinstance(item, dsl.Sym) and str(item) in dsl.SOURCE_NAMES:
            _bind_positional_input(inputs, op, {"input": "source"})
            slot += 1
        # A knob passed by position -- `(swirl source intensity x y size)` --
        # is deliberately left unbound: the app's positional order is its own
        # and does not follow the GLSL signature, so guessing put `myswirl`'s
        # intensity into `swirl`'s `modelTransform`.
        elif isinstance(item, dsl.Sym) and bound and str(item) in bound:
            # A knob passed by position. Only where the operator is a lambda,
            # which writes its own order down: `soft-focus` blurs with
            # `(gaussian-blur2 source blurRadius)`, and that second slot is
            # the `radius` the lambda declares. Without it the blur ran at
            # its own default and the control did nothing.
            order = LAMBDA_PARAM_ORDER.get(op)
            images = set(IMAGE_INPUTS.get(op) or ["source"]) | {"source", "source1"}
            if order and slot < len(order) and order[slot] not in images:
                params.setdefault(order[slot], {"bind": str(item)})
            slot += 1
        elif isinstance(item, list):
            child = _dsl_node(item, known_ids, depth + 1, env, bound)
            slot += 1
            if child is not None:
                _bind_positional_input(inputs, op, child)
            else:
                try:
                    value = dsl.evaluate(item, env or {})
                except Exception:  # noqa: BLE001
                    value = None
                if value is not None:
                    params.setdefault(f"_positional{len(params)}", value)
        i += 1

    if not inputs:
        # Nothing was bound, so the node reads the graph's own image.
        inputs[(IMAGE_INPUTS.get(op) or ["source"])[0]] = {"input": "source"}
    # A positional value with nowhere to go is dropped rather than guessed at.
    params = {k: v for k, v in params.items() if not k.startswith("_positional")}
    return {"filter": op, "inputs": inputs, "params": params}


# `X.P(env, FilterClass.field, <callback>, z.T(pairs))` and
# `LocusKt.b(env, FilterClass.field, z.T(pairs), ...)` both mean the same
# thing: one filter with parameter overrides.
# `LocusKt` is deliberately absent: those wrap a filter in a blend rather than
# standing for it, and `locus_node` builds that structure instead.
SINGLE_NODE_CALL = re.compile(r"\bAbstractC\w+\.\w+\s*\(\s*\w+\s*,")


def single_node(body: str, parser: GraphParser) -> dict | None:
    for m in SINGLE_NODE_CALL.finditer(body):
        open_idx = body.index("(", m.start())
        close = match_paren(body, open_idx)
        if close == -1:
            continue
        args = split_args(body[open_idx + 1 : close])
        if len(args) < 2:
            continue
        try:
            filter_id = parser.filter_ref(args[1])
        except Unparsed:
            continue
        params: dict = {}
        for name, raw in find_pairs(" ".join(args[2:])):
            value = parser.value(raw)
            if value is not None and not (isinstance(value, dict) and "input" in value):
                params[name] = value
        return {
            "filter": filter_id,
            "inputs": {"source": {"input": "source"}},
            "params": params,
        }
    return None


# A whole family of looks is written in the app's own language rather than in
# Java at all:
#
#   (lambda ((name preset-vectors)
#            (param smoothing :type #<double> :default 0.05 ...))
#     (adjust (image-view :image (post-impressionism-gl source :smoothing smoothing ...))
#             :luminosity 0.1))
#
# The declaration list names the operator and its parameters; the body is an
# ordinary nested expression, so it converts to a graph like any other.
LAMBDA_LIT = re.compile(r'"((?:[^"\\]|\\.)*)"', re.S)

# `c.T("dreamy", "(lambda ((name \"luminous-lime\") ...")` -- the operator is
# registered under one name while the lambda calls itself another.  Keying by
# the internal name filed `dreamy` under `luminous-lime`, which nothing then
# referenced, so the look was lost.
LAMBDA_REG = re.compile(r'\.[uvT]\(\s*"([a-z][a-z0-9-]*)"\s*,')

# `image-view` only re-samples its input; it carries no effect of its own.
TRANSPARENT_OPS = {"image-view"}


def parse_lambda(text: str) -> tuple[str, dict, dict, object] | None:
    """(name, literal defaults, declarations, body) from a lambda.

    A lambda states its knobs before its body:

        (param modelTransform :type #<mat3>
               :inherit (wave-flow modelTransform) :priority 20)
        (param insideTransform :type #<mat3>
               :inherit (wave-flow modelTransform) :displayName "inside")

    and the body then passes them by name.  Reading only the body's literals
    missed these entirely: `blob` passes nothing but bound names, so it came
    out with no parameters at all.
    """
    try:
        tree = dsl.parse(text)
    except Exception:  # noqa: BLE001
        return None
    if not isinstance(tree, list) or len(tree) < 3:
        return None
    if str(tree[0]) != "lambda":
        return None

    decls, body = tree[1], tree[2]
    if not isinstance(decls, list):
        return None

    # `(lambda (source intensity x y size) (swirl source intensity x y size))`
    # -- the plain form, whose parameters are a bare name list rather than
    # `(param ...)` declarations.  It has no name of its own, so the caller's
    # registered name is the only one, and every parameter is passed through.
    if decls and all(isinstance(d, dsl.Sym) for d in decls):
        plain = {str(d): {} for d in decls}
        return "", {}, plain, body

    name = None
    defaults: dict = {}
    declared: dict = {}
    for decl in decls:
        if not isinstance(decl, list) or not decl:
            continue
        head = str(decl[0])
        if head == "name" and len(decl) > 1:
            name = str(decl[1])
            continue
        if head != "param" or len(decl) < 2:
            continue
        pname = str(decl[1])
        spec: dict = {}
        for i in range(2, len(decl) - 1):
            key = decl[i]
            if not isinstance(key, dsl.Sym):
                continue
            val = decl[i + 1]
            if str(key) == ":default" and not isinstance(val, (list, dsl.Sym)):
                spec["default"] = val
                defaults[pname] = val
            elif str(key) == ":inherit" and isinstance(val, list) and len(val) == 2:
                spec["inherit"] = [str(val[0]), str(val[1])]
            elif str(key) == ":displayName" and isinstance(val, str):
                spec["label"] = val
            elif str(key) == ":type" and isinstance(val, (str, dsl.Sym)):
                spec["type"] = str(val).strip("#<>")
        declared[pname] = spec
    # A lambda need not name itself -- `gaussian-blur2` is registered as
    # `q7.u("gaussian-blur2", C2.f("(lambda ((type #<image>) ...)"))` with no
    # `(name ...)` inside it -- and the registration is the better name
    # anyway. Dropping these lost the operator, and with it every graph that
    # stands on one: `sharpen` and `dehaze` both blend towards a
    # `gaussian-blur2` that could not be resolved.
    return name or "", defaults, declared, body


def lambda_graphs(src: str, parser: GraphParser) -> dict[str, dict]:
    """Every operator this source defines in the app's own language."""
    out: dict[str, dict] = {}
    registered = {}
    for r in LAMBDA_REG.finditer(src):
        registered[r.end()] = r.group(1)
    for m in LAMBDA_LIT.finditer(src):
        raw = m.group(1)
        if "(lambda" not in raw:
            continue
        # The name it was registered under wins over the one it gives itself;
        # the literal may sit a call or two inside the registration, so take
        # the nearest one preceding it.
        before = [k for k in registered if k <= m.start()]
        outer = registered[max(before)] if before else None
        try:
            text = raw.encode().decode("unicode_escape")
        except Exception:  # noqa: BLE001
            text = raw
        parsed = parse_lambda(text)
        if parsed is None:
            continue
        name, defaults, declared, body = parsed
        name = outer or name
        if not name:
            continue
        # Names the body passes through rather than setting, so the node
        # records the binding instead of losing the argument.
        # Every knob the lambda declares, not only the ones without a
        # default: a default says what the control starts at, not that the
        # node should be wired to the number instead of the control.
        bound = set(declared)
        LAMBDA_PARAM_ORDER.setdefault(name, list(declared))
        node = _dsl_node(body, parser.known_ids, 0, defaults, bound)
        if node is not None:
            out[name] = {"id": name, "root": node, "declared": declared}
    return out


def declared_from_k0(body: str, registry: Registry) -> dict:
    """Knobs a Java-registered look declares in its `K0` parameter list.

    `preset-color-reflector` names `hueMul`, `satMul` and `lumMul` there and
    nowhere else, so without reading it the look had nothing to adjust.
    """
    m = K0_CALL.search(body)
    if not m:
        return {}
    open_idx = body.index("(", m.end() - 1)
    close = match_paren(body, open_idx)
    if close == -1:
        return {}
    args = split_args(body[open_idx + 1 : close])
    if not args:
        return {}
    listed = re.match(r"^(?:[\w.]+\.)?[nm]\.X\((.*)\)$", args[0].strip(), re.S)
    exprs = split_args(listed.group(1)) if listed else [args[0]]
    out: dict = {}
    for expr in exprs:
        try:
            spec = registry.eval_expr(expr)
        except Exception:  # noqa: BLE001
            continue
        if spec and spec.get("name") and spec.get("default") is not None:
            out[spec["name"]] = {"default": spec["default"], "label": spec.get("label")}
    return out


# `q7.u(str, ...)` -- the operator name comes from a field the subclass sets
# through `super("sharpen", ...)`, so the registration itself names nothing.
VAR_REGISTER_RE = re.compile(r"\.[uv]\(\s*(?!\")\w+\s*,")
SUPER_NAME_RE = re.compile(r'super\(\s*"([a-z][a-z0-9-]*)"\s*,')
EXTENDS_RE = re.compile(r"\bclass\s+(\w+)\s+extends\s+([\w.]+)")


def subclass_graphs(paths, parser: GraphParser, known: set) -> dict[str, dict]:
    """Looks a base class registers under a name only its subclasses know.

    `UnsharpMask` registers `(linear-blend source (gaussian-blur2 source
    blurRadius) :intensity (neg intensity))` under a field, and `Sharpen`
    supplies the field through `super("sharpen", ...)`.  Neither half names an
    operator on its own, so the look was invisible from both sides.
    """
    by_name = {p.stem: p for p in paths}
    parents = {}
    for path in paths:
        m = EXTENDS_RE.search(path.read_text())
        if m:
            parents[m.group(1)] = m.group(2).rsplit(".", 1)[-1]

    out: dict[str, dict] = {}
    for path in paths:
        src = path.read_text()
        for op in SUPER_NAME_RE.findall(src):
            # Re-parsed on every pass rather than skipped once seen: the base
            # class blends towards a `gaussian-blur2` that only a later pass
            # can resolve, and the caller keeps whichever parse got furthest.
            if op in out:
                continue
            seen, parent = set(), parents.get(path.stem)
            while parent and parent not in seen:
                seen.add(parent)
                parent_path = by_name.get(parent)
                if parent_path is not None:
                    node = _variable_registration(parent_path.read_text(), parser)
                    if node is not None:
                        out[op] = {
                            "id": op,
                            "root": node,
                            "declared": _super_declared(src, op, parser),
                            "source": str(path),
                        }
                        break
                parent = parents.get(parent)
    return out


def _super_declared(src: str, op: str, parser: GraphParser) -> dict:
    """The knobs a subclass passes to its base through `super("op", <list>)`.

    The base holds the list in a field and splices it into the registration,
    so the names live on one side and the expression on the other:
    `Sharpen` states its `intensity` and `blurRadius` this way.
    """
    if parser.registry is None:
        return {}
    m = re.search(rf'super\(\s*"{re.escape(op)}"\s*,', src)
    if not m:
        return {}
    open_idx = src.rindex("(", m.start(), m.end())
    close = match_paren(src, open_idx)
    if close == -1:
        return {}
    args = split_args(src[open_idx + 1 : close])
    out: dict = {}
    for arg in args[1:]:
        listed = re.match(r"^(?:[\w.]+\.)?[nm]\.X\((.*)\)$", arg.strip(), re.S)
        exprs = split_args(listed.group(1)) if listed else [arg]
        for expr in exprs:
            try:
                spec = parser.registry.eval_expr(expr)
            except Exception:  # noqa: BLE001
                continue
            if spec and spec.get("name") and spec.get("default") is not None:
                out[spec["name"]] = {
                    "default": spec["default"],
                    "label": spec.get("label"),
                }
    return out


def _variable_registration(src: str, parser: GraphParser) -> dict | None:
    """The graph a class registers under a variable operator name."""
    for m in VAR_REGISTER_RE.finditer(src):
        open_idx = src.rindex("(", m.start(), m.end())
        close = match_paren(src, open_idx)
        if close == -1:
            continue
        body = src[open_idx + 1 : close]
        dm = None if f"new {NODE_CLASS}(" in body else DSL_EXPR.search(body)
        if dm:
            node = dsl_to_graph(dm.group(1), parser.known_ids)
            if node is not None:
                return node
    return None


def extract(src: str, parser: GraphParser) -> dict[str, dict]:
    """Every graph registered in one decompiled file."""
    out: dict[str, dict] = {}
    for m in REGISTER_RE.finditer(src):
        name = m.group(1)
        open_idx = src.rindex("(", m.start(), m.end())
        close = match_paren(src, open_idx)
        if close == -1:
            continue
        body = src[open_idx + 1 : close]
        # Locals are scoped to everything up to this registration: a file
        # registering a dozen looks reuses the same variable names, and
        # reading them file-wide gave every `preset-iridize*` the last one's
        # settings.
        parser.load_locals(src[:close + 1])
        declared = declared_from_k0(body, parser.registry) if parser.registry else {}
        parser.knobs = set(declared)
        # The root node is the outermost C0558g0 in the registration.  A look
        # written as a DSL expression has no node tree at all; where both
        # appear the expression is a nested argument -- a palette, say -- and
        # taking it as the root replaced the whole of `preset-chop` with the
        # `color-list-to-palette-image` buried inside it.
        dm = None if f"new {NODE_CLASS}(" in body else DSL_EXPR.search(body)
        if dm:
            node = dsl_to_graph(dm.group(1), parser.known_ids, bound=set(declared))
            if node is not None:
                out[name] = {"id": name, "root": node, "declared": declared}
                continue

        node = single_node(body, parser)
        if node is None:
            node = locus_node(body, parser)
        if node is not None:
            out[name] = {"id": name, "root": node, "declared": declared}
            continue

        idx = body.find(f"new {NODE_CLASS}(")
        if idx == -1:
            # The registration may just name a local holding the graph.
            for var in re.findall(r"\b(\w+)\b", body):
                node_src = parser.node_locals.get(var)
                if not node_src:
                    continue
                try:
                    root = parser.node(node_src)
                except Unparsed:
                    continue
                out[name] = {"id": name, "root": root}
                break
            if name in out:
                continue
            idx = body.find(NODE_CLASS + "(")
            if idx == -1:
                continue
            idx = body.rfind("new ", 0, idx)
            if idx == -1:
                continue
        node_open = body.index("(", idx)
        node_close = match_paren(body, node_open)
        if node_close == -1:
            continue
        try:
            root = parser.node(body[idx : node_close + 1])
        except Unparsed:
            continue
        out[name] = {"id": name, "root": root, "declared": declared}
    return out


def main() -> None:
    shaders = json.loads(Path("work/shaders.json").read_text())
    load_image_inputs(shaders)
    load_param_order(shaders)
    class_to_id = {rec["class"]: fid for fid, rec in shaders.items()}
    # CPU filters are valid graph nodes too, so their ids must be resolvable.
    from gltcstdio.backends.cpu import REGISTRY as CPU_REGISTRY

    # Keyed by class, `class_to_id` keeps only one operator per class, so the
    # known set has to come from the operator ids themselves -- several
    # classes register more than one.
    known = set(shaders) | set(CPU_REGISTRY)
    parser = GraphParser(class_to_id, known)

    root = Path(sys.argv[1] if len(sys.argv) > 1 else "work/decompiled")
    colors = load_colors(root)
    parser.registry = Registry(
        (root / "sources/V4/AbstractC0565h2.java").read_text(), colors
    )
    parser.registry.run()
    parser.field_aliases = build_field_aliases(
        sorted((root / "sources").rglob("*Kt.java")), class_to_id
    )
    graphs: dict[str, dict] = {}
    scanned = 0
    files = [
        p
        for p in sorted((root / "sources").rglob("*.java"))
        if ".v(" in (t := p.read_text()) or ".u(" in t or "(lambda" in t
    ]
    scanned = len(files)
    # Graphs may use other graphs as nodes, so repeat until nothing new
    # resolves: each pass makes the previous pass's ids referenceable.
    for _ in range(4):
        before = len(graphs)
        for path in files:
            src = path.read_text()
            parser.load_locals(src)
            found = extract(src, parser)
            found.update(lambda_graphs(src, parser))

            for name, g in found.items():
                g["source"] = str(path)
                # A later pass sees operators the earlier ones did not, and a
                # node it could not resolve was dropped rather than kept as a
                # hole -- so the first parse of a graph that stands on another
                # graph is short, and only adding new names left it that way.
                # `glass-marble` came out as its outermost `adjust` with the
                # `lens-blur` and `globe` under it gone, and `schema4-preset`
                # lost both of the graphs it blends. Keep whichever parse
                # resolved more of the tree.
                if name not in graphs or _resolved(g["root"]) > _resolved(
                    graphs[name]["root"]
                ):
                    graphs[name] = g
        # A base class may register a look under a name only its subclasses
        # know; that needs every file in hand, so it runs after the sweep.
        for name, g in subclass_graphs(files, parser, set(graphs)).items():
            # Same as above: the first pass cannot see the operators a later
            # one defines, so keep whichever parse resolved more.
            if name not in graphs or _resolved(g["root"]) > _resolved(
                graphs[name]["root"]
            ):
                graphs[name] = g
        parser.known_ids |= set(graphs)
        if len(graphs) == before:
            break

    dest = Path("work/graphs.json")
    dest.write_text(json.dumps(graphs, indent=1))

    def depth(node, d=1):
        return max([d] + [depth(c, d + 1) for c in node.get("inputs", {}).values()])

    def count(node):
        return 1 + sum(count(c) for c in node.get("inputs", {}).values())

    print(f"{len(graphs)} filter graphs from {scanned} files -> {dest}")
    if graphs:
        sizes = [count(g["root"]) for g in graphs.values()]
        print(f"  nodes per graph: min {min(sizes)}, max {max(sizes)}")
        for name in list(graphs)[:5]:
            g = graphs[name]
            print(f"   {name:28s} {count(g['root'])} nodes, depth {depth(g['root'])}")


if __name__ == "__main__":
    main()
