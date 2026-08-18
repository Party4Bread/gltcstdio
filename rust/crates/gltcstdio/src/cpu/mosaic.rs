//! Mosaics: circle packing, quadtree squares and Delaunay triangles.

use std::f32::consts::PI;

use super::blur::{gaussian, Plane};
use super::{f, i, luma, rgba, Inputs, Rng, Values};
use crate::image::Image;

/// Circles packed largest-first where the image is flat and smallest where
/// it has detail, then filled with the mean colour underneath and outlined.
pub fn circle_mosaic(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (w, h) = (img.width as i64, img.height as i64);
    let short = img.width.min(img.height) as f32;
    let r_min = (f(v, "minRadius") * short).max(1.0);
    let r_max = (f(v, "maxRadius") * short).max(r_min + 1.0);
    let thickness = f(v, "thickness");
    let border = rgba(v, "borderColor");

    // Detail is the high-pass of luminance, as in the Python build.
    let g = Plane::scalar(img, |p| luma(p[0] / 255.0, p[1] / 255.0, p[2] / 255.0));
    let blurred = gaussian(&g, 2.0);
    let detail: Vec<f32> = g
        .data
        .iter()
        .zip(&blurred.data)
        .map(|(a, b)| (a - b).abs())
        .collect();

    let mut out = vec![[0.0f32; 4]; (w * h) as usize];
    let mut occupied = vec![false; (w * h) as usize];
    let mut rng = Rng::seeded(0);

    // Largest first, so big circles claim the flat regions and small ones
    // fill in around detail.
    let mut radius = r_max;
    while radius >= r_min {
        let step = (radius as i64).max(1);
        let mut cy = radius as i64;
        while cy < h {
            let mut cx = radius as i64;
            while cx < w {
                if occupied[(cy * w + cx) as usize] {
                    cx += step;
                    continue;
                }
                // Detail suppresses large circles.
                let (ly0, ly1) = ((cy - step).max(0), (cy + step).min(h));
                let (lx0, lx1) = ((cx - step).max(0), (cx + step).min(w));
                // Summed at double precision: the mean decides whether a
                // circle is placed at all, so a drifting total changes the
                // packing rather than a pixel.
                let mut sum = 0.0f64;
                let mut n = 0usize;
                for y in ly0..ly1 {
                    for x in lx0..lx1 {
                        sum += detail[(y * w + x) as usize] as f64;
                        n += 1;
                    }
                }
                if n > 0 && sum / n as f64 > 0.04 && radius > r_min {
                    cx += step;
                    continue;
                }

                let jy = rng.uniform(-0.15, 0.15) as f32 * radius;
                let jx = rng.uniform(-0.15, 0.15) as f32 * radius;
                let (py, px) = (cy as f32 + jy, cx as f32 + jx);

                // Only the circle's bounding box: every pixel of the disc is
                // inside it, so the result is the same as testing the whole
                // image and the cost is bounded by the circle.
                let y0 = ((py - radius) as i64).max(0);
                let y1 = ((py + radius) as i64 + 2).min(h);
                let x0 = ((px - radius) as i64).max(0);
                let x1 = ((px + radius) as i64 + 2).min(w);
                if y0 >= y1 || x0 >= x1 {
                    cx += step;
                    continue;
                }

                let r2 = radius * radius;
                let mut clash = false;
                'scan: for y in y0..y1 {
                    for x in x0..x1 {
                        let d2 = (y as f32 - py).powi(2) + (x as f32 - px).powi(2);
                        if d2 <= r2 && occupied[(y * w + x) as usize] {
                            clash = true;
                            break 'scan;
                        }
                    }
                }
                if clash {
                    cx += step;
                    continue;
                }

                let mut acc = [0.0f64; 4];
                let mut count = 0usize;
                for y in y0..y1 {
                    for x in x0..x1 {
                        if (y as f32 - py).powi(2) + (x as f32 - px).powi(2) > r2 {
                            continue;
                        }
                        let p = img.get(x as u32, y as u32);
                        for c in 0..4 {
                            acc[c] += p[c] as f64;
                        }
                        count += 1;
                    }
                }
                let colour = acc.map(|s| (s / count.max(1) as f64) as f32);
                let inner = radius * (1.0 - thickness);
                for y in y0..y1 {
                    for x in x0..x1 {
                        let d2 = (y as f32 - py).powi(2) + (x as f32 - px).powi(2);
                        if d2 > r2 {
                            continue;
                        }
                        let at = (y * w + x) as usize;
                        out[at] = if thickness > 0.0 && d2 > inner * inner {
                            border.map(|c| c * 255.0)
                        } else {
                            colour
                        };
                        occupied[at] = true;
                    }
                }
                cx += step;
            }
            cy += step;
        }
        radius *= 0.6;
    }

    let mut image = img.clone();
    for at in 0..(w * h) as usize {
        if occupied[at] {
            for c in 0..4 {
                image.data[at * 4 + c] = out[at][c].clamp(0.0, 255.0) as u8;
            }
        }
    }
    image
}

