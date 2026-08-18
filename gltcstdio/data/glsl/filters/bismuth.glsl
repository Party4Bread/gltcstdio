vec4 bismuth(vec2 uv, vec2 outPos, float intensity, float angle, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 orig = tf(invModelTransform, uv);
    vec2 p = orig;
    int N = int(abs(intensity)*500.0);
    float delta = 0.001 * sign(intensity);
    vec2 disp = mat2(invModelTransform) * (delta * vec2(cos(angle), sin(angle)));
    for(int i=0; i<N; ++i) {
        vec4 inc = __source__(p);
        if (max(abs(inc.r-inc.g), abs(inc.r-inc.b))<0.01) {
            p -= disp;
        }
        if (inc.r>inc.g && inc.r>inc.b) {
            p += disp;
        }
        else if (inc.g>inc.b) {
            p += disp.yx;
        }
        else {
            p -= disp.yx;
        }

    }
    vec2 totalDisp = p - orig;
    vec4 outColor = __source__(uv + totalDisp);

    return outColor;
}
