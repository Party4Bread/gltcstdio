//! The one image type everything here passes around: 8-bit RGBA, top row first.

/// An RGBA8 image, row-major, four bytes per pixel.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Image {
    pub width: u32,
    pub height: u32,
    pub data: Vec<u8>,
}

impl Image {
    pub fn new(width: u32, height: u32, data: Vec<u8>) -> Self {
        assert_eq!(
            data.len(),
            (width as usize) * (height as usize) * 4,
            "RGBA8 needs width * height * 4 bytes"
        );
        Self { width, height, data }
    }

    /// A transparent image of the given size.
    pub fn empty(width: u32, height: u32) -> Self {
        Self {
            width,
            height,
            data: vec![0; (width as usize) * (height as usize) * 4],
        }
    }

    pub fn pixels(&self) -> usize {
        (self.width as usize) * (self.height as usize)
    }

    #[inline]
    pub fn get(&self, x: u32, y: u32) -> [u8; 4] {
        let i = ((y as usize) * (self.width as usize) + x as usize) * 4;
        [self.data[i], self.data[i + 1], self.data[i + 2], self.data[i + 3]]
    }

    #[inline]
    pub fn set(&mut self, x: u32, y: u32, px: [u8; 4]) {
        let i = ((y as usize) * (self.width as usize) + x as usize) * 4;
        self.data[i..i + 4].copy_from_slice(&px);
    }

    /// The image as floats in 0..1, four channels per pixel.
    pub fn to_f32(&self) -> Vec<f32> {
        self.data.iter().map(|&b| b as f32 / 255.0).collect()
    }

    /// The inverse of [`to_f32`], rounding and clamping into range.
    pub fn from_f32(width: u32, height: u32, values: &[f32]) -> Self {
        Self::new(
            width,
            height,
            values
                .iter()
                .map(|v| (v * 255.0).round().clamp(0.0, 255.0) as u8)
                .collect(),
        )
    }

    /// Nearest-neighbour sample, clamped at the edges.
    #[inline]
    pub fn clamped(&self, x: i64, y: i64) -> [u8; 4] {
        let x = x.clamp(0, self.width as i64 - 1) as u32;
        let y = y.clamp(0, self.height as i64 - 1) as u32;
        self.get(x, y)
    }
}
