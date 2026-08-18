vec4 scintillatingIllusion(vec2 uv, vec2 outPos, int source_specified, float thickness, float radius, float radiusVariability, vec4 colorIn, vec4 colorDots, vec4 colorBorder) {
    vec2 u = fract(uv)-0.5;
    vec2 id = vec2(0.0);
    if (radiusVariability!=0.0) id = floor(uv);
    
    float d = length(u);
    vec4 col;
    radius *= 0.5;
    radius *= 1.0 + (rand2rel(id).x * radiusVariability);
    if (d<radius) {
        col = colorDots;
    }
    else {        
        if (abs(u.x)<thickness || abs(u.y)<thickness) col = colorBorder;
        else col = colorIn;
    }
    
    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}
