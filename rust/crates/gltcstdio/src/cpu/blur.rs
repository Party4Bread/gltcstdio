//! The separable Gaussian and everything built on it.

use super::{f, luma, rgba, Inputs, Values};
use crate::image::Image;

/// A normalised Gaussian kernel, cut at three sigma as the app's blur is.
pub fn kernel(sigma: f32) -> Vec<f32> {
    let radius = ((sigma * 3.0).round() as usize).max(1);
    let mut k: Vec<f32> = (0..=2 * radius)
        .map(|i| {
            let x = i as f32 - radius as f32;
            (-(x * x) / (2.0 * sigma * sigma)).exp()
        })
        .collect();
    let total: f32 = k.iter().sum();
    for v in &mut k {
        *v /= total;
    }
    k
}

/// A plane of `channels` interleaved f32 values.
pub struct Plane {
    pub width: usize,
    pub height: usize,
    pub channels: usize,
    pub data: Vec<f32>,
}

impl Plane {
    pub fn from_image(img: &Image) -> Self {
        Self {
            width: img.width as usize,
            height: img.height as usize,
            channels: 4,
            data: img.data.iter().map(|&b| b as f32).collect(),
        }
    }

    /// One channel of an image, or a function of its channels.
    pub fn scalar(img: &Image, mut pick: impl FnMut([f32; 4]) -> f32) -> Self {
        let mut data = Vec::with_capacity(img.pixels());
        for i in 0..img.pixels() {
            let p = [
                img.data[i * 4] as f32,
                img.data[i * 4 + 1] as f32,
                img.data[i * 4 + 2] as f32,
                img.data[i * 4 + 3] as f32,
            ];
            data.push(pick(p));
        }
        Self {
            width: img.width as usize,
            height: img.height as usize,
            channels: 1,
            data,
        }
    }

    #[inline]
    pub fn at(&self, x: usize, y: usize, c: usize) -> f32 {
        self.data[(y * self.width + x) * self.channels + c]
    }

    /// Clamp to the edge, as the blur's padding does.
    #[inline]
    pub fn clamped(&self, x: i64, y: i64, c: usize) -> f32 {
        let x = x.clamp(0, self.width as i64 - 1) as usize;
        let y = y.clamp(0, self.height as i64 - 1) as usize;
        self.at(x, y, c)
    }
}

/// Convolve along one axis: 0 is vertical, 1 is horizontal.
pub fn convolve1d(p: &Plane, k: &[f32], axis: usize) -> Plane {
    let pad = (k.len() / 2) as i64;
    let mut out = vec![0.0f32; p.data.len()];
    for y in 0..p.height {
        for x in 0..p.width {
            for c in 0..p.channels {
                let mut acc = 0.0;
                for (i, w) in k.iter().enumerate() {
                    let off = i as i64 - pad;
                    let (sx, sy) = if axis == 1 {
                        (x as i64 + off, y as i64)
                    } else {
                        (x as i64, y as i64 + off)
                    };
                    acc += w * p.clamped(sx, sy, c);
                }
                out[(y * p.width + x) * p.channels + c] = acc;
            }
        }
    }
    Plane {
        width: p.width,
        height: p.height,
        channels: p.channels,
        data: out,
    }
}

/// A two-pass Gaussian blur.
pub fn gaussian(p: &Plane, sigma: f32) -> Plane {
    if sigma <= 0.0 {
        return Plane {
            width: p.width,
            height: p.height,
            channels: p.channels,
            data: p.data.clone(),
        };
    }
    let k = kernel(sigma);
    convolve1d(&convolve1d(p, &k, 0), &k, 1)
}

fn to_image(p: &Plane, width: u32, height: u32) -> Image {
    Image::new(
        width,
        height,
        p.data.iter().map(|v| v.clamp(0.0, 255.0) as u8).collect(),
    )
}

/// Radius is relative to the shorter side, so the look is resolution
/// independent -- the same convention the shader filters use.
fn sigma_for(img: &Image, radius: f32) -> f32 {
    radius * img.width.min(img.height) as f32
}

