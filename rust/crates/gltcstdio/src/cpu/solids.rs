//! Ray-marched solids and the wireframe overlays.
//!
//! Each marches a signed-distance field and shades the hit, using the source
//! image as the environment the surface reflects and refracts -- which is how
//! the originals put the photograph back into the render.

use std::f32::consts::PI;

use super::blur::{gaussian, Plane};
use super::{f, i, luma, rgba, Inputs, Values};
use crate::image::Image;

const MAX_STEPS: usize = 48;
const MAX_DIST: f32 = 12.0;
const SURF: f32 = 0.002;

type Vec3 = [f32; 3];

fn sub(a: Vec3, b: Vec3) -> Vec3 {
    [a[0] - b[0], a[1] - b[1], a[2] - b[2]]
}
fn add(a: Vec3, b: Vec3) -> Vec3 {
    [a[0] + b[0], a[1] + b[1], a[2] + b[2]]
}
fn scale(a: Vec3, k: f32) -> Vec3 {
    [a[0] * k, a[1] * k, a[2] * k]
}
fn dot(a: Vec3, b: Vec3) -> f32 {
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
}
fn length(a: Vec3) -> f32 {
    dot(a, a).sqrt()
}
fn normalize(a: Vec3) -> Vec3 {
    let n = length(a);
    if n < 1e-9 {
        [0.0, 0.0, 1.0]
    } else {
        scale(a, 1.0 / n)
    }
}

/// The camera ray through one pixel.
fn ray(x: u32, y: u32, w: u32, h: u32, zoom: f32) -> Vec3 {
    let aspect = w as f32 / (h.max(1)) as f32;
    let u = (x as f32 / (w.max(2) - 1) as f32 * 2.0 - 1.0) * aspect;
    let v = y as f32 / (h.max(2) - 1) as f32 * 2.0 - 1.0;
    normalize([u, v, zoom])
}

/// Sample the source image as an environment map for a ray direction.
fn env(img: &Image, dir: Vec3) -> [f32; 3] {
    let u = 0.5 + dir[0].atan2(dir[2]) / (2.0 * PI);
    let v = 0.5 - dir[1].clamp(-1.0, 1.0).asin() / PI;
    let xi = ((u * (img.width - 1) as f32) as i64).clamp(0, img.width as i64 - 1);
    let yi = ((v * (img.height - 1) as f32) as i64).clamp(0, img.height as i64 - 1);
    let p = img.get(xi as u32, yi as u32);
    [p[0] as f32, p[1] as f32, p[2] as f32]
}

/// March until the field says we are at the surface, or we give up.
fn march(sdf: &dyn Fn(Vec3) -> f32, ro: Vec3, rd: Vec3) -> (f32, bool) {
    let mut t = 0.0f32;
    for _ in 0..MAX_STEPS {
        let d = sdf(add(ro, scale(rd, t)));
        if d < SURF && t < MAX_DIST {
            return (t, true);
        }
        t += d.max(SURF * 0.5);
        if t >= MAX_DIST {
            break;
        }
    }
    (t, false)
}

fn normal_at(sdf: &dyn Fn(Vec3) -> f32, p: Vec3) -> Vec3 {
    let e = 0.002;
    normalize([
        sdf([p[0] + e, p[1], p[2]]) - sdf([p[0] - e, p[1], p[2]]),
        sdf([p[0], p[1] + e, p[2]]) - sdf([p[0], p[1] - e, p[2]]),
        sdf([p[0], p[1], p[2] + e]) - sdf([p[0], p[1], p[2] - e]),
    ])
}

