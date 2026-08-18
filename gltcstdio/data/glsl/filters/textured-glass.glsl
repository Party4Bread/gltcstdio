float getSurface(vec2 u) {
    return 10. * (perlinNoise(u)+0.7*perlinNoise(u*2.1223));
}

vec3 getNormal(vec2 p) {
    float d = 0.001;
    float y = getSurface(p);
    float yx = getSurface(vec2(p.x+d, p.y));
    float yz = getSurface(vec2(p.x, p.y+d));
    return normalize(vec3((yx-y)/d, 1.0, (yz-y)/d));
}

vec4 texturedGlass(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity) {
    vec2 t = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
    
    vec2 delta = getNormal(t*10.0).xy;
    //vec2 delta = vec2(getSurface(t*10.0), getSurface(t*10.0 + 23.23));

    return __source__(pos + delta*intensity*0.1);
}
