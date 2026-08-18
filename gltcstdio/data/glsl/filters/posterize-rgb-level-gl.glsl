vec4 posterizeRgbLevel(vec2 pos, vec2 outPos, int count) {
    vec4 color = __source__(pos);
    float c = max(1.0, float(count) - 1.0);
    return vec4(floor(color.rgb * c + 0.5) / c, color.a);
}
