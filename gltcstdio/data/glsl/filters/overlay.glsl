vec4 overlay(vec2 uv, vec2 outPos, int blendMode, float intensity, float thickness, float shadows, vec4 color, vec2 source2Dim, mat3 modelTransform) {
    vec4 bkgColor = __source1__(uv);
    
    vec2 u = tf(inverse(modelTransform), uv);
    float ratio2 = source2Dim.x/source2Dim.y;
    vec2 borderDim = vec2(ratio2+thickness*0.3, 1.0+thickness*0.3);
    if (abs(u.x)<=ratio2 && abs(u.y)<=1.) {
        vec4 overColor = __source2__(u);
        vec4 blended = blend(blendMode, bkgColor, overColor);
        vec4 mixed = mix(bkgColor, blended, intensity);                    
        return mergeColor(bkgColor, mixed);
    }
    else if (abs(u.x)<=borderDim.x && abs(u.y)<=borderDim.y) {
        return color;
    }   
    else {
        if (shadows==0.0) return bkgColor;
        float d = sdRectangle(u, borderDim);
        float s = smoothstep(shadows*0.6, 0.0, d)*.5;
        return mergeColor(bkgColor, vec4(0., 0., 0., s));
        //return mix(bkgColor, vec4(0., 0., 0., 1.), s);
    }               
}
