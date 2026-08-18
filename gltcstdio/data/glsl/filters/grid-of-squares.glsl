float sdf(vec2 u, float count, float shape, mat3 cellTransform) {
    u = (cellTransform * vec3((u-clamp(round(u), -count, count)) * 2., 1.)).xy;
    
    if (shape<0.0) return sdRectangle(u, vec2(0.5));
    else if (shape<=1.0) return mix(sdRectangle(u, vec2(0.5)), sdDisk(u, 0.5), shape);
    else if (shape<=2.0) return mix(sdDisk(u, 0.5), sdEquiTriangle(u*1.5), shape-1.0);
    else return sdEquiTriangle(u*1.5);
}

vec4 gridOfSquares(vec2 uv, vec2 outPos, int count, float shape, float shadows, vec4 colorIn, vec4 colorOut, vec4 colorShadow, vec4 colorGlow, mat3 modelTransform, mat3 insideTransform, mat3 cellTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float d = sdf(u, float(count), shape, inverse(cellTransform));
   
    float shadow = 0.0;
    vec4 tint = vec4(0.0);
    vec2 v = uv;
    if (d>0.0) {
        if (shadows>0.0) shadow = 0.7*smoothstep(shadows, 0., d);
        tint = colorOut;
    }
    else {
        if (shadows<0.0) shadow = 0.7*smoothstep(shadows, 0., d);
        tint = colorIn;
        v = tf(inverse(insideTransform), uv);
    }
    
    vec4 color = __source__(v);
    vec4 glow = (colorGlow.a!=0.0) ? vec4(colorGlow.rgb * 0.01/abs(d), min(1.0, colorGlow.a* 0.01/abs(d))) : vec4(0.);           
    return mergeGlow(mergeColor(mergeColor(color, tint), vec4(colorShadow.rgb, colorShadow.a*shadow)), glow);
}
