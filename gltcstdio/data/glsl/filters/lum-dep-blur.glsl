vec4 lumDepBlur(vec2 uv, vec2 outPos, float radius, float power, float hardness, vec2 sourceDim, mat3 modelTransform) {
    float pixel = 2.0 / sourceDim.y;
    
    float lum = pow(luma(__source__(uv).rgb), pow(1.1, power));    
    float k = lum;//abs(0.5-lum)*2.;
    radius = radius * k;
    vec4 total = vec4(0.);
    
    total *= total;
    float div = 0.0;
    int N = int(ceil(radius/pixel));
    float step = pixel;
    float gInv = 1.0;
    for(int j=-N; j<=N; ++j) {
        for(int i=-N; i<=N; ++i) {
            vec2 delta = pixel*vec2(float(i), float(j));
            vec4 col = __source__(uv + delta);
            total += col*col;
            div += 1.;
        }
    }
    return sqrt(total/div);
}
