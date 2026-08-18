vec4 selectByColorDifference(vec2 pos, vec2 outPos, vec4 colorIn, vec4 colorOut, float target, float tolerance, float hardness) {
    vec4 col1 = __source1__(pos);
    vec4 col2 = __source2__(pos);
    float dist = length(col1.rgb-col2.rgb) * max(col1.a, col2.a) / SQRT3;
    float distTarget = abs(dist-target) / tolerance;
    float k = hardness==1.0 ? step(-1.0, -distTarget) : smoothstep(1.0, hardness, distTarget);       
    
    return mix(mergeColor(col1, colorOut), mergeColor(col2, colorIn), k);
}
