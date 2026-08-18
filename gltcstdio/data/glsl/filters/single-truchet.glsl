vec4 truchet(vec2 uv, vec2 outPos, int source_specified, float border, float thickness, float variability, float randomSeed, vec4 color1, vec4 colorLines, vec4 colorBorder, vec4 colorBkg) {
    vec2 u = fract(uv);
    vec2 id = floor(uv);
    
    float rnd = mix(0.0, rand2relSeeded(id, randomSeed).x + .5, variability);
//    float rnd = mix(0.0, rand2relSeeded(id, randomSeed).x, variability);
    
    if (rnd<0.25) u = vec2(u.x, 1.- u.y);
    else if (rnd<0.5) u = vec2(1.-u.x, u.y);
    else if (rnd<0.75) u = vec2(1.-u.x, 1.- u.y);
//    if (rnd<0.2) u = vec2(u.x, 1.- u.y);
//    else if (rnd<0.4) u = vec2(1.-u.x, u.y);
//    else if (rnd<0.6) u = vec2(1.-u.x, 1.- u.y);
//    else if (rnd<0.8) u = abs(u-0.5)+0.5;
        
    vec4 col;
    float t = thickness;
    
    float d = abs(length(u) - 0.5) * 2.;
    if (d > t) {
        u = 1.-u;
        d = abs(length(u) - 0.5) * 2.;
        if (d > t) col = colorBkg;
        else if (d > t * (1.-border)) col = colorBorder;
        else col = colorLines;   
    }
    else if (d > t * (1.-border)) col = colorBorder;
    else col = colorLines;   
    
    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}
