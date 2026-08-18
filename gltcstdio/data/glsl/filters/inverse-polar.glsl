vec4 inversePolar(vec2 uv, vec2 outPos, mat3 modelTransform) {
    float ang = uv.x * PI + PI;
    float len = (1.0-uv.y)*0.72;
    vec2 u = len * vec2(cos(ang), sin(ang));
    vec2 v = tf(modelTransform, u);
    return __source__(v);
}
