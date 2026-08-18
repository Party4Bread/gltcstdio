//! The filters that run on the CPU.
//!
//! These are ports of the numpy reimplementations, for the effects the app
//! does not build as one static shader -- it generates them per mode from a
//! table of code objects, or the shader is incomplete in the APK itself.
//! Each keeps the app's parameter contract: the same names, ranges and
//! defaults, read from the same bank.

use std::collections::{BTreeMap, HashMap};

use crate::bank::FilterSpec;
use crate::image::Image;
use crate::Error;

pub mod rng;

mod blur;
mod geometry;
mod mosaic;
mod paint;
mod solids;
mod text;
mod tone;

pub use rng::Rng;

/// Resolved parameter values, keyed by name, flattened to floats.
pub type Values = BTreeMap<String, Vec<f32>>;

/// The extra images a filter reads.
pub type Inputs = HashMap<String, Image>;

/// Read a scalar parameter.
pub fn f(values: &Values, name: &str) -> f32 {
    values.get(name).and_then(|v| v.first()).copied().unwrap_or(0.0)
}

/// Read an integer parameter.
pub fn i(values: &Values, name: &str) -> i32 {
    f(values, name).round() as i32
}

/// Read a colour, as four floats in 0..1.
pub fn rgba(values: &Values, name: &str) -> [f32; 4] {
    let v = values.get(name).cloned().unwrap_or_default();
    [
        v.first().copied().unwrap_or(0.0),
        v.get(1).copied().unwrap_or(0.0),
        v.get(2).copied().unwrap_or(0.0),
        v.get(3).copied().unwrap_or(1.0),
    ]
}

/// Perceptual luminance of an RGB triple, in the Rec. 709 weights the
/// reimplementations use.
#[inline]
pub fn luma(r: f32, g: f32, b: f32) -> f32 {
    0.2126 * r + 0.7152 * g + 0.0722 * b
}

#[inline]
pub fn lerp(a: f32, b: f32, k: f32) -> f32 {
    a + (b - a) * k
}

#[inline]
pub fn smoothstep(edge0: f32, edge1: f32, x: f32) -> f32 {
    let t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

/// Blend `front` over `back`, both premultiplied by nothing, alpha in 0..1.
#[inline]
pub fn over(back: [f32; 4], front: [f32; 4]) -> [f32; 4] {
    let a = front[3];
    [
        lerp(back[0], front[0], a),
        lerp(back[1], front[1], a),
        lerp(back[2], front[2], a),
        back[3].max(a),
    ]
}

/// Every CPU filter, by id.
type Filter = fn(&Image, &Values, &Inputs) -> Image;

fn lookup(id: &str) -> Option<Filter> {
    Some(match id {
        // -- blur ---------------------------------------------------------
        "gaussian-blur2" => blur::gaussian_blur,
        "gaussian-blur-test" => blur::gaussian_blur_test,
        "gaussian-blur-test-raw" => blur::gaussian_blur_test,
        "gaussian-blurh-test" => blur::gaussian_blur_h,
        "gaussian-blurv-test" => blur::gaussian_blur_v,
        "lens-blurh" => blur::lens_blur_h,
        "lens-blurv" => blur::lens_blur_v,
        "bloom-simple" => blur::bloom_simple,
        "dehaze" => blur::dehaze,
        "gloss-texture" => blur::gloss_texture,
        "sine-spike" => geometry::sine_spike,

        // -- tone and colour ----------------------------------------------
        "blend" => tone::blend,
        "crt-contrast-gl" => blur::crt_contrast,
        "flashback" => tone::flashback,
        "negative-mirror" => tone::negative_mirror,
        "saturated-square" => tone::saturated_square,
        "metal" => tone::metal,
        "pastel" => paint::pastel,
        "preset-hacker" => tone::preset_hacker,
        "procedural-test-blend" => tone::procedural_test_blend,
        "color-list-to-palette-image" => tone::color_list_to_palette_image,
        "dithering-pattern" => tone::dithering_pattern,
        "image-view" => tone::image_view,
        "crop-and-resize-rel" => tone::crop_and_resize_rel,
        "splash" => tone::splash,

        // -- geometry -----------------------------------------------------
        "concentric-circle-breaks-effect" => geometry::concentric_circle_breaks,
        "concentric-square-breaks-effect" => geometry::concentric_square_breaks,
        "stripe-breaks-effect" => geometry::stripe_breaks,
        "concentric-circle-displacement-gl" => geometry::concentric_circle_displacement,
        "concentric-square-displacement-gl" => geometry::concentric_square_displacement,
        "stripe-displacement-gl" => geometry::stripe_displacement,
        "broken-glass" => geometry::broken_glass,
        "streak-waves" => geometry::streak_waves,
        "gyro-rings" => geometry::gyro_rings,
        "pixel-sort" => geometry::pixel_sort,
        "pixel-sort-raw" => geometry::pixel_sort,
        "one-line" => geometry::one_line,

        // -- mosaic and painting ------------------------------------------
        "circle-mosaic" => mosaic::circle_mosaic,
        "random-tile-placer" => tone::random_tile_placer,
        "delaunay-triangulate" => mosaic::delaunay_triangulate,
        "square-mosaic" => mosaic::square_mosaic,
        "wormhole" => mosaic::wormhole,
        "pointer" => mosaic::pointer,
        "mobius-torus" => solids::mobius_torus,
        "hyperbolic-lace" => solids::hyperbolic_lace,
        "knife-painting" => paint::knife_painting,
        "saint-remy" => paint::saint_remy,
        "canvas-circle-brush" => paint::canvas_circle_brush,
        "canvas-smooth-circle-brush" => paint::canvas_smooth_circle_brush,
        "canvas-spray-brush" => paint::canvas_spray_brush,
        "canvas-glitch-brush" => paint::canvas_glitch_brush,
        "ink-b" => paint::ink_b,

        // -- generated solids ---------------------------------------------
        "fractal-solid-simplified-gl" => solids::fractal_solid_simplified,
        "rayMarcher" => solids::ray_marcher,
        "hex-3d-tiling" => solids::hex_3d_tiling,
        "mesh-gl" => solids::mesh,
        "reflective-mesh-gl" => solids::reflective_mesh,
        "height-map-wireframe-3-gl" => solids::height_map_wireframe,

        // -- text ---------------------------------------------------------
        "text" => text::text,
        "alien-text" => text::alien_text,
        "code-text" => text::code_text,
        "dna-text" => text::dna_text,
        "vhs-text" => text::vhs_text,
        "shadowed-text" => text::shadowed_text,
        "photo-label" => text::photo_label,
        "numbers" => text::numbers,

        _ => return None,
    })
}

/// Whether a CPU filter is implemented here.
pub fn has(id: &str) -> bool {
    lookup(id).is_some()
}

/// Every implemented CPU filter id.
pub fn ids() -> Vec<&'static str> {
    crate::bank()
        .filters
        .values()
        .filter(|f| f.backend == crate::Backend::Cpu && has(&f.id))
        .map(|f| f.id.as_str())
        .collect()
}

pub(crate) fn render(
    spec: &FilterSpec,
    image: &Image,
    values: &Values,
    inputs: &Inputs,
) -> Result<Image, Error> {
    match lookup(&spec.id) {
        Some(run) => Ok(run(image, values, inputs)),
        None => Err(Error::NoCpu(spec.id.clone())),
    }
}
