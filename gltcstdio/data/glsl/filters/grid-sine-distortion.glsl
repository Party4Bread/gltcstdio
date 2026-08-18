vec4 gridSineDistortion(vec2 uv, vec2 outPos, float intensity, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float d = length(v);

    float delta = 10.0*intensity * cos(v.x*PI) * cos(v.y*PI);
    u = tf(modelTransform,  v + delta*v);

    
    return __source__(u);
}
