vec4 pinch(vec2 pos, vec2 outPos, mat3 modelTransform, float dampening, float threshold, vec4 highFreqColor, vec2 sourceDim) {
        vec2 u = tf(inverse(modelTransform), pos);
        float y = abs(u.y);
        float dTreshold = threshold * (1. + dampening);
        float div = 1.0;
        if (y>threshold) {
            if (y>dTreshold) {
                 div = y - (dampening*threshold)*0.5;
            }
            else {
                div = mix(threshold, dTreshold - (dampening*threshold)*0.5, pow((y-threshold)/(dTreshold-threshold), 2.));
            }
        }
        else {
            div = threshold;
        }
        u.x /= div;
        float kCol = smoothstep(0.0, 3.0, log(1.0/div)*highFreqColor.a);
        
        u = tf(modelTransform, u);
        
        vec4 outCol = __source__(u);
        return mix(outCol, vec4(highFreqColor.rgb, 1.0), kCol);
    }
