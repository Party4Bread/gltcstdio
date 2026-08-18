vec4 hueGrad(vec2 uv, vec2 outPos, vec2 sourceDim, float delta, float threshold) {
    float g = luma(__source__(uv).rgb);
    
    float pixel = 2.0/sourceDim.y;
    float radius = pixel;
    float maxRadius = 0.0;
    vec2 dir = vec2(0.0, 1.0);
    mat2 rot = rotation2(1.0);
    float deltaRadius = pixel*0.3333;
    
    int MAX_ITER = 2000;
    int i = 0;
    vec2 u = uv + radius * dir;
    while (i<MAX_ITER) {
        float g2 = luma(__source__(u).rgb);
        if ((abs(g-g2)) > threshold) break;
        maxRadius = radius;
        radius += deltaRadius;
        dir = rot * dir;
        u = uv + radius * dir;
        ++i;
    }
    return vec4(vec3(maxRadius), 1.0);
}
