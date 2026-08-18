//! The filter bank: what every filter is, what it takes and how it renders.

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

use crate::value::{coerce, from_json, Params, Value};

/// Where a filter's pixels come from.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Backend {
    /// The app's own shader, translated to WGSL.
    Gl,
    /// A numpy reimplementation ported to Rust.
    Cpu,
    /// A curated look: other filters chained together.
    Graph,
}

/// How close the implementation is to the app.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Fidelity {
    /// The app's GLSL, unmodified apart from what WebGPU cannot express.
    Extracted,
    /// Recovered from bytecode rather than source.
    Recovered,
    /// Written here to the app's parameter contract.
    Reimplemented,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ParamSpec {
    pub name: String,
    #[serde(rename = "type")]
    pub ty: String,
    #[serde(default)]
    pub label: String,
    #[serde(default)]
    pub default: Option<serde_json::Value>,
    pub min: Option<f32>,
    pub max: Option<f32>,
    pub step: Option<f32>,
    #[serde(default)]
    pub widget: String,
    #[serde(default)]
    pub choices: Vec<Choice>,
    /// Applied by the engine around the shader rather than passed into it.
    #[serde(default)]
    pub engine: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Choice {
    pub value: serde_json::Value,
    #[serde(default)]
    pub label: String,
}

impl ParamSpec {
    /// The default, in the parameter's declared shape.
    pub fn default_value(&self) -> Value {
        match &self.default {
            Some(raw) => from_json(raw),
            None => Value::Float(0.0),
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
pub struct Preset {
    pub name: String,
    #[serde(default)]
    pub params: BTreeMap<String, serde_json::Value>,
}

/// One node of a curated look.
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(untagged)]
pub enum Node {
    /// `{"input": "source"}` -- the image the caller passed in.
    Input { input: String },
    /// `{"bind": "intensity"}` -- forwards one of the graph's own parameters.
    Bind { bind: String },
    /// A filter applied to inputs that are themselves nodes.
    Filter(Box<FilterNode>),
    /// A literal value.
    Value(serde_json::Value),
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct FilterNode {
    pub filter: String,
    #[serde(default)]
    pub inputs: BTreeMap<String, Node>,
    #[serde(default)]
    pub params: BTreeMap<String, Node>,
    /// A locus wrapper blends the filter it wraps rather than replacing it,
    /// and every knob of that filter stays reachable through the wrapper.
    #[serde(default)]
    pub forward: bool,
}

/// One `vec4` slot of a filter's uniform buffer, and where its value is from.
#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum Slot {
    /// A configurable parameter.
    Param { name: String, slot: usize, ty: String },
    /// An array parameter, which lives after `U` in its own block member.
    ArrayParam {
        name: String,
        ty: String,
        elem: String,
        length: usize,
        array_index: usize,
    },
    /// Output width / height in pixels.
    OutDim { slot: usize, ty: String },
    /// Output width divided by height.
    OutAspect { slot: usize, ty: String },
    /// Input width divided by height.
    InAspect { slot: usize, ty: String },
    /// The dimensions of one bound image.
    InputDim { input: String, slot: usize, ty: String },
    /// The primary image's dimensions.
    InDim { slot: usize, ty: String },
    /// An identity matrix.
    Identity { slot: usize, ty: String },
    /// A fixed value the engine supplies.
    Const { value: Vec<f32>, slot: usize, ty: String },
}

#[derive(Debug, Clone, Deserialize)]
pub struct TextureBinding {
    /// Which input feeds it; unbound inputs fall back to the primary image.
    pub name: String,
    pub binding: u32,
}

#[derive(Debug, Clone, Deserialize)]
pub struct GpuSpec {
    pub slots: Vec<Slot>,
    pub vec4_count: usize,
    pub textures: Vec<TextureBinding>,
    /// The declared array members, in the order they follow `U`.
    #[serde(default)]
    pub arrays: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct FilterSpec {
    pub id: String,
    pub name: String,
    pub category: String,
    pub backend: Backend,
    pub fidelity: Fidelity,
    #[serde(default)]
    pub params: Vec<ParamSpec>,
    #[serde(default)]
    pub presets: Vec<Preset>,
    #[serde(default = "one")]
    pub inputs: usize,
    #[serde(default)]
    pub extra_inputs: Vec<String>,
    #[serde(default)]
    pub graph: Option<FilterNode>,
    /// The shader this filter is the app's blur wrapper around, if it is one.
    ///
    /// The wrapper feeds one of that shader's inputs from a blurred copy of
    /// the source and exposes the radius as a parameter.  It is a graph, but
    /// it is a filter rather than a look someone assembled, so an editor opens
    /// it as one node instead of taking it apart.
    #[serde(default)]
    pub wrapped: Option<String>,
    #[serde(default)]
    pub gpu: Option<GpuSpec>,
}

fn one() -> usize {
    1
}

impl FilterSpec {
    pub fn param(&self, name: &str) -> Option<&ParamSpec> {
        self.params.iter().find(|p| p.name == name)
    }

    pub fn preset(&self, name: &str) -> Option<&Preset> {
        self.presets.iter().find(|p| p.name == name)
    }

    /// Every parameter's value, kept in the shape it was declared in.
    ///
    /// The flattened form suits a uniform buffer; a graph needs the values
    /// themselves, because it passes them on to the nodes its knobs are bound
    /// to and those are filters with their own declared types.
    pub fn resolve_raw(&self, preset: Option<&str>, values: &Params) -> Params {
        let mut out = Params::new();
        for p in &self.params {
            let mut value = p.default_value();
            if let Some(chosen) = preset.and_then(|n| self.preset(n)) {
                if let Some(raw) = chosen.params.get(&p.name) {
                    value = from_json(raw);
                }
            }
            if let Some(given) = values.get(&p.name) {
                value = given.clone();
            }
            out.insert(p.name.clone(), value);
        }
        out
    }

    /// Every parameter's value: the default, then the preset, then `values`.
    ///
    /// Numbers are clamped to the declared range, matching the app's own
    /// controls, and each value is fitted to its declared type.
    pub fn resolve(&self, preset: Option<&str>, values: &Params) -> BTreeMap<String, Vec<f32>> {
        let mut out = BTreeMap::new();
        for p in &self.params {
            let mut value = p.default_value();
            if let Some(chosen) = preset.and_then(|n| self.preset(n)) {
                if let Some(raw) = chosen.params.get(&p.name) {
                    value = from_json(raw);
                }
            }
            if let Some(given) = values.get(&p.name) {
                value = given.clone();
            }
            // A string reaches the filters as its characters' code points:
            // values are flattened to floats everywhere else, and the text
            // overlays are the only readers.
            if p.ty == "string" {
                let text = match &value {
                    Value::Str(s) => s.clone(),
                    other => other
                        .flatten()
                        .iter()
                        .filter_map(|c| char::from_u32(*c as u32))
                        .collect(),
                };
                out.insert(
                    p.name.clone(),
                    text.chars().map(|c| c as u32 as f32).collect(),
                );
                continue;
            }
            let mut flat = coerce(&p.ty, &value);
            if matches!(p.ty.as_str(), "float" | "int") {
                if let (Some(lo), Some(hi)) = (p.min, p.max) {
                    if lo <= hi {
                        flat[0] = flat[0].clamp(lo, hi);
                    }
                }
            }
            out.insert(p.name.clone(), flat);
        }
        out
    }
}

/// Every filter, keyed by id.
#[derive(Debug, Deserialize)]
pub struct Bank {
    pub filters: BTreeMap<String, FilterSpec>,
}

static BANK_JSON: &str = include_str!(concat!(env!("CARGO_MANIFEST_DIR"), "/assets/bank.json"));

impl Bank {
    /// The bundled bank.
    pub fn load() -> Self {
        serde_json::from_str(BANK_JSON).expect("bundled bank.json is valid")
    }

    pub fn get(&self, id: &str) -> Option<&FilterSpec> {
        self.filters.get(id)
    }

    pub fn ids(&self) -> impl Iterator<Item = &str> {
        self.filters.keys().map(String::as_str)
    }

    pub fn categories(&self) -> Vec<&str> {
        let mut v: Vec<&str> = self.filters.values().map(|f| f.category.as_str()).collect();
        v.sort_unstable();
        v.dedup();
        v
    }
}

/// The process-wide bank, parsed once.
pub fn bank() -> &'static Bank {
    use std::sync::OnceLock;
    static BANK: OnceLock<Bank> = OnceLock::new();
    BANK.get_or_init(Bank::load)
}
