// Per-iteration quadrant warp — mirrors Pap's `f1()` in glitch_broken_geom1.glsl.
// Note: `s` is the per-tile seed (`floor(u)`), so `rnd` is computed once at
// entry and reused across iterations — matches the Pap shader exactly.
// GLSL ES has no `fmod` — `mod(a, b)` is the spec-compliant equivalent for the
// non-negative-base case used here.
vec2 geomBreak1F1(vec2 u, vec2 split, vec2 s, int N, float intensity) {
    vec2 rnd = rand2rel(s);
    for(int i=0; i<N; ++i) {
        if (u.x > split.x && u.y > split.y) {
            u *= 1.0 + rnd.x;
            // u.x += 0.02*u.y;  // preserved as a commented-out Pap quirk
        }
        else if (u.x <= split.x && u.y > split.y) {
            float ox = u.x;
            u.x = sign(rnd.x) * u.y;
            u.y = sign(rnd.y) * ox;
        }
        else if (u.x > split.x) {
            u.x += rnd.y * 2.0;
        }
        else {
            u.x = mod(sign(u.x) * pow(abs(u.x), rnd.y), 1.0);
            u.y = mod(sign(u.y) * pow(abs(u.y), rnd.x), 1.0);
        }

        if (max(abs(u.x), abs(u.y)) > 1.5) {
            u *= pow(2.0, intensity);
        }
    }
    return u;
}

vec4 geomBreak1GL(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, mat3 modelTransform) {
    // Inverse-sampling convention (codebase norm, same fix as HexRadialInterpolateGL):
    // Pap forward-applied `u = u_ModelTransform * pos` (the filter does NOT override
    // doInverseModelTransform), which makes M's scale INVERSE to on-screen feature size —
    // so the holistic touch client ran the whole transform (pinch/pan/rotate) backwards
    // ("inverted touch transform"). Enter the tiling grid via `inverse(modelTransform)*pos`
    // instead: `modelTransform` becomes a plain placement transform (scale ∝ feature size)
    // and the standard inPlace=false client inverts it holistically. Pap's default here is
    // MODEL_SCALE=1/ANGLE=0 → identity, whose inverse is identity, so `u` is byte-identical
    // to Pap at the default look (no default change needed).
    vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    // Pap: split = fract(u)*4.0 - 2.0   (per-tile quadrant boundary in [-2, 2]).
    vec2 split = fract(u) * 4.0 - 2.0;

    // sourceDim is the auto-supplied `${name}Dim` (width, height).
    float ratio = sourceDim.x / sourceDim.y;
    vec2 vRatio = vec2(ratio, 1.0);

    // f1 operates in [-1, 1]^2 space (`pos/vRatio`), per-tile seeded by
    // `floor(u)` (same coord space as Pap).
    vec2 warped = geomBreak1F1(pos / vRatio, split, floor(u), count, intensity) * vRatio;

    return __source__(warped);
}
