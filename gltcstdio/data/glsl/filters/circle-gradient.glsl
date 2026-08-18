vec4 circleGradient(vec2 uv, vec2 outPos, vec4 color1, vec4 color2, int source_specified, float hardness, float shapeAspectRatio) {
    float dist = length(withShapeAspectRatio(uv, shapeAspectRatio));
    float k = hardness==1.0 ? step(dist, 1.0) : smoothstep(1.0, hardness, dist);
    vec4 outColor = mix(color1, color2, k);

    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
