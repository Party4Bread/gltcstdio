//! Warps: the break and displacement families, streaks and sorting.
//!
//! Each break filter displaces every pixel along the local normal of a family
//! of curves -- concentric circles, concentric squares, stripes -- by an
//! amount that varies per band.  The displacement variants are the same warp
//! with the per-band randomness turned off, so the image slides along the
//! family instead of shattering.

use std::f32::consts::PI;

use super::{f, i, luma, Inputs, Rng, Values};
use crate::image::Image;

/// The per-band displacement multipliers.
fn band_offsets(count: i32, variability: f32, seed: f32) -> Vec<f32> {
    let mut rng = Rng::seeded((seed as i64 & 0xFFFF) as u64);
    (0..count.max(1) + 2)
        .map(|_| (rng.random() as f32 - 0.5) * 2.0 * variability)
        .collect()
}

/// Displace each pixel along `(dir_x, dir_y)` by a per-band amount.
///
/// `band` is a continuous coordinate across the curve family; its integer
/// part picks the band and the fractional part fades the displacement out
/// towards the band edges, which keeps the pieces looking broken rather than
/// smeared.
fn warp(
    img: &Image,
    v: &Values,
    band_of: impl Fn(f32, f32) -> (f32, f32, f32),
) -> Image {
    let distortion = f(v, "distortion");
    let dampening = f(v, "dampening");
    let perturbation = f(v, "perturbation");
    let variability = f(v, "variability");
    let count = i(v, "count");
    let seed = f(v, "randomSeed");

    let offsets = band_offsets(count, variability, seed);
    let scale = img.width.min(img.height) as f32;
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let (band, dir_x, dir_y) = band_of(x as f32, y as f32);
            let idx = band.floor();
            let frac = band - idx;
            let slot = (idx as i64).clamp(0, offsets.len() as i64 - 1) as usize;
            let per_band = offsets[slot];

            // Dampening pulls outer bands back towards their original place.
            let falloff =
                1.0 - dampening * (band.abs() / count.max(1) as f32).clamp(0.0, 1.0);
            // Perturbation adds a wobble within each band.
            let wobble = 1.0 + perturbation * (frac * PI * 2.0).sin();
            let amount = distortion * scale * per_band * falloff * wobble;

            let sx = (x as f32 + dir_x * amount).round() as i64;
            let sy = (y as f32 + dir_y * amount).round() as i64;
            out.set(x, y, img.clamped(sx, sy));
        }
    }
    out
}

fn centre(img: &Image) -> (f32, f32) {
    ((img.width as f32 - 1.0) / 2.0, (img.height as f32 - 1.0) / 2.0)
}

pub fn concentric_circle_breaks(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (cx, cy) = centre(img);
    let scale = (img.width.min(img.height) as f32 * 0.5).max(1.0);
    let count = i(v, "count").max(1) as f32;
    warp(img, v, |x, y| {
        let (dx, dy) = (x - cx, y - cy);
        let r = dx.hypot(dy);
        let safe = if r < 1e-6 { 1.0 } else { r };
        (r / scale * count, dx / safe, dy / safe)
    })
}

pub fn concentric_square_breaks(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (cx, cy) = centre(img);
    let scale = (img.width.min(img.height) as f32 * 0.5).max(1.0);
    let count = i(v, "count").max(1) as f32;
    warp(img, v, |x, y| {
        let (dx, dy) = (x - cx, y - cy);
        // Chebyshev distance gives square rings.
        let d = dx.abs().max(dy.abs());
        let on_x = dx.abs() >= dy.abs();
        let nx = if on_x { dx.signum() } else { 0.0 };
        let ny = if on_x { 0.0 } else { dy.signum() };
        (d / scale * count, nx, ny)
    })
}

pub fn stripe_breaks(img: &Image, v: &Values, _: &Inputs) -> Image {
    let h = (img.height as f32).max(1.0);
    let count = i(v, "count").max(1) as f32;
    warp(img, v, move |_x, y| (y / h * count, 1.0, 0.0))
}

pub fn concentric_circle_displacement(img: &Image, v: &Values, i: &Inputs) -> Image {
    concentric_circle_breaks(img, v, i)
}

pub fn concentric_square_displacement(img: &Image, v: &Values, i: &Inputs) -> Image {
    concentric_square_breaks(img, v, i)
}

pub fn stripe_displacement(img: &Image, v: &Values, i: &Inputs) -> Image {
    stripe_breaks(img, v, i)
}

