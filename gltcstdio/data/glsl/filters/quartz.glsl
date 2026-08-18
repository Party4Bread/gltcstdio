vec4 quartz(vec2 pos, vec2 outPos, float intensity, int count, float randomSeed, float variability, mat3 modelTransform) {
    vec2 origPos = pos;

    for(int ii=0; ii<count; ++ii) {
        vec2 t = tf(inverse(modelTransform), pos);

        float ci = floor(t.x);
        float cj = floor(t.y);

        float k = 0.0;

        vec2 minDelta;
        float d2min = 1000000000.0;
        int minI = 0;
        int minJ = 0;
        vec2 minCenter;
        float minRadiusModifier;

        for(int j = -2; j <= 2; ++j) {
            for(int i = -2; i <= 2; ++i) {
                vec2 center = vec2(float(i)+ci, float(j)+cj);
                vec2 delta = rand2relSeeded(center, randomSeed);
                float radiusModifier = max(0.01, 1.0 + (delta.x * 1.));
                center += vec2(0.5, 0.5) + delta*variability*2.;
                vec2 d = t - center;
                float d2 = abs(d.x)+abs(d.y);//dot(d, d);

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

        pos = newPos;
    }

    return __source__(pos);
}
