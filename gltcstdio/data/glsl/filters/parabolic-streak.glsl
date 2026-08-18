vec4 parabolicStreak(vec2 uv, vec2 outPos, int count, mat3 modelTransform, float offset) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float h = length(u)/(1. + offset*u.y);
    vec2 c = vec2(0., h);
    vec2 dv = u-c;
    vec2 uv2 = vec2(0., 2.*h);
    
    vec4 outCol = __source__(tf(modelTransform, uv2));
    
    return outCol;
}