/// Fresnel-weighted mix of a reflected and a refracted environment sample.
fn shade(
    img: &Image,
    n: Vec3,
    rd: Vec3,
    hit: bool,
    material: [f32; 4],
    fog: [f32; 4],
    fresnel_strength: f32,
) -> [f32; 3] {
    if !hit {
        return [fog[0] * 255.0, fog[1] * 255.0, fog[2] * 255.0];
    }
    let cos_i = (-dot(n, rd)).clamp(0.0, 1.0);
    let fres = ((1.0 - cos_i).powi(5) * fresnel_strength).clamp(0.0, 1.0);
    let refl = sub(rd, scale(n, 2.0 * dot(n, rd)));
    let refr = add(scale(rd, 0.85), scale(n, 0.15));
    let a = env(img, refl);
    let b = env(img, refr);
    let mut out = [0.0f32; 3];
    for c in 0..3 {
        out[c] = (a[c] * fres + b[c] * (1.0 - fres)) * material[c];
    }
    out
}

fn render_solid(
    img: &Image,
    v: &Values,
    camera_z: f32,
    sdf: impl Fn(Vec3) -> f32,
) -> Image {
    let material = rgba(v, "colorMaterial");
    let fog = rgba(v, "colorFog");
    let fresnel = f(v, "fresnelStrength");
    let ro = [0.0, 0.0, camera_z];
    let sdf: &dyn Fn(Vec3) -> f32 = &sdf;

    let mut out = Image::empty(img.width, img.height);
    for y in 0..img.height {
        for x in 0..img.width {
            let rd = ray(x, y, img.width, img.height, 1.6);
            let (t, hit) = march(sdf, ro, rd);
            let p = add(ro, scale(rd, t));
            let n = normal_at(sdf, p);
            let col = shade(img, n, rd, hit, material, fog, fresnel);
            out.set(
                x,
                y,
                [
                    col[0].clamp(0.0, 255.0) as u8,
                    col[1].clamp(0.0, 255.0) as u8,
                    col[2].clamp(0.0, 255.0) as u8,
                    255,
                ],
            );
        }
    }
    out
}

/// Folded box: the classic cheap 3D fractal.
pub fn fractal_solid_simplified(img: &Image, v: &Values, _: &Inputs) -> Image {
    let radius = f(v, "radius");
    let iterations = i(v, "iterations").max(1);
    render_solid(img, v, -3.5, move |p| {
        let mut q = p;
        let mut s = 1.0f32;
        for _ in 0..iterations {
            q = [q[0].abs(), q[1].abs(), q[2].abs()];
            q = [q[0] * 2.0 - radius, q[1] * 2.0 - radius, q[2] * 2.0 - radius];
            s *= 2.0;
        }
        (length(q) - radius) / s
    })
}

/// A rounded solid lit by the image, as the app's generic marcher does.
pub fn ray_marcher(img: &Image, v: &Values, _: &Inputs) -> Image {
    let r = f(v, "radius");
    let material = rgba(v, "colorTransmission");
    let fog = [0.03, 0.04, 0.06, 1.0];
    let fresnel = f(v, "fresnelStrength");
    render_named(img, -3.4, material, fog, fresnel, move |p| {
        let q = [
            p[0].abs() - r * 0.6,
            p[1].abs() - r * 0.6,
            p[2].abs() - r * 0.6,
        ];
        let outside = [q[0].max(0.0), q[1].max(0.0), q[2].max(0.0)];
        let box_d = length(outside) - r * 0.25;
        let sphere = length(p) - r;
        // Smooth intersection gives the rounded, jewel-like solid.
        let k = 0.2;
        let hh = (0.5 - 0.5 * (sphere - box_d) / k).clamp(0.0, 1.0);
        sphere * (1.0 - hh) + box_d * hh + k * hh * (1.0 - hh)
    })
}

