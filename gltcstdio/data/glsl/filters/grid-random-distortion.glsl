vec4 getRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0-abs(w)),
        max(0.0, w),
        1.0
    );
}

vec2 sstep(vec2 a, vec2 b, float k) {
    return vec2(mix(a.x, b.x, smoothstep(0.0, 1.0, k)), mix(a.y, b.y, smoothstep(0.0, 1.0, k)));
}

vec4 gridRandomDistortion(vec2 uv, vec2 outPos, float intensity, float randomSeed, float dispersion, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), uv);
    vec2 f = floor(t);
    vec2 r = fract(t);
    float v = intensity * 4.;
    vec2 delta00 = rand2relSeeded(f, randomSeed) * v;
    vec2 delta10 = rand2relSeeded(f+vec2(1.0, 0.0), randomSeed) * v;
    vec2 delta01 = rand2relSeeded(f+vec2(0.0, 1.0), randomSeed) * v;
    vec2 delta11 = rand2relSeeded(f+vec2(1.0, 1.0), randomSeed) * v;

    if (dispersion==0.0) {
        vec2 delta = sstep(sstep(delta00, delta10, r.x), sstep(delta01, delta11, r.x), r.y);
        vec4 dcol = vec4(delta.x, delta.y, 0.5, 1.0);
        vec4 outColor = mix(__source__(uv+delta), dcol, 0.0);

        return outColor;
    }
    else {
        float wStep = 0.05;
        vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
        vec4 totalWeight = vec4(0.0, 0.0, 0.0, 0.0);
        vec2 delta = sstep(sstep(delta00, delta10, r.x), sstep(delta01, delta11, r.x), r.y);
        for(float w=-1.0; w<=1.0; w+=wStep) {
            vec4 dcol = vec4(delta.x, delta.y, 0.5, 1.0);
            vec4 outColor = mix(__source__(uv+(1.0+w*dispersion)*delta), dcol, 0.0);
            vec4 weight = getRGBWeights(w);
            totalColor += weight*outColor;
            totalWeight += weight;
        }
        return totalColor / totalWeight;
    }
}
