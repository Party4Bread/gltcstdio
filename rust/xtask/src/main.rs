//! Translate the exported GLSL into the WGSL the crate ships.
//!
//! `tools/export_rust.py` writes one `assets/glsl/<id>.frag` per GPU filter in
//! Vulkan-flavoured GLSL.  This turns each into WGSL with naga so the runtime
//! carries no shader frontend -- which matters most on the web, where the
//! translation cannot be done at load time anyway.
//!
//! Run from the workspace root:  cargo run -p xtask --release -- translate

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

fn assets() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("crates/gltcstdio/assets")
}

fn translate_one(src: &str) -> Result<String, String> {
    let mut frontend = naga::front::glsl::Frontend::default();
    let options = naga::front::glsl::Options {
        stage: naga::ShaderStage::Fragment,
        defines: Default::default(),
    };
    let module = frontend
        .parse(&options, src)
        .map_err(|e| first_error("parse", &e.emit_to_string(src)))?;
    let info = naga::valid::Validator::new(
        naga::valid::ValidationFlags::all(),
        naga::valid::Capabilities::all(),
    )
    .validate(&module)
    .map_err(|e| first_error("validate", &e.emit_to_string(src)))?;
    naga::back::wgsl::write_string(&module, &info, naga::back::wgsl::WriterFlags::empty())
        .map_err(|e| format!("wgsl: {e}"))
}

/// The first line of a naga diagnostic that names the problem.
fn first_error(stage: &str, report: &str) -> String {
    let line = report
        .lines()
        .find(|l| l.contains("error"))
        .unwrap_or("unknown")
        .trim();
    format!("{stage}: {}", line.chars().take(120).collect::<String>())
}

fn main() {
    if let Some(p) = std::env::args().nth(1).filter(|a| a.ends_with(".frag")) {
        probe_one(&p);
        return;
    }
    // A browser refuses a sample taken in non-uniform control flow, so those
    // filters have a second source that takes the mip level explicitly.  Both
    // sets are translated; the build picks one per target.
    translate_dir("glsl", "wgsl", true);
    translate_dir("glsl-web", "wgsl-web", false);
}

fn translate_dir(from: &str, to: &str, index: bool) {
    let assets = assets();
    let glsl_dir = assets.join(from);
    let wgsl_dir = assets.join(to);
    let _ = std::fs::remove_dir_all(&wgsl_dir);
    std::fs::create_dir_all(&wgsl_dir).unwrap();
    if !glsl_dir.exists() {
        return;
    }

    let mut sources: Vec<PathBuf> = std::fs::read_dir(&glsl_dir)
        .unwrap_or_else(|e| panic!("{}: {e}", glsl_dir.display()))
        .filter_map(|e| e.ok().map(|e| e.path()))
        .filter(|p| p.extension().and_then(|s| s.to_str()) == Some("frag"))
        .collect();
    sources.sort();

    let mut ok = 0usize;
    let mut failed: BTreeMap<String, Vec<String>> = BTreeMap::new();
    let mut bytes = 0usize;
    for path in &sources {
        let id = path.file_stem().unwrap().to_string_lossy().to_string();
        let src = std::fs::read_to_string(path).unwrap();
        match translate_one(&src) {
            Ok(wgsl) => {
                bytes += wgsl.len();
                std::fs::write(wgsl_dir.join(format!("{id}.wgsl")), wgsl).unwrap();
                ok += 1;
            }
            Err(msg) => failed.entry(msg).or_default().push(id),
        }
    }

    let total = sources.len();
    println!("{to}: translated {ok}/{total} shaders, {:.1} MB", bytes as f64 / 1e6);
    if !failed.is_empty() {
        let mut groups: Vec<_> = failed.iter().collect();
        groups.sort_by_key(|(_, ids)| std::cmp::Reverse(ids.len()));
        println!("\nnot translated:");
        for (msg, ids) in groups {
            println!("  {:3}x {msg}", ids.len());
            println!("       {}", ids.join(", ").chars().take(160).collect::<String>());
        }
    }

    if !index {
        return;
    }
    // Record which filters have a shader so the crate can mark the rest.
    let names: Vec<String> = std::fs::read_dir(&wgsl_dir)
        .unwrap()
        .filter_map(|e| e.ok())
        .map(|e| e.path().file_stem().unwrap().to_string_lossy().to_string())
        .collect();
    let mut names = names;
    names.sort();
    std::fs::write(
        assets.join("wgsl_index.json"),
        serde_json::to_string(&names).unwrap(),
    )
    .unwrap();
}

#[allow(dead_code)]
fn probe_one(path: &str) {
    let src = std::fs::read_to_string(path).unwrap();
    let mut frontend = naga::front::glsl::Frontend::default();
    let options = naga::front::glsl::Options {
        stage: naga::ShaderStage::Fragment,
        defines: Default::default(),
    };
    match frontend.parse(&options, &src) {
        Err(e) => println!("PARSE\n{}", e.emit_to_string(&src)),
        Ok(module) => match naga::valid::Validator::new(
            naga::valid::ValidationFlags::all(),
            naga::valid::Capabilities::all(),
        )
        .validate(&module)
        {
            Err(e) => println!("VALIDATE\n{}", e.emit_to_string(&src)),
            Ok(info) => match naga::back::wgsl::write_string(
                &module, &info, naga::back::wgsl::WriterFlags::empty()) {
                Ok(w) => println!("OK {} bytes", w.len()),
                Err(e) => println!("WGSL {e}"),
            },
        },
    }
}
