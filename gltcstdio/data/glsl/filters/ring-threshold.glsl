vec4 ringThreshold(vec2 uv, vec2 outPos, vec2 sourceDim, float scale, float ringRatio, float threshold) {
    float ratio = sourceDim.x / sourceDim.y;
    vec2 sp = uv / scale;                                         // undo the downscale to sample the source
    if (abs(sp.x) > ratio || abs(sp.y) > 1.0) return vec4(0.0, 0.0, 0.0, 1.0);   // black frame
    vec4 col = __source__(sp);
    float q = max(abs(sp.x) / ratio, abs(sp.y));                 // 0 = centre, 1 = image edge (rectangular)
    if (q > 0.0) {
        float ring = max(ceil(log(q) / log(ringRatio)), 1.0);   // ring 1 = outermost band
        float t = threshold * pow(0.5, ring - 1.0);             // 0.5, 0.25, 0.125, ...
        if (luma(col.rgb) < t) return vec4(0.0, 0.0, 0.0, col.a);
    }
    return col;
}
