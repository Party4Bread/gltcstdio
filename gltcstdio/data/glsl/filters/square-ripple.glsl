vec4 squareRippleIllusion(vec2 uv, vec2 outPos, int source_specified, int count, float thickness, vec4 color1, vec4 color2, vec4 color3, vec4 color4) {
    vec2 u = abs(fract(uv-0.5)-0.5);
    vec2 id = floor(uv-0.5);
    
    vec2 uv2 = uv;
    //vec2 u2 = fract(uv2);
    vec2 id2 = floor(uv2);
    
    float crossLen = mix(0.15, 0.5, thickness);
    thickness *= 0.2;
    
    if ((u.x<crossLen && u.y<thickness) || (u.y<crossLen && u.x<thickness)) {
        int k = int(id.x + id.y);
        bool invert = (k/count)%2 == 0;
        if (k%3==0 ^^ invert) return color3; else return color4;
    }
    else {
        int k = int(id2.x + id2.y);
        if (k%2==0) return color1; else return color2;
    }
}