/// A quadtree: split a square only where it still holds detail.
pub fn square_mosaic(img: &Image, v: &Values, _: &Inputs) -> Image {
    let levels = i(v, "levels");
    let threshold = f(v, "threshold");
    let thickness = f(v, "thickness");
    let border = rgba(v, "borderColor");
    let (w, h) = (img.width as i64, img.height as i64);

    let mut out = img.clone();
    let mut stack = vec![(0i64, 0i64, w.max(h), 0i32)];
    while let Some((y0, x0, size, depth)) = stack.pop() {
        if y0 >= h || x0 >= w {
            continue;
        }
        let y1 = (y0 + size).min(h);
        let x1 = (x0 + size).min(w);
        if y1 <= y0 || x1 <= x0 {
            continue;
        }

        let mut sum = [0.0f64; 3];
        let mut sq = 0.0f64;
        let mut n = 0usize;
        for y in y0..y1 {
            for x in x0..x1 {
                let p = img.get(x as u32, y as u32);
                for c in 0..3 {
                    sum[c] += p[c] as f64;
                    sq += (p[c] as f64).powi(2);
                }
                n += 1;
            }
        }
        let total = n * 3;
        let mean_all = (sum[0] + sum[1] + sum[2]) / total as f64;
        let std = (sq / total as f64 - mean_all * mean_all).max(0.0).sqrt() as f32;

        if depth < levels && std > threshold * 255.0 && size > 2 {
            let half = size / 2;
            for dy in [0, half] {
                for dx in [0, half] {
                    stack.push((y0 + dy, x0 + dx, half, depth + 1));
                }
            }
            continue;
        }

        let mean = sum.map(|s| (s / n as f64) as f32);
        for y in y0..y1 {
            for x in x0..x1 {
                let mut px = img.get(x as u32, y as u32);
                for c in 0..3 {
                    px[c] = mean[c].clamp(0.0, 255.0) as u8;
                }
                out.set(x as u32, y as u32, px);
            }
        }
        let t = (thickness * size as f32) as i64;
        if t > 0 {
            let edge = border.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);
            for y in y0..(y0 + t).min(y1) {
                for x in x0..x1 {
                    let mut px = out.get(x as u32, y as u32);
                    px[..3].copy_from_slice(&edge[..3]);
                    out.set(x as u32, y as u32, px);
                }
            }
            for y in y0..y1 {
                for x in x0..(x0 + t).min(x1) {
                    let mut px = out.get(x as u32, y as u32);
                    px[..3].copy_from_slice(&edge[..3]);
                    out.set(x as u32, y as u32, px);
                }
            }
        }
    }
    out
}

