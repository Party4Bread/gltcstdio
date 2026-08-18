vec4 inversion(vec2 uv, vec2 outPos, int mode, float intensity, float dampening, int iterations, mat3 modelTransform, mat3 modelTransform2) {
    vec2 center = tf(modelTransform, vec2(0.0));
    vec2 unit = tf(modelTransform, vec2(1., 0.));
    float radius = length(unit);

    mat3 t2 = inverse(modelTransform2);
    vec2 u = uv;
    for(int i=0; i<iterations; ++i) {
        float len = length(u-center);
        vec2 dir = (u-center)/len;
        float inversedLen = radius / len;
        u = center + intensity * inversedLen*dir;
        if (mode!=1) u = abs(tf(t2, u)); else u = tf(t2, u);
        if (dampening!=-100.0) {
            float k = len<radius ? pow(len/radius, 2.0*pow(1.04, dampening)) : 1.0;
            if (dampening<0.0) k = mix(k, 1.0, -dampening/100.0); // transition towards full v at intensity = -100.0
            u = mix(uv, u, k);
        }
    }
    return __source__(u);
}
