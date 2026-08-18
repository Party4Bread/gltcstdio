vec4 hatch(vec2 pos, vec2 outPos, int source_specified, mat3 modelTransform, float thickness, vec4 color1, vec4 color2) {
    vec4 outColor = mix(color1, color2, fract(pos.x)>thickness ? 0.0 : 1.0);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
