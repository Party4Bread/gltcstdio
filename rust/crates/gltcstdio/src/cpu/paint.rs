//! Painterly filters and the canvas brushes.
//!
//! The painterly four flatten the image into regions and re-render them with
//! a different mark: flat facets for the knife, soft blocks for pastel,
//! flowing strokes for Saint-Remy, shard outlines for broken glass (which
//! lives with the other warps).

use super::blur::{gaussian, Plane};
use super::{f, i, luma, rgba, Inputs, Rng, Values};
use crate::image::Image;

/// Flatten to regions by quantising colour, coarser as tolerance rises.
///
/// The jitter is drawn per pixel in row-major order, which is the order
/// numpy fills `rng.random((h, w, 1))`.
fn quantise(plane: &Plane, tolerance: f32, seed: f32) -> Plane {
    let levels = (2.0 + (1.0 - tolerance) * 22.0).round().max(2.0);
    let mut rng = Rng::seeded((seed as i64 & 0xFFFF) as u64);
    let step = 255.0 / (levels - 1.0);
    let amplitude = 255.0 / levels * 0.5;

    let mut out = Plane {
        width: plane.width,
        height: plane.height,
        channels: plane.channels,
        data: vec![0.0; plane.data.len()],
    };
    for i in 0..plane.width * plane.height {
        let jitter = (rng.random() as f32 - 0.5) * amplitude;
        for c in 0..plane.channels {
            let value = plane.data[i * plane.channels + c] + jitter;
            out.data[i * plane.channels + c] =
                ((value / step).round() * step).clamp(0.0, 255.0);
        }
    }
    out
}

fn rgb_plane(img: &Image) -> Plane {
    let mut data = Vec::with_capacity(img.pixels() * 3);
    for i in 0..img.pixels() {
        for c in 0..3 {
            data.push(img.data[i * 4 + c] as f32);
        }
    }
    Plane {
        width: img.width as usize,
        height: img.height as usize,
        channels: 3,
        data,
    }
}

fn with_rgb(img: &Image, rgb: &Plane) -> Image {
    let mut out = img.clone();
    for i in 0..img.pixels() {
        for c in 0..3 {
            out.data[i * 4 + c] = rgb.data[i * 3 + c].clamp(0.0, 255.0) as u8;
        }
    }
    out
}

/// Flat facets with a hard edge, as a palette knife leaves.
pub fn knife_painting(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (tolerance, seed) = (f(v, "tolerance"), f(v, "randomSeed"));
    let flat = quantise(&rgb_plane(img), tolerance, seed);
    // A light blur then re-quantise merges specks into broad strokes.
    let flat = quantise(&gaussian(&flat, 1.5), tolerance, seed);
    with_rgb(img, &flat)
}

/// Soft chalky blocks: quantised colour, lifted towards white, grained.
pub fn pastel(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (tolerance, seed, grain) = (f(v, "tolerance"), f(v, "randomSeed"), f(v, "grain"));
    let mut flat = gaussian(&quantise(&rgb_plane(img), tolerance, seed), 1.2);

    // Chalk sits lighter and less saturated than the source.
    for i in 0..flat.width * flat.height {
        let mean = (flat.data[i * 3] + flat.data[i * 3 + 1] + flat.data[i * 3 + 2]) / 3.0;
        for c in 0..3 {
            flat.data[i * 3 + c] = flat.data[i * 3 + c] * 0.72 + mean * 0.10 + 255.0 * 0.18;
        }
    }

    let mut rng = Rng::seeded(((seed as i64 & 0xFFFF) + 1) as u64);
    for i in 0..flat.width * flat.height {
        let noise = (rng.random() as f32 - 0.5) * (60.0 * grain);
        for c in 0..3 {
            flat.data[i * 3 + c] += noise;
        }
    }
    with_rgb(img, &flat)
}

/// Strokes that follow the image gradient, as in the Starry Night manner.
pub fn saint_remy(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, thickness, brightness) =
        (f(v, "intensity"), f(v, "thickness"), f(v, "brightness"));
    let g = gaussian(
        &Plane::scalar(img, |p| luma(p[0] / 255.0, p[1] / 255.0, p[2] / 255.0)),
        2.0,
    );
    let (w, h) = (img.width as usize, img.height as usize);
    let step = (thickness * w.min(h) as f32 * 0.03).max(1.0);
    let taps = 5i32;

    let mut out = img.clone();
    for y in 0..h {
        for x in 0..w {
            let gx = if x > 0 && x + 1 < w {
                g.at(x + 1, y, 0) - g.at(x - 1, y, 0)
            } else {
                0.0
            };
            let gy = if y > 0 && y + 1 < h {
                g.at(x, y + 1, 0) - g.at(x, y - 1, 0)
            } else {
                0.0
            };
            // Flow along the isophotes -- perpendicular to the gradient.
            let mag = gx.hypot(gy) + 1e-6;
            let (fx, fy) = (-gy / mag, gx / mag);

            let mut acc = [0.0f32; 3];
            for tap in -taps..=taps {
                let sx = (x as f32 + fx * tap as f32 * step).round() as i64;
                let sy = (y as f32 + fy * tap as f32 * step).round() as i64;
                let px = img.clamped(sx, sy);
                for c in 0..3 {
                    acc[c] += px[c] as f32;
                }
            }
            let n = (2 * taps + 1) as f32;
            let src = img.get(x as u32, y as u32);
            let mut px = src;
            for c in 0..3 {
                let mixed = src[c] as f32 * (1.0 - intensity) + acc[c] / n * intensity;
                px[c] = (mixed * (1.0 + brightness)).clamp(0.0, 255.0) as u8;
            }
            out.set(x as u32, y as u32, px);
        }
    }
    out
}

