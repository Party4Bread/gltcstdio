vec4 duotone(vec2 pos, vec2 outPos, float threshold, float hardness) {
    vec4 col = __source__(pos);
    float l = luma(col.rgb);
    
    float g;
    
    if (hardness==1.0) {
        g = l<threshold ? 0.0 : 1.0;
    }
    else {
        float a = mix(0.0, threshold, hardness);
        float b = mix(1.0, threshold, hardness);
        g = smoothstep(a, b, l);
    }
    
    return vec4(vec3(g), 1.0);
    
}
