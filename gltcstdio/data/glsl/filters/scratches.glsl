vec4 scratches(vec2 uv, vec2 outPos, vec4 color, vec4 colorBkg, mat3 modelTransform, float coverage, float len, float variability, float randomSeed, vec2 sourceDim) {
    // Elongated Voronoi scratch pass. Edit live via setTestGlsl / loadTestGlsl.
    vec2 t = tf(inverse(modelTransform), uv);
    vec2 p = (t * 20.0) * vec2(0.1, 1.0);   // base density x the (0.1,1.0) elongation twist

    float ci = floor(p.x);
    float cj = floor(p.y);
    float d2min = 1e9;
    vec2 minId = vec2(0.0);
    for (int j = -1; j <= 1; ++j) {
        for (int i = -1; i <= 1; ++i) {
            vec2 id = vec2(ci + float(i), cj + float(j));
            vec2 center = id + vec2(0.5) + rand2relSeeded(id, randomSeed) * variability;
            vec2 d = p - center;
            float dd = dot(d, d);
            if (dd < d2min) { d2min = dd; minId = id; }
        }
    }

    // coverage: fraction of rows that carry a scratch
    bool scratchRow = hash11(minId.y * 1.7 + randomSeed) < coverage;
    // len: fraction of each period filled along the long axis (random phase per row)
    float PERIOD = 8.0;
    float phase = floor(hash11(minId.y * 2.3 + randomSeed + 5.0) * PERIOD);
    float seg = mod(minId.x + phase, PERIOD);
    bool inLen = seg < len * PERIOD;

    return (scratchRow && inLen) ? color : colorBkg;
}
