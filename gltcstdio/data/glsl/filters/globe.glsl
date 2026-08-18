vec4 globe(vec2 uv, vec2 outPos, float intensity, vec2 sourceDim, float power, float shadows, vec4 colorShadow, mat3 modelTransform, mat3 shadowTransform) {
    mat3 t = inverse(modelTransform);
    float ratio = sourceDim.x / sourceDim.y;
    vec2 u = ratio<1.0 ? uv / ratio : uv;
    vec2 v = tf(t, u);
    
    float d = measure(v, power);
    float kShadow = 0.0;
    
    if (d<1.0) {
        float hh = sqrt(1.0 - d*d);
        if (hh != 0.0) {        
            float h = 1.0 + hh;
            float s = (- d * intensity) / hh;
            float dilation = 1.0 + (h * s)/d;
    
            u = tf(modelTransform,  dilation*v).xy;
        }
        if (shadows<0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = pow(pow(abs(vs.x), power) + pow(abs(vs.y), power), 1.0/power);
            kShadow = 1.0*smoothstep(shadows, 0., ds-1.0);
        }
    }         
    else if (shadows>0.0) {
        vec2 vs = tf(inverse(shadowTransform), v);
        float ds = pow(pow(abs(vs.x), power) + pow(abs(vs.y), power), 1.0/power);
        kShadow = 1.0*smoothstep(shadows, 0., ds-1.0);
    }
    
    u = ratio<1.0 ? u * ratio : u;
    vec4 col = __source__(u);
    return mix(col, vec4(colorShadow.rgb, col.a), kShadow*colorShadow.a);
}
