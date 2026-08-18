vec4 linearBlend(vec2 pos, vec2 outPos) {
    vec4 in1 = __source1__(pos);
    vec4 in2 = __source2__(pos);
    vec4 in3 = __source3__(pos);
    
    vec4 blended = (in1 + in2 + in3)/3.;
    return blended;
}
