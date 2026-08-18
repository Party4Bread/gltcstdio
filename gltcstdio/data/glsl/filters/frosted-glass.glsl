vec2 perlinDisplace(vec2 u, int count, float intensity) {
    float s = 1.0;
    float maxDisplacement = intensity; 

    vec2 totalDisp;

    for(int i = 0; i<count; ++i) {
        vec2 disp = interpolatedRand2(u*s);
        totalDisp += maxDisplacement * (disp - vec2(0.5, 0.5))*2.0;

        maxDisplacement *= 0.5;
        s *= 2.2;
    }

    return u + totalDisp;
}

vec4 frostedGlass(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity, float radiusVariability, float variability, float randomSeed, float perturbation) {
    vec2 t = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    if (perturbation > 0.0) {
        //t = fractalValueNoiseDisplace(t, t, 3, perturbation*4.0);
        t = perlinDisplace(t, 3, perturbation*4.0);
    }

    float ci = floor(t.x);
    float cj = floor(t.y);

    float k = 0.0;

    vec2 displacement = vec2(0.0, 0.0);

    for(int j = -2; j <= 2; ++j) {
        for(int i = -2; i <= 2; ++i) {
            vec2 center = vec2(float(i)+ci, float(j)+cj);
            vec2 delta = rand2relSeeded(center, randomSeed);
            float radiusModifier = max(0.3, 1.2 + (delta.x * radiusVariability));
            center += vec2(0.5, 0.5) + delta*variability;
            vec2 d = t - center;
            k = length(d);

            float threshold = radiusModifier;
            if (k < threshold) {
                k /= threshold;
                float r = (0.5-k)*(0.5-k)*4.0;
                float dp = (1.0-r)/(0.5+r);
                displacement += dp * d;
            }
        }
    }

    return __source__(pos + displacement*intensity*intensity);
}
