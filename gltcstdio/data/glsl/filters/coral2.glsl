mat3 getRGBCoefficients(float k, float offset) {
    float offset1 = PI/3.0;
    float offset2 = offset1*2.0;
    float kk = k + offset*PI;
    float a = sin(kk);
    float b = sin(kk+offset1);
    float c = sin(kk+offset2);
    return mat3(vec3(a, b, c), vec3(b, c, a), vec3(0.));
}

vec4 coral2(vec2 uv, vec2 outPos, float intensity, float angle, float power, float balance, float offset) {
    vec2 p = uv;
    float delta = 0.001;
    vec2 d = vec2(delta, 0.0);
    int N = int(abs(intensity)*500.0); 
    mat2 rot = rotation2(angle);
    float exponent = pow(4., power);
    for(int i=0; i<N; ++i) {
        vec3 rgb = __source__(p).rgb;
        vec2 dir = (getRGBCoefficients(float(i)*balance, offset) * (rgb-vec3(.5))).xy;
        p += sign(intensity) * delta*(pow(length(rgb), exponent)) * (rot*dir);
    }

    vec4 outColor = __source__(p);
    return outColor;
}
