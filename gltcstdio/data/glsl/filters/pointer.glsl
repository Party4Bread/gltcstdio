vec4 dynamicTest(vec2 uv, vec2 outPos, float intensity, float power, float frequency, vec2 sourceDim) {
    uv += intensity * power * 0.05 * vec2(sin(uv.y * 30.0 * frequency), cos(uv.x * 20.0 * frequency));
    return __source__(uv);
}
