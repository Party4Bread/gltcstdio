vec4 blendImg(vec2 pos, vec2 outPos, int blendMode, float intensity, int mask_specified, mat3 maskTransform) {
    vec4 in1 = __source1__(pos);
    vec4 in2 = __source2__(pos);
    //float mask = mask_specified==1 ? luma(__mask__(tf(maskTransform, pos)).rgb) : 0.5; // this makes more sense but see note above!!
    float mask = mask_specified==1 ? luma(__mask__(pos).rgb) : 0.5;
    //if (invert==1) mask = 1. - mask;
    vec4 blended = blend(blendMode, in1, in2);
    return mix(in1, blended, mask * intensity);
}
