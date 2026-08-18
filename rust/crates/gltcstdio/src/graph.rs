//! Curated looks: filters chained into a small graph.
//!
//! A node names a filter, the images feeding its inputs -- each of which is
//! another node -- and its parameters.  A parameter can be a literal or
//! `{"bind": "intensity"}`, which forwards one of the graph's own knobs, so a
//! look exposes a handful of controls over a chain several filters deep.
//!
//! A graph is rendered depth-first: every input is produced before the node
//! that consumes it, and each node goes through the ordinary backends.

use std::collections::{BTreeMap, HashMap};

use crate::bank::{FilterNode, Node};
use crate::image::Image;
use crate::value::{from_json, to_json, Params, Value};
use crate::{Error, Renderer};

/// How deep a graph may nest before it is assumed to be cyclic.
///
/// A chain nests one level per filter, so this is also the longest chain the
/// editor can build; it is a guard against a cycle rather than a budget, and
/// nothing in the bank comes near it.
const MAX_DEPTH: usize = 64;

/// The names a node uses for the image flowing through the chain.
const PRIMARY_INPUTS: [&str; 2] = ["source", "source1"];

/// Where a node sits in the graph: the input names leading to it from the root.
type Path = Vec<String>;

/// Name -> (the value the outermost node gives it, the paths that follow it).
type Bindings = BTreeMap<String, (serde_json::Value, Vec<Path>)>;

impl Renderer {
    pub(crate) fn render_graph<'a>(
        &'a mut self,
        node: &'a FilterNode,
        image: &'a Image,
        outer: &'a Params,
        sources: &'a HashMap<String, Image>,
        depth: usize,
    ) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<Image, Error>> + 'a>> {
        let bindings = graph_bindings(node);
        // A graph's own nodes start one level in, so depth 0 means only what
        // a caller asked for by name.  Everything inside a chain is a stage
        // feeding another, which is what the stage cache is for.
        Box::pin(self.render_graph_at(node, image, outer, sources, depth + 1, bindings, Vec::new()))
    }

    /// Boxed because a node renders another node: an `async fn` cannot name
    /// its own future.
    #[allow(clippy::too_many_arguments)]
    fn render_graph_at<'a>(
        &'a mut self,
        node: &'a FilterNode,
        image: &'a Image,
        outer: &'a Params,
        sources: &'a HashMap<String, Image>,
        depth: usize,
        bindings: Bindings,
        path: Path,
    ) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<Image, Error>> + 'a>> {
        Box::pin(self.render_graph_inner(node, image, outer, sources, depth, bindings, path))
    }

    #[allow(clippy::too_many_arguments)]
    async fn render_graph_inner(
        &mut self,
        node: &FilterNode,
        image: &Image,
        outer: &Params,
        sources: &HashMap<String, Image>,
        depth: usize,
        bindings: Bindings,
        path: Path,
    ) -> Result<Image, Error> {
        if depth > MAX_DEPTH {
            return Err(Error::Graph("graph nesting too deep".into()));
        }

        let mut inputs: HashMap<String, Image> = HashMap::new();
        for (name, child) in &node.inputs {
            let rendered = match child {
                // A leaf naming an image the caller supplied, or the one
                // flowing through the chain when the name is not bound.  This
                // is what lets a graph read from more than one image.
                Node::Input { input } => {
                    sources.get(input).cloned().unwrap_or_else(|| image.clone())
                }
                Node::Filter(f) => {
                    let mut child_path = path.clone();
                    child_path.push(name.clone());
                    self.render_graph_at(
                        f,
                        image,
                        outer,
                        sources,
                        depth + 1,
                        bindings.clone(),
                        child_path,
                    )
                    .await?
                }
                // Anything else in an input slot means the source; the app
                // reaches its primary input positionally.
                _ => image.clone(),
            };
            inputs.insert(name.clone(), rendered);
        }

        // The chain's image is this node's primary, and is not also offered
        // as a named input -- the backend falls back to the primary for any
        // input a caller did not bind, which comes to the same thing.
        let mut primary = image.clone();
        for name in PRIMARY_INPUTS {
            if let Some(found) = inputs.remove(name) {
                primary = found;
                break;
            }
        }

        let params = node_params(node, outer, &bindings, &path);

        self.render_node(&node.filter, &primary, &params, &inputs, depth)
            .await
    }
}

/// A structured value with its open knobs filled from the caller's.
///
/// Anything that is not a `{"bind": ...}` is carried through untouched, so a
/// plain literal costs one walk and comes back as it was.
fn fill_holes(raw: &serde_json::Value, outer: &Params) -> serde_json::Value {
    match raw {
        serde_json::Value::Object(map) => {
            let Some(serde_json::Value::String(knob)) = map.get("bind") else {
                return raw.clone();
            };
            let Some(given) = outer.get(knob) else {
                // Nothing supplied it, so the cell keeps whatever a caller
                // would have seen: the value resolution above fills every
                // declared knob, so this is a name no filter declares.
                return serde_json::Value::from(0.0);
            };
            let flipped;
            let value = if map.get("neg").and_then(serde_json::Value::as_bool) == Some(true) {
                flipped = negate(given);
                &flipped
            } else {
                given
            };
            to_json(value)
        }
        serde_json::Value::Array(items) => serde_json::Value::Array(
            items.iter().map(|item| fill_holes(item, outer)).collect(),
        ),
        other => other.clone(),
    }
}

/// A value with its sign flipped, for a knob the graph forwards negated.
fn negate(value: &Value) -> Value {
    match value {
        Value::Float(x) => Value::Float(-x),
        Value::Int(i) => Value::Int(-i),
        Value::Seq(xs) => Value::Seq(xs.iter().map(|x| -x).collect()),
        other => other.clone(),
    }
}

