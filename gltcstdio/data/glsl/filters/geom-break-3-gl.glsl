// Per-iteration recursive quadrant-zoom — mirrors Pap's `f1()` in
// glitch_broken_geom3.glsl. The pixel's quadrant (relative to `split`)
// selects scale + center such that the chosen quadrant fills [-1, 1]^2
// for the next iteration.
vec2 geomBreak3F1(vec2 u, vec2 split, int N) {
    for(int i=0; i<N; ++i) {
        vec2 sc;
        vec2 center;
        if (u.x > split.x && u.y > split.y) {
            sc = 2.0 / vec2(1.0 - split.x, 1.0 - split.y);
            center = vec2(1.0 + split.x, 1.0 + split.y) / 2.0;
        }
        else if (u.x <= split.x && u.y > split.y) {
            sc = 2.0 / vec2(1.0 + split.x, 1.0 - split.y);
            center = vec2(-1.0 + split.x, 1.0 + split.y) / 2.0;
        }
        else if (u.x > split.x) {
            sc = 2.0 / vec2(1.0 - split.x, 1.0 + split.y);
            center = vec2(1.0 + split.x, -1.0 + split.y) / 2.0;
        }
        else {
            sc = 2.0 / vec2(1.0 + split.x, 1.0 + split.y);
            center = vec2(-1.0 + split.x, -1.0 + split.y) / 2.0;
        }
        u = u * sc - center * sc;
    }
    return u;
}

vec4 geomBreak3GL(vec2 pos, vec2 outPos, int count, vec2 sourceDim, mat3 modelTransform) {
    // Pap: u = u_ModelTransform * vec3(pos, 1.0)  (forward — Pap does NOT
    // override doInverseModelTransform()).
    vec2 u = (modelTransform * vec3(pos, 1.0)).xy;

    // Pap: split = fract(u)*2.0 - 1.0   (per-tile split point in [-1, 1]).
    vec2 split = fract(u) * 2.0 - 1.0;

    float ratio = sourceDim.x / sourceDim.y;
    vec2 vRatio = vec2(ratio, 1.0);

    // f1 operates in [-1, 1]^2 space, rescaled back via vRatio for sampling.
    vec2 warped = geomBreak3F1(pos / vRatio, split, count) * vRatio;

    return __source__(warped);
}
