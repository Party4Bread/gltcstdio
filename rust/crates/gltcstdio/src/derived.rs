//! Uniforms the engine computes in Java rather than reading from a parameter.
//!
//! `metaballs-gl` declares `vec4[32] spheres, int spheres_size` and the app
//! fills both from `count`, `radius`, `regularity` and `randomSeed`.  Without
//! that step the array stays all zeros and the ray march hits nothing.
//!
//! The positions are jittered by Kotlin's XorWow `Random(i)`, reproduced here
//! so the arrangement matches the app rather than merely moving.

use std::collections::BTreeMap;
use std::f64::consts::{PI, TAU};

const MAX_SPHERES: usize = 32;
/// `AbstractC3132C.C(count, 0, 27)` clamps the count before the layout switch.
const MAX_COUNT: usize = 27;

/// Kotlin's `Random(seed)`, as `k6.e` implements it.
///
/// `A.g.e(i)` builds it as `k6.e(i, i >> 31)`, and the constructor discards
/// the first 64 steps.
struct XorWow {
    x: u32,
    y: u32,
    z: u32,
    w: u32,
    v: u32,
    d: u32,
}

impl XorWow {
    fn new(seed: i64) -> Self {
        let lo = seed as u32;
        let hi = (seed >> 31) as u32;
        let mut r = Self {
            x: lo,
            y: hi,
            z: 0,
            w: 0,
            v: !(seed as u32),
            d: ((seed as u32) << 10) ^ (hi >> 4),
        };
        for _ in 0..64 {
            r.next_int();
        }
        r
    }

    fn next_int(&mut self) -> u32 {
        let x = self.x;
        let t = x ^ (x >> 2);
        self.x = self.y;
        self.y = self.z;
        self.z = self.w;
        let v = self.v;
        self.w = v;
        self.v = (t ^ (t << 1)) ^ v ^ (v << 4);
        self.d = self.d.wrapping_add(362437);
        self.v.wrapping_add(self.d)
    }

    /// `d.a(bits)`: the top `count` bits of the next draw.
    fn bits(&mut self, count: u32) -> u32 {
        self.next_int() >> (32 - count)
    }

    /// `d.b()`.
    fn next_double(&mut self) -> f64 {
        (((self.bits(26) as u64) << 27) + self.bits(27) as u64) as f64 / 9.007_199_254_740_992e15
    }

    /// `d.d()`.
    fn next_float(&mut self) -> f64 {
        self.bits(24) as f64 / 1.677_721_6e7
    }
}

/// `Metaballs3D.H`: `n` points on a circle at height `z`.
fn ring(n: usize, z: f64, radius: f64, phase: f64) -> Vec<[f64; 3]> {
    (0..n)
        .map(|i| {
            let a = (i as f64 * 2.0 * PI) / n as f64 + phase;
            [a.cos() * radius, a.sin() * radius, z]
        })
        .collect()
}

/// The polyhedron the app arranges `count` spheres on.
fn layout(count: usize) -> Vec<[f64; 3]> {
    let half = 0.5;
    let root3 = 3.0f64.sqrt();
    let root2_2 = 2.0f64.sqrt() / 2.0;
    let h = root3 / 2.0;
    let t3 = root3 / 3.0;
    let t23 = root3 * 2.0 / 3.0;
    let s72 = (1.256_637_061_435_917_2f64).sin();

    let axes = || {
        vec![
            [-1.0, 0.0, 0.0],
            [1.0, 0.0, 0.0],
            [0.0, -1.0, 0.0],
            [0.0, 1.0, 0.0],
            [0.0, 0.0, -1.0],
            [0.0, 0.0, 1.0],
        ]
    };
    let cube = || {
        let mut out = Vec::with_capacity(8);
        for z in [-root2_2, root2_2] {
            for y in [-root2_2, root2_2] {
                for x in [-root2_2, root2_2] {
                    out.push([x, y, z]);
                }
            }
        }
        out
    };
    let poles = || vec![[0.0, 0.0, -1.0], [0.0, 0.0, 1.0]];

    match count {
        0 => Vec::new(),
        1 => vec![[0.0, 0.0, 0.0]],
        2 => vec![[-1.0, 0.0, 0.0], [1.0, 0.0, 0.0]],
        3 => vec![[-1.0, -t3, 0.0], [1.0, -t3, 0.0], [0.0, t23, 0.0]],
        4 => vec![
            [-1.0, -t3, -half],
            [1.0, -t3, -half],
            [0.0, t23, -half],
            [0.0, 0.0, 1.0],
        ],
        5 => {
            let k = 2.0 / 3.0;
            vec![
                [-k, -t3 * k, 0.0],
                [k, -t3 * k, 0.0],
                [0.0, t23 * k, 0.0],
                [0.0, 0.0, -1.0],
                [0.0, 0.0, 1.0],
            ]
        }
        6 => axes(),
        7 => {
            let mut out = vec![[0.0, 0.0, 0.0]];
            out.extend(axes());
            out
        }
        8 => cube(),
        9 => {
            let mut out = vec![[0.0, 0.0, 0.0]];
            out.extend(cube());
            out
        }
        10 | 11 => {
            let mut out = if count == 11 {
                vec![[0.0, 0.0, 0.0]]
            } else {
                Vec::new()
            };
            out.extend(poles());
            out.extend(ring(4, -half, h, 0.0));
            out.extend(ring(4, half, h, 0.0));
            out
        }
        12 | 13 => {
            let mut out = if count == 13 {
                vec![[0.0, 0.0, 0.0]]
            } else {
                Vec::new()
            };
            out.extend(poles());
            out.extend(ring(5, -s72 / 2.0, s72, 0.0));
            out.extend(ring(5, s72 / 2.0, s72, (0.628_318_530_717_958_6f64).sin()));
            out
        }
        14 | 15 => {
            let mut out = if count == 15 {
                vec![[0.0, 0.0, 0.0]]
            } else {
                Vec::new()
            };
            out.extend(poles());
            out.extend(ring(6, -0.5, 1.0, 0.0));
            out.extend(ring(6, half, 1.0, 0.0));
            out
        }
        _ => {
            // A spiral over the sphere for everything larger.
            let step = 2.0 * PI / (count as f64).sqrt();
            let last = count - 1;
            let delta = (PI - step) / last as f64;
            let mut out = vec![[0.0, 0.0, -1.0]];
            for i in 1..last {
                let polar = 0.5 * step + i as f64 * delta;
                let r = polar.sin();
                let azimuth = i as f64 * step;
                out.push([azimuth.cos() * r, azimuth.sin() * r, polar.cos()]);
            }
            out.push([0.0, 0.0, 1.0]);
            out
        }
    }
}