/// Tunnel coordinates: the image repeats away towards a vanishing point.
pub fn wormhole(img: &Image, v: &Values, _: &Inputs) -> Image {
    let intensity = f(v, "intensity");
    let count = f(v, "count");
    let overlap = f(v, "overlap");
    let tint = rgba(v, "color");
    let (w, h) = (img.width as f32, img.height as f32);

    // Centred coordinates span the first pixel to the last, so the divisor is
    // one less than the width, and the lookup rounds rather than truncates.
    let span_x = (w - 1.0).max(1.0);
    let span_y = (h - 1.0).max(1.0);
    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let u = (x as f32 / span_x - 0.5) * 2.0;
            let vv = (y as f32 / span_y - 0.5) * 2.0;
            let r = u.hypot(vv).max(1e-4);
            let a = vv.atan2(u);
            // Depth grows as 1/r, which is what makes the tunnel recede.
            let depth = 1.0 / r * intensity + overlap;
            let su = (a / (2.0 * PI) * count).rem_euclid(1.0);
            let sv = depth.rem_euclid(1.0);
            let mut px = img.clamped(
                (su * (w - 1.0)).round() as i64,
                (sv * (h - 1.0)).round() as i64,
            );
            let shade = (r * 1.6).clamp(0.0, 1.0);
            for c in 0..3 {
                px[c] = (px[c] as f32 * shade * tint[c]).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// An arrow drawn over the image.
pub fn pointer(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (px, py) = (f(v, "x"), f(v, "y"));
    let angle = f(v, "angle");
    let size = f(v, "size");
    let colour = rgba(v, "color").map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);

    let l = size * img.width.min(img.height) as f32;
    let (cx, cy) = (px * img.width as f32, py * img.height as f32);
    let (ca, sa) = (angle.cos(), angle.sin());
    let at = |u: f32, vv: f32| {
        (cx + (u * ca - vv * sa) * l, cy + (u * sa + vv * ca) * l)
    };
    let shaft = [at(-0.5, -0.08), at(0.2, -0.08), at(0.2, 0.08), at(-0.5, 0.08)];
    let head = [at(0.2, -0.28), at(0.55, 0.0), at(0.2, 0.28)];

    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let p = (x as f32, y as f32);
            if in_polygon(p, &shaft) || in_polygon(p, &head) {
                out.set(x, y, colour);
            }
        }
    }
    out
}

/// Even-odd containment test.
fn in_polygon(p: (f32, f32), poly: &[(f32, f32)]) -> bool {
    let mut inside = false;
    let n = poly.len();
    for i in 0..n {
        let a = poly[i];
        let b = poly[(i + 1) % n];
        if (a.1 > p.1) != (b.1 > p.1) {
            let t = (p.1 - a.1) / (b.1 - a.1);
            if p.0 < a.0 + t * (b.0 - a.0) {
                inside = !inside;
            }
        }
    }
    inside
}

/// Points drawn towards image detail, triangulated, each triangle flat-filled
/// with the mean colour of the pixels it covers.
///
/// The Python build picks its points with `numpy.Generator.choice`, a weighted
/// draw without replacement whose internal ordering is not reproduced here;
/// the points land in the same places by the same weights but not in the same
/// sequence, so the triangulation differs in detail.
pub fn delaunay_triangulate(img: &Image, v: &Values, _: &Inputs) -> Image {
    let count = i(v, "count").max(4) as usize;
    let seed = f(v, "randomSeed");
    let (w, h) = (img.width as usize, img.height as usize);

    let g = Plane::scalar(img, |p| luma(p[0] / 255.0, p[1] / 255.0, p[2] / 255.0));
    let blurred = gaussian(&g, 2.0);
    // Keep flat regions represented, as the Python weight does.
    let weight: Vec<f64> = g
        .data
        .iter()
        .zip(&blurred.data)
        .map(|(a, b)| ((a - b).abs() + 0.02) as f64)
        .collect();
    let total: f64 = weight.iter().sum();

    let mut rng = Rng::seeded(seed as u64);
    let mut points: Vec<(f64, f64)> = vec![
        (0.0, 0.0),
        (w as f64 - 1.0, 0.0),
        (0.0, h as f64 - 1.0),
        (w as f64 - 1.0, h as f64 - 1.0),
    ];
    let mut taken = vec![false; w * h];
    let mut tries = 0usize;
    while points.len() < count && tries < count * 40 {
        tries += 1;
        // Inverse-CDF draw over the same weights.
        let target = rng.random() * total;
        let mut acc = 0.0;
        let mut idx = 0usize;
        for (i, weight) in weight.iter().enumerate() {
            acc += weight;
            if acc >= target {
                idx = i;
                break;
            }
        }
        if taken[idx] {
            continue;
        }
        taken[idx] = true;
        points.push(((idx % w) as f64, (idx / w) as f64));
    }

    let triangles = triangulate(&points);
    let mut out = img.clone();
    for t in triangles {
        let (a, b, c) = (points[t.0], points[t.1], points[t.2]);
        let x0 = a.0.min(b.0).min(c.0).max(0.0) as usize;
        let x1 = ((a.0.max(b.0).max(c.0) as usize) + 1).min(w);
        let y0 = a.1.min(b.1).min(c.1).max(0.0) as usize;
        let y1 = ((a.1.max(b.1).max(c.1) as usize) + 1).min(h);
        if x1 <= x0 || y1 <= y0 {
            continue;
        }
        let d = (b.1 - c.1) * (a.0 - c.0) + (c.0 - b.0) * (a.1 - c.1);
        if d.abs() < 1e-9 {
            continue;
        }

        let mut acc = [0.0f64; 4];
        let mut n = 0usize;
        let mut covered = Vec::new();
        for y in y0..y1 {
            for x in x0..x1 {
                let (sx, sy) = (x as f64, y as f64);
                let l1 = ((b.1 - c.1) * (sx - c.0) + (c.0 - b.0) * (sy - c.1)) / d;
                let l2 = ((c.1 - a.1) * (sx - c.0) + (a.0 - c.0) * (sy - c.1)) / d;
                if l1 < 0.0 || l2 < 0.0 || 1.0 - l1 - l2 < 0.0 {
                    continue;
                }
                let p = img.get(x as u32, y as u32);
                for c in 0..4 {
                    acc[c] += p[c] as f64;
                }
                n += 1;
                covered.push((x as u32, y as u32));
            }
        }
        if n == 0 {
            continue;
        }
        let mean = acc.map(|s| (s / n as f64).clamp(0.0, 255.0) as u8);
        for (x, y) in covered {
            out.set(x, y, mean);
        }
    }
    out
}

