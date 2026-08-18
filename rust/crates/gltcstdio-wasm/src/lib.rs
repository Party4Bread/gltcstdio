//! WebGPU bindings: the same bank, rendered in a browser.
//!
//! Images cross as `Uint8Array` of RGBA8 with an explicit width and height,
//! which is exactly what `ImageData` holds, so a canvas round-trip needs no
//! conversion on either side.
//!
//! ```js
//! import init, { Filters } from "./gltcstdio_wasm.js";
//! await init();
//! const filters = await Filters.open();
//! const out = await filters.render("halftone", data, w, h, '{"intensity":0.8}');
//! ```

use gltcstdio::{bank, Backend, Fidelity, FilterSpec, Image, Params, Renderer, Value};
use wasm_bindgen::prelude::*;

/// A renderer holding an open WebGPU device.
#[wasm_bindgen]
pub struct Filters {
    inner: Renderer,
    /// Images bound to the secondary inputs a filter reads.
    inputs: std::collections::HashMap<String, Image>,
}

#[wasm_bindgen]
impl Filters {
    /// Open a WebGPU device.  Rejects if the browser has none.
    pub async fn open() -> Result<Filters, JsError> {
        console_error_panic_hook::set_once();
        // wgpu reports what it refuses through `log`; without a sink those
        // messages are lost and a failed pipeline looks like a blank frame.
        let _ = console_log::init_with_level(log::Level::Warn);
        let inner = Renderer::new()
            .await
            .map_err(|e| JsError::new(&e.to_string()))?;
        if !inner.has_gpu() {
            // Say what the driver said.  "No WebGPU" on its own leaves the
            // reader guessing between a browser without the API, a GPU the
            // browser will not use, and a driver that refused the request.
            let why = inner.gpu_error().unwrap_or("the adapter request returned nothing");
            return Err(JsError::new(&format!(
                "no WebGPU device: {why}. The API is present only if \
                 `navigator.gpu` exists; a device on top of it also needs a \
                 GPU the browser is willing to use."
            )));
        }
        Ok(Filters {
            inner,
            inputs: std::collections::HashMap::new(),
        })
    }

    /// Render `rgba` through a filter, returning RGBA8 of the same size.
    ///
    /// `params` is a JSON object of parameter values; anything it omits keeps
    /// the filter's own default.
    pub async fn render(
        &mut self,
        filter_id: String,
        rgba: Vec<u8>,
        width: u32,
        height: u32,
        params: Option<String>,
    ) -> Result<Vec<u8>, JsError> {
        let image = Image::new(width, height, rgba);
        let values = parse_params(params.as_deref())?;
        let out = self
            .inner
            .apply_with_inputs_async(&filter_id, &image, &values, &self.inputs)
            .await
            .map_err(|e| JsError::new(&e.to_string()))?;
        Ok(out.data)
    }

    /// Render a chain the page built, described as JSON.
    ///
    /// The shape is the one the bank stores a curated look in:
    /// `{"filter": id, "inputs": {port: node}, "params": {name: value}}`,
    /// where a node is either another of these or `{"input": "source"}`.
    pub async fn render_graph(
        &mut self,
        graph: String,
        rgba: Vec<u8>,
        width: u32,
        height: u32,
    ) -> Result<Vec<u8>, JsError> {
        let node: gltcstdio::FilterNode = serde_json::from_str(&graph)
            .map_err(|e| JsError::new(&format!("graph: {e}")))?;
        let image = Image::new(width, height, rgba);
        // The bound images are offered to the graph's leaves as well as to
        // each filter's named inputs, so a chain can read from more than one.
        let out = self
            .inner
            .apply_graph_with_sources_async(&node, &image, &Params::new(), &self.inputs)
            .await
            .map_err(|e| JsError::new(&self.explain(e)))?;
        Ok(out.data)
    }

