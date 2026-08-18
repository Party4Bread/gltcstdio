vec4 crtContrast(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float radius, float angle, mat3 modelTransform) {
            radius = radius * 0.1;
            vec4 color = __source__(pos);
            
            float pixel = 2.0 / sourceDim.y;
            
            vec2 pos2 = tf(modelTransform, pos + radius*vec2(cos(angle), sin(angle)));
            int n = int(min(50., length(pos2-pos)/pixel));
            if (n<=0) return color;
            vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
            vec2 p = pos;
            vec2 delta = (pos2-pos)/float(n);
            float div = 0.0;
            for(int i=0; i<=n; ++i) {
                float d = float(i) / float(n);
                if (d<=1.0) {
//                    float k = (d>0.5) ? (1.0-d)*(1.0-d)*2.0 : 1.0 - d*d*2.0;
                    float k = 1.0;
                    total += k*__source__(p);
                    div += k;
                    p += delta;
                }
            }
            vec4 blur = total / div;
            
            float kIntensity = intensity * 2.;       
            return (1.0+kIntensity)*color - kIntensity*blur;   
        }
