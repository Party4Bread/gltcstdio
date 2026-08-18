float response(float d, float glow) {
    float base = (glow<0.2) ? 1.0 : 1.0+(glow-0.2)*4.;
    return base * (d<=0.0 ? 1.0 : min(1.0, glow*0.01/d)) * smoothstep(2.0, 1.2, d);
}

vec4 barcode(vec2 uv, vec2 outPos, int count, float randomSeed, float len, float thickness, vec4 color, float glow, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);

    vec2 rnd = rand2relSeeded(vec2(10.0, 10.0), randomSeed);
    vec2 rnd2 = rand2relSeeded(vec2(11.0, -5.5), randomSeed);
    float code1 = floor((rnd2.x+0.5)*256.0 + (rnd.x+0.5)*65536.0);
    float code2 = floor((rnd2.y+0.5)*256.0 + (rnd.y+0.5)*65536.0);

    float k = 0.0;
    float N = float(count);
    float unit = thickness/(3.0*N);
    float code = code1;
    for(float i=0.0; i<N; ++i) {
        float width = mod(code, 2.0)+1.0;
        code = floor(code/2.0);
        if (code==0.0) code = code2;
        float d = sdRectangle(u-vec2((i/(N-1.0)-0.5)*len, 0.0), vec2(width*unit*0.5, 0.5));
        k += response(d, glow);
    }

    vec4 bkgCol = __source__(uv);
    // k overshoots 1 in the glow bloom; the excess is a brightness multiplier, min(1,k) is coverage.
    vec4 glowCol = spilloverChannels(vec4(color.rgb*max(1.0, k), color.a));
    vec4 outCol = mergeColor(bkgCol, vec4(glowCol.rgb, glowCol.a*min(1.0, k)));

    return outCol;
}
