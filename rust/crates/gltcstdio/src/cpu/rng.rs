//! numpy's `default_rng`, so the ported filters draw the same numbers.
//!
//! The reimplemented filters seed a generator from a parameter and scatter
//! points with it, so "the same algorithm" is not enough -- a different
//! stream is a different picture.  This is `SeedSequence` feeding `PCG64`,
//! which is what `numpy.random.default_rng(seed)` builds.

const INIT_A: u32 = 0x43b0_d7e5;
const MULT_A: u32 = 0x931e_8875;
const INIT_B: u32 = 0x8b51_f9dd;
const MULT_B: u32 = 0x58f3_8ded;
const MIX_MULT_L: u32 = 0xca01_f9dd;
const MIX_MULT_R: u32 = 0x4973_f715;
const XSHIFT: u32 = 16;
const POOL_SIZE: usize = 4;

const PCG_MULTIPLIER: u128 = 0x2360_ED05_1FC6_5DA4_4385_DF64_9FCC_F645;

/// numpy's `SeedSequence`: entropy in, generator state out.
struct SeedSequence {
    pool: [u32; POOL_SIZE],
}

impl SeedSequence {
    fn new(entropy: &[u32]) -> Self {
        let mut pool = [0u32; POOL_SIZE];
        let mut hash_const = INIT_A;

        let hashmix = |value: u32, hash_const: &mut u32| -> u32 {
            let mut value = value ^ *hash_const;
            *hash_const = hash_const.wrapping_mul(MULT_A);
            value = value.wrapping_mul(*hash_const);
            value ^ (value >> XSHIFT)
        };
        let mix = |x: u32, y: u32| -> u32 {
            let result = MIX_MULT_L.wrapping_mul(x).wrapping_sub(MIX_MULT_R.wrapping_mul(y));
            result ^ (result >> XSHIFT)
        };

        for i in 0..POOL_SIZE {
            let v = entropy.get(i).copied().unwrap_or(0);
            pool[i] = hashmix(v, &mut hash_const);
        }
        for i_src in 0..POOL_SIZE {
            for i_dst in 0..POOL_SIZE {
                if i_src != i_dst {
                    let h = hashmix(pool[i_src], &mut hash_const);
                    pool[i_dst] = mix(pool[i_dst], h);
                }
            }
        }
        for i_src in POOL_SIZE..entropy.len() {
            for i_dst in 0..POOL_SIZE {
                let h = hashmix(entropy[i_src], &mut hash_const);
                pool[i_dst] = mix(pool[i_dst], h);
            }
        }
        Self { pool }
    }

    fn generate_state(&self, n_words: usize) -> Vec<u32> {
        let mut out = Vec::with_capacity(n_words);
        let mut hash_const = INIT_B;
        for i in 0..n_words {
            let mut data = self.pool[i % POOL_SIZE];
            data ^= hash_const;
            hash_const = hash_const.wrapping_mul(MULT_B);
            data = data.wrapping_mul(hash_const);
            out.push(data ^ (data >> XSHIFT));
        }
        out
    }
}

/// PCG64 XSL-RR, as numpy configures it.
pub struct Rng {
    state: u128,
    inc: u128,
    /// The unused half of the last 64-bit draw, for `next_u32`.
    buffered: Option<u32>,
}

impl Rng {
    /// `numpy.random.default_rng(seed)` for a non-negative integer seed.
    pub fn seeded(seed: u64) -> Self {
        // numpy spreads the seed over 32-bit words, dropping a leading zero.
        let mut entropy: Vec<u32> = vec![(seed & 0xffff_ffff) as u32];
        if seed > 0xffff_ffff {
            entropy.push((seed >> 32) as u32);
        }
        let words = SeedSequence::new(&entropy).generate_state(8);
        let pack = |lo: u32, hi: u32| ((hi as u64) << 32) | lo as u64;
        let init_state =
            ((pack(words[0], words[1]) as u128) << 64) | pack(words[2], words[3]) as u128;
        let init_seq =
            ((pack(words[4], words[5]) as u128) << 64) | pack(words[6], words[7]) as u128;

        let mut rng = Self {
            state: 0,
            inc: (init_seq << 1) | 1,
            buffered: None,
        };
        rng.step();
        rng.state = rng.state.wrapping_add(init_state);
        rng.step();
        rng
    }

    #[inline]
    fn step(&mut self) {
        self.state = self.state.wrapping_mul(PCG_MULTIPLIER).wrapping_add(self.inc);
    }

