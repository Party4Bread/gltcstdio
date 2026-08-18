vec4 cells(vec2 pos, vec2 outPos, float intensity, float distortion, float randomSeed, float variability, float radiusVariability, float perturbation, float pixelation, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), pos);

    if (perturbation > 0.0) {
        t += sineSurfaceRand2Seeded(t*(1.0+perturbation*0.00), randomSeed) * 2.5*perturbation;
    }
    
    float ci = floor(t.x);
    float cj = floor(t.y);

    float k = 0.0;

    vec2 minDelta;
    float d2min = 1e9;
    int minI = 0;
    int minJ = 0;
    vec2 minCenter;
    float minRadiusModifier;

    for(int j = -2; j <= 2; ++j) {
        for(int i = -2; i <= 2; ++i) {
            vec2 center = vec2(float(i)+ci, float(j)+cj);
            vec2 delta = rand2relSeeded(center, randomSeed);
            float radiusModifier = max(0.01, 1.0 + (delta.x * radiusVariability));
            center += vec2(0.5, 0.5) + delta*variability*2.;
            vec2 d = t - center;
            float d2 = dot(d, d);

            if (d2/radiusModifier < d2min) {
                d2min = d2;
                minI = i;
                minJ = j;
                minCenter = center;
                minDelta = delta;
                minRadiusModifier = radiusModifier;
            }
        }
    }

    k = sqrt(d2min);
    k = clamp(k, 0.0, 1.0);

    vec2 delta = minDelta * intensity*2.;
    vec2 newPos = pos + delta;

    bool distorted = false;
    if (d2min > 0.0 && distortion > 0.0 && pixelation!=100.0) {
            vec2 dd = t - minCenter;
            float radius = 100.0; //???????????
            float threshold = radius*0.01 * minRadiusModifier;
            if (k < threshold) {
                distorted = true;
                k /= threshold;
                float r = 1.0-k;
                float dp = distortion*2. * (1.0-r)/(0.5+r);
                newPos += dd * dp;
            }
    }


    vec4 outColor = __source__(newPos);

    if (pixelation != 0.0) {
        vec2 pixelPos = (modelTransform * vec3(minCenter, 1.0)).xy + delta;
        outColor = mix(outColor, __source__(pixelPos), pixelation);
    }

    return outColor;
}
