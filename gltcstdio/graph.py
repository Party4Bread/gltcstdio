"""Execution of the app's curated looks, which chain several filters.

Each `preset-*` operator is a small graph rather than a single shader: one
filter's output feeds the next, sometimes through more than one branch.  A
graph is rendered depth-first -- every input is produced before the node that
consumes it -- and each node is rendered by the ordinary backends, so the
graphs need no rendering machinery of their own.
"""

from __future__ import annotations

from typing import Any

import numpy as np


class GraphError(RuntimeError):
    """A graph could not be rendered."""


# The name a node uses for the image flowing through the chain.
PRIMARY_INPUTS = ("source", "source1")


def render_graph(
    node: dict,
    image: np.ndarray,
    render_node,
    overrides: dict[str, Any] | None = None,
    depth: int = 0,
    bindings: dict | None = None,
    path: tuple = (),
) -> np.ndarray:
    """Render one graph node, producing its inputs first.

    `render_node(filter_id, image, params, inputs)` renders a single filter;
    the caller supplies it so this module stays free of backend detail.
    """
    if depth > 16:
        raise GraphError("graph nesting too deep")
    if bindings is None:
        bindings = graph_bindings(node)

    inputs: dict[str, np.ndarray] = {}
    for name, child in (node.get("inputs") or {}).items():
        if "input" in child:
            # A leaf referring to the graph's own input image.
            inputs[name] = image
        else:
            inputs[name] = render_graph(
                child, image, render_node, overrides, depth + 1, bindings, path + (name,)
            )

    primary = image
    for name in PRIMARY_INPUTS:
        if name in inputs:
            primary = inputs.pop(name)
            break

    params = {}
    # Knobs this node takes with the sign flipped, so an override delivered by
    # name below arrives the same way round as the binding did.
    negated = set()
    for k, v in (node.get("params") or {}).items():
        if isinstance(v, dict) and "bind" in v:
            # A lambda knob passed through by name: the value comes from the
            # caller, and with none supplied the filter keeps its own default.
            # `"neg": true` is the app's `(neg intensity)` -- an unsharp mask
            # is a blend towards the blur run backwards.
            if v.get("neg"):
                negated.add(k)
            if overrides and v["bind"] in overrides:
                params[k] = _signed(overrides[v["bind"]], negated, k)
            continue
        params[k] = _fill_holes(v, overrides)

    # An override reaches only the nodes its knob is bound to.  Two stages can
    # set the same name to different values, and delivering by name alone lets
    # one overwrite the other.
    if overrides:
        for k, v in overrides.items():
            binding = bindings.get(k)
            if binding is not None:
                if k in params and path in binding[1]:
                    params[k] = _signed(v, negated, k)
            elif not path or node.get("forward"):
                # A name no node sets.  The app's presets address the root
                # filter's own parameters this way -- `preset-channel-reflect1`
                # is a `channelMultiplier` whose preset supplies the six
                # channel weights -- and a locus wrapper forwards the whole
                # parameter list of the filter it blends in.  `render_node`
                # drops anything the filter does not declare, so offering it
                # here is safe.
                params[k] = _signed(v, negated, k)

    return render_node(node["filter"], primary, params, inputs)


def _fill_holes(value, overrides):
    """A structured value with its open knobs filled from the caller's.

    A literal may have controls left open inside it: the app sets
    `preset-focus`'s locus with `(mat3 (vec3 locusScale 0 0) (vec3 0
    locusScale 0) (vec3 tx ty 1))`, so three of the nine cells are knobs.
    """
    if isinstance(value, dict):
        knob = value.get("bind")
        if knob is None:
            return value
        given = (overrides or {}).get(knob, 0.0)
        return -given if value.get("neg") and isinstance(given, (int, float)) else given
    if isinstance(value, list):
        return [_fill_holes(v, overrides) for v in value]
    return value


def _signed(value, negated: set, name: str):
    """`value` with its sign flipped, for a knob the graph forwards negated."""
    if name not in negated:
        return value
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return -value
    if isinstance(value, (list, tuple)):
        return [-x if isinstance(x, (int, float)) else x for x in value]
    return value


def graph_occurrences(node: dict, path: tuple = (), out: dict | None = None) -> dict:
    """Name -> [(path, value)] for every parameter any node in the graph sets.

    The path is the chain of input names from the root, so an override can be
    delivered to the node it came from rather than to every node that happens
    to use the same name.
    """
    out = {} if out is None else out
    for k, v in (node.get("params") or {}).items():
        if isinstance(v, dict) and "bind" in v:
            continue  # a declared knob, handled from the declaration list
        out.setdefault(k, []).append((path, v))
    for name, child in (node.get("inputs") or {}).items():
        if "input" not in child:
            graph_occurrences(child, path + (name,), out)
    return out


def graph_bindings(node: dict) -> dict:
    """Name -> (default, paths) for the knobs a graph can expose.

    Used to expose a graph's knobs without inventing new ones: whatever its
    nodes set is what a caller can meaningfully change.

    Where several nodes set a name to the same value it is one knob and every
    one of them follows it -- that is how the app's own lambdas bind a shared
    `randomSeed`.  Where they disagree it is two literals that happen to share
    a name, and only the outermost is exposed; pushing one node's value into
    the other is what flattened `schema4-boxes`, whose mirror's near-identity
    `modelTransform` was replacing its streak's 0.064 scale.
    """
    bindings = {}
    for name, occurrences in graph_occurrences(node).items():
        first_value = occurrences[0][1]
        agreed = [p for p, v in occurrences if v == first_value]
        if len(agreed) == len(occurrences):
            bindings[name] = (first_value, agreed)
        else:
            # Outermost wins: `graph_occurrences` walks the root first.
            bindings[name] = (first_value, [occurrences[0][0]])
    return bindings


def graph_params(node: dict) -> dict:
    """The default value of each knob a graph exposes."""
    return {name: value for name, (value, _) in graph_bindings(node).items()}


def bound_targets(node: dict, out: dict | None = None) -> dict:
    """Knob name -> (filter id, parameter name) it is passed into.

    A lambda knob carries no description of its own; the parameter it feeds
    does.  `myswirl` is `(lambda (source intensity x y size) (swirl ...))`,
    so its knobs are `swirl`'s parameters under the lambda's names.
    """
    out = {} if out is None else out
    for key, value in (node.get("params") or {}).items():
        if isinstance(value, dict) and "bind" in value:
            out.setdefault(value["bind"], (node["filter"], key))
    for child in (node.get("inputs") or {}).values():
        if "input" not in child:
            bound_targets(child, out)
    return out


def forwarded_filters(node: dict, out: list | None = None) -> list[str]:
    """Filters a node forwards its whole parameter list to.

    A locus wrapper blends the filter it wraps rather than replacing it, and
    every knob of that filter stays reachable through the wrapper.
    """
    out = [] if out is None else out
    if node.get("forward") and node.get("filter"):
        out.append(node["filter"])
    for child in (node.get("inputs") or {}).values():
        if "input" not in child:
            forwarded_filters(child, out)
    return out


def graph_filters(node: dict, out: list | None = None) -> list[str]:
    """The filter ids a graph uses, outermost first."""
    out = [] if out is None else out
    out.append(node["filter"])
    for child in (node.get("inputs") or {}).values():
        if "input" not in child:
            graph_filters(child, out)
    return out
