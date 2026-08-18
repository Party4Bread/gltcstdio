vec4 radialShimmer(vec2 uv, vec2 outPos, float spacing, float intensity, int count, float dampening, float shape, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float d = length(v);

    if (d<1.0) {
        float dampen = dampening >= 0.0 ? pow(1.0-d, dampening*2.) : pow(d, -dampening*5.);
        float angle = atan(v.y, v.x);
        
        float dd = spacing<=0.0 ? d-1.0 : log((d-1.0)*spacing+1.0)/(spacing);
        float z = triangleToSquareWave(dd * float(count), shape);
      
        float dAngle = intensity * z * dampen;
        angle += dAngle;
        u = tf(modelTransform,  d * vec2(cos(angle), sin(angle)));
    } 
    
    return __source__(u);
}
