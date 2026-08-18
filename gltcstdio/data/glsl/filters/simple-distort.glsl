vec4 whirl(vec2 pos, vec2 outPos) {
    vec2 u = pos;

    float d = length(u);

    if (d>=1.0) {
        return __source__(pos);
    }
    else {                
        float dangle = 10. * (1.0-cos(d*2.0*PI));
        float ca = cos(dangle);
        float sa = sin(dangle);
        vec2 coord = vec2(ca*u.x - sa*u.y, ca*u.y + sa*u.x);
        vec4 col = __source__(coord);
        
        return col;
    }
}
