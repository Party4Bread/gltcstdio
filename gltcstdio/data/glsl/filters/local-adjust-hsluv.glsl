vec4 adjustHSLuv(vec2 pos, vec2 outPos, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, vec4 tint, mat3 modelTransform) {                   
    vec4 col = __source__(pos);

    float d = length(tf(inverse(modelTransform), pos));
    if (d>=1.0) return col;
    
    vec4 outCol = adjustColor(col, brightness, contrast, luminosity, gamma, saturation, hue, tint);   
    
    float k = smoothstep(1.0, 0.5, d);
              
    return mix(col, outCol, k);
}
