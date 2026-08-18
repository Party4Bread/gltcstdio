vec4 colorSwap(vec2 pos, vec2 outPos, vec4 color, float intensity, float tolerance) {
    vec4 srcCol = __source__(pos);
    float k = intensity + 1.;
    float closeness = length((color.rgb-srcCol.rgb)*max(color.a, srcCol.a)) / (tolerance*SQRT3);
    return mix(color + k * (srcCol - color), srcCol, smoothstep(0.0, 1.0, closeness));     
}
