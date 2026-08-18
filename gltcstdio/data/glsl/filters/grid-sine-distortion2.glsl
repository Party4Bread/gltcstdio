vec4 gridSineDistortion2(vec2 uv, vec2 outPos, float intensity, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float d = length(v);

    vec2 delta = intensity * 100.0 * vec2(sin(v.x), sin(v.y));
    u = tf(modelTransform,  v + delta);

    
    return __source__(u);
}
