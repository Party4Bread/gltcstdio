vec4 gradient(vec2 uv, vec2 outPos, int source_specified, vec4 color1, vec4 color2) {
    float k = (clamp(uv.x, -1., 1.) + 1.) * .5;
    vec4 outColor = mix(color1, color2, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
