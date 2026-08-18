vec4 linearBlend(vec2 pos, vec2 outPos, float intensity, int blendMode) {
    vec4 in1 = __source1__(pos);
    vec4 in2 = __source2__(pos);
    
    vec4 blended = blend(blendMode, in1, in2);
    return mix(in1, blended, intensity);
}
