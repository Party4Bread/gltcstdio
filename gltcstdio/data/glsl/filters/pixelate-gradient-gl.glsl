vec4 pixelateGradient(vec2 pos, vec2 outPos, mat3 modelTransform,
                       float shapeAspectRatio) {
    float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    float scale = 1.0 / resolution;
    float scaleY = sqrt(1.0 / shapeAspectRatio);
    float scaleX = 1.0 / scaleY;
    vec2 scaleV = vec2(scaleX, scaleY) * scale;

    vec2 uu = floor(pos / scaleV + 0.5);
    vec2 du = (pos / scaleV - uu) + 0.5;
    vec2 u = uu * scaleV;

    vec2 delta = vec2(0.4, 0.0);
    vec4 cx1 = __source__(u - delta * scaleV);
    vec4 cx2 = __source__(u + delta * scaleV);
    vec4 cy1 = __source__(u - delta.yx * scaleV);
    vec4 cy2 = __source__(u + delta.yx * scaleV);

    vec4 outCol;
    if (length(cx1 - cx2) > length(cy1 - cy2)) {
        outCol = mix(cx1, cx2, du.x);
    } else {
        outCol = mix(cy1, cy2, du.y);
    }
    return outCol;
}
