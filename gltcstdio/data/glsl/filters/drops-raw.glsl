vec4 drops(vec2 uv, vec2 outPos, int sourceBkg_specified, float intensity, float radius, float radiusVariability, float perturbation, float variability, float randomSeed, mat3 modelTransform) {
            mat3 t = inverse(modelTransform);
            vec2 u = uv;
            vec2 v = tf(t, uv);
            
            if (perturbation > 0.0) {
                v += sineSurfaceRand2Seeded(v*(1.0+perturbation*0.00), randomSeed) * 2.5*perturbation;
            }
        //    if (perturbation > 0.0) {
        //        t = perlinDisplace(t, 3, u_Perturbation*0.04);
        //    }
        
            float ci = floor(v.x);
            float cj = floor(v.y);
        
            float k = 0.0;
        
            vec2 minDelta;
            float d2min = INF;
            int minI = 0;
            int minJ = 0;
            vec2 minCenter;
            float minRadiusModifier;
            bool inBubble = false;
            float minRad = 0.0;
        
            for(int j = -2; j <= 2; ++j) {
                for(int i = -2; i <= 2; ++i) {
                    vec2 center = vec2(float(i)+ci, float(j)+cj);
                    vec2 delta = rand2relSeeded(center, randomSeed);
                    float radiusModifier = max(0.01, 1.0 + (delta.x * radiusVariability));
                    float rad = radius * radiusModifier;
                    float rad2 = rad*rad;
                    center += vec2(0.5, 0.5) + delta*variability*2.;
                    vec2 d = v - center;
                    float d2 = dot(d, d);
        
                    if (d2 < rad2) {
                        bool better = true;
                        if (inBubble) {
                            // distance between the 2 centers
                            vec2 dd = minCenter - center;
                            float cd2 = dot(dd, dd);
                            float cd = sqrt(cd2);
        
                            float minRad2 = minRad*minRad;
                            float inProj = (rad2 + cd2 - minRad2) / (2.0*cd); // position along the center's axis of the intersecting line
        
                            // distance of the projection of the current point on the center's axis to the current center (xx, yy)
                            float proj = dot(v-center, dd) / cd;
                            better = proj <= inProj;
                        }
        
                        if (better) {
                            inBubble = true;
        
                            d2min = d2;
                            minI = i;
                            minJ = j;
                            minCenter = center;
                            minDelta = delta;
                            minRadiusModifier = radiusModifier;
                            minRad = rad;
                        }
                    }
                }
            }
        
            k = sqrt(d2min);
        //    k = clamp(k, 0.0, 1.0);
        
            vec2 newPos = uv;
        
        // old mirror lab code:
//            if (inBubble && intensity > 0.0) {
//                vec2 dd = v - minCenter;
//        
//                k /= minRad;
//                float r = 1.0-k;
//                float dp = intensity*5.0 * (1.0-r)/(0.5+r);
//                newPos += dd * dp;
//        //        return vec4(0.0, 0.0, 0.0, 1.0);
//            }
            if (inBubble && intensity != 0.0) {
                vec2 dd = v - minCenter;
                float rad = radius * minRadiusModifier;
                float d = sqrt(d2min)/rad;//length(dd);
                float hh = sqrt(1.0 - d*d);
                if (hh != 0.0) {        
                    float h = 1.0 + hh;
                    float s = (- d * intensity) / hh;
                    float dilation = 1.0 + (h * s)/d;
            
                    newPos = tf(modelTransform,  minCenter + dilation*dd).xy;
                }
            }
        
            vec4 outColor = inBubble || sourceBkg_specified==0
                ? __source__(newPos)
                : __sourceBkg__(uv);
        
            return outColor;

        }