    /// Bind an image to every secondary input a filter might read.
    ///
    /// The page offers one slot rather than one per name: a filter reads at
    /// most a couple, and anything left unbound falls back to the main image.
    pub fn set_input(&mut self, names: Vec<String>, rgba: Vec<u8>, width: u32, height: u32) {
        let image = Image::new(width, height, rgba);
        for name in names {
            self.inputs.insert(name, image.clone());
        }
    }

    /// Forget every bound secondary input.
    pub fn clear_inputs(&mut self) {
        self.inputs.clear();
    }

    /// Drop what the renderer remembers having rendered and uploaded.
    ///
    /// Both caches bound themselves, so this is for a page that wants the
    /// memory back sooner -- or one measuring what they are worth, which
    /// cannot be timed through a cache holding the answer already.
    pub fn forget_cached(&mut self) {
        self.inner.forget_stages();
        self.inner.forget_uploads();
    }

    /// Drop the rendered stages but keep the uploaded images, which is what
    /// separates what each cache is worth.
    pub fn forget_stages(&mut self) {
        self.inner.forget_stages();
    }

    /// Stage-cache hits and misses since the module was opened, as `[hits,
    /// misses]`.
    pub fn cache_stats(&self) -> Vec<f64> {
        let (hits, misses) = self.inner.stage_stats();
        vec![hits as f64, misses as f64]
    }

    /// Compile every shader and report the ones this browser refuses, as
    /// JSON `[{id, error}]`.  Used to calibrate the export, since WebGPU is
    /// stricter than native wgpu about sampling in non-uniform control flow.
    pub async fn compile_check(&mut self) -> String {
        let mut failures = Vec::new();
        for spec in bank().filters.values() {
            if spec.gpu.is_none() {
                continue;
            }
            if let Some(error) = self.inner.check(spec).await {
                failures.push(serde_json::json!({ "id": spec.id, "error": error }));
            }
        }
        serde_json::to_string(&failures).unwrap_or_else(|_| "[]".into())
    }

    /// A render failure, with the device's own state if it explains it.
    ///
    /// Once the device is gone every call fails, and the message that matters
    /// is not the one the call produced.
    fn explain(&self, e: gltcstdio::Error) -> String {
        match self.inner.device_lost() {
            Some(why) => format!(
                "the GPU device was lost ({why}). Reload the page; if that does \
                 not help, the browser's GPU process is down and only \
                 restarting the browser will bring it back."
            ),
            None => e.to_string(),
        }
    }

    /// Render through one of the filter's presets.
    pub async fn render_preset(
        &mut self,
        filter_id: String,
        rgba: Vec<u8>,
        width: u32,
        height: u32,
        preset: String,
    ) -> Result<Vec<u8>, JsError> {
        let image = Image::new(width, height, rgba);
        let out = self
            .inner
            .apply_preset_async(&filter_id, &image, &preset, &Params::new())
            .await
            .map_err(|e| JsError::new(&e.to_string()))?;
        Ok(out.data)
    }
}

fn parse_params(json: Option<&str>) -> Result<Params, JsError> {
    let Some(text) = json.filter(|t| !t.trim().is_empty()) else {
        return Ok(Params::new());
    };
    let raw: serde_json::Value =
        serde_json::from_str(text).map_err(|e| JsError::new(&format!("params: {e}")))?;
    let object = raw
        .as_object()
        .ok_or_else(|| JsError::new("params must be a JSON object"))?;
    Ok(object
        .iter()
        .map(|(k, v)| (k.clone(), Value::from_json(v)))
        .collect())
}

/// Every filter id, as a JSON array.
#[wasm_bindgen]
pub fn list_filters() -> String {
    serde_json::to_string(&bank().ids().collect::<Vec<_>>()).unwrap_or_else(|_| "[]".into())
}

