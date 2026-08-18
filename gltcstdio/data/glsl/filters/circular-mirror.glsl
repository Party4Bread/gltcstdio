vec4 circularMirror(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float shapeAspectRatio, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    vec2 ar = aRatio(shapeAspectRatio);
    float d = length(v * ar);
    
    if (d>1.0) {
        //v = 2.0*normalize(v)-v;
        vec2 normV = v / d;
        v = mix(2.0*normV-v, 1.0/d * normV, intensity);
        u = tf(modelTransform, v).xy;
    }                     
    
    vec4 outCol = __source__(u);
    
    return outCol;
}
