vec2 hueOffsetDistortedDistort(vec2 p, float k, float randomSeed) {
    vec3 pp = vec3(p, randomSeed);
    vec3 m = vec3(sin(randomSeed), sin(randomSeed + 10.0), sin(-randomSeed + 20.0));
    pp.xyz += k * 1.0  * sin((2.0 + m.x) * pp.yzx);
    pp.xyz += k * 0.75 * sin((2.0 + m.y) * pp.yzx);
    pp.xyz += k * 0.5  * sin((2.0 + m.z) * pp.yzx);
    return pp.xy;
}

vec4 hueOffsetDistortedGl(vec2 pos, vec2 outPos, float intensity, float balance, float randomSeed, mat3 modelTransform) {
    // pap2mp's modelTransform is the model->screen (forward) transform; the
    // Pap shader used `u_ModelTransform * vec3(pos, 1.0)` where Pap
    // pre-inverted it (`doInverseModelTransform() = true`). Mirror this by
    // inverting in-shader.
    vec2 u = tf(inverse(modelTransform), pos);

    vec4 col = __source__(pos);
    vec4 hsl = rgbToHsl(col);
    // Hue shift driven by distortion x-component * 2000 * saturation.
    hsl[0] += hueOffsetDistortedDistort(u, 1.1, randomSeed).x * 2000.0 * hsl[1];
    // Saturation inversion balance: Pap used balance(-100..100) * 0.005 + 0.5;
    // with balance now in -1..1, the equivalent factor is balance * 0.5 + 0.5.
    hsl[1] = mix(hsl[1], 1.0 - hsl[1], balance * 0.5 + 0.5);
    vec4 outCol = hslToRgb(hsl);

    // Original Pap formula:
    //   k = intensity(0..100)*0.01 * locus
    //   return clamp(mix(col, outCol, k*2.0), 0.0, 1.0);
    // After 0..100 → 0..1 rescale: k = intensity * locus, mix factor = k*2.0.
    // The `*2.0` boost is intentional over-mixing — at intensity=1 it produces
    // `2*outCol - col` (clamped). Reproduce faithfully; locus is layered on by
    // `.withLocusHandling()` wiring at the Model.kt level.
    return clamp(mix(col, outCol, intensity * 2.0), 0.0, 1.0);
}
