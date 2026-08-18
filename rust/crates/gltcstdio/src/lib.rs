//! The filter bank behind gltcstdio.
//!
//! The effect engine these came from is a GLSL pipeline, so most filters here
//! are its own shader source, translated to WGSL and run through wgpu -- natively on
//! Vulkan, Metal or DX12, and in a browser on WebGPU.  The rest are ports of
//! the numpy reimplementations for the effects the app does not build as one
//! static shader, plus the curated looks, which chain other filters.
//!
//! ```no_run
//! use gltcstdio::{params, Image, Renderer};
//!
//! let mut r = Renderer::new_blocking()?;
//! let src = Image::empty(512, 512);
//! let out = r.apply("halftone", &src, &params![("intensity", 0.8)])?;
//! # Ok::<(), gltcstdio::Error>(())
//! ```

#![forbid(unsafe_code)]
// The pixel loops index by coordinate on purpose: most walk two arrays at
// once, and the arithmetic is what makes them readable against the numpy and
// GLSL they were ported from.
#![allow(clippy::needless_range_loop)]

pub mod bank;
pub mod derived;
pub mod graph;
mod image;
mod value;

pub mod cpu;
#[cfg(feature = "gpu")]
pub mod gpu;

pub use bank::{bank, Backend, Bank, Fidelity, FilterNode, FilterSpec, Node, ParamSpec, Preset};
pub use graph::graph_params;
pub use image::Image;
pub use value::{array_spec, coerce, type_shape, Params, Value};

use std::collections::{BTreeMap, HashMap};

/// Anything that can stop a render.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Error {
    /// No filter with that id.
    Unknown(String),
    /// The filter needs the GPU and this build or machine has none.
    NoGpu(String),
    /// The filter has no shader in the bundle.
    NoShader(String),
    /// The GPU accepted the work but could not finish it.
    Render(String),
    /// A curated look that does not resolve.
    Graph(String),
    /// A CPU filter that is not implemented.
    NoCpu(String),
}

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::Unknown(id) => write!(f, "no filter named {id:?}"),
            Error::NoGpu(why) => write!(f, "no GPU available: {why}"),
            Error::NoShader(id) => write!(f, "{id} has no shader in this bundle"),
            Error::Render(why) => write!(f, "render failed: {why}"),
            Error::Graph(why) => write!(f, "graph: {why}"),
            Error::NoCpu(id) => write!(f, "{id} has no CPU implementation"),
        }
    }
}

impl std::error::Error for Error {}

/// Renders filters from the bundled bank.
///
/// Holds the GPU device and the pipelines built so far, so keep one around
/// rather than making a new one per image.
pub struct Renderer {
    #[cfg(feature = "gpu")]
    gpu: Option<gpu::GpuRenderer>,
    /// Why there is no device, when there is none.
    ///
    /// Opening one can fail for reasons only the driver knows, and a caller
    /// that reports "no GPU" without them leaves the user nothing to act on.
    #[cfg(feature = "gpu")]
    gpu_error: Option<String>,
}

impl Renderer {
    /// Open a GPU device, falling back to CPU-only if there is none.
    pub async fn new() -> Result<Self, Error> {
        #[cfg(feature = "gpu")]
        {
            match gpu::GpuRenderer::new().await {
                Ok(g) => Ok(Self {
                    gpu: Some(g),
                    gpu_error: None,
                }),
                Err(e) => {
                    log::warn!("no GPU, CPU filters only: {e}");
                    Ok(Self {
                        gpu: None,
                        gpu_error: Some(e.to_string()),
                    })
                }
            }
        }
        #[cfg(not(feature = "gpu"))]
        {
            Ok(Self {})
        }
    }

    /// [`Renderer::new`] without an async runtime.  Not available on the web.
    #[cfg(all(feature = "blocking", not(target_arch = "wasm32")))]
    pub fn new_blocking() -> Result<Self, Error> {
        pollster::block_on(Self::new())
    }

    /// CPU filters only, with no GPU device at all.
    pub fn cpu_only() -> Self {
        Self {
            #[cfg(feature = "gpu")]
            gpu: None,
            #[cfg(feature = "gpu")]
            gpu_error: None,
        }
    }

