vec4 smoothHatch(vec2 uv, vec2 outPos, int source_specified, vec4 color1, vec4 color2, float balance, float hardness) {
    float k = triangleToSquareWave(stepWiseSCurve(uv.x*0.5, balance)*2.0-1.0, hardness)*0.5 + 0.5;
        
    vec4 outColor = mix(color1, color2, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
