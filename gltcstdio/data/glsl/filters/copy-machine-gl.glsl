// Per-iteration warp — mirrors Pap's `f1()` in glitch_broken_geom4.glsl.
// Per iteration: pick a type from {0,1,2,3} based on the pixel's quadrant
// relative to `split`, rotate the type by `i` mod 4 (the "copy machine"
// cascading schedule), then apply one of four operations:
//   type 0: zoom out  (u *= 2)
//   type 1: rotate CCW 90  (x,y -> -y, x)
//   type 2: rotate CW  90  (x,y -> y, -x)
//   type 3: zoom in   (u /= 2)
// GLSL ES has no `fmod` — `mod(a, b)` is the equivalent for non-negative
// operands as used here.
vec2 copyMachineF1(vec2 u, vec2 split, int N) {
    for(int i=0; i<N; ++i) {
        float type;
        if (u.x > split.x && u.y > split.y) {
            type = 0.0;
        }
        else if (u.x <= split.x && u.y > split.y) {
            type = 1.0;
        }
        else if (u.x > split.x) {
            type = 2.0;
        }
        else {
            type = 3.0;
        }
        type = mod(type + float(i), 4.0);

        if (type == 0.0) {
            u *= 2.0;
        }
        else if (type == 1.0) {
            float ox = u.x;
            u.x = -u.y;
            u.y = ox;
        }
        else if (type == 2.0) {
            float ox = u.x;
            u.x = u.y;
            u.y = -ox;
        }
        else {
            u /= 2.0;
        }
    }
    return u;
}

vec4 copyMachineGL(vec2 pos, vec2 outPos, int count, vec2 sourceDim, mat3 modelTransform) {
    // Inverse-sampling convention (codebase norm, same fix as HexRadialInterpolateGL):
    // Pap forward-applied `u = u_ModelTransform * pos` (GeomBreak4 does NOT override
    // doInverseModelTransform), which makes M's scale INVERSE to on-screen tile size —
    // so the holistic touch client ran pinch backwards ("scaling inverted"). Enter the
    // tiling grid via `inverse(modelTransform)*pos` instead: `modelTransform` becomes a
    // plain placement transform (scale ∝ tile size) and the standard inPlace=false client
    // inverts the whole transform holistically. The default is the inverse of Pap's
    // forward matrix, so `u` is byte-identical to Pap's at the default look.
    mat3 gridTransform = inverse(modelTransform);
    vec2 u = (gridTransform * vec3(pos, 1.0)).xy;

    // Pap: split = fract(u)*2.0 - 1.0   (per-tile split point in [-1, 1]).
    vec2 split = fract(u) * 2.0 - 1.0;

    float ratio = sourceDim.x / sourceDim.y;
    vec2 vRatio = vec2(ratio, 1.0);

    vec2 warped = copyMachineF1(pos / vRatio, split, count) * vRatio;

    return __source__(warped);
}