    /// Why [`Renderer::has_gpu`] is false, in the driver's own words.
    pub fn gpu_error(&self) -> Option<&str> {
        #[cfg(feature = "gpu")]
        {
            self.gpu_error.as_deref()
        }
        #[cfg(not(feature = "gpu"))]
        {
            None
        }
    }

    /// Build a filter's pipeline and report what the driver refused.
    ///
    /// Returns `None` when the filter compiles, or has no shader to compile.
    pub async fn check(&mut self, spec: &FilterSpec) -> Option<String> {
        #[cfg(feature = "gpu")]
        {
            self.gpu.as_mut()?.check(spec).await
        }
        #[cfg(not(feature = "gpu"))]
        {
            let _ = spec;
            None
        }
    }

    /// Whether a GPU device is open.
    pub fn has_gpu(&self) -> bool {
        #[cfg(feature = "gpu")]
        {
            self.gpu.is_some()
        }
        #[cfg(not(feature = "gpu"))]
        {
            false
        }
    }

    /// Release the images the renderer is holding on the device.
    ///
    /// Uploads are kept by content so a repeated render skips rebuilding the
    /// mip chain, which is most of what one costs. The cache bounds itself, so
    /// this is for a caller that wants the memory back sooner.
    pub fn forget_uploads(&mut self) {
        #[cfg(feature = "gpu")]
        if let Some(gpu) = self.gpu.as_mut() {
            gpu.forget_uploads();
        }
    }

    /// Apply a filter at its defaults, overridden by `values`.
    pub async fn apply_async(
        &mut self,
        id: &str,
        image: &Image,
        values: &Params,
    ) -> Result<Image, Error> {
        self.render_node(id, image, values, &HashMap::new(), 0).await
    }

    /// Apply a filter through one of its presets.
    pub async fn apply_preset_async(
        &mut self,
        id: &str,
        image: &Image,
        preset: &str,
        values: &Params,
    ) -> Result<Image, Error> {
        let spec = bank().get(id).ok_or_else(|| Error::Unknown(id.into()))?;
        let resolved = spec.resolve(Some(preset), values);
        let settings = spec.resolve_raw(Some(preset), values);
        self.render_resolved(spec, image, &resolved, &settings, &HashMap::new(), 0)
            .await
    }

    /// Apply a filter with extra images bound to its secondary inputs.
    pub async fn apply_with_inputs_async(
        &mut self,
        id: &str,
        image: &Image,
        values: &Params,
        inputs: &HashMap<String, Image>,
    ) -> Result<Image, Error> {
        self.render_node(id, image, values, inputs, 0).await
    }

    /// Render a chain the caller describes, rather than one from the bank.
    ///
    /// The node takes the same shape a curated look is stored in -- a filter,
    /// the nodes feeding its inputs, and its parameters -- so a chain built
    /// by hand and one shipped with the app go through the same engine.
    pub async fn apply_graph_async(
        &mut self,
        graph: &bank::FilterNode,
        image: &Image,
        values: &Params,
    ) -> Result<Image, Error> {
        self.render_graph(graph, image, values, &HashMap::new(), 0)
            .await
    }

    /// Render a chain that reads from more than one image.
    ///
    /// A leaf is `{"input": "source"}` for the image passed in, or any other
    /// name to take one of `sources` -- which is how a chain feeds two
    /// different photographs into a blend, rather than the same one twice.
    /// An unbound name falls back to the image passed in, so a graph always
    /// renders even with nothing supplied.
    pub async fn apply_graph_with_sources_async(
        &mut self,
        graph: &bank::FilterNode,
        image: &Image,
        values: &Params,
        sources: &HashMap<String, Image>,
    ) -> Result<Image, Error> {
        self.render_graph(graph, image, values, sources, 0).await
    }

    /// [`Renderer::apply_graph_with_sources_async`] without an async runtime.
    #[cfg(all(feature = "blocking", not(target_arch = "wasm32")))]
    pub fn apply_graph_with_sources(
        &mut self,
        graph: &bank::FilterNode,
        image: &Image,
        values: &Params,
        sources: &HashMap<String, Image>,
    ) -> Result<Image, Error> {
        pollster::block_on(self.apply_graph_with_sources_async(graph, image, values, sources))
    }

    /// [`Renderer::apply_graph_async`] without an async runtime.
    #[cfg(all(feature = "blocking", not(target_arch = "wasm32")))]
    pub fn apply_graph(
        &mut self,
        graph: &bank::FilterNode,
        image: &Image,
        values: &Params,
    ) -> Result<Image, Error> {
        pollster::block_on(self.apply_graph_async(graph, image, values))
    }

