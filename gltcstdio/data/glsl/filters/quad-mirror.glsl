mat3 getFlipTransform(int mode) {
    float sx = mode%2==1 ? -2.0 : 2.0;
    float sy = mode>1 ? -2.0 : 2.0;
    return mat3(sx, 0.0, 0.0, 0.0, sy, 0.0, 0.0, 0.0, 1.0);
}

vec4 quadMirror(vec2 uv, vec2 outPos, int mode, vec2 sourceDim, mat3 texTransform) {
    vec2 translation = vec2(-0.5 * sourceDim.x/sourceDim.y, -0.5);
    if (uv.y<0.0) { mode = mode/16; translation.y = -translation.y; }
    if (uv.x<0.0) { mode = mode/4;  translation.x = -translation.x; }
    mode = mode%4;
    vec2 u = tf(inverse(texTransform) * getFlipTransform(mode), uv + translation);
    return __source__(u);
}