/// Displace along a sine raised to a power, which sharpens it into spikes.
pub fn sine_spike(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (power, count, amount) = (f(v, "power"), f(v, "count"), f(v, "amount"));
    let w = (img.width as f32).max(1.0);
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let phase = x as f32 / w * count * 2.0 * PI;
            let s = phase.sin();
            let spike = s.signum() * s.abs().powf(power);
            let sy = (y as f32 + spike * amount * img.height as f32).round() as i64;
            out.set(x, y, img.clamped(x as i64, sy));
        }
    }
    out
}

/// Voronoi shards, each nudged off its seat, with lit cracks between.
pub fn broken_glass(img: &Image, v: &Values, _: &Inputs) -> Image {
    let count = i(v, "count").max(3) as usize;
    let displacement = f(v, "displacement");
    let lines = super::rgba(v, "colorLines");
    let mut rng = Rng::seeded((f(v, "randomSeed") as i64 & 0xFFFF) as u64);

    let (w, h) = (img.width as f32, img.height as f32);
    // numpy fills `rng.random(n) * w` then `rng.random(n) * h`, so all the x
    // values are drawn before any of the y values.
    let xs: Vec<f32> = (0..count).map(|_| rng.random() as f32 * w).collect();
    let ys: Vec<f32> = (0..count).map(|_| rng.random() as f32 * h).collect();
    let shifts: Vec<[f32; 2]> = (0..count)
        .map(|_| {
            let a = (rng.random() as f32 - 0.5) * 2.0;
            let b = (rng.random() as f32 - 0.5) * 2.0;
            [
                a * displacement * w.min(h),
                b * displacement * w.min(h),
            ]
        })
        .collect();

    let crack_width = (w.min(h) * 0.004).max(1.0);
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            // Nearest and second-nearest site: the gap between them is the crack.
            let (mut d0, mut d1, mut nearest) = (f32::MAX, f32::MAX, 0usize);
            for s in 0..count {
                let d = (x as f32 - xs[s]).hypot(y as f32 - ys[s]);
                if d < d0 {
                    d1 = d0;
                    d0 = d;
                    nearest = s;
                } else if d < d1 {
                    d1 = d;
                }
            }
            if d1 - d0 < crack_width {
                out.set(x, y, lines.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8));
                continue;
            }
            let sx = (x as f32 + shifts[nearest][0]).round() as i64;
            let sy = (y as f32 + shifts[nearest][1]).round() as i64;
            out.set(x, y, img.clamped(sx, sy));
        }
    }
    out
}

/// Smear each row along a wave, so the streaks undulate.
pub fn streak_waves(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (striation, length, count) = (f(v, "striation"), f(v, "length"), f(v, "count"));
    let amp = length * img.width as f32 * (0.5 + 0.5 * striation);
    let taps = 7;
    let mut out = img.clone();
    for y in 0..img.height {
        let phase = y as f32 / (img.height as f32).max(1.0) * count * 2.0 * PI;
        for x in 0..img.width {
            let mut acc = [0.0f32; 4];
            for tap in 0..taps {
                let t = tap as f32 / (taps - 1) as f32;
                let off = (phase + t * PI).sin() * amp * t;
                let px = img.clamped((x as f32 + off).round() as i64, y as i64);
                for c in 0..4 {
                    acc[c] += px[c] as f32;
                }
            }
            out.set(
                x,
                y,
                acc.map(|value| (value / taps as f32).clamp(0.0, 255.0) as u8),
            );
        }
    }
    out
}

/// Nested rings, each tilted a little more than the last.
pub fn gyro_rings(img: &Image, v: &Values, _: &Inputs) -> Image {
    let angle = f(v, "angle");
    let count = i(v, "count").max(1);
    let thickness = f(v, "thickness");
    let line = super::rgba(v, "color").map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);

    let (cx, cy) = centre(img);
    let short = img.width.min(img.height) as f32;
    let t = (thickness * short).max(1.0);
    let mut out = img.clone();
    for ring in 0..count {
        let a = angle + ring as f32 * PI / count as f32;
        // A tilted circle projects to an ellipse.
        let squash = (0.25 + 0.75 * a.cos().abs()).max(1e-3);
        let (ca, sa) = (a.cos(), a.sin());
        let radius = short * 0.45 * (1.0 - ring as f32 / (count + 1) as f32);
        for y in 0..img.height {
            for x in 0..img.width {
                let (dx, dy) = (x as f32 - cx, y as f32 - cy);
                let u = dx * ca + dy * sa;
                let vv = (-dx * sa + dy * ca) / squash;
                if (u.hypot(vv) - radius).abs() < t {
                    out.set(x, y, line);
                }
            }
        }
    }
    out
}

