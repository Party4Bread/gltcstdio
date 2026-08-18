#define AA 2

vec4 numberFont(vec2 uv, vec2 outPos, int mode, float value, int decimals, vec4 color1, float thickness, mat3 modelTransform, vec2 outDim, float glow) {
    mat3 im = inverse(modelTransform);
    vec2 u = tf(im, uv);
    vec4 bkg = __source__(uv);
    // AA width = one output texel, measured in glyph space (derivative-free, zoom-independent).
    float pixel = 2.0 / outDim.y;
    float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;

    bool neg = value < 0.0;
    float av = abs(value);
    float ipart = floor(av);

    // integer digit count
    int nint = 1;
    float t2 = ipart;
    for (int i = 0; i < 9; i++) {
        if (t2 >= 10.0) { t2 = floor(t2 / 10.0); nint++; }
    }

    int nglyph = nint + (neg ? 1 : 0) + (decimals > 0 ? 1 + decimals : 0);

    float adv = 0.88;                        // advance width per glyph cell
    float total = float(nglyph) * adv;
    float left = -total * 0.5;
    float fx = u.x - left;
    int slot = int(floor(fx / adv));

    float halfW = 0.03 + thickness * 0.20;   // stroke half-width

    // Nearest glyph across this cell + its two neighbours (min) drives the ink; each glyph's glow
    // is summed (additive light) so adjacent haloes reinforce and merge instead of just clipping.
    float d = 1e9;
    float gsum = 0.0;
    for (int s = slot - 1; s <= slot + 1; s++) {
        if (s < 0 || s >= nglyph) continue;
        int sch = ndfCharForSlot(s, nint, neg, decimals, ipart, av);
        if (sch == 12) continue;
        vec2 sp = vec2(fx - (float(s) + 0.5) * adv, -u.y);
        float sd = (mode == 0) ? ndfDigital(sch, sp) : ndfCurved(sch, sp);
        d = min(d, sd);
        gsum += exp(-max(sd - halfW, 0.0) * 6.0);   // neon glow: soft falloff, summed over glyphs
    }

    float cov = 1.0 - smoothstep(halfW - aa, halfW + aa, d);
    float g = glow * gsum * (1.0 - cov);

    if (cov <= 0.0 && g <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
    outc.rgb += color1.rgb * g;
    outc.a = max(outc.a, min(g, 1.0));
    return outc;
}