fn signed(value: &Value, negated: &std::collections::BTreeSet<String>, name: &str) -> Value {
    if negated.contains(name) {
        negate(value)
    } else {
        value.clone()
    }
}

/// What one node of a graph is given, once the caller's values are delivered.
///
/// This is the whole of a node's parameter resolution, so anything that wants
/// to know what a stage of a look is actually set to -- an editor opening one,
/// as much as the renderer running it -- asks here rather than working it out
/// again and drifting.
fn node_params(node: &FilterNode, outer: &Params, bindings: &Bindings, path: &Path) -> Params {
    let mut params = Params::new();
    // Knobs this node takes with the sign flipped, so an override delivered
    // by name below arrives the same way round as the binding did.
    let mut negated: std::collections::BTreeSet<String> = Default::default();
    for (name, value) in &node.params {
        match value {
            Node::Bind { bind, neg } => {
                // A knob passed through by name: the value comes from the
                // caller, and with none supplied the filter keeps its own
                // default.
                if *neg {
                    negated.insert(name.clone());
                }
                if let Some(given) = outer.get(bind) {
                    params.insert(name.clone(), if *neg { negate(given) } else { given.clone() });
                }
            }
            Node::Value(raw) => {
                // A literal may have knobs left open inside it: the app sets
                // `preset-focus`'s locus with `(mat3 (vec3 locusScale 0 0)
                // (vec3 0 locusScale 0) (vec3 tx ty 1))`, so three of the
                // nine cells are controls rather than numbers.
                params.insert(name.clone(), from_json(&fill_holes(raw, outer)));
            }
            Node::Input { input } => {
                params.insert(name.clone(), Value::Str(input.clone()));
            }
            Node::Filter(_) => {}
        }
    }

    // An override reaches only the nodes its knob is bound to.  Two stages
    // can set the same name to different values, and delivering by name
    // alone lets one overwrite the other.
    for (name, value) in outer {
        match bindings.get(name) {
            Some((_, paths)) => {
                if params.contains_key(name) && paths.contains(path) {
                    params.insert(name.clone(), signed(value, &negated, name));
                }
            }
            None if path.is_empty() || node.forward => {
                // A name no node sets.  The app's presets address the root
                // filter's own parameters this way, and a locus wrapper
                // forwards the whole parameter list of the filter it
                // blends in.  Anything the filter does not declare is
                // dropped when its parameters are resolved.
                params.insert(name.clone(), signed(value, &negated, name));
            }
            None => {}
        }
    }
    params
}

/// A look with every parameter resolved to the value it renders with.
///
/// The result is the same tree with no `bind` left in it, which is what an
/// editor needs to open a look as nodes that behave the way the look does.
pub fn resolve_graph(node: &FilterNode, outer: &Params) -> FilterNode {
    let bindings = graph_bindings(node);
    resolve_at(node, outer, &bindings, &Vec::new())
}

fn resolve_at(node: &FilterNode, outer: &Params, bindings: &Bindings, path: &Path) -> FilterNode {
    let params = node_params(node, outer, bindings, path);
    let mut inputs = BTreeMap::new();
    for (name, child) in &node.inputs {
        let resolved = match child {
            Node::Filter(f) => {
                let mut child_path = path.clone();
                child_path.push(name.clone());
                Node::Filter(Box::new(resolve_at(f, outer, bindings, &child_path)))
            }
            other => other.clone(),
        };
        inputs.insert(name.clone(), resolved);
    }
    FilterNode {
        filter: node.filter.clone(),
        inputs,
        params: params
            .into_iter()
            .map(|(name, value)| (name, Node::Value(to_json(&value))))
            .collect(),
        forward: node.forward,
    }
}

/// Name -> [(path, value)] for every parameter any node in the graph sets.
///
/// The path is the chain of input names from the root, so an override can be
/// delivered to the node it came from rather than to every node that happens
/// to use the same name.
fn graph_occurrences(
    node: &FilterNode,
    path: &Path,
    out: &mut BTreeMap<String, Vec<(Path, serde_json::Value)>>,
) {
    for (name, value) in &node.params {
        // A declared knob is handled from the declaration list.
        if let Node::Value(raw) = value {
            out.entry(name.clone())
                .or_default()
                .push((path.clone(), raw.clone()));
        }
    }
    for (name, child) in &node.inputs {
        if let Node::Filter(f) = child {
            let mut child_path = path.clone();
            child_path.push(name.clone());
            graph_occurrences(f, &child_path, out);
        }
    }
}

/// Name -> (default, paths) for the knobs a graph can expose.
///
/// Where several nodes set a name to the same value it is one knob and every
/// one of them follows it -- that is how the app's own lambdas bind a shared
/// `randomSeed`.  Where they disagree it is two literals that happen to share
/// a name, and only the outermost is exposed.
pub(crate) fn graph_bindings(node: &FilterNode) -> Bindings {
    let mut occurrences = BTreeMap::new();
    graph_occurrences(node, &Vec::new(), &mut occurrences);

    let mut out = Bindings::new();
    for (name, seen) in occurrences {
        let first = seen[0].1.clone();
        let agreed: Vec<Path> = seen
            .iter()
            .filter(|(_, v)| *v == first)
            .map(|(p, _)| p.clone())
            .collect();
        let paths = if agreed.len() == seen.len() {
            agreed
        } else {
            // Outermost wins: the walk visits the root first.
            vec![seen[0].0.clone()]
        };
        out.insert(name, (first, paths));
    }
    out
}

/// The default value of each knob a graph exposes.
pub fn graph_params(node: &FilterNode) -> BTreeMap<String, Value> {
    graph_bindings(node)
        .into_iter()
        .map(|(name, (value, _))| (name, from_json(&value)))
        .collect()
}
