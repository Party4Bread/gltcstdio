vec2 getDisplacement(vec2 pos, float scale, float randomSeed) {
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

                float intensity = 20.0;//scale*0.1;
                return displacement*intensity;

            }

float threshold(float value) {
    return min(pow(min(1.1, value+0.3), 30.0), 4.0);
}

vec4 dust(vec2 uv, vec2 outPos, float intensity, float randomSeed, vec2 outDim, mat3 modelTransform) {
            mat3 invModelTransform = inverse(modelTransform);
            vec2 t = tf(invModelTransform, uv);
            float scale = length(invModelTransform[0].xy);

            vec4 col = __source__(uv);
            
            if (intensity != 0.0) {
        //        color.rgb = color.rgb * (1.0 + perlinDisplace(pos, t, u_Count, intensity*0.02).x);
                float lumNoise = voronoiOctaveNoise(getDisplacement(t, scale, randomSeed), 1);
                float g = threshold(lumNoise);
                float dustValue = intensity*g; // 0..intensity*4.0
//                if (balance<0.0) {
//                    float grey = dustValue>1.0 ? clamp(dustValue, 0.0, 4.0)/4.0 : 0.0;
//                    vec3 mergedCol = mix(col.rgb, vec3(grey), smoothstep(1.0, 1.2, dustValue));
//                    col.rgb = mix(col.rgb+dustValue, mergedCol, -balance);
//                }
//                else {
//                    float grey = 1.0;
//                    vec3 mergedCol = mix(col.rgb, vec3(grey), smoothstep(0.9, 1.1, dustValue));
//                    col.rgb = mix(col.rgb+dustValue, mergedCol, balance);
//                }
                col.rgb += intensity*g;//vec3(g, g, g); //col.rgb * (1.0 + intensity*0.02*lumNoise);
            }
        
            return col;
        }
