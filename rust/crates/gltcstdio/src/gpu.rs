//! The wgpu renderer: one full-screen triangle per filter.
//!
//! Every shader is a fragment shader over a covering triangle, with the same
//! three-part binding layout the export tool writes:
//!
//!   binding 0  a uniform buffer of `vec4` slots, plus any array parameters
//!   binding 1  the sampler every texture is read through
//!   binding 2+ one texture per image the filter reads
//!
//! What goes in each slot is in the bank, so filling the buffer is a walk over
//! [`Slot`] rather than anything shader-specific.

use std::collections::HashMap;

use crate::bank::{FilterSpec, GpuSpec, Slot};
use crate::image::Image;
use crate::value::array_spec;
use crate::Error;

include!(concat!(env!("OUT_DIR"), "/shaders.rs"));

/// The WGSL for a filter, or None if it has no shader.
pub fn shader_source(id: &str) -> Option<&'static str> {
    SHADERS
        .binary_search_by_key(&id, |(name, _)| name)
        .ok()
        .map(|i| SHADERS[i].1)
}

/// Filters that have a shader, sorted by id.
pub fn shader_ids() -> impl Iterator<Item = &'static str> {
    SHADERS.iter().map(|(name, _)| *name)
}

const TEXTURE_FORMAT: wgpu::TextureFormat = wgpu::TextureFormat::Rgba8Unorm;

struct Prepared {
    pipeline: wgpu::RenderPipeline,
    layout: wgpu::BindGroupLayout,
}

/// How much of the device's memory the upload cache may hold.
///
/// Smaller in a browser, where the GPU is shared with every other tab and the
/// page cannot see how much is left.  Exhausting it takes the whole GPU
/// process down, and no reload brings it back.
///
/// A chain re-rendered with one value changed reuses every input upstream of
/// it, so the budget wants to cover a few stages at the sizes people work at:
/// 128 MB is about thirty 1024x1024 uploads, or five at 2048x2048.
#[cfg(target_arch = "wasm32")]
const UPLOAD_BUDGET: usize = 48 << 20;
#[cfg(not(target_arch = "wasm32"))]
const UPLOAD_BUDGET: usize = 128 << 20;

/// Kept whatever the budget says: the source and a stage either side of it.
const UPLOAD_FLOOR: usize = 3;

/// A GPU device with the pipelines built so far.
pub struct GpuRenderer {
    device: wgpu::Device,
    queue: wgpu::Queue,
    sampler: wgpu::Sampler,
    pipelines: HashMap<String, Prepared>,
    /// (content key, bytes held, view) for the images uploaded most recently.
    uploads: Vec<(u64, usize, wgpu::TextureView)>,
    /// Set if the driver takes the device away, which nothing here can undo.
    lost: std::sync::Arc<std::sync::Mutex<Option<String>>>,
}

