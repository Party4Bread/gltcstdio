vec4 cellsWithRotationGL(vec2 pos, vec2 outPos, float intensity, float variability, float randomSeed, float perturbation, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), pos);

    if (perturbation > 0.0) {
        // Pap: perlinDisplace(t, 3, u_Perturbation*0.04) — substituted with
        // sineSurfaceRand2Seeded (matches Cells.kt). At perturbation=0 the
        // branch isn't taken, so the default first-insert look is bit-exact.
        t += sineSurfaceRand2Seeded(t * (1.0 + perturbation * 0.0), randomSeed) * 2.5 * perturbation;
    }

    float ci = floor(t.x);
    float cj = floor(t.y);

    vec2 minDelta = vec2(0.0);
    float d2min = 1e9;
    vec2 minCenter = vec2(0.0);

    for (int j = -2; j <= 2; ++j) {
        for (int i = -2; i <= 2; ++i) {
            vec2 center = vec2(float(i) + ci, float(j) + cj);
            vec2 delta = rand2relSeeded(center, randomSeed);
            // Pap radiusVariability is hardcoded to 0 in the filter, so
            // radiusModifier = max(0.01, 1.0 + 0) = 1.0 — inlined here.
            center += vec2(0.5, 0.5) + delta * variability * 2.0;
            vec2 d = t - center;
            float d2 = dot(d, d);

            if (d2 < d2min) {
                d2min = d2;
                minCenter = center;
                minDelta = delta;
            }
        }
    }

    // Pap: vec2 delta = minDelta * intensity*0.02; angle = delta.x*10.0
    //   = minDelta.x * intensity_raw * 0.2
    // pap2mp (intensity in -1..1): intensity_raw = 100 * intensity, so
    //   angle = minDelta.x * intensity * 20.0
    float angle = minDelta.x * intensity * 20.0;
    float cosa = cos(angle);
    float sina = sin(angle);

    // absCenter = minCenter mapped back to pos-space. Pap uses
    // u_InverseModelTransform; pap2mp expresses this as modelTransform itself
    // (which is cell→pos by pap2mp convention).
    vec2 absCenter = (modelTransform * vec3(minCenter, 1.0)).xy;

    // Pap's rotation matrix (preserved verbatim — column-major GLSL ctor):
    //   mat3(cosa, sina, 0, -sina, cosa, 0, 0, 0, 1)
    // reads as columns: col0=(cosa,sina,0), col1=(-sina,cosa,0) → effective
    // 2x2 R = [[cosa, -sina], [sina, cosa]] (standard CCW rotation).
    vec2 rel = pos - absCenter;
    vec2 rotated = vec2(cosa * rel.x - sina * rel.y, sina * rel.x + cosa * rel.y);
    vec2 newPos = absCenter + rotated;

    return __source__(newPos);
}
