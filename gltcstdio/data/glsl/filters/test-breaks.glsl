vec4 testBreaks(vec2 uv, vec2 outPos, float dampening, float perturbation, float distortion, float variability, float randomSeed, mat3 modelTransform, mat3 displaceTransform) {
            mat3 inverseModelTransform = inverse(modelTransform);
            vec2 u = uv;
            vec2 t = tf(inverseModelTransform, uv);

            if (perturbation > 0.0) {
                t += sineSurfaceRand2Seeded(t*(1.0+perturbation*1.00), randomSeed) * 2.5*perturbation;
            }        
            
            float dist, maxDist;
            {
    float len = length(t);
    float index = floor(len/2.0);
    float var = variability * rand2relSeeded(vec2(index, index), randomSeed).x * 2.0;
    float dd = 1. + var;
    float dx = mod(len, 2.0);
    float inside = (mod(len, 2.0) < 1.0+var) ? 1.0 : 0.0;
    dist = dx<=dd ? max(dx-dd, -dx) : min(dx-dd, 2.0-dx); 
    maxDist = dx<=dd ? dd*.5 : 1.-dd*.5; 
}
            
            vec2 delta = dist<0.0 ? tf(inverse(displaceTransform), uv)-uv: vec2(0.); //(rand2(vec2(minIndex+1.0, minIndex))-vec2(0.5, 0.5)) * intensity*2.0;
            vec2 newPos = uv + delta*(1.0-dampening);
        
            if (distortion > 0.0 && dist < 0.0) {
                vec2 grad = normalize(vec2(dFdx(dist)/dFdx(uv.x), dFdy(dist)/dFdy(uv.y)));
                float r = -dist/maxDist;
                float dp = distortion*2.0 * (1.0-r)/(0.5+r);
                newPos += dp * grad;
            }
            else if (distortion < 0.0 && dist >0.0) {
                vec2 grad = normalize(vec2(dFdx(dist)/dFdx(uv.x), dFdy(dist)/dFdy(uv.y)));
                float r = dist/maxDist;
                float dp = -distortion*2.0 * (1.0-r)/(0.5+r);
                newPos += dp * grad;
            }
        
//            bool distorted = false;
//            if (d2min > 0.0 && distortion > 0.0 && pixelation!=1.0) {
//                    vec2 dd = t - minCenter;
//                    distorted = true;
//                    float k = clamp(sqrt(d2min), 0.0, 1.0) / sqrt(d2min2);
//                    float r = 1.0-k;
//                    float dp = distortion*2.0 * (1.0-r)/(0.5+r);
//                    newPos += dd * dp;
//            }
        
            vec4 outColor = __source__(newPos);
        
            return outColor;
        }
