//! What one extra filter in a chain costs, and where that time goes.
//!
//! Run with `cargo run -p gltcstdio --release --example hop_cost`.
//! Every figure is the best of several runs, so a busy machine cannot
//! inflate it.

use std::time::Instant;

use gltcstdio::{bank, Image, Params, Renderer};

fn image(size: u32) -> Image {
    let mut img = Image::empty(size, size);
    for y in 0..size {
        for x in 0..size {
            img.set(x, y, [(x % 255) as u8, (y % 255) as u8, 90, 255]);
        }
    }
    img
}

fn best<F: FnMut()>(runs: usize, mut f: F) -> f64 {
    let mut lo = f64::MAX;
    for _ in 0..runs {
        let t = Instant::now();
        f();
        lo = lo.min(t.elapsed().as_secs_f64() * 1000.0);
    }
    lo
}

fn chain(depth: usize) -> serde_json::Value {
    let mut node = serde_json::json!({ "input": "source" });
    for _ in 0..depth {
        node = serde_json::json!({ "filter": "emboss", "inputs": { "source": node } });
    }
    node
}

fn main() {
    let Ok(mut r) = Renderer::new_blocking() else {
        eprintln!("no GPU device");
        return;
    };
    if !r.has_gpu() {
        eprintln!("no GPU device");
        return;
    }
    let spec = bank().get("emboss").expect("emboss is in the bank").clone();

    for size in [512u32, 1024, 2048] {
        let img = image(size);
        println!("\n{size}x{size}");

        // The mip chain the upload builds, on its own.
        let mips = best(20, || {
            let mut level = (img.width, img.height, img.data.clone());
            while level.0 > 1 || level.1 > 1 {
                level = gltcstdio::gpu::downsample(level.0, level.1, &level.2);
            }
        });
        println!("  cpu mip chain              {mips:8.2} ms");

        // Cold means the renderer has not seen this image: the upload builds
        // the mip chain.  Warm is what a slider drag or a thumbnail pays.
        let cold = best(20, || {
            r.forget_uploads();
            r.apply("emboss", &img, &Params::new()).expect("render");
        });
        let warm = best(20, || {
            r.apply("emboss", &img, &Params::new()).expect("render");
        });
        println!("  one filter, cold           {cold:8.2} ms");
        println!("  one filter, warm           {warm:8.2} ms");

        for depth in [2usize, 4, 8] {
            let node: gltcstdio::FilterNode =
                serde_json::from_value(chain(depth)).expect("a chain of emboss");
            let cold = best(10, || {
                r.forget_uploads();
                r.apply_graph(&node, &img, &Params::new()).expect("chain");
            });
            let warm = best(10, || {
                r.apply_graph(&node, &img, &Params::new()).expect("chain");
            });
            println!("  chain of {depth:<2} cold / warm    {cold:8.2} / {warm:.2} ms");
        }

        // What a slider drag actually costs: one value moves each time, so
        // everything upstream of it is unchanged and everything downstream
        // is not.  A drag on the last filter is the cheap end, on the first
        // the dear end, and the editor's thumbnails are the same shape.
        for (at, label) in [(0usize, "first"), (3, "last ")] {
            let mut step = 0.0f32;
            let t = best(10, || {
                step += 0.017;
                let mut node = serde_json::json!({ "input": "source" });
                for i in 0..4 {
                    let mut params = serde_json::Map::new();
                    if i == at {
                        params.insert("intensity".into(), (0.2 + step).into());
                    }
                    node = serde_json::json!({
                        "filter": "emboss", "inputs": { "source": node }, "params": params });
                }
                let node: gltcstdio::FilterNode =
                    serde_json::from_value(node).expect("a chain of emboss");
                r.apply_graph(&node, &img, &Params::new()).expect("chain");
            });
            println!("  drag on the {label} of 4      {t:8.2} ms");
        }
        let _ = &spec;
    }
}
