vec4 blockFadeGL(vec2 pos, vec2 outPos,
                 float intensity, float dampening, float regularity,
                 float randomSeed, vec4 color1, vec4 color2,
                 mat3 modelTransform) {
    // Plain Pap-faithful form: u = inverse(modelTransform) * pos (mirrors Pap's
    // `u = u_ModelTransform * pos`; we store the inverse). The pap2mp y-up ↔ Pap y-down
    // reflection is baked into the modelTransform DEFAULT (via flipY(), see constructor),
    // NOT here — so there are no coordinate hacks and the touch handles stay natural
    // (decompose() carries the reflection as a negative scale-y).
    mat3 forwardM = inverse(modelTransform);
    vec2 u = (forwardM * vec3(pos, 1.0)).xy;
    // Pap: scaleX = length(vec2(u_ModelTransform[0][0], u_ModelTransform[1][0]))
    // (first column of the forward matrix → scale factor for uniform scale+rotation).
    float scaleX = length(vec2(forwardM[0][0], forwardM[1][0]));

    vec2 rnd1 = rand2relSeeded(floor(vec2(u.y, u.y)), randomSeed);
    float xOffset = floor(15.0 * rnd1.x + 0.5);

    vec4 col = __source__(pos);
    float dx = floor(xOffset - u.x);
    vec2 rnd2 = rand2relSeeded(vec2(dx, floor(u.y)), randomSeed);

    // Pap: u_Variability = 100 - u_Regularity; with both 0..100,
    //     dx + rnd2.y * u_Variability * 4.0 / abs(dx)
    //   → with regularity in 0..1: variability = 1 - regularity;
    //     dx + rnd2.y * (1 - regularity) * 400.0 / abs(dx)
    float variability = 1.0 - regularity;
    if (dx + rnd2.y * variability * 400.0 / abs(dx) <= 0.0) return col;

    // Pap: clamp(0.0, 1.0, 1.0 - dx/scaleX)  (Pap's clamp(min, max, val) order)
    float kx = clamp(1.0 - dx / scaleX, 0.0, 1.0);
    float scanIntensity = 0.3;
    float scanK = (1.0 - scanIntensity + scanIntensity * cos(PI * fract(u.x) * 8.0));
    vec4 overCol = mix(color1, color2, kx) * vec4(scanK, scanK, scanK, 1.0);

    // Pap: clamp(0.0, 1.0, 1.0 - (1.0-kx) * u_Dampening * 0.01)
    //   → with dampening in -1..1 (DampeningRel): drop the *0.01.
    float alpha = clamp(1.0 - (1.0 - kx) * dampening, 0.0, 1.0);
    // Pap: intensity = getMaskedParameter(u_Intensity, outPos) * 0.01 * alpha
    //   → bare intensity (no per-pixel mask in pap2mp) * alpha. The
    //   `*0.01` collapses because pap2mp intensity is already 0..1.
    float blend = intensity * alpha;
    vec4 outCol = mix(col, overCol, blend);

    // Locus mix `mix(col, outCol, getLocus(...))` stripped — chained
    // externally via `.withLocusHandling()` at the wire site.
    return outCol;
}