impl GpuRenderer {
    /// Open a device on the default adapter.
    pub async fn new() -> Result<Self, Error> {
        let instance = wgpu::Instance::new(&wgpu::InstanceDescriptor::default());
        let adapter = instance
            .request_adapter(&wgpu::RequestAdapterOptions {
                power_preference: wgpu::PowerPreference::HighPerformance,
                force_fallback_adapter: false,
                compatible_surface: None,
            })
            .await
            .map_err(|e| Error::NoGpu(e.to_string()))?;
        let (device, queue) = adapter
            .request_device(&wgpu::DeviceDescriptor {
                label: Some("gltcstdio"),
                required_features: wgpu::Features::empty(),
                required_limits: wgpu::Limits::downlevel_defaults()
                    .using_resolution(adapter.limits()),
                experimental_features: wgpu::ExperimentalFeatures::disabled(),
                memory_hints: wgpu::MemoryHints::Performance,
                trace: wgpu::Trace::Off,
            })
            .await
            .map_err(|e| Error::NoGpu(e.to_string()))?;

        // WebGPU reports validation failures asynchronously, and a pipeline
        // that fails to build simply draws nothing; without this the page
        // shows a blank frame and says nothing about why.
        device.on_uncaptured_error(std::sync::Arc::new(|error| {
            log::error!("wgpu: {error}");
        }));

        // A device can be taken away mid-session -- memory exhausted, the GPU
        // process restarted, the driver resetting.  Every later call then
        // fails for a reason the caller cannot see, so the reason is kept.
        let lost = std::sync::Arc::new(std::sync::Mutex::new(None));
        {
            let lost = lost.clone();
            device.set_device_lost_callback(move |reason, message| {
                let note = format!("{reason:?}: {message}");
                log::error!("wgpu device lost -- {note}");
                if let Ok(mut slot) = lost.lock() {
                    *slot = Some(note);
                }
            });
        }

        let sampler = device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("gltcstdio-sampler"),
            address_mode_u: wgpu::AddressMode::ClampToEdge,
            address_mode_v: wgpu::AddressMode::ClampToEdge,
            address_mode_w: wgpu::AddressMode::ClampToEdge,
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            mipmap_filter: wgpu::FilterMode::Linear,
            ..Default::default()
        });

        Ok(Self {
            device,
            queue,
            sampler,
            pipelines: HashMap::new(),
            uploads: Vec::new(),
            lost,
        })
    }

    fn prepare(&mut self, spec: &FilterSpec, gpu: &GpuSpec) -> Result<(), Error> {
        if !self.pipelines.contains_key(&spec.id) {
            let source = shader_source(&spec.id)
                .ok_or_else(|| Error::NoShader(spec.id.clone()))?;
            let module = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some(&spec.id),
                    source: wgpu::ShaderSource::Wgsl(source.into()),
                });

            let mut entries = vec![
                wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Buffer {
                        ty: wgpu::BufferBindingType::Uniform,
                        has_dynamic_offset: false,
                        min_binding_size: None,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 1,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                    count: None,
                },
            ];
            for t in &gpu.textures {
                entries.push(wgpu::BindGroupLayoutEntry {
                    binding: t.binding,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Float { filterable: true },
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                });
            }

            let layout = self
                .device
                .create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
                    label: Some(&spec.id),
                    entries: &entries,
                });
            let pipeline_layout =
                self.device
                    .create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
                        label: Some(&spec.id),
                        bind_group_layouts: &[&layout],
                        push_constant_ranges: &[],
                    });
            let vertex = self
                .device
                .create_shader_module(wgpu::ShaderModuleDescriptor {
                    label: Some("gltcstdio-vertex"),
                    source: wgpu::ShaderSource::Wgsl(VERTEX_WGSL.into()),
                });
            let pipeline = self
                .device
                .create_render_pipeline(&wgpu::RenderPipelineDescriptor {
                    label: Some(&spec.id),
                    layout: Some(&pipeline_layout),
                    vertex: wgpu::VertexState {
                        module: &vertex,
                        entry_point: Some("vs_main"),
                        buffers: &[],
                        compilation_options: Default::default(),
                    },
                    fragment: Some(wgpu::FragmentState {
                        module: &module,
                        entry_point: Some("main"),
                        targets: &[Some(wgpu::ColorTargetState {
                            format: TEXTURE_FORMAT,
                            blend: None,
                            write_mask: wgpu::ColorWrites::ALL,
                        })],
                        compilation_options: Default::default(),
                    }),
                    primitive: wgpu::PrimitiveState::default(),
                    depth_stencil: None,
                    multisample: wgpu::MultisampleState::default(),
                    multiview: None,
                    cache: None,
                });
            self.pipelines
                .insert(spec.id.clone(), Prepared { pipeline, layout });
        }
        Ok(())
    }

    /// Render one filter.
    ///
    /// `inputs` supplies the secondary images a filter reads; anything it
    /// wants but the caller did not give falls back to the primary image,
    /// which keeps every filter renderable.
    pub async fn render(
        &mut self,
        spec: &FilterSpec,
        image: &Image,
        values: &std::collections::BTreeMap<String, Vec<f32>>,
        inputs: &HashMap<String, Image>,
        size: (u32, u32),
    ) -> Result<Image, Error> {
        let gpu = spec
            .gpu
            .as_ref()
            .ok_or_else(|| Error::NoShader(spec.id.clone()))?;
        let (out_w, out_h) = size;

        // Textures first: their sizes feed the uniform buffer.
        let mut views = Vec::new();
        let mut dims: HashMap<String, (u32, u32)> = HashMap::new();
        for t in &gpu.textures {
            let src = inputs.get(&t.name).unwrap_or(image);
            dims.insert(t.name.clone(), (src.width, src.height));
            views.push(self.upload(src));
        }

        let data = uniform_bytes(gpu, values, image, &dims, (out_w, out_h));
        let buffer = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("params"),
            size: data.len().max(16) as u64,
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        self.queue.write_buffer(&buffer, 0, &data);

        // Building the pipeline inside an error scope turns a shader the
        // driver refuses into a reported failure rather than a blank frame --
        // WebGPU is stricter than native wgpu about where a texture may be
        // sampled, and reports that asynchronously.
        let fresh = !self.pipelines.contains_key(&spec.id);
        if fresh {
            self.device.push_error_scope(wgpu::ErrorFilter::Validation);
        }
        self.prepare(spec, gpu)?;
        if fresh {
            if let Some(error) = self.device.pop_error_scope().await {
                self.pipelines.remove(&spec.id);
                return Err(Error::Render(error.to_string()));
            }
        }

        let mut bind = vec![
            wgpu::BindGroupEntry {
                binding: 0,
                resource: buffer.as_entire_binding(),
            },
            wgpu::BindGroupEntry {
                binding: 1,
                resource: wgpu::BindingResource::Sampler(&self.sampler),
            },
        ];
        for (t, view) in gpu.textures.iter().zip(&views) {
            bind.push(wgpu::BindGroupEntry {
                binding: t.binding,
                resource: wgpu::BindingResource::TextureView(view),
            });
        }
        let group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some(&spec.id),
            layout: &self.pipelines[&spec.id].layout,
            entries: &bind,
        });

        let target = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("target"),
            size: wgpu::Extent3d {
                width: out_w,
                height: out_h,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: TEXTURE_FORMAT,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::COPY_SRC,
            view_formats: &[],
        });
        let target_view = target.create_view(&Default::default());

        // The read-back buffer's rows must be a multiple of 256 bytes.
        let unpadded = out_w as usize * 4;
        let padded = unpadded.div_ceil(256) * 256;
        let readback = self.device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("readback"),
            size: (padded * out_h as usize) as u64,
            usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
            mapped_at_creation: false,
        });

        let mut encoder = self
            .device
            .create_command_encoder(&wgpu::CommandEncoderDescriptor { label: None });
        {
            let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some(&spec.id),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &target_view,
                    depth_slice: None,
                    resolve_target: None,
                    ops: wgpu::Operations {
                        load: wgpu::LoadOp::Clear(wgpu::Color::TRANSPARENT),
                        store: wgpu::StoreOp::Store,
                    },
                })],
                depth_stencil_attachment: None,
                timestamp_writes: None,
                occlusion_query_set: None,
            });
            pass.set_pipeline(&self.pipelines[&spec.id].pipeline);
            pass.set_bind_group(0, &group, &[]);
            pass.draw(0..3, 0..1);
        }
        encoder.copy_texture_to_buffer(
            wgpu::TexelCopyTextureInfo {
                texture: &target,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            wgpu::TexelCopyBufferInfo {
                buffer: &readback,
                layout: wgpu::TexelCopyBufferLayout {
                    offset: 0,
                    bytes_per_row: Some(padded as u32),
                    rows_per_image: Some(out_h),
                },
            },
            wgpu::Extent3d {
                width: out_w,
                height: out_h,
                depth_or_array_layers: 1,
            },
        );
        self.queue.submit(Some(encoder.finish()));

        // Wait for the copy to land.  On the web nothing may block, so the
        // callback is awaited; natively the same await resolves as soon as
        // the poll below has run it.
        let slice = readback.slice(..);
        let signal = MapSignal::default();
        let notify = signal.clone();
        slice.map_async(wgpu::MapMode::Read, move |result| notify.complete(result));
        #[cfg(not(target_arch = "wasm32"))]
        self.device
            .poll(wgpu::PollType::wait_indefinitely())
            .map_err(|e| Error::Render(e.to_string()))?;
        signal
            .await
            .map_err(|e| Error::Render(format!("read back: {e}")))?;
        let mapped = slice.get_mapped_range();
        let mut out = Vec::with_capacity(unpadded * out_h as usize);
        for row in 0..out_h as usize {
            out.extend_from_slice(&mapped[row * padded..row * padded + unpadded]);
        }
        drop(mapped);
        readback.unmap();

        Ok(Image::new(out_w, out_h, out))
    }

    /// Upload an image with a full mip chain.
    ///
    /// The app's engine builds mipmaps for every input and samples through
    /// them, and a filter that minifies -- a mosaic reading one texel per
    /// cell, a kaleidoscope folding the image down -- gets an averaged colour
    /// rather than whichever texel it happened to land on.  Without the chain
    /// those filters came out flat where the app shows detail.
    /// Build a filter's pipeline and report what the driver refused.
    ///
    /// WebGPU is stricter than native wgpu about where a texture may be
    /// sampled, so a shader can be valid here and rejected in a browser.  This
    /// compiles one and returns the message rather than leaving a blank frame.
    pub async fn check(&mut self, spec: &FilterSpec) -> Option<String> {
        let gpu = spec.gpu.as_ref()?;
        self.device.push_error_scope(wgpu::ErrorFilter::Validation);
        let built = self.prepare(spec, gpu).err().map(|e| e.to_string());
        let reported = self.device.pop_error_scope().await.map(|e| e.to_string());
        built.or(reported)
    }

    /// Why the device was taken away, if it was.
    pub fn lost(&self) -> Option<String> {
        self.lost.lock().ok().and_then(|slot| slot.clone())
    }

    /// Drop the cached uploads, releasing the device memory they hold.
    ///
    /// Rendering does not need this -- the cache bounds itself -- but a caller
    /// that has finished with an image can hand the memory back, and it is
    /// what lets a benchmark measure a cold render.
    pub fn forget_uploads(&mut self) {
        self.uploads.clear();
    }

    /// Upload an image, reusing the texture if these exact pixels are cached.
    ///
    /// Building the mip chain is most of what a render costs -- 72-83% of one,
    /// rising with size -- and the same image goes up again on every slider
    /// move, for every thumbnail and for every second input. The key is the
    /// content, so a cached texture is only ever reused for identical pixels.
    fn upload(&mut self, image: &Image) -> wgpu::TextureView {
        let key = content_key(image);
        if let Some(at) = self.uploads.iter().position(|(k, _, _)| *k == key) {
            // Least recently used goes first, so the source image -- which
            // every render of a chain reads -- outlives the intermediates.
            let hit = self.uploads.remove(at);
            let view = hit.2.clone();
            self.uploads.push(hit);
            return view;
        }
        let view = self.upload_fresh(image);

        // The chain is about 4/3 of the image, and the budget bounds how much
        // of the device's memory this holds on to.
        let bytes = image.data.len() * 4 / 3;
        self.uploads.push((key, bytes, view.clone()));
        let mut held: usize = self.uploads.iter().map(|(_, b, _)| b).sum();
        while held > UPLOAD_BUDGET && self.uploads.len() > UPLOAD_FLOOR {
            held -= self.uploads.remove(0).1;
        }
        view
    }

    fn upload_fresh(&self, image: &Image) -> wgpu::TextureView {
        let levels = mip_levels(image.width, image.height);
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("input"),
            size: wgpu::Extent3d {
                width: image.width,
                height: image.height,
                depth_or_array_layers: 1,
            },
            mip_level_count: levels,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: TEXTURE_FORMAT,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });

        let mut level = (image.width, image.height, image.data.clone());
        for mip in 0..levels {
            let (w, h, data) = &level;
            self.queue.write_texture(
                wgpu::TexelCopyTextureInfo {
                    texture: &texture,
                    mip_level: mip,
                    origin: wgpu::Origin3d::ZERO,
                    aspect: wgpu::TextureAspect::All,
                },
                data,
                wgpu::TexelCopyBufferLayout {
                    offset: 0,
                    bytes_per_row: Some(w * 4),
                    rows_per_image: Some(*h),
                },
                wgpu::Extent3d {
                    width: *w,
                    height: *h,
                    depth_or_array_layers: 1,
                },
            );
            if mip + 1 < levels {
                level = downsample(*w, *h, data);
            }
        }
        texture.create_view(&Default::default())
    }
}

