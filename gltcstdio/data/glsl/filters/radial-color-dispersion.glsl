vec4 getRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0-abs(w)),
        max(0.0, w),
        1.0
    );
}

vec4 radialColorDispersion(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float hardness, float shapeAspectRatio, mat3 modelTransform) {
            vec2 p = tf(inverse(modelTransform), pos);
            float stepLen = 2.0/sourceDim.y;//0.002;

            if (p.x==0.0 && p.y==0.0) return __source__(pos);

            float pDist = length(p);
            float shapeDist = length(withShapeAspectRatio(p, shapeAspectRatio));
            float k = smoothstep(hardness*0.999, 1.0, shapeDist);
        
            vec2 dir = normalize(p);
            vec2 step = dir * stepLen;
        
            float distance = k * intensity;
            float halfDist = distance * .5;
                        
            vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
            vec4 totalW = vec4(0.0, 0.0, 0.0, 0.0);
            
            float start = max(0.0, pDist-halfDist);
            float end = pDist+halfDist;
            float actualDistance = end-start;
            if (actualDistance<=stepLen) return __source__(pos);
            
//            for(float d = start; d<end; d += stepLen) {
//                vec2 q = tf(modelTransform, d*dir);
//                vec4 weights = getRGBWeights((d-start)/actualDistance * 2.0 - 1.0);
//                totalColor += weights * __source__(q);
//                totalW += weights;
//            }
            vec2 startQ = tf(modelTransform, start*dir);
            vec2 endQ = tf(modelTransform, end*dir);
            float n = max(3.0, ceil(actualDistance/stepLen));
            for(float i=0.0; i<n; ++i) {
                float k = i/(n-1.0);
                vec2 q = mix(startQ, endQ, k);
                vec4 weights = getRGBWeights(k * 2.0 - 1.0);
                vec4 col = __source__(q);
                totalColor += weights * col*col;
                totalW += weights;
            }
        
            vec4 dispersedColor = sqrt(totalColor / totalW); //n * 1.5;
            //vec4 baseColor = __source__(pos);
        
            return dispersedColor;
        }
