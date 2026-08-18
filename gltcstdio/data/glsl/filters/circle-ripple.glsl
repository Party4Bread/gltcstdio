vec4 circleRippleIllusion(vec2 uv, vec2 outPos, int source_specified, float squish, int count, vec4 colorIn, vec4 colorOut, vec4 colorTop, vec4 colorBottom) {
    uv.y /= squish;
    float iy = floor(uv.y);
    float y = fract(uv.y);
    float x = fract(uv.x + iy*0.5);
    vec2 u = vec2(x, y) - 0.5;
    
    float d = length(u);
    vec4 col;
    float radius = 0.45;
    if (d<radius) {
        if (d>radius*0.8) {
            bool up = ((int(iy)/count)%2 == 0) ^^ (u.y<0.0);
            col = up ? colorTop : colorBottom;
        }
        else {
            col = colorIn;
        }
    }
    else {        
        col = colorOut;
    }
    
    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}
