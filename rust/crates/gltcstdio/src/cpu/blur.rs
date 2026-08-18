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
///
/// One line and one channel at a time, copied into a buffer that already
/// carries the edge padding, so the inner loop is a dot product of two
/// contiguous slices with no bounds to test and no branch to take.  That is
/// what makes a wide kernel affordable: at sigma 128 it is 769 taps per
/// output, and clamping each of them against the image, as a single indexed
/// loop must, costs more than the multiply it guards -- 1.7 s against 0.65 s
/// for a 512x512 image at that width.
///
/// Pairing the symmetric taps to halve the multiplies was tried and is
/// slower: it needs the channels interleaved in the inner loop, and the
/// vectoriser does more with the flat `zip` than it loses to the extra work.
pub fn convolve1d(p: &Plane, k: &[f32], axis: usize) -> Plane {
    let pad = k.len() / 2;
    let (w, h, ch) = (p.width, p.height, p.channels);
    let mut out = vec![0.0f32; p.data.len()];
    let (span, lines) = if axis == 1 { (w, h) } else { (h, w) };
    let step = if axis == 1 { ch } else { w * ch };

    let mut line = vec![0.0f32; span + 2 * pad];
    for l in 0..lines {
        let head = if axis == 1 { l * w * ch } else { l * ch };
        for c in 0..ch {
            for (i, slot) in line.iter_mut().enumerate() {
                // `mode="edge"`: the ends repeat rather than fade to black.
                let at = (i as i64 - pad as i64).clamp(0, span as i64 - 1) as usize;
                *slot = p.data[head + at * step + c];
            }
            for i in 0..span {
                let window = &line[i..i + k.len()];
                let mut acc = 0.0;
                for (weight, value) in k.iter().zip(window) {
                    acc += weight * value;
                }
                out[head + i * step + c] = acc;
            }
        }
    }
    Plane {
        width: w,
        height: h,
        channels: ch,
        data: out,
    }
}

/// A two-pass Gaussian blur.
///
/// Blurring at reduced resolution was tried, since the cost grows with sigma
/// and a wide blur leaves no detail finer than the scale that would be
/// dropped.  It is not close enough: at radius 0.08 it moved 9% of the image
/// by more than 2/255 and the worst pixel by 128.  The cost stays.
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

#[cfg(test)]
mod tests {
    use super::*;

    /// The convolution written the obvious way: for every output, read every
    /// tap straight out of the plane.  `convolve1d` copies each line into a
    /// padded buffer first so its inner loop is a contiguous dot product,
    /// which is several times quicker and must land on the same numbers.
    fn directly(p: &Plane, k: &[f32], axis: usize) -> Plane {
        let pad = (k.len() / 2) as i64;
        let (w, h, ch) = (p.width, p.height, p.channels);
        let (span, lines) = if axis == 1 { (w, h) } else { (h, w) };
        let step = if axis == 1 { ch } else { w * ch };
        let mut out = vec![0.0f32; p.data.len()];
        for l in 0..lines {
            let head = if axis == 1 { l * w * ch } else { l * ch };
            for c in 0..ch {
                for i in 0..span {
                    let mut acc = 0.0;
                    for (j, weight) in k.iter().enumerate() {
                        let at = (i as i64 + j as i64 - pad).clamp(0, span as i64 - 1);
                        acc += weight * p.data[head + at as usize * step + c];
                    }
                    out[head + i * step + c] = acc;
                }
            }
        }
        Plane { width: w, height: h, channels: ch, data: out }
    }

    fn a_plane(w: usize, h: usize, ch: usize) -> Plane {
        // Something with structure in both axes and in every channel, so a
        // transposed or channel-crossed read would show up.
        let data = (0..w * h * ch)
            .map(|i| {
                let (x, y, c) = ((i / ch) % w, (i / ch) / w, i % ch);
                ((x * 7 + y * 13 + c * 29) % 251) as f32 / 251.0
            })
            .collect();
        Plane { width: w, height: h, channels: ch, data }
    }

    #[test]
    fn the_padded_convolution_is_the_plain_one() {
        // Kernels wider than the image exercise the clamped ends, which is
        // where a padded buffer is easiest to get wrong.
        for (w, h, ch) in [(16, 9, 4), (9, 16, 3), (1, 5, 4), (5, 1, 4), (2, 2, 1)] {
            let p = a_plane(w, h, ch);
            for taps in [1usize, 3, 8, 21] {
                let k: Vec<f32> = (0..taps).map(|i| (i + 1) as f32 / taps as f32).collect();
                for axis in [0, 1] {
                    let fast = convolve1d(&p, &k, axis);
                    let plain = directly(&p, &k, axis);
                    assert_eq!(
                        fast.data, plain.data,
                        "{w}x{h}x{ch}, {taps} taps, axis {axis}"
                    );
                }
            }
        }
    }
}