/// A content key for an image: two rolling hashes over its bytes, combined.
///
/// Hashing 4 MB costs about a millisecond against the twenty-five the mip
/// chain costs, so the cache pays for itself on the first hit.
fn content_key(image: &Image) -> u64 {
    let mut a: u64 = 0xcbf2_9ce4_8422_2325 ^ ((image.width as u64) << 32 | image.height as u64);
    let mut b: u64 = 0x9e37_79b9_7f4a_7c15 ^ image.data.len() as u64;
    let mut words = image.data.chunks_exact(8);
    for word in &mut words {
        let v = u64::from_le_bytes(word.try_into().expect("chunks_exact(8)"));
        a = (a ^ v).wrapping_mul(0x0000_0100_0000_01b3);
        b = b.rotate_left(23).wrapping_add(v).wrapping_mul(0x9e37_79b9_7f4a_7c15);
    }
    for (i, byte) in words.remainder().iter().enumerate() {
        a = (a ^ ((*byte as u64) << (i * 8))).wrapping_mul(0x0000_0100_0000_01b3);
    }
    a ^ b.rotate_left(31)
}

/// How many mip levels an image of this size has.
fn mip_levels(width: u32, height: u32) -> u32 {
    32 - width.max(height).max(1).leading_zeros()
}

/// Which parent texels make up one child texel along an axis, and how much
/// each contributes.
///
/// This is the rule GL states for deriving a mipmap: an even parent halves
/// with a two-tap box, an odd one needs three taps weighted by position,
/// because the child texels do not line up with pairs of parent texels.  A
/// plain box filter over an odd dimension drifts, and the drift compounds
/// down the chain -- which showed up as a much poorer match on any image
/// whose sides are not powers of two.
fn taps(parent: u32, index: u32) -> [(u32, f32); 3] {
    let child = (parent / 2).max(1);
    if parent == 1 {
        return [(0, 1.0), (0, 0.0), (0, 0.0)];
    }
    if parent.is_multiple_of(2) {
        return [(index * 2, 0.5), (index * 2 + 1, 0.5), (0, 0.0)];
    }
    let denom = (2 * child + 1) as f32;
    [
        (index * 2, (child - index) as f32 / denom),
        (index * 2 + 1, child as f32 / denom),
        (index * 2 + 2, (index + 1) as f32 / denom),
    ]
}

