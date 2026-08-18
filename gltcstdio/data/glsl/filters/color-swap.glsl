vec4 colorSwap(vec2 pos, vec2 outPos, vec4 colorIn, vec4 colorOut, float tolerance, float hardness) {
    vec4 col = __source__(pos);
    float closeness = length((col.rgb-colorIn.rgb)*max(col.a, colorIn.a)) / (tolerance*SQRT3);
    float k = hardness==1.0 ? step(-1.0, -closeness) : smoothstep(1.0, hardness, closeness);            
    return mix(col, colorOut, k);
}
