vec4 copper(vec2 pos, vec2 outPos, float intensity, int count, float randomSeed, float variability, mat3 modelTransform) {
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

        vec2 newPos = pos;
        
        if (d2min > 0.0 && intensity > 0.0) {
            vec2 dd = t - minCenter;
            float radius = 100.0; //???????????
            float threshold = radius*0.01 * minRadiusModifier;
            if (k < threshold) {
                k /= threshold;
                float r = 1.0-k;
                float dp = intensity*2.0 * (1.0-r)/(0.5+r);
                newPos += dd * dp;
            }
        }

        pos = newPos;
    }

    return __source__(pos);
}