/// Pixel sort.
///
/// The inner kernels were readable in the decompiled source: the key is
/// `r + g + b` over 0..765, sorting is stable, and "interpolate" replaces a
/// run with a ramp between its lowest-key and highest-key pixel.  `intensity`
/// sets how wide a key band counts as part of a run.
pub fn pixel_sort(img: &Image, v: &Values, _: &Inputs) -> Image {
    let mode = i(v, "mode");
    let intensity = f(v, "intensity");
    let boundary = i(v, "boundary");
    let angle = f(v, "angle");

    let lo = 765.0 * (1.0 - intensity) * 0.5;
    let hi = 765.0 - lo;
    let key_of = |p: [u8; 4]| p[0] as i32 + p[1] as i32 + p[2] as i32;
    let in_band = |k: i32| match boundary {
        1 => k as f32 >= lo,
        2 => k as f32 <= hi,
        _ => k as f32 >= lo && k as f32 <= hi,
    };

    // Horizontal and vertical scans are exact; other angles run along
    // whichever axis the angle is closer to.
    let a = angle.rem_euclid(PI);
    let vertical = (PI * 0.25..PI * 0.75).contains(&a);

    let mut out = img.clone();
    let lines: usize = if vertical { img.width as usize } else { img.height as usize };
    let len: usize = if vertical { img.height as usize } else { img.width as usize };
    for line in 0..lines {
        let at = |i: usize| -> (u32, u32) {
            if vertical {
                (line as u32, i as u32)
            } else {
                (i as u32, line as u32)
            }
        };
        let pixels: Vec<[u8; 4]> = (0..len).map(|i| { let (x, y) = at(i); img.get(x, y) }).collect();
        let keys: Vec<i32> = pixels.iter().map(|p| key_of(*p)).collect();

        let mut start = 0usize;
        while start < len {
            if !in_band(keys[start]) {
                start += 1;
                continue;
            }
            let mut end = start;
            while end < len && in_band(keys[end]) {
                end += 1;
            }
            let span = end - start;
            if span > 1 {
                if mode == 1 {
                    // Ramp between the darkest and brightest of the run.
                    let mut lo_i = start;
                    let mut hi_i = start;
                    for k in start..end {
                        if keys[k] < keys[lo_i] {
                            lo_i = k;
                        }
                        if keys[k] > keys[hi_i] {
                            hi_i = k;
                        }
                    }
                    for k in 0..span {
                        let t = k as f32 / (span - 1) as f32;
                        let mut px = [0u8; 4];
                        for c in 0..4 {
                            let a = pixels[lo_i][c] as f32;
                            let b = pixels[hi_i][c] as f32;
                            px[c] = (a * (1.0 - t) + b * t).clamp(0.0, 255.0) as u8;
                        }
                        let (x, y) = at(start + k);
                        out.set(x, y, px);
                    }
                } else {
                    let mut order: Vec<usize> = (start..end).collect();
                    // Stable, so equal keys keep their original order.
                    order.sort_by_key(|k| keys[*k]);
                    for (k, src) in order.into_iter().enumerate() {
                        let (x, y) = at(start + k);
                        out.set(x, y, pixels[src]);
                    }
                }
            }
            start = end;
        }
    }
    out
}

