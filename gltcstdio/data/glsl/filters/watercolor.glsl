vec4 watercolor(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float delta, float balance) {
    float lum = luma(__source__(pos).rgb);
    float intensityModifier;
    if (abs(balance)>=1.0) intensityModifier = balance;
    else {
        float a = balance>=0. ? 0.0 : -balance;
        float b = balance>=0. ? 1.0-balance : 1.0; 
        intensityModifier = smoothstep(a, b, lum)*2. - 1.;
    }
    intensity *= intensityModifier;
    
    int N = int(abs(intensity)*500.0);
    float step = 0.001 * sign(intensity);

    vec4 total = __source__(pos);
    float d = delta*.1;
    vec4 cx0 = __source__(vec2(pos.x-d, pos.y));
    vec4 cx1 = __source__(vec2(pos.x+d, pos.y));
    vec4 cy0 = __source__(vec2(pos.x, pos.y-d));
    vec4 cy1 = __source__(vec2(pos.x, pos.y+d));
    vec2 grad = vec2((length(cx1)-length(cx0))/(2.0*d), (length(cy1)-length(cy0))/(2.0*d)); // gradient
    
    if (grad.x==0.0 && grad.y==0.0) return total;
    grad = normalize(grad);
    for(int i=0; i<N; ++i) {
        vec4 cx0 = __source__(vec2(pos.x-d, pos.y));
        vec4 cx1 = __source__(vec2(pos.x+d, pos.y));
        vec4 cy0 = __source__(vec2(pos.x, pos.y-d));
        vec4 cy1 = __source__(vec2(pos.x, pos.y+d));
        vec2 g1 = vec2((length(cx1)-length(cx0))/(2.0*d), (length(cy1)-length(cy0))/(2.0*d)); // gradient
        
        if (g1.x==0.0 && g1.y==0.0) return total/float(i+1);
        vec2 g2 = grad + 0.5*normalize(g1);
        if (g2.x==0.0 && g2.y==0.0) return total/float(i+1);
        grad = normalize(g2);
        pos += sign(delta) * step * grad;

        if (length(pos)>3.0) return vec4(1.0, 0.0, 0.0, 1.0);
        else if (length(pos)<0.0001) return vec4(0.0, 1.0, 0.0, 1.0);

//        pos += step * vec2(grad.y, grad.x);
        total += __source__(pos);
    }
    return total/float(N+1);
}
