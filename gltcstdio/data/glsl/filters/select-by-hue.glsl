vec4 selectByHue(vec2 pos, vec2 outPos, vec4 colorIn, vec4 colorOut, float hue, float tolerance, float hardness) {
    vec4 col1 = __source1__(pos);
    vec4 col2 = __source2__(pos);
    
    float col1Hue = rgbToHsl(col1).x;
    float targetHue = hue;
    float d = col1Hue-targetHue;
    if (d < 0.0) d = -d;
    if (d > 180.0) d = 360.0-d;
    float maxD = 360.0 * tolerance;
    d /= maxD;
    float k = hardness==1.0 ? step(-1.0, -d) : smoothstep(1.0, hardness, d);
    
    return mix(mergeColor(col1, colorOut), mergeColor(col2, colorIn), k);
}