/// `render_solid` with the material and fog given rather than read from the
/// parameters, for the filters that name those knobs differently.
fn render_named(
    img: &Image,
    camera_z: f32,
    material: [f32; 4],
    fog: [f32; 4],
    fresnel: f32,
    sdf: impl Fn(Vec3) -> f32,
) -> Image {
    let ro = [0.0, 0.0, camera_z];
    let sdf: &dyn Fn(Vec3) -> f32 = &sdf;
    let mut out = Image::empty(img.width, img.height);
    for y in 0..img.height {
        for x in 0..img.width {
            let rd = ray(x, y, img.width, img.height, 1.6);
            let (t, hit) = march(sdf, ro, rd);
            let p = add(ro, scale(rd, t));
            let n = normal_at(sdf, p);
            let col = shade(img, n, rd, hit, material, fog, fresnel);
            out.set(
                x,
                y,
                [
                    col[0].clamp(0.0, 255.0) as u8,
                    col[1].clamp(0.0, 255.0) as u8,
                    col[2].clamp(0.0, 255.0) as u8,
                    255,
                ],
            );
        }
    }
    out
}

/// A torus whose tube cross-section rotates as it goes round.
pub fn mobius_torus(img: &Image, v: &Values, _: &Inputs) -> Image {
    let big = f(v, "radius");
    let small = f(v, "roundness");
    let twists = i(v, "count").max(1) as f32;
    render_solid(img, v, -3.2, move |p| {
        let ang = p[2].atan2(p[0]);
        let rad = p[0].hypot(p[2]) - big;
        let (c, s) = ((ang * twists * 0.5).cos(), (ang * twists * 0.5).sin());
        let u = rad * c + p[1] * s;
        let w = -rad * s + p[1] * c;
        (u.abs() - small).max(w.abs() - small * 0.25)
    })
}

/// A wireframe grid whose height follows image luminance.
fn wire_overlay(img: &Image, v: &Values) -> Image {
    let n = i(v, "rezolution").max(2) as f32;
    let thickness = f(v, "thickness").max(1e-3);
    let glow = f(v, "glow");
    let elevate = f(v, "elevation");
    let colour = rgba(v, "colorLines");

    let g = gaussian(
        &Plane::scalar(img, |p| luma(p[0] / 255.0, p[1] / 255.0, p[2] / 255.0)),
        1.5,
    );
    let (w, h) = (img.width as usize, img.height as usize);
    let short = w.min(h) as f32;

    let mut mask = vec![0.0f32; w * h];
    for y in 0..h {
        for x in 0..w {
            // Displace the grid coordinates by the height field.
            let shift = (g.at(x, y, 0) - 0.5) * elevate * short;
            let u = (x as f32 / w as f32) * n;
            let vv = ((y as f32 + shift) / h as f32) * n;
            let du = (u.rem_euclid(1.0)).min(1.0 - u.rem_euclid(1.0));
            let dv = (vv.rem_euclid(1.0)).min(1.0 - vv.rem_euclid(1.0));
            mask[y * w + x] = (1.0 - du.min(dv) / thickness).clamp(0.0, 1.0);
        }
    }
    if glow > 0.0 {
        let spread = gaussian(
            &Plane {
                width: w,
                height: h,
                channels: 1,
                data: mask.clone(),
            },
            2.0,
        );
        for i in 0..mask.len() {
            mask[i] = (mask[i] + spread.data[i] * glow).clamp(0.0, 1.0);
        }
    }

    let mut out = img.clone();
    for y in 0..h {
        for x in 0..w {
            let k = mask[y * w + x];
            let src = img.get(x as u32, y as u32);
            let mut px = src;
            for c in 0..3 {
                px[c] = (src[c] as f32 * (1.0 - k) + colour[c] * 255.0 * k)
                    .clamp(0.0, 255.0) as u8;
            }
            out.set(x as u32, y as u32, px);
        }
    }
    out
}

pub fn mesh(img: &Image, v: &Values, _: &Inputs) -> Image {
    wire_overlay(img, v)
}

pub fn height_map_wireframe(img: &Image, v: &Values, _: &Inputs) -> Image {
    wire_overlay(img, v)
}

