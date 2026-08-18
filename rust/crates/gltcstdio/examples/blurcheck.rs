//! Evidence for a known defect: `gaussian-blur2` should be the app's own
//! pair of shaders, and cannot be until they sample correctly.
//!
//! `effects/blur/GaussianBlur.java` registers
//!
//!     (lambda ((param source :type image)
//!              (param radius :type double :standardRange (0 1) :default 0.05))
//!       (gaussian-blurh (gaussian-blurv source radius) radius))
//!
//! so `gaussian-blur2` is a graph over two recovered shaders, not a filter of
//! its own.  The bank instead carries a CPU reimplementation -- a plain
//! separable Gaussian, where the app's shaders accumulate in squared space
//! and walk down the mip chain as the radius grows.  It is also the slowest
//! thing in the bank: this example measures 200 ms at radius 0.02 and 1.6 s
//! at 0.12 on a 900x900 image, against 3.8 ms for the app's pair, whose cost
//! does not grow with the radius at all.  The 21 blur wrappers and every
//! chain built on them route through it.
//!
//! Substituting the graph is wrong today, because those two shaders do not
//! yet sample correctly on their own.  They are three of the shaders written
//! against the engine's earlier uniform convention, and they read the source
//! through `u_SourceTransform`, which both renderers bind to the identity
//! matrix.  The coordinate they are handed spans world units -- `(v_uv - 0.5)
//! * 2 * vec2(aspect, 1)` -- so with an identity transform they sample the
//! texture at those coordinates directly and translate the image by half a
//! frame instead of blurring it.  `gaussian-blurv` at radius 0 should return
//! its input untouched; it comes back a mean 31/255 away.
//!
//! Fixing it means binding that uniform to the map from world coordinates
//! back to texture space, in `gltcstdio/backends/gl.py` for the Python
//! renderer and as its own slot kind -- `Slot::Identity` is generic and
//! correct elsewhere -- for the WGSL one.  `blur` is the third shader
//! affected.  Until then the CPU reimplementation stays.

use gltcstdio::{params, FilterNode, Image, Params, Renderer};

fn main() {
    let n = 900u32;
    let mut src = Image::empty(n, n);
    for y in 0..n {
        for x in 0..n {
            let ring = (((x as f32 - 450.0).powi(2) + (y as f32 - 450.0).powi(2)).sqrt()
                / 12.0).sin();
            src.set(x, y, [(x % 256) as u8, (y % 256) as u8,
                           ((ring * 0.5 + 0.5) * 255.0) as u8, 255]);
        }
    }
    let mut r = Renderer::new_blocking().expect("renderer");

    for radius in [0.02f32, 0.05, 0.12] {
        let graph: FilterNode = serde_json::from_value(serde_json::json!({
            "filter": "gaussian-blurh",
            "params": {"radius": radius},
            "inputs": {"source": {
                "filter": "gaussian-blurv",
                "params": {"radius": radius},
                "inputs": {"source": {"input": "source"}},
            }},
        })).unwrap();

        let _ = r.apply_graph(&graph, &src, &Params::new());
        let t = std::time::Instant::now();
        let gpu = r.apply_graph(&graph, &src, &Params::new()).unwrap();
        let gpu_ms = t.elapsed().as_secs_f64() * 1000.0;

        let _ = r.apply("gaussian-blur2", &src, &params![("radius", radius)]);
        let t = std::time::Instant::now();
        let cpu = r.apply("gaussian-blur2", &src, &params![("radius", radius)]).unwrap();
        let cpu_ms = t.elapsed().as_secs_f64() * 1000.0;

        let diff: Vec<i32> = gpu.data.iter().zip(&cpu.data)
            .map(|(a, b)| (*a as i32 - *b as i32).abs()).collect();
        let mean = diff.iter().sum::<i32>() as f64 / diff.len() as f64;
        let worst = diff.iter().copied().max().unwrap_or(0);
        println!("radius {radius:.2}: app's shaders {gpu_ms:8.1} ms | \
                  our CPU blur {cpu_ms:8.1} ms | mean diff {mean:5.1} worst {worst}");
    }
}