/// One continuous stroke through points dithered from the image.
///
/// `FloydSteinbergDithering`, `OneLineRenderer`, `Point` and `Segment` all
/// survived decompilation and show the approach: dither the image to points
/// whose density tracks darkness, then join them with a nearest-neighbour
/// tour, which is what makes the line wander as one stroke.
pub fn one_line(img: &Image, v: &Values, _: &Inputs) -> Image {
    let count = i(v, "count").max(1) as usize;
    let thickness = f(v, "thickness");
    let stroke = super::rgba(v, "colorStroke");
    let paper = super::rgba(v, "colorBkg");

    let (w, h) = (img.width as usize, img.height as usize);
    // Dither on a reduced grid: the stroke follows tone, not pixels.
    let step = (((h * w) as f32 / (count * 4) as f32).sqrt() as usize).max(1);
    let sw = w.div_ceil(step);
    let sh = h.div_ceil(step);

    let mut buf = vec![0.0f32; sw * sh];
    // Accumulated at double precision: numpy sums pairwise, and a running
    // single-precision total drifts a part in 10^5 over seven thousand cells
    // -- enough to move the dither's threshold and send the stroke elsewhere.
    let mut total = 0.0f64;
    for y in 0..sh {
        for x in 0..sw {
            let p = img.get((x * step).min(w - 1) as u32, (y * step).min(h - 1) as u32);
            let g = luma(p[0] as f32 / 255.0, p[1] as f32 / 255.0, p[2] as f32 / 255.0);
            buf[y * sw + x] = 1.0 - g;
            total += (1.0 - g) as f64;
        }
    }
    // The scale is worked out at double precision and applied there too:
    // numpy's own scalar is a `float64`, which is not weak, so the whole
    // multiply promotes.
    let cells = (sh * sw) as f64;
    let target = (count as f64 / cells).clamp(1e-6, 1.0);
    if total > 0.0 {
        let k = target * cells / total;
        for value in &mut buf {
            *value = (*value as f64 * k).clamp(0.0, 1.0) as f32;
        }
    }

    // Floyd-Steinberg: every cell that fires becomes a point.
    let mut points: Vec<(f32, f32)> = Vec::new();
    for y in 0..sh {
        for x in 0..sw {
            let old = buf[y * sw + x];
            let new = if old > 0.5 { 1.0 } else { 0.0 };
            if new > 0.5 {
                points.push((x as f32, y as f32));
            }
            let err = old - new;
            if x + 1 < sw {
                buf[y * sw + x + 1] += err * 7.0 / 16.0;
            }
            if y + 1 < sh {
                if x > 0 {
                    buf[(y + 1) * sw + x - 1] += err * 3.0 / 16.0;
                }
                buf[(y + 1) * sw + x] += err * 5.0 / 16.0;
                if x + 1 < sw {
                    buf[(y + 1) * sw + x + 1] += err * 1.0 / 16.0;
                }
            }
        }
    }
    if points.len() > count {
        let n = points.len();
        points = (0..count)
            .map(|k| points[(k * (n - 1)) / (count - 1).max(1)])
            .collect();
    }
    for p in &mut points {
        p.0 *= step as f32;
        p.1 *= step as f32;
    }

    let mut out = Image::empty(img.width, img.height);
    let bg = paper.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);
    for y in 0..img.height {
        for x in 0..img.width {
            out.set(x, y, bg);
        }
    }
    if points.len() < 2 {
        return out;
    }

    // Greedy nearest-neighbour tour.
    let mut remaining: Vec<bool> = vec![true; points.len()];
    let mut tour = vec![points[0]];
    remaining[0] = false;
    let mut cur = points[0];
    for _ in 1..points.len() {
        let mut best = usize::MAX;
        let mut best_d = f32::MAX;
        for (k, p) in points.iter().enumerate() {
            if !remaining[k] {
                continue;
            }
            let d = (p.0 - cur.0).powi(2) + (p.1 - cur.1).powi(2);
            if d < best_d {
                best_d = d;
                best = k;
            }
        }
        remaining[best] = false;
        cur = points[best];
        tour.push(cur);
    }

    let r = (thickness * step as f32).max(0.5);
    let fg = stroke.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);
    for pair in tour.windows(2) {
        let (p0, p1) = (pair[0], pair[1]);
        let x0 = ((p0.0.min(p1.0) - r - 1.0).max(0.0)) as u32;
        let x1 = ((p0.0.max(p1.0) + r + 2.0).min(w as f32)) as u32;
        let y0 = ((p0.1.min(p1.1) - r - 1.0).max(0.0)) as u32;
        let y1 = ((p0.1.max(p1.1) + r + 2.0).min(h as f32)) as u32;
        let d = (p1.0 - p0.0, p1.1 - p0.1);
        let seg2 = d.0 * d.0 + d.1 * d.1;
        for y in y0..y1 {
            for x in x0..x1 {
                let t = if seg2 < 1e-9 {
                    0.0
                } else {
                    (((x as f32 - p0.0) * d.0 + (y as f32 - p0.1) * d.1) / seg2)
                        .clamp(0.0, 1.0)
                };
                let px = p0.0 + t * d.0;
                let py = p0.1 + t * d.1;
                if (x as f32 - px).hypot(y as f32 - py) <= r {
                    out.set(x, y, fg);
                }
            }
        }
    }
    out
}
