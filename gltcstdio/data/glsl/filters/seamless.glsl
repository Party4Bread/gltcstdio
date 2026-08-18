vec4 seamless(vec2 uv, vec2 outPos, vec2 sourceDim, float blend) {
    float inRatio = sourceDim.x/sourceDim.y;
    float margin = blend * min(inRatio, 1.0);
    float halfMargin = margin * .5;
    float outRatio = (2.*inRatio-margin) / (2.-margin);
    float outToInScale = (2. - margin) / 2.; 
    
    vec2 u = uv * outToInScale;
    
    vec2 u2 = u;
    vec2 k = vec2(1.);
    vec2 lim = vec2(inRatio, 1.0) - halfMargin;
    vec2 mlim = vec2(inRatio, 1.0) - margin;
    
    if (u.x<-mlim.x) { 
        u2.x = lim.x + (u.x+lim.x);
        k.x = 1.0 - (-mlim.x - u.x)/margin;
    }
    else if (u.x>mlim.x) {
        u2.x = -inRatio + (u.x-mlim.x);
        k.x = 1.0 - (u.x - mlim.x)/margin;
    }

    if (u.y<-mlim.y) { 
        u2.y = lim.y + (u.y+lim.y);
        k.y = 1.0 - (-mlim.y - u.y)/margin;
    }
    else if (u.y>mlim.y) {
        u2.y = -1.0 + (u.y-mlim.y);
        k.y = 1.0 - (u.y - mlim.y)/margin;
    }
    
    if (k.x!=1.0 || k.y!=1.0) {
        return mix(
            mix(__source__(vec2(u2.x, u2.y)), __source__(vec2(u.x, u2.y)), k.x), 
            mix(__source__(vec2(u2.x, u.y)), __source__(u), k.x),
            k.y
        );
    }
    else {            
        return __source__(u);
    }
}
