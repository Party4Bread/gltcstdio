//! Colour, tone and framing operators.

use super::blur::{gaussian, Plane};
use super::{f, i, luma, rgba, Inputs, Rng, Values};
use crate::image::Image;

/// Bilinear resample to a new size, as the Python build's Lanczos resize
/// stands in for; the app itself only ever scales by small factors here.
pub fn resize(img: &Image, width: u32, height: u32) -> Image {
    let mut out = Image::empty(width, height);
    let sx = img.width as f32 / width as f32;
    let sy = img.height as f32 / height as f32;
    for y in 0..height {
        for x in 0..width {
            let fx = ((x as f32 + 0.5) * sx - 0.5).max(0.0);
            let fy = ((y as f32 + 0.5) * sy - 0.5).max(0.0);
            let x0 = fx.floor() as i64;
            let y0 = fy.floor() as i64;
            let tx = fx - x0 as f32;
            let ty = fy - y0 as f32;
            let mut px = [0u8; 4];
            for c in 0..4 {
                let p00 = img.clamped(x0, y0)[c] as f32;
                let p10 = img.clamped(x0 + 1, y0)[c] as f32;
                let p01 = img.clamped(x0, y0 + 1)[c] as f32;
                let p11 = img.clamped(x0 + 1, y0 + 1)[c] as f32;
                let top = p00 + (p10 - p00) * tx;
                let bottom = p01 + (p11 - p01) * tx;
                px[c] = (top + (bottom - top) * ty).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// Blend the image with a flipped copy of itself.
///
/// The app's `blend` takes two inputs; with one image the second is its
/// mirror, which keeps the operator meaningful on a single source.
pub fn blend(img: &Image, v: &Values, _: &Inputs) -> Image {
    let amount = f(v, "amount");
    let mode = i(v, "mode");
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let a = img.get(x, y);
            let b = img.get(img.width - 1 - x, y);
            let mut px = a;
            for c in 0..3 {
                let av = a[c] as f32 / 255.0;
                let bv = b[c] as f32 / 255.0;
                let mixed = match mode {
                    1 => av * bv,
                    2 => 1.0 - (1.0 - av) * (1.0 - bv),
                    3 => {
                        if av < 0.5 {
                            2.0 * av * bv
                        } else {
                            1.0 - 2.0 * (1.0 - av) * (1.0 - bv)
                        }
                    }
                    4 => (av - bv).abs(),
                    _ => bv,
                };
                px[c] = ((av * (1.0 - amount) + mixed * amount) * 255.0).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// Ghosted echoes of the frame, fading and shrinking inwards.
pub fn flashback(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, count) = (f(v, "intensity"), i(v, "count").max(1));
    let mut acc: Vec<f32> = img.data.iter().map(|&b| b as f32).collect();
    for echo in 1..=count {
        let k = 1.0 - echo as f32 / (count + 1) as f32;
        let s = 1.0 - 0.08 * echo as f32;
        let sw = ((img.width as f32 * s) as u32).max(1);
        let sh = ((img.height as f32 * s) as u32).max(1);
        let small = resize(img, sw, sh);
        let ox = (img.width - sw) / 2;
        let oy = (img.height - sh) / 2;
        for y in 0..sh {
            for x in 0..sw {
                let src = small.get(x, y);
                let base = (((oy + y) as usize) * img.width as usize + (ox + x) as usize) * 4;
                for c in 0..4 {
                    acc[base + c] += src[c] as f32 * (k * intensity);
                }
            }
        }
    }
    let scale = 1.0 + intensity * 0.7;
    Image::new(
        img.width,
        img.height,
        acc.iter().map(|v| (v / scale).clamp(0.0, 255.0) as u8).collect(),
    )
}

/// Blend the image with its inverted mirror.
pub fn negative_mirror(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (amount, axis) = (f(v, "blend"), i(v, "axis"));
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let src = if axis == 0 {
                img.get(img.width - 1 - x, y)
            } else {
                img.get(x, img.height - 1 - y)
            };
            let a = img.get(x, y);
            let mut px = [0u8; 4];
            for c in 0..3 {
                let inv = 255.0 - src[c] as f32;
                px[c] = (a[c] as f32 * (1.0 - amount) + inv * amount).clamp(0.0, 255.0) as u8;
            }
            px[3] = (a[3] as f32 * (1.0 - amount) + src[3] as f32 * amount) as u8;
            out.set(x, y, px);
        }
    }
    out
}

/// Saturation lifted inside a centred square, left alone outside.
pub fn saturated_square(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, size) = (f(v, "intensity"), f(v, "size"));
    let s = size * 0.5;
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let inside = (x as f32 / img.width as f32 - 0.5).abs() < s
                && (y as f32 / img.height as f32 - 0.5).abs() < s;
            if !inside {
                continue;
            }
            let p = img.get(x, y);
            let mean = (p[0] as f32 + p[1] as f32 + p[2] as f32) / 3.0;
            let mut px = p;
            for c in 0..3 {
                let value = mean + (p[c] as f32 - mean) * (1.0 + intensity * 2.0);
                px[c] = value.clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// Two-tone ink wash: smooth, then cut at a threshold.  (Shared with `paint`.)
pub fn ink(img: &Image, threshold: f32, smoothing: f32, ink: [f32; 4], paper: [f32; 4]) -> Image {
    let mut g = Plane::scalar(img, |p| luma(p[0] / 255.0, p[1] / 255.0, p[2] / 255.0));
    if smoothing > 0.0 {
        g = gaussian(&g, smoothing * img.width.min(img.height) as f32);
    }
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let dark = g.at(x as usize, y as usize, 0) < threshold;
            let colour = if dark { ink } else { paper };
            let mut px = img.get(x, y);
            for c in 0..3 {
                px[c] = (colour[c] * 255.0).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// Green phosphor terminal: monochrome, scanlined, with code overlaid.
pub fn preset_hacker(img: &Image, v: &Values, inputs: &Inputs) -> Image {
    let intensity = f(v, "intensity");
    let tint = rgba(v, "color");
    let mut out = img.clone();
    for y in 0..img.height {
        let scan = 0.75 + 0.25 * ((y as f32 * std::f32::consts::PI).cos() * 0.5 + 0.5);
        for x in 0..img.width {
            let p = img.get(x, y);
            let g = luma(p[0] as f32 / 255.0, p[1] as f32 / 255.0, p[2] as f32 / 255.0);
            let mut px = p;
            for c in 0..3 {
                let lit = g * tint[c] * 255.0 * scan;
                px[c] = (lit * intensity + p[c] as f32 * (1.0 - intensity)).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    let mut code = Values::new();
    code.insert("size".into(), vec![0.028]);
    code.insert("lines".into(), vec![14.0]);
    code.insert("color".into(), tint.to_vec());
    super::text::code_text(&out, &code, inputs)
}

/// A checker pattern blended over the image, as the app's test card does.
pub fn procedural_test_blend(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (amount, scale) = (f(v, "blend"), f(v, "scale"));
    let cell = ((scale * img.width.min(img.height) as f32) as u32).max(1);
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let checker = ((x / cell + y / cell) % 2) as f32 * 255.0;
            let p = img.get(x, y);
            let mut px = p;
            for c in 0..3 {
                px[c] = (p[c] as f32 * (1.0 - amount) + checker * amount).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// The Bayer matrix the dithering filters use, as an image.
pub fn dithering_pattern(img: &Image, v: &Values, _: &Inputs) -> Image {
    let want = i(v, "size");
    let n: usize = if want <= 2 {
        2
    } else if want >= 8 {
        8
    } else {
        4
    };
    let mut m: Vec<Vec<f32>> = vec![vec![0.0, 2.0], vec![3.0, 1.0]];
    while m.len() < n {
        let k = m.len();
        let mut next = vec![vec![0.0f32; k * 2]; k * 2];
        for y in 0..k {
            for x in 0..k {
                next[y][x] = 4.0 * m[y][x];
                next[y][x + k] = 4.0 * m[y][x] + 2.0;
                next[y + k][x] = 4.0 * m[y][x] + 3.0;
                next[y + k][x + k] = 4.0 * m[y][x] + 1.0;
            }
        }
        m = next;
    }
    let peak = m.iter().flatten().cloned().fold(0.0f32, f32::max).max(1.0);
    let mut out = Image::empty(img.width, img.height);
    for y in 0..img.height {
        for x in 0..img.width {
            let value = (m[y as usize % n][x as usize % n] / peak * 255.0) as u8;
            out.set(x, y, [value, value, value, 255]);
        }
    }
    out
}

/// The image's dominant colours laid out as a palette strip.
pub fn color_list_to_palette_image(img: &Image, v: &Values, _: &Inputs) -> Image {
    let n = i(v, "count").max(2) as usize;
    // Even quantisation is enough to pull out the palette without clustering.
    let mut counts: std::collections::HashMap<[u8; 3], usize> = std::collections::HashMap::new();
    for i in 0..img.pixels() {
        let key = [0, 1, 2].map(|c| {
            ((img.data[i * 4 + c] as f32 / 255.0 * 4.0).round() * (255.0 / 4.0)) as u8
        });
        *counts.entry(key).or_default() += 1;
    }
    let mut ranked: Vec<([u8; 3], usize)> = counts.into_iter().collect();
    // Ties broken by colour so the strip is the same on every run.
    ranked.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));
    let mut palette: Vec<[u8; 3]> = ranked.iter().take(n).map(|(k, _)| *k).collect();
    while palette.len() < n {
        let last = *palette.last().unwrap_or(&[0, 0, 0]);
        palette.push(last);
    }

    let mut out = Image::empty(img.width, img.height);
    for x in 0..img.width {
        let slot = ((x as f32 / img.width as f32 * n as f32) as usize).min(n - 1);
        let c = palette[slot];
        for y in 0..img.height {
            out.set(x, y, [c[0], c[1], c[2], 255]);
        }
    }
    out
}

/// Re-sample the image through a transform; outside it, the border shows.
pub fn image_view(img: &Image, v: &Values, _: &Inputs) -> Image {
    let s = f(v, "scale").max(1e-3);
    let (dx, dy) = (f(v, "x"), f(v, "y"));
    let border = rgba(v, "borderColor");
    let (w, h) = (img.width as f32, img.height as f32);
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let u = (x as f32 - w / 2.0) / s + w / 2.0 - dx * w;
            let vv = (y as f32 - h / 2.0) / s + h / 2.0 - dy * h;
            if u >= 0.0 && u < w && vv >= 0.0 && vv < h {
                out.set(x, y, img.clamped(u as i64, vv as i64));
            } else {
                out.set(x, y, border.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8));
            }
        }
    }
    out
}

/// Crop by relative bounds, then resize back to the original size.
pub fn crop_and_resize_rel(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (w, h) = (img.width, img.height);
    let x0 = (f(v, "left").clamp(0.0, 1.0) * w as f32) as u32;
    let x1 = ((f(v, "right").clamp(0.0, 1.0) * w as f32) as u32).max(x0 + 1).min(w);
    let y0 = (f(v, "top").clamp(0.0, 1.0) * h as f32) as u32;
    let y1 = ((f(v, "bottom").clamp(0.0, 1.0) * h as f32) as u32).max(y0 + 1).min(h);

    let mut crop = Image::empty(x1 - x0, y1 - y0);
    for y in y0..y1 {
        for x in x0..x1 {
            crop.set(x - x0, y - y0, img.get(x, y));
        }
    }
    resize(&crop, w, h)
}

/// Radial smears from scattered centres, as a thrown liquid leaves.
pub fn splash(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, count, seed) = (f(v, "intensity"), i(v, "count").max(1), f(v, "seed"));
    let (w, h) = (img.width as f32, img.height as f32);
    let mut rng = Rng::seeded((seed as i64 & 0xFFFF) as u64);

    let mut centres = Vec::with_capacity(count as usize);
    for _ in 0..count {
        let sx = rng.random() as f32 * w;
        let sy = rng.random() as f32 * h;
        let rad = (0.05 + rng.random() as f32 * 0.2) * w.min(h);
        centres.push((sx, sy, rad));
    }

    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let (mut dx, mut dy) = (0.0f32, 0.0f32);
            for (sx, sy, rad) in &centres {
                let ux = x as f32 - sx;
                let uy = y as f32 - sy;
                let d = ux.hypot(uy) + 1e-6;
                let fall = (1.0 - d / rad).clamp(0.0, 1.0).powi(2);
                dx += ux / d * fall * rad * 0.5;
                dy += uy / d * fall * rad * 0.5;
            }
            let sxi = (x as f32 + dx * intensity).round() as i64;
            let syi = (y as f32 + dy * intensity).round() as i64;
            out.set(x, y, img.clamped(sxi, syi));
        }
    }
    out
}

/// Scatter copies of random crops back over the image.
pub fn random_tile_placer(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (count, size, seed) = (i(v, "count").max(1), f(v, "size"), f(v, "randomSeed"));
    let (w, h) = (img.width as i64, img.height as i64);
    let s = ((size * img.width.min(img.height) as f32) as i64).max(2);
    let mut rng = Rng::seeded((seed as i64 & 0xFFFF) as u64);
    let mut out = img.clone();
    for _ in 0..count {
        let sy = rng.integers(0, (h - s).max(1));
        let sx = rng.integers(0, (w - s).max(1));
        let dy = rng.integers(0, (h - s).max(1));
        let dx = rng.integers(0, (w - s).max(1));
        for y in 0..s.min(h - dy).min(h - sy) {
            for x in 0..s.min(w - dx).min(w - sx) {
                let px = img.get((sx + x) as u32, (sy + y) as u32);
                out.set((dx + x) as u32, (dy + y) as u32, px);
            }
        }
    }
    out
}
