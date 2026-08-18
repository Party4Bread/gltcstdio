vec4 squareFresnel(vec2 uv, vec2 outPos, mat3 modelTransform, float intensity) {
    vec2 pos = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float level = floor(max(abs(pos.x), abs(pos.y)));
    float scale = pow(intensity, level);
    return __source__(uv*scale);
}
