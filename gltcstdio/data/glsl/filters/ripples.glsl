vec4 ripples(vec2 uv, vec2 outPos, float spacing, float intensity, int count, float dampening, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float d = length(v);

    if (d<1.0) {
        float dampen = dampening >= 0.0 ? pow(1.0-d, dampening*2.) : pow(d, -dampening*5.);
        float dd = spacing<=0.0 ? d-1.0 : log((d-1.0)*spacing+1.0)/(spacing);
        float dilation = 1.0 + intensity * sin(dd * float(count) * PI) * dampen;
        u = tf(modelTransform,  dilation*v);
    } 
    
    return __source__(u);
}
