vec4 fractalize(vec2 uv, vec2 outPos, float intensity, int iterations, mat3 modelTransform) {
    float totalK = 0.0;
    float k = 1.0;
    vec2 u = uv;
    vec4 total = vec4(0.0);
    mat3 t = inverse(modelTransform);
    for(int i=0; i<iterations; ++i) {
        total += __source__(u)*k;
        totalK += k;
        k *= intensity;
        u = tf(t, u);
    }
    return total/totalK;
}
