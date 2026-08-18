vec4 getRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0-abs(w)),
        max(0.0, w),
        1.0
    );
}

vec4 randomColorDispersion(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float randomSeed, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), pos);

    vec2 f = floor(t);
    vec2 r = fract(t);
    float v = 2.0;
    vec2 delta00 = rand2relSeeded(f, randomSeed) * v;
    vec2 delta10 = rand2relSeeded(f+vec2(1.0, 0.0), randomSeed) * v;
    vec2 delta01 = rand2relSeeded(f+vec2(0.0, 1.0), randomSeed) * v;
    vec2 delta11 = rand2relSeeded(f+vec2(1.0, 1.0), randomSeed) * v;

    float stepLen = 2.0/sourceDim.y;
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    vec4 totalWeight = vec4(0.0, 0.0, 0.0, 0.0);
    float dispersion = intensity;
    vec2 delta = smoothmix2(smoothmix2(delta00, delta10, r.x), smoothmix2(delta01, delta11, r.x), r.y);
    vec2 range = dispersion*delta;
    float N = ceil(0.1+length(range)/stepLen);
    float wStep = 1.0/N;//length(range)==0.0 ? 1.0 : stepLen/length(range);//0.05;
    //for(float w=-1.0; w<=1.0; w+=wStep) {
    vec4 col;
    for(float i=-N; i<=N; ++i) {
        float w = i*wStep;
//        vec4 dcol = vec4(delta.x, delta.y, 0.5, 1.0);
        vec4 scol = __source__(pos+w*range);
        if (i==0.0) col = scol;
        vec4 outColor = scol;//mix(scol, dcol, 0.0);
        vec4 weight = getRGBWeights(w);
        totalColor += weight*outColor;
        totalWeight += weight;
    }
    vec4 outCol = totalColor / totalWeight;
    return outCol;   
}
