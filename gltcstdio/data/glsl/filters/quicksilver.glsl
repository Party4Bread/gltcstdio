vec4 quicksilver(vec2 pos, vec2 outPos, float intensity, mat3 modelTransform, int displacement_specified) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 delta = displacement_specified==1 ? __displacement__(tf(inverseModelTransform, pos)).xy * intensity : __source1__(tf(inverseModelTransform, pos)).xy * intensity;
    vec4 outCol = __source1__(pos+delta);                
    return outCol;
}
