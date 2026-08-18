vec4 basicInterpolatedShapes(vec2 uv, vec2 outPos, int insideImage_specified, 
        float shadows, float roundness, float multiplier,
        vec4 colorOutline, float outlineThickness,
        float brightness, float contrast, float saturation, float hue,
        vec4 colorIn, vec4 colorOut, vec4 colorShadow, vec4 colorGlow, 
        int insideLock, mat3 modelTransform, mat3 insideTransform, mat3 shadowTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float d = 0.0;
    d = sdEquiTriangle(vec2(u.x, -u.y)*1.5);     
    d = d*multiplier - roundness;
    
    float shadow = 0.0;
    vec4 tint = vec4(0.0);
    vec2 v = uv;
    bool inside = d<=0.0;
    if (inside) {
        if (shadows<0.0) {
            u = tf(inverse(shadowTransform), u);
            float saveD = d;
            d = d*multiplier - roundness;
             d = sdEquiTriangle(vec2(u.x, -u.y)*1.5);     
            shadow = 0.7*smoothstep(shadows, 0., d); // d is shadow d here
            d = saveD;
        }
        tint = colorIn;
        mat3 iTransform = insideLock==0 ? insideTransform : modelTransform*insideTransform;
        v = tf(inverse(iTransform), uv);
    }
    else {
        if (shadows>0.0) {
            u = tf(inverse(shadowTransform), u);
            float saveD = d;
            d = d*multiplier - roundness;
             d = sdEquiTriangle(vec2(u.x, -u.y)*1.5);     
            shadow = 0.7*smoothstep(shadows, 0., d); // d is shadow d here
            d = saveD;
        }
        tint = colorOut;
    }
    
    vec4 sColor = (insideImage_specified==1 && inside) ? __insideImage__(v) : __source__(v);
    vec4 color = sColor;
    if (inside) color = adjustColorHSLuv(color, brightness, contrast, 0.0, 0.0, saturation, hue, vec4(0.0));
    vec4 glow = (colorGlow.a!=0.0) ? vec4(colorGlow.rgb * 0.01/abs(d), min(1.0, colorGlow.a* 0.01/abs(d))) : vec4(0.);           
    color = mergeGlow(mergeColor(mergeColor(color, tint), vec4(colorShadow.rgb, colorShadow.a*shadow)), glow);
    if (abs(d)<outlineThickness*.5) {
        color = mergeColor(color, colorOutline);
        shadow = 0.0;
    }
    return color;
}            
