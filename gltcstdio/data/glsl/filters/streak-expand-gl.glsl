vec4 streakExpand(vec2 uv, vec2 outPos, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, uv);
    u.y -= sign(u.y)*min(1.0, abs(u.y));
    vec2 w = tf(modelTransform, u);
    
    return __source__(w);
}
