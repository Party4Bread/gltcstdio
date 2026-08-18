vec4 coloredHalftoneDots(vec2 uv, vec2 outPos, float intensity, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, uv);
    vec2 center = floor(u) + vec2(0.5, 0.5);
    vec2 centerAbs = tf(modelTransform, center);

    vec4 inCol = __source__(uv);
    float unitAbs = length(modelTransform[0].xy);
    vec2 delta = vec2(unitAbs, 0.0) * 0.5;
    vec4 sampleCol = (__source__(centerAbs)
        + __source__(centerAbs+delta)
        + __source__(centerAbs-delta)
        + __source__(centerAbs+delta.yx)
        + __source__(centerAbs-delta.yx)) / 5.0;

    float lum = (sampleCol.r+sampleCol.g+sampleCol.b)/3.0;
    float radius = lum*0.5;
    float k = 0.0;
    float d = length(u-center);
    if (d <= radius) {
        k = 1.0;
    }
    vec4 hsl = rgbToHsl(sampleCol);
    hsl[2] = max(hsl[2], 0.5);
    vec4 paintCol = hslToRgb(hsl);
    vec4 outCol = mix(vec4(0.0, 0.0, 0.0, 1.0), paintCol, k);

    return mix(inCol, outCol, intensity);
}