fn circumcircle(a: (f64, f64), b: (f64, f64), c: (f64, f64)) -> Option<(f64, f64, f64)> {
    let d = 2.0 * (a.0 * (b.1 - c.1) + b.0 * (c.1 - a.1) + c.0 * (a.1 - b.1));
    if d.abs() < 1e-12 {
        return None;
    }
    let (a2, b2, c2) = (
        a.0 * a.0 + a.1 * a.1,
        b.0 * b.0 + b.1 * b.1,
        c.0 * c.0 + c.1 * c.1,
    );
    let ux = (a2 * (b.1 - c.1) + b2 * (c.1 - a.1) + c2 * (a.1 - b.1)) / d;
    let uy = (a2 * (c.0 - b.0) + b2 * (a.0 - c.0) + c2 * (b.0 - a.0)) / d;
    Some((ux, uy, (a.0 - ux).powi(2) + (a.1 - uy).powi(2)))
}

/// Bowyer-Watson incremental Delaunay triangulation.
fn triangulate(points: &[(f64, f64)]) -> Vec<(usize, usize, usize)> {
    let n = points.len();
    if n < 3 {
        return Vec::new();
    }
    let (mut minx, mut maxx, mut miny, mut maxy) = (f64::MAX, f64::MIN, f64::MAX, f64::MIN);
    for p in points {
        minx = minx.min(p.0);
        maxx = maxx.max(p.0);
        miny = miny.min(p.1);
        maxy = maxy.max(p.1);
    }
    let dmax = (maxx - minx).max(maxy - miny) * 10.0 + 10.0;
    let (cx, cy) = ((minx + maxx) / 2.0, (miny + maxy) / 2.0);

    // Super-triangle containing every point; its vertices go at the end.
    let mut pts = points.to_vec();
    pts.push((cx - dmax, cy - dmax));
    pts.push((cx + dmax, cy - dmax));
    pts.push((cx, cy + dmax));
    let mut tris = vec![(n, n + 1, n + 2)];

    for i in 0..n {
        let p = pts[i];
        let mut bad = Vec::new();
        let mut keep = Vec::new();
        for t in tris.drain(..) {
            match circumcircle(pts[t.0], pts[t.1], pts[t.2]) {
                Some((ux, uy, r2)) if (p.0 - ux).powi(2) + (p.1 - uy).powi(2) <= r2 => {
                    bad.push(t)
                }
                _ => keep.push(t),
            }
        }
        // Edges on the boundary of the cavity appear exactly once.
        let mut counts: std::collections::HashMap<(usize, usize), usize> =
            std::collections::HashMap::new();
        for t in &bad {
            for e in [(t.0, t.1), (t.1, t.2), (t.2, t.0)] {
                let k = (e.0.min(e.1), e.0.max(e.1));
                *counts.entry(k).or_default() += 1;
            }
        }
        tris = keep;
        let mut boundary: Vec<(usize, usize)> = counts
            .into_iter()
            .filter(|(_, c)| *c == 1)
            .map(|(e, _)| e)
            .collect();
        boundary.sort_unstable();
        tris.extend(boundary.into_iter().map(|e| (e.0, e.1, i)));
    }

    tris.into_iter()
        .filter(|t| t.0 < n && t.1 < n && t.2 < n)
        .collect()
}