/// The image inputs a filter takes, the one flowing through the chain first.
///
/// A shader's samplers are its inputs, and 21 of them name the primary
/// `source1` rather than `source` -- the engine reads either -- so the names
/// come from the shader rather than from a convention. A filter that samples
/// nothing still takes an image, so a chain can pass through it.
fn ports(spec: &FilterSpec) -> Vec<String> {
    let mut names: Vec<String> = match &spec.gpu {
        Some(gpu) => gpu.textures.iter().map(|t| t.name.clone()).collect(),
        None => spec.extra_inputs.clone(),
    };
    let primary = ["source", "source1"]
        .into_iter()
        .find(|p| names.iter().any(|n| n == p));
    match primary {
        Some(primary) => {
            names.retain(|n| n != primary);
            names.insert(0, primary.to_string());
        }
        // A shader that samples nothing takes no image: 28 of them generate
        // their picture outright, and offering an input that cannot reach the
        // shader invites wiring one up and watching it do nothing.  A CPU or
        // graph filter is not a shader and always reads the image it is given.
        None if spec.gpu.is_some() => {}
        None => names.insert(0, "source".to_string()),
    }
    names
}

fn described(spec: &FilterSpec) -> serde_json::Value {
    serde_json::json!({
        "id": spec.id,
        "name": spec.name,
        "category": spec.category,
        "backend": match spec.backend {
            Backend::Gl => "gpu",
            Backend::Cpu => "cpu",
            Backend::Graph => "graph",
        },
        "fidelity": match spec.fidelity {
            Fidelity::Extracted => "extracted",
            Fidelity::Recovered => "recovered",
            Fidelity::Reimplemented => "reimplemented",
        },
        "extraInputs": spec.extra_inputs,
        "ports": ports(spec),
        "wrapped": spec.wrapped,
        "derived": gltcstdio::derived::derived_names(&spec.id),
        "params": spec.params.iter().map(|p| serde_json::json!({
            "name": p.name,
            "type": p.ty,
            "label": p.label,
            "widget": p.widget,
            "min": p.min,
            "max": p.max,
            "step": p.step,
            "default": p.default,
            "engine": p.engine,
            "array": gltcstdio::array_spec(&p.ty)
                .map(|(elem, length)| serde_json::json!({ "elem": elem, "length": length })),
            "choices": p.choices.iter().map(|c| serde_json::json!({
                "value": c.value,
                "label": c.label,
            })).collect::<Vec<_>>(),
        })).collect::<Vec<_>>(),
        // The values come with the name so an editor can load a preset into a
        // node and let the user carry on from it, rather than only re-render.
        "presets": spec.presets.iter().map(|p| serde_json::json!({
            "name": p.name,
            "params": p.params,
        })).collect::<Vec<_>>(),
    })
}

/// One filter's metadata, as JSON: name, category, backend, params, presets.
#[wasm_bindgen]
pub fn describe(filter_id: &str) -> Option<String> {
    serde_json::to_string(&described(bank().get(filter_id)?)).ok()
}

/// The chain a curated look is made of, as JSON, or None if it is one filter.
///
/// Loading one of these into an editor shows how the app builds its own
/// looks, and makes them a starting point rather than a fixed result.
#[wasm_bindgen]
pub fn graph_of(filter_id: &str) -> Option<String> {
    let spec = bank().get(filter_id)?;
    let graph = spec.graph.as_ref()?;
    // Resolved, because a look's own declared defaults are delivered onto its
    // nodes when it renders: 45 of the 175 look different from the raw tree.
    // The engine works that out, so an editor opening one need not.
    let resolved = gltcstdio::graph::resolve_graph(graph, &spec.resolve_raw(None, &Params::new()));
    serde_json::to_string(&resolved).ok()
}

/// The chain as it is stored, with `bind` references left in place.
#[wasm_bindgen]
pub fn raw_graph_of(filter_id: &str) -> Option<String> {
    serde_json::to_string(bank().get(filter_id)?.graph.as_ref()?).ok()
}

/// Every filter's metadata in one call, so the page needs no round trips.
#[wasm_bindgen]
pub fn catalog() -> String {
    let all: Vec<serde_json::Value> = bank().filters.values().map(described).collect();
    serde_json::to_string(&all).unwrap_or_else(|_| "[]".into())
}