/// One mip level down, by the rule above on each axis.
pub fn downsample(width: u32, height: u32, data: &[u8]) -> (u32, u32, Vec<u8>) {
    let (w, h) = ((width / 2).max(1), (height / 2).max(1));
    // A plain halving is an integer average, and the driver measured against
    // drops the fraction there; the weighted case goes through floats and
    // rounds.  Matching both is what the comparison against the GL renderer
    // actually shows, at every image size tried.
    let halved = width.is_multiple_of(2) && height.is_multiple_of(2);
    let mut out = vec![0u8; (w as usize) * (h as usize) * 4];
    for y in 0..h {
        let rows = taps(height, y);
        for x in 0..w {
            let cols = taps(width, x);
            for c in 0..4 {
                let mut sum = 0.0f32;
                for (sy, wy) in rows {
                    if wy == 0.0 {
                        continue;
                    }
                    for (sx, wx) in cols {
                        if wx == 0.0 {
                            continue;
                        }
                        let at = ((sy.min(height - 1) * width + sx.min(width - 1)) * 4 + c)
                            as usize;
                        sum += data[at] as f32 * wy * wx;
                    }
                }
                let value = if halved { sum } else { sum.round() };
                out[((y * w + x) * 4 + c) as usize] = value.clamp(0.0, 255.0) as u8;
            }
        }
    }
    (w, h, out)
}