pub fn gaussian_blur(img: &Image, v: &Values, _: &Inputs) -> Image {
    let p = Plane::from_image(img);
    let out = gaussian(&p, sigma_for(img, f(v, "radius")));
    to_image(&out, img.width, img.height)
}

pub fn gaussian_blur_test(img: &Image, v: &Values, i: &Inputs) -> Image {
    gaussian_blur(img, v, i)
}

fn directional(img: &Image, radius: f32, horizontal: bool, hardness: f32) -> Image {
    let (w, h) = (img.width as f32, img.height as f32);
    let sigma = (radius * w.min(h)).max(1e-3);
    let n = ((sigma * 3.0) as usize).max(1);
    let mut k: Vec<f32> = (0..=2 * n)
        .map(|i| {
            let x = i as f32 - n as f32;
            (-(x * x) / (2.0 * sigma * sigma)).exp()
        })
        .collect();
    let total: f32 = k.iter().sum();
    for value in &mut k {
        *value /= total;
    }

    let src = Plane::from_image(img);
    let mut acc = convolve1d(&src, &k, if horizontal { 1 } else { 0 });

    if hardness > 0.0 {
        // A lens blur leaves the middle sharp and falls off outwards.
        let short = w.min(h);
        for y in 0..img.height {
            for x in 0..img.width {
                let dx = x as f32 - w / 2.0;
                let dy = y as f32 - h / 2.0;
                let r = dx.hypot(dy) / (0.5 * short);
                let t = ((r - hardness) / (1.0 - hardness).max(1e-6)).clamp(0.0, 1.0);
                for c in 0..4 {
                    let i = ((y as usize) * (img.width as usize) + x as usize) * 4 + c;
                    acc.data[i] = src.data[i] * (1.0 - t) + acc.data[i] * t;
                }
            }
        }
    }
    to_image(&acc, img.width, img.height)
}

pub fn gaussian_blur_h(img: &Image, v: &Values, _: &Inputs) -> Image {
    directional(img, f(v, "radius"), true, 0.0)
}

pub fn gaussian_blur_v(img: &Image, v: &Values, _: &Inputs) -> Image {
    directional(img, f(v, "radius"), false, 0.0)
}

pub fn lens_blur_h(img: &Image, v: &Values, _: &Inputs) -> Image {
    directional(img, f(v, "radius"), true, f(v, "hardness"))
}

pub fn lens_blur_v(img: &Image, v: &Values, _: &Inputs) -> Image {
    directional(img, f(v, "radius"), false, f(v, "hardness"))
}

/// Blur what is brighter than the threshold and add it back.
pub fn bloom_simple(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, threshold, radius) = (f(v, "intensity"), f(v, "threshold"), f(v, "radius"));
    let mut highlights = Plane {
        width: img.width as usize,
        height: img.height as usize,
        channels: 3,
        data: vec![0.0; img.pixels() * 3],
    };
    for i in 0..img.pixels() {
        let rgb = [
            img.data[i * 4] as f32,
            img.data[i * 4 + 1] as f32,
            img.data[i * 4 + 2] as f32,
        ];
        let l = luma(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0);
        let mask = ((l - threshold) / (1.0 - threshold).max(1e-6)).clamp(0.0, 1.0);
        for c in 0..3 {
            highlights.data[i * 3 + c] = rgb[c] * mask;
        }
    }
    let sigma = sigma_for(img, radius);
    let glow = if sigma > 0.0 {
        gaussian(&highlights, sigma)
    } else {
        highlights
    };

    let mut out = img.clone();
    for i in 0..img.pixels() {
        for c in 0..3 {
            let value = img.data[i * 4 + c] as f32 + glow.data[i * 3 + c] * intensity;
            out.data[i * 4 + c] = value.clamp(0.0, 255.0) as u8;
        }
    }
    out
}

