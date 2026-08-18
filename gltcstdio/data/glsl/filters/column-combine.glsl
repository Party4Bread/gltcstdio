vec4 columnCombine(vec2 pos, vec2 outPos, float shadows, float thickness, vec4 color, mat3 modelTransform, mat3 viewTransform1, mat3 viewTransform2) {
    vec2 u = tf(inverse(modelTransform), pos);   
    float d = abs(u.x) - 0.3;
    vec4 col = (d>0.0) ? __source1__(tf(inverse(viewTransform1), pos)) : __source2__(tf(inverse(viewTransform2), pos));
    float dd = d*length(modelTransform[0].xy);
    
    if (abs(dd)<thickness*0.1) return vec4(color.rgb, 1.);
    
    if (sign(shadows)==sign(d) && shadows!=0.0) {
        float sh = smoothstep(shadows, 0.0, dd);
        col = mergeColor(col, vec4(color.rgb, color.a*sh));                
    }       
    return col;
}
