vec4 perlinNoise2(vec2 pos, vec2 outPos, mat3 viewTransform, int octaves, vec4 color1, vec4 color2, float hardness, float balance, float shapeAspectRatio, float variability, float randomSeed, float styleSeed) {
    vec2 uv = pos / aRatio(shapeAspectRatio);
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));

    float k = 1.;
    float x = 0.;
    float total = 0.0;

    for(int i=0; i<octaves; ++i) {
        // variability: per-octave random rotation + area-preserving aspect stretch, seeded.
        vec2 r = rand2relSeeded(vec2(float(i) + 17.3), styleSeed * 0.1);  // [-0.5, 0.5]
        float angle = r.x * PI2 * variability;
        float ar = pow(20.0, r.y * 2.0 * variability);  // up to 20, down to 1/20 at variability 1
        mat2 rot = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
        mat2 stretch = mat2(ar, 0.0, 0.0, 1.0 / ar);
        vec2 suv = stretch * rot * uv;

        x += k * perlinNoise3(vec3(suv, randomSeed));
        total += k;
        float scaleVar = variability * (fract(r.x*3.4)-0.5) * 2.0;
        k *= 0.5 * pow(2., scaleVar);
        uv = transform * uv;
    }

    x /= total;

    // balance: bias x toward 0 (color1) or 1 (color2); 0 leaves it unchanged.
    x = balance >= 0.0 ? mix(x, 1.0, balance) : mix(x, 0.0, -balance);

    // hardness: sharpen an S-curve around 0.5, becoming a hard step at hardness 1.
    float w = 1.0 - hardness;
    if (w <= 0.0) {
        x = step(0.5, x);
    } else {
        float e = 1.0 / w;
        float a = 0.5 * pow(2.0 * (x < 0.5 ? x : 1.0 - x), e);
        x = x < 0.5 ? a : 1.0 - a;
    }

    return mix(color1, color2, x);
}
