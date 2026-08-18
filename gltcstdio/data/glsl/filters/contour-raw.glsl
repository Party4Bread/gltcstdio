float sampleCol(vec4 color, float count) {
    return floor((color.r + color.g + color.b)*(count-1.0)/3.0 + 0.5);
}

vec4 contour(vec2 uv, vec2 outPos, vec2 sourceDim, int count, vec4 colorBkg, vec4 colorStroke, float thickness) {
            float pixel = 2.0 / sourceDim.y;
            vec2 p = vec2(pixel, 0.0);
        
            float sum = 0.0;
            float max = 0.0;
            float fRadius = thickness*0.01 / pixel;
            float r2 = fRadius*fRadius;
            int radius = int(floor(0.5 + fRadius));
            float fcount = float(count);
            
            float maxCoverage = 0.0;
            
            for(int j=-radius; j<=radius; ++j) {
                for(int i=-radius; i<=radius; ++i) {
                    vec2 delta = vec2(float(i), float(j));
                    vec2 minDelta = abs(delta) - 0.25;
                    if ((i==0 && j==0) || (dot(minDelta, minDelta)<r2)) {
//                        float coverage = 0.2;
//                        vec2 deltaTmp = minDelta + vec2(0.25, 0.25); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
//                        deltaTmp = minDelta + vec2(0.5, 0.0); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
//                        deltaTmp = minDelta + vec2(0.0, 0.5); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
//                        deltaTmp = minDelta + vec2(0.5, 0.5); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
                        float coverage = smoothstep((fRadius+0.75)*(fRadius+0.75), (fRadius-0.75)*(fRadius-0.75), dot(delta, delta));
                        
                        vec2 pos = uv + delta*vec2(pixel, pixel);
                        float s0 = sampleCol(__source__(pos+p.xy), fcount);
                        float s1 = sampleCol(__source__(pos-p.xy), fcount);
                        float s2 = sampleCol(__source__(pos+p.yx), fcount);
                        float s3 = sampleCol(__source__(pos-p.yx), fcount);
                        float s = sampleCol(__source__(pos), fcount);
                        
                        bool onContour = s!=s0 || s!=s1 || s!=s2 || s!=s3;
                        if (onContour && maxCoverage<coverage) maxCoverage = coverage;
                    }
                }
            }
        
            vec4 color = mixColors(colorBkg, colorStroke, maxCoverage);
            vec4 bkgColor = __source__(uv);
        
            return mergeColor(bkgColor, color);
        }