fn spheres(
    values: &BTreeMap<String, Vec<f32>>,
    defaults: [f64; 4],
    limit: usize,
    scale_of: impl Fn(usize, f64) -> f64,
) -> BTreeMap<String, Vec<f32>> {
    let get = |name: &str, fallback: f64| {
        values
            .get(name)
            .and_then(|v| v.first())
            .map(|v| *v as f64)
            .unwrap_or(fallback)
    };
    let count = get("count", defaults[0]) as i64;
    let radius = get("radius", defaults[1]);
    let regularity = get("regularity", defaults[2]);
    let seed = get("randomSeed", defaults[3]);

    let n = count.clamp(0, limit as i64) as usize;
    let scale = if n > 0 { scale_of(n, radius) } else { 0.0 };
    let spread = 1.0 - regularity;
    let jitter = spread * 0.5;

    let points = layout(n);
    let mut sizes = XorWow::new(0);
    let mut packed: Vec<f32> = Vec::with_capacity(MAX_SPHERES * 4);
    for (i, p) in points.iter().enumerate() {
        let mut rnd = XorWow::new(i as i64);
        let mut offset = || {
            let a = rnd.next_double();
            let b = rnd.next_double();
            ((a + 1.0) * seed + b * TAU).sin() * jitter
        };
        let dx = offset();
        let dy = offset();
        let dz = offset();
        let r = ((sizes.next_float() - 0.5) * spread + 1.1) * scale * 0.1;
        packed.extend_from_slice(&[
            (p[0] + dx) as f32,
            (p[1] + dy) as f32,
            (p[2] + dz) as f32,
            r as f32,
        ]);
    }
    while packed.len() < MAX_SPHERES * 4 {
        packed.extend_from_slice(&[0.0, 0.0, 0.0, 1.0]);
    }
    packed.truncate(MAX_SPHERES * 4);

    let mut out = BTreeMap::new();
    out.insert("spheres".to_string(), packed);
    out.insert("spheres_size".to_string(), vec![points.len() as f32]);
    out
}

/// Whether a filter's uniforms include values the engine computes.
pub fn derives(id: &str) -> bool {
    matches!(id, "metaballs3d" | "metaballs-gl" | "spheres" | "spheres-gl")
}

/// The parameters a filter's engine computes rather than reads.
///
/// A caller sets what feeds them -- the count, the radius -- not the array
/// they produce, so an interface has nothing to offer for these.
pub fn derived_names(id: &str) -> &'static [&'static str] {
    if derives(id) {
        &["spheres", "spheres_size"]
    } else {
        &[]
    }
}

/// The computed uniforms for a filter, keyed as parameters are.
pub fn compute(id: &str, values: &BTreeMap<String, Vec<f32>>) -> BTreeMap<String, Vec<f32>> {
    match id {
        // `Metaballs3D`: `pow(count, 0.25) * radius * 100 * 0.1`, count 0..27.
        "metaballs3d" | "metaballs-gl" => spheres(
            values,
            [6.0, 0.7, 0.0, 0.0],
            MAX_COUNT,
            |n, r| (n as f64).powf(0.25) * r * 100.0 * 0.1,
        ),
        // `Spheres`: `radius * 100 / pow(count, 0.33) * 0.2`, count 0..32.
        "spheres" | "spheres-gl" => spheres(
            values,
            [8.0, 0.3, 1.0, 0.0],
            MAX_SPHERES,
            |n, r| (r * 100.0 / (n as f64).powf(0.33)) * 0.2,
        ),
        _ => BTreeMap::new(),
    }
}
