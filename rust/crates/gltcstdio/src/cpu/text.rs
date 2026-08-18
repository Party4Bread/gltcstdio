//! The text overlays, and the bitmap font they draw with.
//!
//! The Python build draws these with whatever font Pillow finds on the
//! machine, so there is no one glyph shape to match.  The crate ships an
//! atlas rendered once at 64px and scales it, which keeps the letters, the
//! layout and the parameters while owning no font machinery.

use std::sync::OnceLock;

use serde::Deserialize;

use super::{f, i, rgba, Inputs, Rng, Values};
use crate::image::Image;

#[derive(Debug, Deserialize)]
struct Glyph {
    code: u32,
    w: usize,
    h: usize,
    left: i32,
    top: i32,
    advance: f32,
    offset: usize,
}

#[derive(Debug, Deserialize)]
struct FontData {
    px: f32,
    glyphs: Vec<Glyph>,
}

static FONT_JSON: &str = include_str!(concat!(env!("CARGO_MANIFEST_DIR"), "/assets/font.json"));
static FONT_BIN: &[u8] = include_bytes!(concat!(env!("CARGO_MANIFEST_DIR"), "/assets/font.bin"));

fn font() -> &'static FontData {
    static FONT: OnceLock<FontData> = OnceLock::new();
    FONT.get_or_init(|| serde_json::from_str(FONT_JSON).expect("bundled font.json is valid"))
}

fn glyph(ch: char) -> Option<&'static Glyph> {
    let code = ch as u32;
    font().glyphs.iter().find(|g| g.code == code)
}

