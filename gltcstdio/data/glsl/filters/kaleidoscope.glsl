vec4 kaleidoscope(vec2 uv, vec2 outPos, int spikeCount, mat3 modelTransform, float offset, float stretch) {
            vec2 u = uv;//(inverse(modelTransform) * vec3(uv, 1.0)).xy;
            float a = abs(atan(u.x, u.y));
            float period = PI2 / float(spikeCount);
            float halfPeriod = period * 0.5;
            float index = floor(a/period);
            a = mod(a, period);
            if (a>halfPeriod) {
                a = period - a;
                a = mix(offset*(index+1.0), halfPeriod+offset*(index+1.0), a/halfPeriod);
            }
            else {
                a = mix(offset*index, halfPeriod+offset*(index+1.0), a/halfPeriod);
            }
//            if (a>halfPeriod) {
//                a = period - a;
//                a = mix(0.0, halfPeriod, a/halfPeriod);
//            }
//            else {
//                a = mix(0.0, halfPeriod, a/halfPeriod);
//            }
            float d = length(u);
            u = d*vec2(cos(a), sin(a));
            u = (inverse(modelTransform) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
            return __source__(u);
        }
