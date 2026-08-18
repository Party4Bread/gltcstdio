vec4 selectByHue(vec2 pos, vec2 outPos, vec4 colorIn, vec4 colorOut, int source2_specified, float saturation, float tolerance, float hardness) {
    vec4 col1 = __source1__(pos);
    vec4 col2 = source2_specified==1 ? __source2__(pos) : col1;
    
    float col1Sat = rgbToHsl(col1).y;
    float d = abs(col1Sat-saturation);
    float maxD = tolerance;
    d /= maxD;
    float k = hardness==1.0 ? step(-1.0, -d) : smoothstep(1.0, hardness, d);
    
    return mix(mergeColor(col1, colorOut), mergeColor(col2, colorIn), k);
}