/// Where each glyph of `label` sits, and the ink the whole label covers.
///
/// The pen runs on unrounded advances and the box is the ink itself, both of
/// which the font's own layout does; rounding per glyph pushes the later
/// letters out of place, and centring the advances instead of the ink shifts
/// the whole word.
struct Layout {
    glyphs: Vec<(&'static Glyph, f32)>,
    left: f32,
    top: f32,
    width: f32,
    height: f32,
}

fn layout(label: &str, px: f32) -> Layout {
    let font = font();
    let scale = px / font.px;
    let mut glyphs = Vec::new();
    let mut pen = 0.0f32;
    let (mut x0, mut y0, mut x1, mut y1) = (f32::MAX, f32::MAX, f32::MIN, f32::MIN);
    for ch in label.chars() {
        let Some(g) = glyph(ch) else {
            pen += px * 0.5;
            continue;
        };
        let gx = pen + g.left as f32 * scale;
        let gy = g.top as f32 * scale;
        x0 = x0.min(gx);
        y0 = y0.min(gy);
        x1 = x1.max(gx + g.w as f32 * scale);
        y1 = y1.max(gy + g.h as f32 * scale);
        glyphs.push((g, pen));
        pen += g.advance * scale;
    }
    if glyphs.is_empty() {
        return Layout { glyphs, left: 0.0, top: 0.0, width: 0.0, height: 0.0 };
    }
    Layout { glyphs, left: x0, top: y0, width: x1 - x0, height: y1 - y0 }
}

/// How wide the ink of `label` is at `px` pixels tall.
#[allow(dead_code)]
pub fn text_width(label: &str, px: f32) -> f32 {
    layout(label, px).width
}

/// Draw `label` from the pen origin `(x, y)`.
///
/// Coverage is the glyph's own alpha, resampled to this size, times the
/// colour's.
pub fn draw_text(img: &mut Image, label: &str, x: f32, y: f32, px: f32, color: [f32; 4]) {
    let font = font();
    let scale = px / font.px;
    for (g, pen) in layout(label, px).glyphs {
        let gx = x + pen + g.left as f32 * scale;
        let gy = y + g.top as f32 * scale;
        let dw = (g.w as f32 * scale).ceil() as i64;
        let dh = (g.h as f32 * scale).ceil() as i64;
        for dy in 0..dh {
            for dx in 0..dw {
                let cover = coverage(g, dx, dy, scale);
                if cover <= 0.0 {
                    continue;
                }
                let px_x = gx.round() as i64 + dx;
                let px_y = gy.round() as i64 + dy;
                if px_x < 0 || px_y < 0 || px_x >= img.width as i64 || px_y >= img.height as i64 {
                    continue;
                }
                blend(img, px_x as u32, px_y as u32, color, cover * color[3]);
            }
        }
    }
}

/// How much of one destination pixel the glyph covers.
///
/// The atlas is rendered once at 64px, so drawing at any other size is a
/// resample: the area the pixel maps back to is averaged when the text is
/// smaller than the atlas and interpolated when it is larger.  Taking the
/// nearest texel instead left the letters harder-edged than the font's own
/// rasteriser makes them.
fn coverage(g: &Glyph, dx: i64, dy: i64, scale: f32) -> f32 {
    let at = |x: i64, y: i64| -> f32 {
        let x = x.clamp(0, g.w as i64 - 1) as usize;
        let y = y.clamp(0, g.h as i64 - 1) as usize;
        FONT_BIN[g.offset + y * g.w + x] as f32 / 255.0
    };

    if scale < 1.0 {
        // Average the source texels this pixel covers.
        let x0 = (dx as f32 / scale).floor().max(0.0) as i64;
        let x1 = (((dx + 1) as f32 / scale).ceil() as i64).min(g.w as i64);
        let y0 = (dy as f32 / scale).floor().max(0.0) as i64;
        let y1 = (((dy + 1) as f32 / scale).ceil() as i64).min(g.h as i64);
        if x1 <= x0 || y1 <= y0 {
            return 0.0;
        }
        let mut sum = 0.0;
        for y in y0..y1 {
            for x in x0..x1 {
                sum += at(x, y);
            }
        }
        return sum / ((x1 - x0) * (y1 - y0)) as f32;
    }

    let fx = (dx as f32 + 0.5) / scale - 0.5;
    let fy = (dy as f32 + 0.5) / scale - 0.5;
    let x0 = fx.floor();
    let y0 = fy.floor();
    let (tx, ty) = (fx - x0, fy - y0);
    let (x0, y0) = (x0 as i64, y0 as i64);
    let top = at(x0, y0) * (1.0 - tx) + at(x0 + 1, y0) * tx;
    let bottom = at(x0, y0 + 1) * (1.0 - tx) + at(x0 + 1, y0 + 1) * tx;
    top * (1.0 - ty) + bottom * ty
}

fn blend(img: &mut Image, x: u32, y: u32, color: [f32; 4], alpha: f32) {
    let old = img.get(x, y);
    let mut px = [0u8; 4];
    for c in 0..3 {
        let value = old[c] as f32 * (1.0 - alpha) + color[c] * 255.0 * alpha;
        px[c] = value.clamp(0.0, 255.0) as u8;
    }
    px[3] = old[3].max((alpha * 255.0) as u8);
    img.set(x, y, px);
}

/// Draw a line, as the glyph strokes need.
pub fn draw_line(img: &mut Image, a: (f32, f32), b: (f32, f32), color: [f32; 4], width: f32) {
    let steps = ((b.0 - a.0).abs().max((b.1 - a.1).abs()) * 2.0).ceil().max(1.0) as i64;
    let half = (width * 0.5).max(0.5);
    for s in 0..=steps {
        let t = s as f32 / steps as f32;
        let cx = a.0 + (b.0 - a.0) * t;
        let cy = a.1 + (b.1 - a.1) * t;
        let r = half.ceil() as i64;
        for dy in -r..=r {
            for dx in -r..=r {
                if (dx as f32).hypot(dy as f32) > half {
                    continue;
                }
                let x = cx as i64 + dx;
                let y = cy as i64 + dy;
                if x < 0 || y < 0 || x >= img.width as i64 || y >= img.height as i64 {
                    continue;
                }
                blend(img, x as u32, y as u32, color, color[3]);
            }
        }
    }
}

/// A string parameter's value, or a fallback when the caller gave none.
///
/// Values arrive flattened to floats, so a string set by the caller reaches
/// here as an empty list; the default in the bank is what the app ships.
fn label_of(values: &Values, name: &str, fallback: &str) -> String {
    match values.get(name) {
        Some(v) if !v.is_empty() => v
            .iter()
            .map(|c| char::from_u32(*c as u32).unwrap_or(' '))
            .collect(),
        _ => fallback.to_string(),
    }
}

/// The pen origin that centres `label`'s ink on (x, y), given as fractions
/// of the image.
fn centred(img: &Image, values: &Values, label: &str, px: f32) -> (f32, f32) {
    centre_on(
        label,
        px,
        f(values, "x") * img.width as f32,
        f(values, "y") * img.height as f32,
    )
}

/// The pen origin that centres `label`'s ink on a point.
fn centre_on(label: &str, px: f32, cx: f32, cy: f32) -> (f32, f32) {
    let l = layout(label, px);
    (cx - l.width / 2.0 - l.left, cy - l.height / 2.0 - l.top)
}

/// The pixel size a filter asks for.
///
/// A font is built at a whole number of pixels, so the fraction is dropped
/// before the floor is applied -- carrying it through made every letter a
/// little too large and the spacing with it.
fn size_px(img: &Image, values: &Values, floor: f32) -> f32 {
    (f(values, "size") * img.width.min(img.height) as f32)
        .trunc()
        .max(floor)
}

pub fn text(img: &Image, v: &Values, _: &Inputs) -> Image {
    let mut out = img.clone();
    let label = label_of(v, "text", "GLTCSTDIO");
    let px = size_px(img, v, 8.0);
    let (x, y) = centred(img, v, &label, px);
    draw_text(&mut out, &label, x, y, px, rgba(v, "color"));
    out
}

pub fn shadowed_text(img: &Image, v: &Values, _: &Inputs) -> Image {
    let mut out = img.clone();
    let label = label_of(v, "text", "GLTCSTDIO");
    let px = size_px(img, v, 8.0);
    let (x, y) = centred(img, v, &label, px);
    let off = f(v, "offset") * img.width.min(img.height) as f32;
    draw_text(&mut out, &label, x + off, y + off, px, rgba(v, "colorShadow"));
    draw_text(&mut out, &label, x, y, px, rgba(v, "color"));
    out
}

/// `NumbersText`: the numeric readout, drawn over the image.
pub fn numbers(img: &Image, v: &Values, _: &Inputs) -> Image {
    let mut out = img.clone();
    let label = i(v, "mode").to_string();
    let px = size_px(img, v, 8.0);
    let (x, y) = centred(img, v, &label, px);
    draw_text(&mut out, &label, x, y, px, rgba(v, "color"));
    out
}

/// Source-code-looking text laid over the image, as a terminal dump.
pub fn code_text(img: &Image, v: &Values, _: &Inputs) -> Image {
    const WORDS: [&str; 13] = [
        "if", "for", "return", "vec4", "float", "x", "y", "z", "()", "{}", "0.5", "1.0", "==",
    ];
    let mut out = img.clone();
    let px = size_px(img, v, 7.0);
    let lines = i(v, "lines").max(1);
    let step = (img.height as i32 / lines).max(8);
    let color = rgba(v, "color");
    let mut rng = Rng::seeded(0);
    for line in 0..lines {
        let n = rng.integers(4, 12);
        let words: Vec<&str> = (0..n)
            .map(|_| WORDS[rng.integers(0, WORDS.len() as i64) as usize])
            .collect();
        draw_text(
            &mut out,
            &words.join(" "),
            (0.04 * img.width as f32).trunc(),
            (line * step) as f32,
            px,
            color,
        );
    }
    out
}

/// Base letters running along a double helix.
pub fn dna_text(img: &Image, v: &Values, _: &Inputs) -> Image {
    let mut out = img.clone();
    let letters: Vec<char> = label_of(v, "text", "ACGT").chars().collect();
    let letters = if letters.is_empty() {
        vec!['A', 'C', 'G', 'T']
    } else {
        letters
    };
    let px = size_px(img, v, 7.0);
    let color = rgba(v, "color");
    let n = 60;
    for step in 0..n {
        let t = step as f32 / n as f32;
        let y = t * img.height as f32;
        let phase = t * std::f32::consts::PI * 6.0;
        for sign in [1.0f32, -1.0] {
            let x = f(v, "x") * img.width as f32
                + sign * phase.sin() * img.width as f32 * 0.18;
            let ch = letters[step % letters.len()].to_string();
            draw_text(&mut out, &ch, x, y, px, color);
        }
    }
    out
}

/// Glyph-like marks rather than letters, spaced as writing.
pub fn alien_text(img: &Image, v: &Values, _: &Inputs) -> Image {
    let mut out = img.clone();
    let label = label_of(v, "text", "GLTCSTDIO");
    let color = rgba(v, "color");
    let s = f(v, "size") * img.width.min(img.height) as f32;
    let n = label.chars().count().max(1);
    // The Python build seeds from the text's hash, which is not a stable
    // value across runs; a fixed seed keeps the marks the same every time.
    let mut rng = Rng::seeded(label.bytes().fold(0u64, |a, b| a.wrapping_mul(31).wrapping_add(b as u64)));
    for mark in 0..n {
        let cx = f(v, "x") * img.width as f32 + (mark as f32 - n as f32 / 2.0) * s * 0.9;
        let cy = f(v, "y") * img.height as f32;
        for _ in 0..rng.integers(2, 5) {
            let a: Vec<f32> = (0..4).map(|_| rng.random() as f32).collect();
            draw_line(
                &mut out,
                (cx + (a[0] - 0.5) * s, cy + (a[1] - 0.5) * s),
                (cx + (a[2] - 0.5) * s, cy + (a[3] - 0.5) * s),
                color,
                (s * 0.08).max(1.0),
            );
        }
    }
    out
}

/// Tape-style caption: chroma bleed and a scanline comb.
///
/// The bleed comes from the text's own coverage shifted either way, so it
/// glows red on one side and blue on the other, and the comb dims alternate
/// rows of the whole frame rather than only the letters.
pub fn vhs_text(img: &Image, v: &Values, _: &Inputs) -> Image {
    let label = label_of(v, "text", "PLAY");
    let px = size_px(img, v, 8.0);
    let (x, y) = centred(img, v, &label, px);
    let color = rgba(v, "color");
    let bleed = f(v, "bleed");

    // The caption on its own, to take the coverage from.
    let mut layer = Image::empty(img.width, img.height);
    draw_text(&mut layer, &label, x, y, px, color);

    let mut out = img.clone();
    draw_text(&mut out, &label, x, y, px, color);

    let shift = ((bleed * 8.0) as i64).max(1);
    let w = img.width as i64;
    for py in 0..img.height {
        let scan = 0.85 + 0.15 * ((py as f32 * std::f32::consts::PI).cos() * 0.5 + 0.5);
        for pxl in 0..img.width {
            // `np.roll` wraps, so the fringe carries round the edges.
            let red = layer.get(((pxl as i64 - shift).rem_euclid(w)) as u32, py)[3] as f32;
            let blue = layer.get(((pxl as i64 + shift).rem_euclid(w)) as u32, py)[3] as f32;
            let glow = [red * bleed, 0.0, blue * bleed];
            let mut q = out.get(pxl, py);
            for c in 0..3 {
                q[c] = ((q[c] as f32 + glow[c]).clamp(0.0, 255.0) * scan) as u8;
            }
            out.set(pxl, py, q);
        }
    }
    out
}

/// A print border with a caption under the image.
///
/// The image is laid on a larger sheet -- an even border on three sides and a
/// deeper one below -- the caption goes in that lower margin, and the whole
/// sheet is scaled back to the original size, so the picture shrinks inside
/// its mount rather than being covered by a bar.
pub fn photo_label(img: &Image, v: &Values, inputs: &Inputs) -> Image {
    let label = label_of(v, "text", "GLTCSTDIO");
    let (w, h) = (img.width, img.height);
    let short = w.min(h) as f32;
    let border = (f(v, "border") * short) as u32;
    let bottom = border * 3;
    let paper = rgba(v, "colorBkg");

    let mut sheet = Image::empty(w + 2 * border, h + border + bottom);
    let ground = paper.map(|c| (c * 255.0).clamp(0.0, 255.0) as u8);
    for y in 0..sheet.height {
        for x in 0..sheet.width {
            sheet.set(x, y, ground);
        }
    }

    let smoothen = f(v, "smoothen");
    let inner = if smoothen > 0.0 {
        let mut blur = Values::new();
        blur.insert("radius".into(), vec![smoothen]);
        super::blur::gaussian_blur(img, &blur, inputs)
    } else {
        img.clone()
    };
    for y in 0..h {
        for x in 0..w {
            sheet.set(x + border, y + border, inner.get(x, y));
        }
    }

    let px = (f(v, "size") * short).max(8.0);
    let sheet_w = sheet.width as f32;
    let sheet_h = sheet.height as f32;
    let cy = (1.0 - bottom as f32 / (2.0 * sheet_h)) * sheet_h;
    let (tx, ty) = centre_on(&label, px, f(v, "x") * sheet_w, cy);
    draw_text(&mut sheet, &label, tx, ty, px, rgba(v, "color"));
    super::tone::resize(&sheet, w, h)
}