    #[inline]
    pub fn next_u64(&mut self) -> u64 {
        self.step();
        let xored = ((self.state >> 64) as u64) ^ (self.state as u64);
        let rot = (self.state >> 122) as u32;
        xored.rotate_right(rot)
    }

    /// `rng.random()`: a double in [0, 1).
    #[inline]
    pub fn random(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 * (1.0 / 9_007_199_254_740_992.0)
    }

    /// `rng.uniform(low, high)`.
    #[inline]
    pub fn uniform(&mut self, low: f64, high: f64) -> f64 {
        low + (high - low) * self.random()
    }

    /// The next 32 bits.
    ///
    /// numpy splits one 64-bit draw into two 32-bit ones, low half first, and
    /// keeps the high half for the following call.
    #[inline]
    pub fn next_u32(&mut self) -> u32 {
        if let Some(v) = self.buffered.take() {
            return v;
        }
        let next = self.next_u64();
        self.buffered = Some((next >> 32) as u32);
        next as u32
    }

    /// `rng.integers(low, high)`, half-open.
    ///
    /// Lemire's multiply-and-shift with numpy's rejection threshold, over the
    /// 32-bit stream while the range fits in 32 bits, which is the path every
    /// filter here takes.
    pub fn integers(&mut self, low: i64, high: i64) -> i64 {
        if high <= low {
            return low;
        }
        let rng = (high - low - 1) as u64;
        if rng == 0 {
            return low;
        }
        if rng <= u32::MAX as u64 {
            return low + self.lemire_u32(rng as u32) as i64;
        }
        low + self.lemire_u64(rng) as i64
    }

    fn lemire_u32(&mut self, rng: u32) -> u32 {
        let rng_excl = rng as u64 + 1;
        let mut m = self.next_u32() as u64 * rng_excl;
        let mut leftover = m & 0xFFFF_FFFF;
        if leftover < rng_excl {
            let threshold = ((u32::MAX - rng) as u64) % rng_excl;
            while leftover < threshold {
                m = self.next_u32() as u64 * rng_excl;
                leftover = m & 0xFFFF_FFFF;
            }
        }
        (m >> 32) as u32
    }

    fn lemire_u64(&mut self, rng: u64) -> u64 {
        let rng_excl = rng as u128 + 1;
        let mut m = self.next_u64() as u128 * rng_excl;
        let mut leftover = m as u64;
        if (leftover as u128) < rng_excl {
            let threshold = ((u64::MAX - rng) as u128 % rng_excl) as u64;
            while leftover < threshold {
                m = self.next_u64() as u128 * rng_excl;
                leftover = m as u64;
            }
        }
        (m >> 64) as u64
    }

    /// A standard normal.
    ///
    /// numpy draws these with a ziggurat whose tables are not reproduced
    /// here, so this is the polar form instead: the same distribution from
    /// the same stream, but not the same sequence of values.
    pub fn normal(&mut self) -> f64 {
        loop {
            let u = 2.0 * self.random() - 1.0;
            let v = 2.0 * self.random() - 1.0;
            let s = u * u + v * v;
            if s > 0.0 && s < 1.0 {
                return u * (-2.0 * s.ln() / s).sqrt();
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Values from `numpy.random.default_rng(0)`.
    #[test]
    fn matches_numpy_default_rng() {
        let mut rng = Rng::seeded(0);
        let got: Vec<f64> = (0..3).map(|_| rng.random()).collect();
        let want = [0.6369616873214543, 0.2697867137638703, 0.04097352393619469];
        for (a, b) in got.iter().zip(want) {
            assert!((a - b).abs() < 1e-15, "{a} != {b}");
        }
    }

    /// Values from `numpy.random.default_rng(...).integers(low, high)`.
    #[test]
    fn integers_match_numpy() {
        let mut rng = Rng::seeded(0);
        let got: Vec<i64> = (0..6).map(|_| rng.integers(0, 250)).collect();
        assert_eq!(got, vec![212, 159, 127, 67, 76, 10]);

        let mut rng = Rng::seeded(7);
        let got: Vec<i64> = (0..6).map(|_| rng.integers(4, 12)).collect();
        assert_eq!(got, vec![11, 9, 9, 11, 8, 10]);
    }

    #[test]
    fn matches_numpy_for_another_seed() {
        let mut rng = Rng::seeded(42);
        let got: Vec<f64> = (0..2).map(|_| rng.random()).collect();
        let want = [0.7739560485559633, 0.4388784397520523];
        for (a, b) in got.iter().zip(want) {
            assert!((a - b).abs() < 1e-15, "{a} != {b}");
        }
    }
}
