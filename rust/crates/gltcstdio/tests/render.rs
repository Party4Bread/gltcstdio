//! Every filter must render, and the bank must describe them all.
//!
//! The GPU tests are skipped when there is no device, so the suite still runs
//! on a machine without one.

use std::collections::HashMap;

use gltcstdio::{bank, params, Backend, Image, Params, Renderer};

/// A gradient with a disc on it: enough structure that a filter which reads
/// the image produces something different from one that ignores it.
fn test_image(size: u32) -> Image {
    let mut img = Image::empty(size, size);
    let c = size as f32 / 2.0;
    for y in 0..size {
        for x in 0..size {
            let inside = (x as f32 - c).hypot(y as f32 - c) < size as f32 * 0.3;
            let px = if inside {
                [40, 60, 120, 255]
            } else {
                [
                    (x * 255 / size.max(1)) as u8,
                    (y * 255 / size.max(1)) as u8,
                    128,
                    255,
                ]
            };
            img.set(x, y, px);
        }
    }
    img
}

fn renderer() -> Option<Renderer> {
    Renderer::new_blocking().ok().filter(|r| r.has_gpu())
}

#[test]
fn bank_loads_and_is_complete() {
    let bank = bank();
    assert!(bank.filters.len() > 700, "bank has {}", bank.filters.len());
    for (id, spec) in &bank.filters {
        assert_eq!(id, &spec.id);
        assert!(!spec.name.is_empty(), "{id} has no name");
        if spec.backend == Backend::Gl {
            assert!(spec.gpu.is_some(), "{id} is a shader with no gpu spec");
            assert!(
                gltcstdio::gpu::shader_source(id).is_some(),
                "{id} has no WGSL"
            );
        }
        if spec.backend == Backend::Graph {
            assert!(spec.graph.is_some(), "{id} is a graph with no graph");
        }
    }
}

#[test]
fn every_cpu_filter_is_implemented() {
    let missing: Vec<&str> = bank()
        .filters
        .values()
        .filter(|f| f.backend == Backend::Cpu && !gltcstdio::cpu::has(&f.id))
        .map(|f| f.id.as_str())
        .collect();
    assert!(missing.is_empty(), "no CPU implementation for {missing:?}");
}

#[test]
fn cpu_filters_render() {
    let mut r = Renderer::cpu_only();
    let img = test_image(64);
    for spec in bank().filters.values() {
        if spec.backend != Backend::Cpu {
            continue;
        }
        let out = r
            .apply(&spec.id, &img, &Params::new())
            .unwrap_or_else(|e| panic!("{}: {e}", spec.id));
        assert_eq!(out.width, img.width, "{} changed width", spec.id);
        assert_eq!(out.height, img.height, "{} changed height", spec.id);
    }
}

#[test]
fn every_filter_renders_on_the_gpu() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let img = test_image(64);
    let mut failed = Vec::new();
    for id in bank().ids() {
        if let Err(e) = r.apply(id, &img, &Params::new()) {
            failed.push(format!("{id}: {e}"));
        }
    }
    assert!(failed.is_empty(), "{} failed: {failed:?}", failed.len());
}

#[test]
fn parameters_change_the_output() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let img = test_image(64);
    let a = r.apply("halftone", &img, &Params::new()).expect("default");
    let b = r
        .apply("halftone", &img, &params![("intensity", 0.9f32)])
        .expect("with intensity");
    assert_ne!(a.data, b.data, "intensity did nothing");
}

#[test]
fn presets_resolve() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let img = test_image(64);
    let spec = bank().get("halftone").expect("halftone is in the bank");
    for preset in &spec.presets {
        r.apply_preset("halftone", &img, &preset.name, &Params::new())
            .unwrap_or_else(|e| panic!("preset {}: {e}", preset.name));
    }
}

#[test]
fn a_graph_reaches_its_nodes() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let img = test_image(64);
    let graph = bank()
        .filters
        .values()
        .find(|f| f.backend == Backend::Graph && !f.params.is_empty())
        .expect("the bank has curated looks");
    r.apply(&graph.id, &img, &Params::new())
        .unwrap_or_else(|e| panic!("{}: {e}", graph.id));
}

