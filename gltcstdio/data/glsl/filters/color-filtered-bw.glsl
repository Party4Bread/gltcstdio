vec4 colorFilteredBW(vec2 pos, vec2 outPos, float intensity, vec4 color) {
    vec4 col = __source__(pos);
    
    float g = dot(color.rgb, col.rgb);

    float total = (color.r + color.g + color.b);
    float gamma = pow(2.0, (1.5-total)/1.5);
    float grey = clamp(pow(g/total, gamma), 0.0, 1.0);

    return mix(col, vec4(grey, grey, grey, color.a), intensity);
}