/// Two-tone ink wash: smooth, then cut at a threshold.
pub fn ink_b(img: &Image, v: &Values, _: &Inputs) -> Image {
    super::tone::ink(
        img,
        f(v, "threshold"),
        f(v, "smoothing"),
        rgba(v, "color"),
        rgba(v, "colorBkg"),
    )
}

/// Every pixel of the disc around a float centre, with its distance from it.
fn disc(img: &Image, cx: f32, cy: f32, r: f32) -> Vec<(u32, u32, f32)> {
    let x0 = ((cx - r).floor().max(0.0)) as u32;
    let x1 = (((cx + r).ceil() + 1.0).min(img.width as f32)) as u32;
    let y0 = ((cy - r).floor().max(0.0)) as u32;
    let y1 = (((cy + r).ceil() + 1.0).min(img.height as f32)) as u32;
    let mut out = Vec::new();
    for y in y0..y1 {
        for x in x0..x1 {
            out.push((x, y, (x as f32 - cx).hypot(y as f32 - cy)));
        }
    }
    out
}

/// How a brush lays down one mark.
enum Style {
    Circle,
    Smooth,
    Spray,
    Glitch,
}

/// Lay down strokes the way the app's canvas tools do.
///
/// The originals paint where the user drags; with no stroke input the marks
/// are scattered over the image instead, so the look is reproduced even
/// though the placement cannot be.
fn brush(img: &Image, v: &Values, style: Style) -> Image {
    let count = i(v, "count").max(1);
    let size = f(v, "size");
    let seed = f(v, "randomSeed");
    let colour = rgba(v, "color");
    let col = colour.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);

    let (w, h) = (img.width as f32, img.height as f32);
    let r = size * w.min(h) * 0.5;
    let mut rng = Rng::seeded((seed as i64 & 0xFFFF) as u64);
    let mut out = img.clone();

    for _ in 0..count {
        let cx = rng.random() as f32 * w;
        let cy = rng.random() as f32 * h;
        match style {
            // The centre is a float, so the distance is measured from it
            // rather than from the pixel it happens to fall in.
            Style::Circle => {
                for (x, y, d) in disc(&out, cx, cy, r) {
                    if d <= r {
                        out.set(x, y, col);
                    }
                }
            }
            Style::Smooth => {
                for (x, y, d) in disc(&out, cx, cy, r) {
                    let k = (1.0 - d / r.max(1e-6)).clamp(0.0, 1.0).powi(2);
                    if k <= 0.0 {
                        continue;
                    }
                    let old = out.get(x, y);
                    let mut px = [0u8; 4];
                    for c in 0..4 {
                        px[c] = (old[c] as f32 * (1.0 - k) + colour[c] * 255.0 * k)
                            .clamp(0.0, 255.0) as u8;
                    }
                    out.set(x, y, px);
                }
            }
            Style::Spray => {
                let n = (r * r * 0.5) as i64;
                for _ in 0..n {
                    let ax = (cx + rng.normal() as f32 * r * 0.5).clamp(0.0, w - 1.0);
                    let ay = (cy + rng.normal() as f32 * r * 0.5).clamp(0.0, h - 1.0);
                    out.set(ax as u32, ay as u32, col);
                }
            }
            Style::Glitch => {
                let y0 = (cy - r).clamp(0.0, h - 1.0) as u32;
                let y1 = (cy + r).clamp(0.0, h) as u32;
                // The bound is twice the radius truncated, not twice its
                // truncated value -- a half pixel of radius changes it.
                let reach = (r * 2.0) as i64;
                let shift = rng.integers(-reach, reach + 1);
                for y in y0..y1 {
                    let row: Vec<[u8; 4]> = (0..img.width).map(|x| out.get(x, y)).collect();
                    for x in 0..img.width {
                        let src =
                            ((x as i64 - shift).rem_euclid(img.width as i64)) as usize;
                        out.set(x, y, row[src]);
                    }
                }
            }
        }
    }
    out
}

pub fn canvas_circle_brush(img: &Image, v: &Values, _: &Inputs) -> Image {
    brush(img, v, Style::Circle)
}

pub fn canvas_smooth_circle_brush(img: &Image, v: &Values, _: &Inputs) -> Image {
    brush(img, v, Style::Smooth)
}

pub fn canvas_spray_brush(img: &Image, v: &Values, _: &Inputs) -> Image {
    brush(img, v, Style::Spray)
}

pub fn canvas_glitch_brush(img: &Image, v: &Values, _: &Inputs) -> Image {
    brush(img, v, Style::Glitch)
}
