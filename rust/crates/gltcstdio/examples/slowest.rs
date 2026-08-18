//! What the editor waits for: every filter timed at preview size, slowest
//! first.  The editor renders a chain on every change, so a filter that takes
//! a second is felt as lag rather than measured.
//!
//!   cargo run --release --example slowest -- [size] [how-many]

use std::time::Instant;

use gltcstdio::{bank, Backend, Image, Params, Renderer};

/// Timed runs per filter, best taken.
const RUNS: usize = 5;

fn main() {
    let mut args = std::env::args().skip(1);
    let n: u32 = args.next().and_then(|s| s.parse().ok()).unwrap_or(900);
    let show: usize = args.next().and_then(|s| s.parse().ok()).unwrap_or(25);

    // A picture with detail at every scale, so nothing is quick because the
    // input happened to be flat.
    let mut src = Image::empty(n, n);
    for y in 0..n {
        for x in 0..n {
            let (fx, fy) = (x as f32 / n as f32, y as f32 / n as f32);
            let ring = (((fx - 0.5).powi(2) + (fy - 0.5).powi(2)).sqrt() * 40.0).sin();
            src.set(x, y, [
                ((fx * 255.0) as u32 % 256) as u8,
                ((fy * 255.0) as u32 % 256) as u8,
                ((ring * 0.5 + 0.5) * 255.0) as u8,
                255,
            ]);
        }
    }

    let mut r = Renderer::new_blocking().expect("renderer");
    eprintln!("gpu: {}, {n}x{n}", r.has_gpu());

    let mut timed: Vec<(f64, String, &'static str)> = Vec::new();
    for id in bank().ids().collect::<Vec<_>>() {
        let spec = bank().get(id).unwrap();
        // Warm the upload cache and build the pipeline first: a filter's own
        // shader is compiled the first time it is used, which costs several
        // times what rendering it does and would swamp what is being
        // measured.  The stage cache has to go the other way -- it holds the
        // answer to exactly this call, so leaving it would time a memcpy.
        //
        // Best of several, because one run in a sweep of 769 catches whatever
        // the driver was doing for the filter before it.
        if r.apply(id, &src, &Params::new()).is_err() {
            continue;
        }
        let mut best = f64::MAX;
        for _ in 0..RUNS {
            r.forget_stages();
            let started = Instant::now();
            if r.apply(id, &src, &Params::new()).is_err() {
                break;
            }
            best = best.min(started.elapsed().as_secs_f64() * 1000.0);
        }
        if best == f64::MAX {
            continue;
        }
        timed.push((
            best,
            id.to_string(),
            match spec.backend {
                Backend::Cpu => "cpu",
                Backend::Graph => "graph",
                _ => "gpu",
            },
        ));
    }

    timed.sort_by(|a, b| b.0.partial_cmp(&a.0).unwrap());
    let total: f64 = timed.iter().map(|t| t.0).sum();
    println!("{} filters, {:.1} ms total, {:.1} ms median",
             timed.len(), total, timed[timed.len() / 2].0);
    println!("over 250 ms: {}", timed.iter().filter(|t| t.0 > 250.0).count());
    for (ms, id, backend) in timed.iter().take(show) {
        println!("{ms:9.1} ms  {backend:<5}  {id}");
    }
}
