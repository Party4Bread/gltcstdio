vec4 coral(vec2 uv, vec2 outPos, float intensity, float angle, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 orig = tf(invModelTransform, uv);
    vec2 p = orig;

    float delta = 0.001;
    vec2 d = mat2(invModelTransform) * vec2(delta, 0.0);
    int N = int(abs(intensity)*500.0); 
    for(int i=0; i<N; ++i) {
        vec3 hsl = hsl2rgb(__source__(p).rgb);
        float k = 1.0-2.0*abs(0.5-hsl.z);
        float a = angle + (hsl.z*2.0 + k*(hsl.x)/180.0)*PI;
        p += sign(intensity) * delta*vec2(cos(a), sin(a));
    }
    vec2 totalDisp = p - orig;
    vec4 outColor = __source__(uv + totalDisp);
    return outColor;
}
