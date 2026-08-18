vec4 noiseColumns(vec2 uv, vec2 outPos, float shapeAspectRatio, int count, float coverage, float variability, float randomSeed, vec4 color, vec4 highlightColor, mat3 modelTransform) {
    vec4 bkg = __source__(uv);

    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;

    // Bounding rectangle: height 2 (|y|<=1), width 2*shapeAspectRatio, centred on the origin.
    float ar = max(shapeAspectRatio, 0.01);
    if (abs(u.x) > ar || abs(u.y) > 1.0) return bkg;

    float n = float(max(count, 1));
    float cw = 2.0 * ar / n;
    float c = min(floor((u.x + ar) / cw), n - 1.0);

    // Per-column character: chunkiness (row height) and own density around `coverage`.
    vec2 rc = rand2relSeeded(vec2(c * 7.13 + 3.7, c * 1.77 - 8.1), randomSeed) + 0.5;
    float chunk = pow(4.0, (rc.x - 0.5) * 2.0 * variability);
    float density = clamp(coverage * pow(3.0, (rc.y - 0.5) * 2.0 * variability), 0.0, 1.0);

    float rh = chunk * 2.0 / 24.0;                    // row height (base 24 rows)
    float r = floor((u.y + 1.0) / rh);
    float fy = fract((u.y + 1.0) / rh);

    // Above variability 0.5, columns may subdivide horizontally into dash cells (~2:1 wide);
    // ticks always fill their cell's full width, so the grid stays offset-free.
    float nx = 1.0;
    float pSub = clamp((variability - 0.5) * 2.0, 0.0, 1.0);
    if (pSub > 0.0) {
        vec2 rs = rand2relSeeded(vec2(c * 3.31 + 1.7, c * 9.87 + 2.3), randomSeed) + 0.5;
        if (rs.x < pSub) nx = clamp(floor(cw / (rh * 2.0)), 1.0, 64.0);
    }
    float xw = cw / nx;
    float k = min(floor((u.x + ar - c * cw) / xw), nx - 1.0);

    vec2 rd = rand2relSeeded(vec2(c * 13.7 + k * 5.91, r * 2.23 + 4.9), randomSeed) + 0.5;
    if (rd.x > density) return bkg;                   // cell off

    // Tick: full cell width, hashed height fraction, vertically centred in its row
    // (hard edges on purpose — the reference look is NEAREST).
    vec2 rg = rand2relSeeded(vec2(r * 3.17 + k * 9.13, c * 4.79 + 8.31), randomSeed) + 0.5;
    float h = mix(0.35, 0.8, rg.y);
    float y0 = (1.0 - h) * 0.5;
    if (fy < y0 || fy > y0 + h) return bkg;

    vec4 col = fract(rd.y * 13.0) < 0.08 ? highlightColor : color;
    return mergeColor(bkg, col);
}
