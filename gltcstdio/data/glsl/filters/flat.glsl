vec4 flatFill(vec2 uv, vec2 outPos, int source_specified, vec4 color) {
    vec4 outColor = mix(color, color, uv.x); // should just be return color; but a reference to uv seems to be required somewhere in the shader otherwise it causes a GL error. Should require further investigation.
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
