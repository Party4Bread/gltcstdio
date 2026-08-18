vec2 wave(vec2 u, float k) {
    return 5.*vec2(k*sin(u.y*(1.5+sin(u.y*1.1))+0.44)/(abs(u.y)+1.0), k*(sin(u.x)/(abs(u.x)+1.0)));
}

float nextRot(int i, float angle) {
    return 1.507+sin(angle)+sin(float(i)*0.01);
}

vec4 turbulence(vec2 uv, vec2 outPos, float intensity, int iterations, mat3 modelTransform, float translation, float angle) {
    mat3 t = inverse(modelTransform);

    for(int i=0; i<iterations; ++i) {
        uv = tf(t, uv);
        uv += wave(uv, intensity);
        uv = tf(inverse(t), uv);
        vec2 p = vec2(0.);
        //vec2 p = wave(uv, 1.0);
        float tt = pow(translation, 3.);
        t *= translation3(vec2(tt+0.01*cos(angle), tt+0.02*sin(angle)))
            * rotation3(nextRot(i, angle)+.5*p.y)
            * scaling3(1.);
    }

    return __source__(uv);
}