/// Local-contrast lift plus scanlines and a vignette, as a CRT shows.
pub fn crt_contrast(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, radius, scanlines) =
        (f(v, "intensity"), f(v, "radius"), f(v, "scanlines"));
    let (w, h) = (img.width as usize, img.height as usize);
    let src = Plane::from_image(img);
    let local = gaussian(&src, (radius * w.min(h) as f32).max(1e-3));

    let cx = (w as f32 - 1.0) / 2.0;
    let cy = (h as f32 - 1.0) / 2.0;
    let mut out = img.clone();
    for y in 0..h {
        let scan = 1.0
            - scanlines * 0.5 * (1.0 + (y as f32 * std::f32::consts::PI).cos());
        for x in 0..w {
            let r = ((x as f32 - cx) / cx.max(1.0)).hypot((y as f32 - cy) / cy.max(1.0));
            let vignette = (1.15 - 0.35 * r * r).clamp(0.0, 1.0);
            for c in 0..3 {
                let i = (y * w + x) * 4 + c;
                let value = src.data[i] + (src.data[i] - local.data[i]) * (intensity * 2.0);
                out.data[i] = (value * scan * vignette).clamp(0.0, 255.0) as u8;
            }
        }
    }
    out
}

/// Pull back the local haze: subtract a blurred estimate and restretch.
pub fn dehaze(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (intensity, blur_radius) = (f(v, "intensity"), f(v, "blurRadius"));
    let dark = Plane::scalar(img, |p| p[0].min(p[1]).min(p[2]));
    let veil = gaussian(&dark, sigma_for(img, blur_radius));
    let scale = (1.0 - intensity * 0.9).max(1e-3);

    let mut out = img.clone();
    for i in 0..img.pixels() {
        for c in 0..3 {
            let value = (img.data[i * 4 + c] as f32 - veil.data[i] * intensity) / scale;
            out.data[i * 4 + c] = value.clamp(0.0, 255.0) as u8;
        }
    }
    out
}

/// Light the image as a relief: luminance becomes height, then shade it.
pub fn gloss_texture(img: &Image, v: &Values, _: &Inputs) -> Image {
    let (w, h) = (img.width as usize, img.height as usize);
    let shininess = f(v, "shininess");
    let source = rgba(v, "sourceColor");
    let ambient = rgba(v, "ambientColor");

    let height = gaussian(
        &Plane::scalar(img, |p| luma(p[0] / 255.0, p[1] / 255.0, p[2] / 255.0)),
        1.5,
    );

    let scale = w.min(h) as f32 * 0.05;
    let light = {
        let v = [0.4f32, -0.6, 0.7];
        let n = (v[0] * v[0] + v[1] * v[1] + v[2] * v[2]).sqrt();
        [v[0] / n, v[1] / n, v[2] / n]
    };

    let mut out = img.clone();
    for y in 0..h {
        for x in 0..w {
            // The gradient is a central difference, zero on the border.
            let gx = if x > 0 && x + 1 < w {
                (height.at(x + 1, y, 0) - height.at(x - 1, y, 0)) * 0.5
            } else {
                0.0
            };
            let gy = if y > 0 && y + 1 < h {
                (height.at(x, y + 1, 0) - height.at(x, y - 1, 0)) * 0.5
            } else {
                0.0
            };
            let (mut nx, mut ny, mut nz) = (-gx * scale, -gy * scale, 1.0f32);
            let n = (nx * nx + ny * ny + nz * nz).sqrt();
            nx /= n;
            ny /= n;
            nz /= n;

            let diffuse =
                (nx * light[0] + ny * light[1] + nz * light[2]).clamp(0.0, 1.0);
            let spec = diffuse.powf(1.0 + shininess * 60.0);
            for c in 0..3 {
                let value = ambient[c] * 255.0
                    + source[c] * 255.0 * diffuse * 0.7
                    + 255.0 * spec * shininess;
                out.data[(y * w + x) * 4 + c] = value.clamp(0.0, 255.0) as u8;
            }
        }
    }
    out
}
