//! Render every filter once and report, for comparison against the Python
//! implementation.
//!
//!   cargo run --release --example sweep -- <in.rgba> <w> <h> [out-dir]
//!
//! Images are raw RGBA8 so the example needs no codec.

use std::collections::HashMap;
use std::path::PathBuf;
use std::time::Instant;

use gltcstdio::{bank, Backend, Image, Params, Renderer};

fn main() {
    let mut args = std::env::args().skip(1);
    let path = args.next().expect("usage: sweep <in.rgba> <w> <h> [out-dir]");
    let w: u32 = args.next().expect("width").parse().unwrap();
    let h: u32 = args.next().expect("height").parse().unwrap();
    let out_dir = args.next().map(PathBuf::from);
    if let Some(d) = &out_dir {
        std::fs::create_dir_all(d).unwrap();
    }

    let src = Image::new(w, h, std::fs::read(&path).unwrap());
    let mut renderer = Renderer::new_blocking().expect("renderer");
    eprintln!("gpu: {}", renderer.has_gpu());

    let mut counts: HashMap<&str, usize> = HashMap::new();
    let mut failures: Vec<(String, String)> = Vec::new();
    let mut total_ms = 0.0;

    let ids: Vec<&str> = bank().ids().collect();
    for id in &ids {
        let spec = bank().get(id).unwrap();
        let started = Instant::now();
        match renderer.apply(id, &src, &Params::new()) {
            Ok(out) => {
                total_ms += started.elapsed().as_secs_f64() * 1000.0;
                *counts.entry(backend_name(spec.backend)).or_default() += 1;
                if let Some(d) = &out_dir {
                    std::fs::write(d.join(format!("{id}.rgba")), &out.data).unwrap();
                }
            }
            Err(e) => {
                *counts.entry("failed").or_default() += 1;
                failures.push((id.to_string(), e.to_string()));
            }
        }
    }

    println!("rendered {} of {} filters in {total_ms:.0} ms", ids.len() - failures.len(), ids.len());
    let mut kinds: Vec<_> = counts.into_iter().collect();
    kinds.sort();
    for (kind, n) in kinds {
        println!("  {kind:8} {n}");
    }
    if !failures.is_empty() {
        println!("\nfailures:");
        let mut by_reason: HashMap<String, Vec<String>> = HashMap::new();
        for (id, why) in failures {
            by_reason.entry(short(&why)).or_default().push(id);
        }
        let mut groups: Vec<_> = by_reason.into_iter().collect();
        groups.sort_by_key(|(_, ids)| std::cmp::Reverse(ids.len()));
        for (why, ids) in groups {
            println!("  {:4}x {why}", ids.len());
            println!("        {}", ids.join(", ").chars().take(200).collect::<String>());
        }
    }
}

fn backend_name(b: Backend) -> &'static str {
    match b {
        Backend::Gl => "gpu",
        Backend::Cpu => "cpu",
        Backend::Graph => "graph",
    }
}

fn short(why: &str) -> String {
    why.chars().take(80).collect()
}
