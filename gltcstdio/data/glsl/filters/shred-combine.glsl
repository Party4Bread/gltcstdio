vec4 shredCombine(vec2 pos, vec2 outPos, float shadows, float intensity, float thickness, vec4 borderColor, vec4 colorShadow, mat3 axisTransform, mat3 viewTransform1, mat3 viewTransform2) {
    mat3 inverseAxisTransform = inverse(axisTransform);
    vec2 u = tf(inverseAxisTransform, pos); 
    float scale = length(axisTransform[0].xy);
    u = fractalValueNoiseDisplace(u, u, 12, intensity * 5.0);
    float d = u.x * scale;
    
    float th = thickness*0.25;
    if (abs(d) < th) return borderColor;
    
    vec4 outCol;
    if (d<0.0) outCol = __source1__(tf(inverse(viewTransform1), pos));
    else outCol = __source2__(tf(inverse(viewTransform2), pos));

    if (shadows!=0.0) {
        float dShadow = (sign(shadows) * d) - th;
        if (dShadow>0.0) {
            float shadowStrength = smoothstep(abs(shadows), abs(shadows)*0.25, dShadow);
            vec4 shColor = vec4(colorShadow.rgb, colorShadow.a * shadowStrength);
            outCol = mergeColor(outCol, shColor);
        }
    }
    
    return outCol;
}
