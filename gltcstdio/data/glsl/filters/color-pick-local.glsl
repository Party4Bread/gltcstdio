vec4 ghostingMerge(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float mode, int iterations, float angle, int source2_specified, mat3 modelTransform) {
//            mat3 inverseModelTransform = inverse(modelTransform);
            vec4 color = __source__(uv);
            vec4 bestColor = color;
            float bestDist = 100.0;
        
        
            float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
            float scale = 1.0/ resolution;
        
            vec2 dim = vec2(sourceDim.x/sourceDim.y-1.0/sourceDim.y, 1.0-1.0/sourceDim.y);
            vec2 orig = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;
        
            vec2 scaledDim = mat2(modelTransform)*(1.0*dim);
            vec2 offset = -vec2(modelTransform[2][0], modelTransform[2][1])/scaledDim;
            float N = float(iterations);
            vec2 step = N<=1.0? vec2(0.0, 0.0) : vec2(cos(angle), sin(angle))*scaledDim*2.0/(N-1.0);//*scaledDim*0.05;
            vec2 start = -step*scaledDim;
            int zeroDists = 0;
            for (float i=0.0; i<N; ++i) {
                vec2 pos1 = uv + offset + start + i*step;
                float ang = i/float(iterations)*PI2 + angle;
                vec2 pos2 = uv + offset + vec2(cos(ang), sin(ang))*scaledDim;
                vec2 p = mix(pos1, pos2, mode);
                vec4 c = (source2_specified==1) ? __source2__(p) : __source__(p);
                float dist = length(color-c);
                if (dist<bestDist) {
                    if (i==0.0 || dist!=0.0 || zeroDists!=0) {
                        bestDist = dist;
                        bestColor = c;
                    }
                    else if (dist==0.0) {
                        ++zeroDists;
                    }
                }
            }
        
            return bestColor;
        }