/// The full-screen triangle every filter draws over.
const VERTEX_WGSL: &str = r#"
struct VsOut {
    @builtin(position) pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
};

@vertex
fn vs_main(@builtin(vertex_index) i: u32) -> VsOut {
    // One triangle covering the viewport; uv runs 0..1 with v = 0 at the top,
    // so a texture's first row is the top of the image.
    var xy = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>( 3.0, -1.0),
        vec2<f32>(-1.0,  3.0),
    );
    var out: VsOut;
    let p = xy[i];
    out.pos = vec4<f32>(p, 0.0, 1.0);
    out.uv = vec2<f32>((p.x + 1.0) * 0.5, (1.0 - p.y) * 0.5);
    return out;
}
"#;

/// Fill the uniform buffer: the `vec4` slots, then each array parameter.
fn uniform_bytes(
    gpu: &GpuSpec,
    values: &std::collections::BTreeMap<String, Vec<f32>>,
    image: &Image,
    dims: &HashMap<String, (u32, u32)>,
    out: (u32, u32),
) -> Vec<u8> {
    let (out_w, out_h) = out;
    let in_aspect = if image.height > 0 {
        image.width as f32 / image.height as f32
    } else {
        1.0
    };
    let out_aspect = if out_h > 0 {
        out_w as f32 / out_h as f32
    } else {
        1.0
    };

    let mut slots = vec![[0.0f32; 4]; gpu.vec4_count];
    let mut arrays: Vec<Vec<[f32; 4]>> = vec![Vec::new(); gpu.arrays.len()];

    let put = |slots: &mut Vec<[f32; 4]>, at: usize, ty: &str, v: &[f32]| {
        match ty {
            "mat3" => {
                // Stored row-major; a shader column is a row of three.
                for c in 0..3 {
                    for r in 0..3 {
                        slots[at + c][r] = v.get(r * 3 + c).copied().unwrap_or(0.0);
                    }
                }
            }
            "mat4" => {
                for c in 0..4 {
                    for r in 0..4 {
                        slots[at + c][r] = v.get(r * 4 + c).copied().unwrap_or(0.0);
                    }
                }
            }
            _ => {
                for (i, x) in v.iter().take(4).enumerate() {
                    slots[at][i] = *x;
                }
            }
        }
    };

    for slot in &gpu.slots {
        match slot {
            Slot::Param { name, slot: at, ty } => {
                if let Some(v) = values.get(name) {
                    put(&mut slots, *at, ty, v);
                }
            }
            Slot::ArrayParam {
                name,
                ty,
                elem,
                length,
                array_index,
            } => {
                let per = match array_spec(ty).map(|(e, _)| e).unwrap_or(elem.as_str()) {
                    "vec4" => 4,
                    "vec3" => 3,
                    "vec2" => 2,
                    _ => 1,
                };
                let flat = values.get(name).cloned().unwrap_or_default();
                let mut packed = vec![[0.0f32; 4]; *length];
                for i in 0..*length {
                    for c in 0..per {
                        packed[i][c] = flat.get(i * per + c).copied().unwrap_or(0.0);
                    }
                }
                arrays[*array_index] = packed;
            }
            Slot::OutDim { slot: at, ty } => {
                put(&mut slots, *at, ty, &[out_w as f32, out_h as f32])
            }
            Slot::OutAspect { slot: at, ty } => put(&mut slots, *at, ty, &[out_aspect]),
            Slot::InAspect { slot: at, ty } => put(&mut slots, *at, ty, &[in_aspect]),
            Slot::InDim { slot: at, ty } => put(
                &mut slots,
                *at,
                ty,
                &[image.width as f32, image.height as f32],
            ),
            Slot::InputDim {
                input,
                slot: at,
                ty,
            } => {
                let (w, h) = dims
                    .get(input)
                    .copied()
                    .unwrap_or((image.width, image.height));
                put(&mut slots, *at, ty, &[w as f32, h as f32]);
            }
            Slot::Identity { slot: at, ty } => {
                let n = if ty == "mat4" { 4 } else { 3 };
                for c in 0..n {
                    slots[*at + c][c] = 1.0;
                }
            }
            Slot::Const { value, slot: at, ty } => put(&mut slots, *at, ty, value),
        }
    }

    let mut bytes = bytemuck::cast_slice(&slots).to_vec();
    for array in &arrays {
        bytes.extend_from_slice(bytemuck::cast_slice(array));
    }
    bytes
}


/// A future over `map_async`'s callback.
///
/// wgpu hands the result to a callback; on the web there is no way to block
/// until it fires, so it is awaited instead.
#[derive(Clone, Default)]
struct MapSignal {
    state: std::sync::Arc<std::sync::Mutex<MapState>>,
}

#[derive(Default)]
struct MapState {
    result: Option<Result<(), wgpu::BufferAsyncError>>,
    waker: Option<std::task::Waker>,
}

impl MapSignal {
    fn complete(&self, result: Result<(), wgpu::BufferAsyncError>) {
        let mut state = self.state.lock().expect("map signal is not poisoned");
        state.result = Some(result);
        if let Some(waker) = state.waker.take() {
            waker.wake();
        }
    }
}

impl std::future::Future for MapSignal {
    type Output = Result<(), wgpu::BufferAsyncError>;

    fn poll(
        self: std::pin::Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Self::Output> {
        let mut state = self.state.lock().expect("map signal is not poisoned");
        match state.result.take() {
            Some(result) => std::task::Poll::Ready(result),
            None => {
                state.waker = Some(cx.waker().clone());
                std::task::Poll::Pending
            }
        }
    }
}
