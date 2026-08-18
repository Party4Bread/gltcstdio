//! What an editor pays, with and without the stage cache.
//!
//! The editor's work is not one render: it draws the preview, a thumbnail per
//! node showing the chain as far as that node, and -- when a node is selected
//! -- one render per control to find which of them do anything. All of that
//! shares its early stages with the render before it.
//!
//!   cargo run --release --example chain_cost -- [size]

use std::time::Instant;

use gltcstdio::{FilterNode, Image, Params, Renderer};

/// A chain of `n` filters, as the editor builds one.
fn chain(stages: &[&str]) -> FilterNode {
    let mut node = serde_json::json!({"input": "source"});
    for id in stages {
        node = serde_json::json!({"filter": id, "inputs": {"source": node}});
    }
    serde_json::from_value(node).expect("graph")
}

fn main() {
    let n: u32 = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(900);

    let mut src = Image::empty(n, n);
    for y in 0..n {
        for x in 0..n {
            src.set(x, y, [(x % 256) as u8, (y % 256) as u8, 128, 255]);
        }
    }

    let stages = ["circle-mosaic", "emboss", "halftone", "contour", "adjust", "vignette"];
    let mut r = Renderer::new_blocking().expect("renderer");

    // The preview, then a thumbnail for each node: the chain as far as it.
    let prefixes: Vec<FilterNode> = (1..=stages.len()).map(|k| chain(&stages[..k])).collect();

    for warm in [false, true] {
        r.forget_stages();
        r.forget_uploads();
        if warm {
            // What the editor already drew before the change being timed.
            for g in &prefixes {
                let _ = r.apply_graph(g, &src, &Params::new());
            }
        }
        let started = Instant::now();
        let mut drawn = 0;
        for g in &prefixes {
            if r.apply_graph(g, &src, &Params::new()).is_ok() {
                drawn += 1;
            }
        }
        let ms = started.elapsed().as_secs_f64() * 1000.0;
        println!(
            "{:<5} preview + {drawn} thumbnails: {ms:8.1} ms",
            if warm { "warm" } else { "cold" }
        );
    }

    // A slider moved on the last stage: everything above it is unchanged.
    r.forget_stages();
    r.forget_uploads();
    let full = chain(&stages);
    let _ = r.apply_graph(&full, &src, &Params::new());
    for (label, values) in [("same values", Params::new()), ("last stage moved", {
        let mut p = Params::new();
        p.insert("intensity".into(), gltcstdio::Value::Float(0.7));
        p
    })] {
        let started = Instant::now();
        let _ = r.apply_graph(&full, &src, &values);
        println!("{label:<18}: {:8.1} ms", started.elapsed().as_secs_f64() * 1000.0);
    }

    let (hits, misses) = r.stage_stats();
    println!("stage cache: {hits} hits, {misses} misses");
}
