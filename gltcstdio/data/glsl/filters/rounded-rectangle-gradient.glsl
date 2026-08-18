vec4 circleGradient(vec2 uv, vec2 outPos, int source_specified, vec4 color1, vec4 color2, float shapeAspectRatio, float hardness, float roundness) {
    vec2 rectSize = vec2(1., shapeAspectRatio);
    rectSize /= length(rectSize);
    float radius = min(rectSize.x, rectSize.y) * roundness;
    rectSize -= radius;
    float d = sdRectangle(uv*2., rectSize) - radius;
    float k = hardness==1.0 ? step(d*.25, 0.0) : smoothstep(1.0-hardness, 0.0, d*.25);
    vec4 outColor = mix(color1, color2, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
