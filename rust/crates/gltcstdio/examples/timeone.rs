//! Time one filter properly: many runs, best-of, cache cleared each time.
//!   cargo run --release --example timeone -- <id> [size] [runs]
use std::time::Instant;
use gltcstdio::{Image, Params, Renderer};
fn main() {
    let mut a = std::env::args().skip(1);
    let id = a.next().expect("filter id");
    let n: u32 = a.next().and_then(|s| s.parse().ok()).unwrap_or(900);
    let runs: usize = a.next().and_then(|s| s.parse().ok()).unwrap_or(30);
    let mut src = Image::empty(n, n);
    for y in 0..n { for x in 0..n {
        src.set(x, y, [(x % 256) as u8, (y % 256) as u8, ((x ^ y) % 256) as u8, 255]);
    }}
    let mut r = Renderer::new_blocking().expect("renderer");
    let _ = r.apply(&id, &src, &Params::new());     // warm the upload
    let mut best = f64::MAX;
    let mut total = 0.0;
    let mut checksum = 0u64;
    for _ in 0..runs {
        r.forget_stages();
        let t = Instant::now();
        let out = r.apply(&id, &src, &Params::new()).expect("render");
        let ms = t.elapsed().as_secs_f64() * 1000.0;
        checksum = out.content_key();
        best = best.min(ms);
        total += ms;
    }
    println!("{id} at {n}x{n}: best {best:.2} ms, mean {:.2} ms over {runs} runs  [key {checksum:016x}]",
             total / runs as f64);
}
