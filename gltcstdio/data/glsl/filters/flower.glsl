vec4 flower(vec2 uv, vec2 outPos, int spikeCount, float intensity, float dampening, float shape, float variability, float randomSeed, float lighting, mat3 modelTransform) {
         
            float N = float(spikeCount);
            vec2 u = tf(inverse(modelTransform), uv);
            
            float d = length(u);
        
            if (d>=1.0) {
                return __source__(uv);
            }
            else {
                float angle = atan(u.y, u.x);
                float k = intensity;
        
                float variab = 1.0;
                if (variability != 0.0) {
                    float w = (angle+PI)/PI2*N;
                    float index = ceil(w);
                    float dw = index-w;
                    float rnd = rand2relSeeded(vec2(index, index), randomSeed).x + 0.5;
                    variab = 1.0 - variability * rnd;
                }
                if (d>=variab) {
                    return __source__(uv);
                }
        
                float limit = 0.9 * variab;
        
                if (dampening >= 0.0) {
                    float threshold = limit * (1.0 - dampening);
                    if (d > threshold) {
                        k *= 1.0 - (d - threshold) / (variab-threshold);
                    }
                }
                else {
                    if (d > limit) {
                        k *= 1.0 - (d - limit) / (variab-limit);
                    }
                    float threshold = limit * (-dampening);
                    if (d < threshold) {
                        k *= max(0.0, 1.0 - 2.0 * ((threshold - d) / threshold));
                    }
                }
        
        
//                float scaling = 1.0 + k * (1.0+sin((angle+PI) * N - PI/2.0));
                //float scaling = 1.0 + k * (1.0+triangleToSquareWave(angle/PI_2*N, shape));
                float scaling = 1.0 + k * (1.0+triangleToSquareWave((angle+PI)/PI2*4. * N - 1., shape));
                vec2 coord = tf(modelTransform, scaling*u);
                vec4 outCol = __source__(coord);
                
                if (lighting>0.0) {
                    float dilation = length(coord-u);
                    vec2 grad = vec2(dFdx(dilation)/dFdx(u.x), dFdy(dilation)/dFdy(u.y)) * 4.;
                    float light = 1. + lighting * dot(grad, vec2(0., -1.));
                    outCol.rgb *= light;
                }
            
                 return outCol;
            }
        }
