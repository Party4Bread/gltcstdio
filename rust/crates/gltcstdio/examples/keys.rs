//! Content keys for every filter, to compare two builds byte for byte.
use gltcstdio::{bank, Image, Params, Renderer};
fn main() {
    let n: u32 = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(256);
    let mut src = Image::empty(n, n);
    for y in 0..n { for x in 0..n {
        src.set(x, y, [(x % 256) as u8, (y % 256) as u8, ((x * 3 ^ y * 5) % 256) as u8, 255]);
    }}
    let mut r = Renderer::new_blocking().expect("renderer");
    for id in bank().ids().collect::<Vec<_>>() {
        match r.apply(id, &src, &Params::new()) {
            Ok(out) => println!("{id} {:016x}", out.content_key()),
            Err(_) => println!("{id} -"),
        }
    }
}
