vec4 helixWaves(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, float intensity, float frequency, float lighting, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float ratio = sourceDim.x / sourceDim.y;
    
    float X = v.x/ratio+1.0;
    float mirror = mode == 0 ? 1.0 : (sign(mod(X, 4.0)-2.0));
    intensity = mirror * intensity;

    float d = mod(X, 2.0)-1.0;          
    float xx = sin(v.y * 2.0*frequency)*intensity;
    float delta1 = (mix(-1.0, 0.0, (d+1.0)/(xx+1.0)) - d);
    float delta2 = ((d-xx)/(1.0-xx) - d);
    float k = d<xx? 0.0 : 1.0;
    float delta = mix(delta1, delta2, k);
    v.x += delta * ratio;
    
    u = tf(modelTransform, v);
    
    float light = 1.0;
    if (lighting>0.0) {
        float pixel = 2.0/sourceDim.y;
        vec2 grad = vec2(dFdx(delta)/dFdx(u.x), dFdy(delta)/dFdy(u.y)) * 4.;
        //float scaling = length(modelTransform[0].xy); // scaling now integrated in lightDir
        vec2 lightDir = mat2(modelTransform) * vec2(0., -1.);
        light = 1. + lighting * 0.2 * /*scaling */ dot(grad, lightDir);
    }
    vec4 outCol = __source__(u);
    outCol.rgb *= light;
    return outCol;
}
