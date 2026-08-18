vec4 stretch(vec2 uv, vec2 outPos, float intensity, float dampening, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = tf(t, uv);
    float d = length(u);
    u = tf(modelTransform, u * pow(2., -intensity*max(dampening, d)));
    return __source__(u);
}
