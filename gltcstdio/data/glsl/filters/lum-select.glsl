vec4 lumSelect(vec2 pos, vec2 outPos, float target, float tolerance, float hardness) {
    vec4 col = __source__(pos);
    float lum = luma(col.rgb);
    float distTarget = abs(lum-target) / tolerance;
    float k = hardness==1.0 ? step(-1.0, -distTarget) : smoothstep(1.0, hardness, distTarget);       
    
    return vec4(col.rgb, col.a*k);
}
