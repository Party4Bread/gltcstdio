vec4 star(vec2 uv, vec2 outPos, int count, float intensity, float blend, float center, float secondary, float thickness, float randomSeed, vec4 color, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float lum = intensity * star(u, thickness*0.2, center, 1., secondary);
    
    for(int i=1; i<count; ++i) {
        vec2 delta = rand2relSeeded(vec2(float(i)), randomSeed) * (30.0+float(i)*2.0);
        lum += intensity * fract(delta.x*4.0+delta.y*3.0) * star(u+delta, thickness*0.2, center, 1., secondary);
    }       
    
    
    vec4 col = vec4(lum*vec3(color), color.a);           
    vec4 bkgCol = __source__(uv);
    float k1 = blend;
    float k2 = 1.-blend;
    vec4 outCol = mix(bkgCol, bkgCol+col, k2+k1*min(lum*k2*10., 1.));
    return outCol;
}
