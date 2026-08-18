//! Generate the table that maps a filter id to its WGSL.
//!
//! The shaders are `include_str!`'d rather than read at run time so the crate
//! is one self-contained artefact, which is what the web target needs.

use std::fmt::Write as _;
use std::path::Path;

fn main() {
    let assets = Path::new(env!("CARGO_MANIFEST_DIR")).join("assets");
    let wgsl = assets.join("wgsl");
    let web = assets.join("wgsl-web");
    println!("cargo:rerun-if-changed={}", wgsl.display());
    println!("cargo:rerun-if-changed={}", web.display());
    println!("cargo:rerun-if-changed={}", assets.join("bank.json").display());

    // A browser refuses a texture sample taken in non-uniform control flow,
    // so 192 filters have a second source that takes the mip level
    // explicitly.  Only one set is embedded, chosen by target, which keeps
    // the module the same size either way.
    let for_web = std::env::var("CARGO_CFG_TARGET_ARCH").as_deref() == Ok("wasm32");

    let mut names: Vec<String> = std::fs::read_dir(&wgsl)
        .unwrap_or_else(|e| panic!("{}: {e}", wgsl.display()))
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .filter(|p| p.extension().and_then(|s| s.to_str()) == Some("wgsl"))
        .map(|p| p.file_stem().unwrap().to_string_lossy().into_owned())
        .collect();
    names.sort();

    let mut out = String::from(
        "/// Filter id -> its WGSL fragment shader, sorted by id.\n\
         pub static SHADERS: &[(&str, &str)] = &[\n",
    );
    for name in &names {
        let dir = if for_web && web.join(format!("{name}.wgsl")).exists() {
            "wgsl-web"
        } else {
            "wgsl"
        };
        writeln!(
            out,
            "    ({name:?}, include_str!(concat!(env!(\"CARGO_MANIFEST_DIR\"), \"/assets/{dir}/{name}.wgsl\"))),"
        )
        .unwrap();
    }
    out.push_str("];\n");

    let dest = Path::new(&std::env::var("OUT_DIR").unwrap()).join("shaders.rs");
    std::fs::write(dest, out).unwrap();
}
