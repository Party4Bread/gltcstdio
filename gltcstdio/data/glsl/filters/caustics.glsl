vec2 getDisplacement(vec2 pos, float variability, float randomSeed) {
                vec2 t = pos;

                float ci = floor(t.x);
                float cj = floor(t.y);

                float k = 0.0;

                vec2 displacement = vec2(0.0, 0.0);
                float radiusVariability = 1.0;
                float variab = 1.0;

                for(int j = -2; j <= 2; ++j) {
                    for(int i = -2; i <= 2; ++i) {
                        vec2 center = vec2(float(i)+ci, float(j)+cj);
                        vec2 delta = rand2relSeeded(center, randomSeed);
                        float radiusModifier = max(0.3, 1.2 + (delta.x * radiusVariability));
                        center += vec2(0.5, 0.5) + delta * variab;
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

                float scale = 10.0;
                float intensity = scale*0.3 * variability;
                return displacement*intensity;

            }

float threshold(float value) {
    return min(pow(min(1.2, value+0.35), 10.0), 4.0);
}

vec4 caustics(vec2 uv, vec2 outPos, int count, float intensity, float dispersion, float variability, float randomSeed, float vignetting, vec4 color, vec2 outDim, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), uv);
            
    vec4 col = __source__(uv);

    float falloff = 1.0;
    if (vignetting != 0.0) {
        float diag = max(1.0, outDim.x/outDim.y);
        float len = length(uv);
        float radius = (1.5-vignetting) * diag;
        falloff = max(0.0, (1.0 - vignetting*2.0*smoothstep(0.0, radius, len)));
    }

    if (intensity != 0.0) {
        vec3 light;
        if (dispersion == 0.0) {
            int n = count;
            vec2 displacement = getDisplacement(t, variability, randomSeed);
            float g = threshold(voronoiOctaveNoise(t + displacement, n));
            light = color.rgb * vec3(g, g, g);
        }
        else {
            float ab = dispersion * 0.1/(0.01+variability);
            int n = count;
            vec2 displacement = getDisplacement(t, variability, randomSeed);
            float r = threshold(voronoiOctaveNoise(t + displacement*(1.0-ab), n));
            float y = threshold(voronoiOctaveNoise(t + displacement*(1.0-0.5*ab), n));
            float g = threshold(voronoiOctaveNoise(t + displacement, n));
            float c = threshold(voronoiOctaveNoise(t + displacement*(1.0+0.5*ab), n));
            float b = threshold(voronoiOctaveNoise(t + displacement*(1.0+1.5*ab), n));
            light = color.rgb * vec3(r*0.66+0.33*y, 0.4*y+0.2*g+0.4*c, 0.15*c + 0.85*b);
        }

        col.rgb += intensity*5. * light * falloff;
    }

    return col;
}