/// Non-square and odd sizes exercise the aspect uniform and the mip chain,
/// where a dimension no longer halves cleanly.
#[test]
fn renders_at_awkward_sizes() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    for (w, h) in [(64, 33), (33, 64), (81, 15), (1, 40), (40, 1)] {
        let img = test_image(w.max(h));
        let mut cropped = Image::empty(w, h);
        for y in 0..h {
            for x in 0..w {
                cropped.set(x, y, img.get(x, y));
            }
        }
        for id in ["halftone", "hex-pixelate", "circle-mosaic", "etched-circles"] {
            let out = r
                .apply(id, &cropped, &Params::new())
                .unwrap_or_else(|e| panic!("{id} at {w}x{h}: {e}"));
            assert_eq!((out.width, out.height), (w, h), "{id} at {w}x{h}");
        }
    }
}

/// A chain can read from more than one image.
///
/// A leaf naming something other than `source` takes the caller's image of
/// that name, which is what a combine needs: two different photographs, not
/// the same one twice.  An unbound name still falls back to the primary, so
/// a graph always renders.
#[test]
fn a_graph_reads_from_several_images() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let a = test_image(64);
    let mut b = Image::empty(64, 64);
    for y in 0..64 {
        for x in 0..64 {
            b.set(x, y, [255, 0, 255, 255]);
        }
    }

    // `checkerboard-combine` reads `source1` and `source2`; wire the second
    // to a named image rather than to the chain.
    let graph: gltcstdio::FilterNode = serde_json::from_value(serde_json::json!({
        "filter": "checkerboard-combine",
        "inputs": { "source1": {"input": "source"}, "source2": {"input": "other"} },
    }))
    .expect("a two-input chain");

    let mut sources = HashMap::new();
    sources.insert("other".to_string(), b.clone());
    let with = r
        .apply_graph_with_sources(&graph, &a, &Params::new(), &sources)
        .expect("with the second image");
    let without = r
        .apply_graph(&graph, &a, &Params::new())
        .expect("without it");
    assert_ne!(
        with.data, without.data,
        "the second image made no difference"
    );

    // The magenta must actually be in there: it is in neither the source nor
    // a render that never saw it.
    let magenta = |img: &Image| {
        (0..img.pixels()).any(|i| {
            img.data[i * 4] > 200 && img.data[i * 4 + 1] < 60 && img.data[i * 4 + 2] > 200
        })
    };
    assert!(magenta(&with), "the second image did not reach the shader");
    assert!(!magenta(&without), "the test cannot tell the two apart");
}

/// A resolved look must render as the look itself.
///
/// `resolve_graph` is what lets an editor open a curated look as nodes: it
/// bakes the look's declared defaults into each stage the way rendering
/// delivers them.  Forty-five of the 175 looks come out different if that is
/// skipped, so the two paths are compared here rather than assumed equal.
#[test]
fn a_resolved_look_renders_as_the_look() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let img = test_image(64);
    let mut failed = Vec::new();
    for spec in bank().filters.values() {
        let Some(graph) = spec.graph.as_ref() else {
            continue;
        };
        let Ok(direct) = r.apply(&spec.id, &img, &Params::new()) else {
            continue; // a shader this machine refuses is a separate matter
        };
        let resolved =
            gltcstdio::graph::resolve_graph(graph, &spec.resolve_raw(None, &Params::new()));
        match r.apply_graph(&resolved, &img, &Params::new()) {
            Ok(out) if out.data != direct.data => {
                let worst = out
                    .data
                    .iter()
                    .zip(&direct.data)
                    .map(|(a, b)| a.abs_diff(*b))
                    .max()
                    .unwrap_or(0);
                failed.push(format!("{} (worst {worst})", spec.id));
            }
            Err(e) => failed.push(format!("{}: {e}", spec.id)),
            _ => {}
        }
    }
    assert!(failed.is_empty(), "{} differ: {failed:?}", failed.len());
}