/// A faceted mesh whose cells mirror the image back at varying angles.
pub fn reflective_mesh(img: &Image, v: &Values, _: &Inputs) -> Image {
    let n = i(v, "rezolution").max(2) as u32;
    let reflectivity = f(v, "reflectivity");
    let thickness = f(v, "thickness");
    let cell = (img.width.min(img.height) / n).max(2);
    let k = reflectivity * cell as f32 * 4.0;
    let t = thickness * 0.5;

    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            let fx = (x % cell) as f32 / cell as f32 - 0.5;
            let fy = (y % cell) as f32 / cell as f32 - 0.5;
            // Each facet reflects a different part of the image.
            let sx = (x as f32 + fx * k).round() as i64;
            let sy = (y as f32 + fy * k).round() as i64;
            let mut px = img.clamped(sx, sy);
            if fx.abs() > 0.5 - t || fy.abs() > 0.5 - t {
                for c in 0..4 {
                    px[c] = (px[c] as f32 * 0.55) as u8;
                }
            }
            out.set(x, y, px);
        }
    }
    out
}

/// Hexagons shaded as raised prisms, each filled from the image.
pub fn hex_3d_tiling(img: &Image, v: &Values, _: &Inputs) -> Image {
    let n = i(v, "count").max(2) as f32;
    let depth = f(v, "depth");
    let (w, h) = (img.width as f32, img.height as f32);
    let size = w.min(h) / n;
    let root3 = 3.0f32.sqrt();

    let mut out = img.clone();
    for y in 0..img.height {
        for x in 0..img.width {
            // Axial hex coordinates.
            let q = (x as f32 * 2.0 / 3.0) / size;
            let r = (-(x as f32) / 3.0 + root3 / 3.0 * y as f32) / size;
            let (qi, ri) = (q.round(), r.round());
            let edge = (q - qi).abs().max((r - ri).abs());

            let cx = ((qi * 1.5) * size) as i64;
            let cy = (((ri + qi * 0.5) * root3) * size) as i64;
            let mut px = img.clamped(cx, cy);
            // Shade by distance to the cell edge so each tile reads as a face.
            let shade = 1.0 - depth * (edge * 2.0).clamp(0.0, 1.0);
            for c in 0..3 {
                px[c] = (px[c] as f32 * shade).clamp(0.0, 255.0) as u8;
            }
            out.set(x, y, px);
        }
    }
    out
}

/// Lace woven from repeated reflection inside the Poincare disc.
pub fn hyperbolic_lace(img: &Image, v: &Values, _: &Inputs) -> Image {
    let p = i(v, "paramP").max(3) as f32;
    let iterations = i(v, "iterations").max(1);
    let glow = f(v, "glow");
    let c1 = rgba(v, "color1");
    let c2 = rgba(v, "color2");
    let ang = PI / p;

    let mut out = img.clone();
    for py in 0..img.height {
        for px in 0..img.width {
            let u = (px as f32 / (img.width.max(2) - 1) as f32 - 0.5) * 2.0;
            let vv = (py as f32 / (img.height.max(2) - 1) as f32 - 0.5) * 2.0;
            if u * u + vv * vv > 1.0 {
                out.set(px, py, [0, 0, 0, img.get(px, py)[3]]);
                continue;
            }
            let (mut x, mut y) = (u, vv);
            let mut acc = 0.0f32;
            for _ in 0..iterations {
                // Fold into the fundamental wedge, then invert in the circle.
                let a = ((y.atan2(x) + ang).rem_euclid(2.0 * ang) - ang).abs();
                let rad = x.hypot(y);
                x = rad * a.cos();
                y = rad * a.sin();
                let d2 = (x * x + y * y).max(1e-6);
                if d2 > 0.5 {
                    let k = 0.5 / d2;
                    x *= k;
                    y *= k;
                }
                acc += (-8.0 * (x.hypot(y) - 0.5).abs()).exp();
            }
            acc = (acc / iterations as f32 * (1.0 + glow * 3.0)).clamp(0.0, 1.0);
            let mut px_out = img.get(px, py);
            for c in 0..3 {
                let value = (c2[c] + (c1[c] - c2[c]) * acc) * 255.0;
                px_out[c] = value.clamp(0.0, 255.0) as u8;
            }
            out.set(px, py, px_out);
        }
    }
    out
}
