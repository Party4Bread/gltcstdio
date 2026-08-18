vec4 radialColorDispersion(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float hardness, mat3 modelTransform) {
    vec2 p = tf(inverse(modelTransform), pos);
    float stepLen = 0.002;
    
    if (p.x==0.0 && p.y==0.0) return __source__(pos);

    float pDist = length(p);
    float k = smoothstep(hardness*0.999, 1.0, pDist);

    vec2 dir = normalize(p);
    vec2 step = dir * stepLen;

    float distance = k * intensity;
    float halfDist = distance * .5;
    
    float n = 0.0;
    
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    float totalW = 0.0;
    
    float start = max(0.0, pDist-halfDist);
    float end = pDist+halfDist;
    float actualDistance = end-start;
    if (actualDistance<=stepLen) return __source__(pos);
    
    for(float d = start; d<end; d += stepLen) {
        vec2 q = tf(modelTransform, d*dir);
        vec4 col = __source__(q);
        totalColor += col*col;
        totalW += 1.0;
    }

    vec4 dispersedColor = sqrt(totalColor / totalW); 

    return dispersedColor;
}