/// The upload cache must not change a single pixel.
///
/// A texture is reused only when the image's content matches, so rendering
/// through a renderer that has other images cached must give what a cold one
/// gives.  Two sizes go through it between the two renders, which is what
/// would expose a key that collides or a texture reused for the wrong image.
#[test]
fn the_upload_cache_changes_nothing() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let a = test_image(64);
    let b = test_image(48);
    let mut failed = Vec::new();
    for id in bank().ids() {
        let Ok(first) = r.apply(id, &a, &Params::new()) else {
            continue;
        };
        let _ = r.apply(id, &b, &Params::new());
        match r.apply(id, &a, &Params::new()) {
            Ok(again) if again.data != first.data => failed.push(id),
            _ => {}
        }
    }
    assert!(failed.is_empty(), "{} differ: {failed:?}", failed.len());
}

#[test]
fn unknown_filters_are_an_error() {
    let mut r = Renderer::cpu_only();
    let err = r.apply("no-such-filter", &test_image(8), &Params::new());
    assert!(matches!(err, Err(gltcstdio::Error::Unknown(_))));
}

/// A noisy image, so a blur has something to remove. A gradient does not:
/// blurring one is nearly the identity, which would pass whatever happened.
fn noise(size: u32) -> Image {
    let mut img = Image::empty(size, size);
    let mut seed = 12345u32;
    for y in 0..size {
        for x in 0..size {
            let mut next = || {
                seed = seed.wrapping_mul(1664525).wrapping_add(1013904223);
                (seed >> 24) as u8
            };
            img.set(x, y, [next(), next(), next(), 255]);
        }
    }
    img
}

/// Mean difference between vertically adjacent pixels: it falls as an image
/// is blurred down the axis it measures.
fn roughness(img: &Image) -> f64 {
    let (w, h) = (img.width as usize, img.height as usize);
    let mut total = 0.0;
    let mut n = 0.0;
    for y in 1..h {
        for x in 0..w {
            for c in 0..3 {
                let a = img.data[(y * w + x) * 4 + c] as f64;
                let b = img.data[((y - 1) * w + x) * 4 + c] as f64;
                total += (a - b).abs();
                n += 1.0;
            }
        }
    }
    total / n
}

/// The three shaders that sample through `u_SourceTransform` must sample the
/// image, not translate it.
///
/// They are handed a coordinate in world units and read the source with
/// `texture(u_Source, u_SourceTransform * vec3(uv, 1))`, so that uniform is
/// the way back to texture space. Bound to the identity matrix -- which is
/// what every other legacy matrix gets -- they sampled at world coordinates
/// directly and shifted the picture half a frame instead of blurring it,
/// while still returning a plausible-looking image.
#[test]
fn the_blur_shaders_sample_where_they_are_looking() {
    let Some(mut r) = renderer() else {
        eprintln!("no GPU device; skipping");
        return;
    };
    let src = noise(128);
    let rough = roughness(&src);

    // A radius under one pixel has nothing to average, so the shader must
    // hand back exactly what it was given.
    for id in ["gaussian-blurv", "gaussian-blurh"] {
        let out = r.apply(id, &src, &params![("radius", 0.0)]).unwrap();
        assert_eq!(out.data, src.data, "{id} at radius 0 is not its input");
    }

    // Each blurs down its own axis: measured vertically, the vertical pass
    // must flatten the image far more than the horizontal one.
    let v = roughness(&r.apply("gaussian-blurv", &src, &params![("radius", 0.08)]).unwrap());
    let h = roughness(&r.apply("gaussian-blurh", &src, &params![("radius", 0.08)]).unwrap());
    assert!(v < rough * 0.25, "gaussian-blurv barely blurred: {rough:.1} -> {v:.1}");
    assert!(v < h * 0.5, "the two passes blur alike, so neither is on its axis: {v:.1} vs {h:.1}");
}
