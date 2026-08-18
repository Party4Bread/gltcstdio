float rt_response(float d, float glow) {
    // Scale `d` so the per-distance units match BarCode's tuning
    // (where `d` was in O(1) units). Our ticks are O(0.001..0.05)
    // wide; multiply `d` by 100 so the smoothstep cutoff `[2, 1.2]`
    // works at a sensible pos-space distance, and `glow*0.01` becomes
    // a sensible halo radius. This rescaling is the only freedom in
    // matching Pap's Gaussian blur — see header note.
    float dn = d * 100.0;
    float base = (glow < 0.2) ? 1.0 : 1.0 + (glow - 0.2) * 4.0;
    return base * (dn <= 0.0 ? 1.0 : min(1.0, glow * 0.01 / dn)) * smoothstep(2.0, 1.2, dn);
}

vec4 rulerTicksGL(vec2 pos, vec2 outPos,
                  float glow, vec4 color1,
                  mat3 modelTransform) {
    // Standard pap2mp inverse-on-shader convention (mirrors
    // BarCode.kt: `u = tf(inverse(modelTransform), uv)`).
    vec2 p = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    // Pap loop: `y = -H/2 .. H/2 step H/100` → in pos-y space
    // (1 unit = H/2 pixels) that's `y = -1 .. 1 step 0.02`. So
    // `step = 0.02` and `n = round(p.y / step)` is the tick index.
    float step = 0.02;
    float n = floor(p.y / step + 0.5);

    // Out-of-range: no tick → return source untouched.
    if (abs(n) > 50.0) return __source__(pos);

    // Big tick every 5 indices (Pap `N % 5 == 0`).
    float bigTick = (mod(abs(n) + 0.5, 5.0) < 1.0) ? 1.5 : 1.0;

    // Tick rectangle half-extents in pos-space:
    //   hTick      = H/40  * bigTick → 0.05  * bigTick (pos-x)
    //   strokeHalf = H*0.0015*bigTick → 0.0015*bigTick (pos-y)
    //   (Pap's stroke is drawn around the line; half-width = stroke/2;
    //    we use the BarCode pattern where the rectangle dim is the
    //    full half-extent.)
    float hTick = 0.05 * bigTick;
    float strokeHalf = 0.0015 * bigTick;

    // SDF to the nearest tick (centered at (0, n*step)).
    vec2 q = vec2(p.x, p.y - n * step);
    float d = sdRectangle(q, vec2(hTick, strokeHalf));

    float k = rt_response(d, glow);

    vec4 bkgCol = __source__(pos);
    // k overshoots 1 in the glow bloom; the excess is a brightness multiplier, min(1,k) is coverage.
    vec4 glowCol = spilloverChannels(vec4(color1.rgb * max(1.0, k), color1.a));
    vec4 outCol = mergeColor(bkgCol, vec4(glowCol.rgb, glowCol.a * min(1.0, k)));

    return outCol;
}
