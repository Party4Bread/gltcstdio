vec4 rotateSimple(vec2 uv, vec2 outPos, mat3 viewTransform) {
    return __source__(tf(inverse(viewTransform), uv));
}
