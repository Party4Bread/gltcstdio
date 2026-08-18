vec4 gallium(vec2 pos, vec2 outPos, int iterations, float intensity, float angle, mat3 modelTransform) {
                mat3 inverseModelTransform = inverse(modelTransform);
                float nIntens = intensity / float(iterations);
                
                for(int i=0; i<iterations; ++i) {
                    vec4 col = __source__(tf(inverseModelTransform, pos));
                    float len = mix(col.r, col.g, col.b);
                    float ang1 = mix(col.g, col.b, col.r)*PI2 + angle;
                    float ang2 = mix(col.b, col.r, col.g)*PI2 + angle;
                    vec2 delta = nIntens * len * (vec2(cos(ang1), sin(ang2)) - 0.5);
//                    vec2 delta = __source__(tf(inverseModelTransform, pos)).xy * intensity;
                    pos += delta;                   
                }
                
                return __source__(pos);
            }
