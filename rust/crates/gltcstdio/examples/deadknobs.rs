//! Declared knobs that change nothing, measured rather than inferred.
//!
//! A graph exposes its knobs by binding them into its nodes; one that binds
//! nothing reaches nothing, and the control is dead. `sharpen` was like that
//! -- extracted as a graph with none of its bindings -- so this looks for the
//! rest of them.
//!
//! A knob can be legitimately inert at the defaults (a fog colour with the
//! fog off), so this is a list to read, not a verdict.
use gltcstdio::{bank, Backend, Image, Params, Renderer, Value};

fn main() {
    let n = 128u32;
    let mut src = Image::empty(n, n);
    for y in 0..n {
        for x in 0..n {
            src.set(x, y, [(x * 2 % 256) as u8, (y * 2 % 256) as u8,
                           ((x * 3 ^ y * 5) % 256) as u8, 255]);
        }
    }
    let mut r = Renderer::new_blocking().expect("renderer");
    let only_graphs = std::env::args().any(|a| a == "--graphs");

    let mut total = 0;
    for id in bank().ids().collect::<Vec<_>>() {
        let spec = bank().get(id).unwrap();
        if only_graphs && spec.backend != Backend::Graph {
            continue;
        }
        let Ok(base) = r.apply(id, &src, &Params::new()) else { continue };
        let mut dead = Vec::new();
        let mut live = 0;
        for p in &spec.params {
            // Somewhere plainly different from where it sits.
            let alt = match (p.ty.as_str(), p.min, p.max) {
                ("float", Some(lo), Some(hi)) if lo < hi => {
                    let now = p.default_value().as_f32().unwrap_or(lo);
                    Value::Float(if (now - lo).abs() > (now - hi).abs() { lo } else { hi })
                }
                ("int", Some(lo), Some(hi)) if lo < hi => {
                    let now = p.default_value().as_f32().unwrap_or(lo);
                    Value::Int(if (now - lo).abs() > (now - hi).abs() { lo as i32 } else { hi as i32 })
                }
                _ => continue,
            };
            let mut values = Params::new();
            values.insert(p.name.clone(), alt);
            match r.apply(id, &src, &values) {
                Ok(out) if out.data == base.data => dead.push(p.name.clone()),
                Ok(_) => live += 1,
                Err(_) => {}
            }
        }
        if !dead.is_empty() {
            total += dead.len();
            println!("{id} [{:?}] {} dead of {}: {dead:?}",
                     spec.backend, dead.len(), dead.len() + live);
        }
    }
    println!("\n{total} knobs changed nothing");
}
