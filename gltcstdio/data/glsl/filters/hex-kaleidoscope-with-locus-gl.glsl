vec4 hexKaleidoscope(vec2 uv, vec2 outPos, int mode, int spikeCount, float offset, float shadows, vec4 colorShadow, mat3 modelTransform, mat3 viewTransform, mat3 shadowTransform) {
    vec2 u = uv;
    vec4 hex = hexPolarCoords(u);
    float a = hex.x;
    float anglePeriod = PI2 / float(spikeCount);
    a = mod(a, anglePeriod);
    if (mode==0) a = a>anglePeriod/2.0 ? anglePeriod - a : a;
    vec2 dv = offset * u;
    //vec2 dv = (offsetTransform * vec3(u, 1.0)).xy;
    vec2 w = hex.y*vec2(cos(a), sin(a));
    vec2 v = (inverse(modelTransform) * vec3(w + dv, 1.0)).xy;
    
    vec4 col = __source__(v);
    if (shadows>0.0) {
        vec2 hex2 = tf(inverse(shadowTransform), hex.y*vec2(cos(hex.x), sin(hex.x)));
        float kShadow = smoothstep(-0.15+shadows, -0.15, (0.5-length(hex2))*2.0) * colorShadow.a;
        col.rgb = mix(col.rgb, colorShadow.rgb, kShadow);
    }
    
    return col;
}
