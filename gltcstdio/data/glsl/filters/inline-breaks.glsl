vec2 getCenter(float i, float variability, float randomSeed) {
    float x = i*0.2;
    vec2 p = x*vec2(cos(x), sin(x));
    if (variability!=0.0) {
        p += x * variability * 2. * (hash12(i*10. + randomSeed) - .5);
    }
    return p;
}

        vec4 spiralBreaks(vec2 uv, vec2 outPos, float intensity, float perturbation, float distortion, float variability, float randomSeed, float pixelation, mat3 modelTransform) {
            mat3 inverseModelTransform = inverse(modelTransform);
            vec2 u = uv;
            vec2 t = tf(inverseModelTransform, uv);
            
//            if (perturbation > 0.0) {
//                t = perlinDisplace(t, 3, perturbation*4.0);
//            }
            if (perturbation > 0.0) {
                t += sineSurfaceRand2Seeded(t*(1.0+perturbation*0.00), randomSeed) * 2.5*perturbation;
            }        
        
            float d2min = INF;
            float d2min2 = INF;
            vec2 minCenter;
            float minIndex = 0.0;
        
        //    float N = 60.0;
            float N = 200.0;
            for(float i=0.0; i<N; ++i) {
                float angle = i*6.0*PI2/N;
                vec2 center = getCenter(i, variability, randomSeed);
        
                vec2 d = t - center;
                float d2 = dot(d, d);
        
                if (d2 < d2min) {
                    d2min2 = d2min;
                    d2min = d2;
                    minIndex = i;
                    minCenter = center;
                }
                else if (d2 < d2min2) {
                    d2min2 = d2;
                }
            }
        
            vec2 delta = (rand2(vec2(minIndex+1.0, minIndex))-vec2(0.5, 0.5)) * intensity*2.0;
            vec2 newPos = uv + delta;
        
            bool distorted = false;
            if (d2min > 0.0 && distortion > 0.0 && pixelation!=1.0) {
                    vec2 dd = t - minCenter;
                    distorted = true;
                    float k = clamp(sqrt(d2min), 0.0, 1.0) / sqrt(d2min2);
        //            float k = sqrt(d2min / d2min2);
                    float r = 1.0-k;
                    float dp = distortion*2.0 * (1.0-r)/(0.5+r);
                    newPos += dd * dp;
            }
        
            vec4 outColor = __source__(newPos);
        
            if (pixelation!= 0.0) {
                vec2 pixelPos = tf(modelTransform, minCenter) + delta;
                outColor = mix(outColor, __source__(pixelPos), pixelation);
            }
        
            return outColor;
        }
