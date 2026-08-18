vec2 wave(vec2 u, float k, float w) {
    //return vec2(0., k*(abs(sin(u.x*2. + w*3.*sin(u.y*0.3)))-.5));
    //return vec2(0., k*(sin(u.x*2.)));
    //return mix(vec2(0., k*(sin(u.x*2.))), vec2(0., k*(abs(sin(u.x*2. + w*3.*sin(u.y*0.3)))-.5)), w);
    return w>=0. ? mix(vec2(0., k*(abs(sin(u.x*2.)) - .5)), vec2(0., k*(sin(u.x*2.))), w)
        : mix(vec2(0., k*(abs(sin(u.x*2.)) - .5)), vec2(0., k*(abs(sin(u.x*2. + w*3.*sin(u.y*0.3)))-.5)), min(1., -w));
}

float nextRot(int i, float angle) {
    return angle*float(i+1);
}

vec4 turbulence2(vec2 uv, vec2 outPos, float intensity, float dampening, float balance, int iterations, mat3 modelTransform, mat3 iterTransform, float translation, float angle) {
    mat3 t = inverse(modelTransform);

    for(int i=0; i<iterations; ++i) {
        uv = tf(t, uv);
        uv += wave(uv, intensity, balance);
        intensity *= 1. - dampening;
        uv = tf(inverse(t), uv);
        vec2 p = vec2(0.);
        t *= translation3(vec2(0.02, -0.01)*translation) * rotation3(nextRot(i, angle)) * iterTransform;
    }

    return __source__(uv);
}