    /// [`Renderer::apply_async`] without an async runtime.  Native only.
    #[cfg(all(feature = "blocking", not(target_arch = "wasm32")))]
    pub fn apply(&mut self, id: &str, image: &Image, values: &Params) -> Result<Image, Error> {
        pollster::block_on(self.apply_async(id, image, values))
    }

    /// [`Renderer::apply_preset_async`] without an async runtime.
    #[cfg(all(feature = "blocking", not(target_arch = "wasm32")))]
    pub fn apply_preset(
        &mut self,
        id: &str,
        image: &Image,
        preset: &str,
        values: &Params,
    ) -> Result<Image, Error> {
        pollster::block_on(self.apply_preset_async(id, image, preset, values))
    }

    /// [`Renderer::apply_with_inputs_async`] without an async runtime.
    #[cfg(all(feature = "blocking", not(target_arch = "wasm32")))]
    pub fn apply_with_inputs(
        &mut self,
        id: &str,
        image: &Image,
        values: &Params,
        inputs: &HashMap<String, Image>,
    ) -> Result<Image, Error> {
        pollster::block_on(self.apply_with_inputs_async(id, image, values, inputs))
    }

    pub(crate) async fn render_node(
        &mut self,
        id: &str,
        image: &Image,
        values: &Params,
        inputs: &HashMap<String, Image>,
        depth: usize,
    ) -> Result<Image, Error> {
        let spec = bank().get(id).ok_or_else(|| Error::Unknown(id.into()))?;
        let resolved = spec.resolve(None, values);
        // A graph hands its knobs down to the nodes they are bound to, so the
        // whole resolved set goes with it, not only what the caller set.
        let settings = spec.resolve_raw(None, values);
        self.render_resolved(spec, image, &resolved, &settings, inputs, depth)
            .await
    }

    /// Boxed because a graph node renders another node: an `async fn` cannot
    /// name its own future.
    fn render_resolved<'a>(
        &'a mut self,
        spec: &'static FilterSpec,
        image: &'a Image,
        resolved: &'a BTreeMap<String, Vec<f32>>,
        settings: &'a Params,
        inputs: &'a HashMap<String, Image>,
        depth: usize,
    ) -> std::pin::Pin<Box<dyn std::future::Future<Output = Result<Image, Error>> + 'a>> {
        Box::pin(self.render_resolved_inner(spec, image, resolved, settings, inputs, depth))
    }

    async fn render_resolved_inner(
        &mut self,
        spec: &'static FilterSpec,
        image: &Image,
        resolved: &BTreeMap<String, Vec<f32>>,
        settings: &Params,
        inputs: &HashMap<String, Image>,
        depth: usize,
    ) -> Result<Image, Error> {
        // A few filters have the app build a uniform in Java from the other
        // parameters; `metaballs-gl` renders nothing without its sphere array.
        let resolved = &if derived::derives(&spec.id) {
            let mut merged = resolved.clone();
            merged.extend(derived::compute(&spec.id, resolved));
            merged
        } else {
            resolved.clone()
        };
        match spec.backend {
            Backend::Graph => {
                let node = spec
                    .graph
                    .as_ref()
                    .ok_or_else(|| Error::Graph(format!("{} has no graph", spec.id)))?;
                // A look's leaves read the caller's named images too, so a
                // curated look and a hand-built chain reach them alike.
                self.render_graph(node, image, settings, inputs, depth).await
            }
            Backend::Cpu => cpu::render(spec, image, resolved, inputs),
            Backend::Gl => {
                #[cfg(feature = "gpu")]
                {
                    let gpu = self
                        .gpu
                        .as_mut()
                        .ok_or_else(|| Error::NoGpu("renderer has no device".into()))?;
                    gpu.render(spec, image, resolved, inputs, (image.width, image.height))
                        .await
                }
                #[cfg(not(feature = "gpu"))]
                {
                    let _ = (image, resolved, inputs);
                    Err(Error::NoGpu("built without the gpu feature".into()))
                }
            }
        }
    }
}

/// Every filter id in the bank.
pub fn list_filters() -> impl Iterator<Item = &'static str> {
    bank().ids()
}
