vec4 rubidium(vec2 pos, vec2 outPos, int displacement_specified, float intensity, float balance, mat3 modelTransform) {
    vec4 disp = displacement_specified==1 ? __displacement__(tf(inverse(modelTransform), pos)) : __source1__(tf(inverse(modelTransform), pos));
    float scale = pow(2.0, intensity * 4.0 * (luma(disp.rgb) - 0.5));
    vec2 u1 = pos * scale;
    
    float sR = pow(2.0, intensity * 4.0 * (disp.r - 0.5));
    //vec2 center = (disp.gb - 0.5) * 2.0;
    vec2 center = 1.5 * disp.g * vec2(cos(disp.b*PI2), sin(disp.b*PI2) - 0.5);
    vec2 u2 = (pos-center)*sR + center;
    
    return __source1__(mix(u1, u2, balance));
}
