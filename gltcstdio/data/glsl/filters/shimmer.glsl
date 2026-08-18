vec4 shimmer(vec2 uv, vec2 outPos, float intensity, float dampening, float shape, mat3 modelTransform) {
    vec2 v = tf(inverse(modelTransform), uv);
    float d = dampening==0.0 ? 1.0 : smoothstep(5.0/dampening, 0.5/dampening, abs(v.x));
    v.y += intensity * triangleToSquareWave(v.x*20.0+1.0, shape) * d * 0.05; 
    vec2 u = tf(modelTransform,  v);
         
    return __source__(u);
}
