vec4 squareLand(vec2 uv, vec2 outPos, int source_specified, int iterations, float coverage, vec4 color, vec4 colorBkg) {
    
    vec2 id = floor(uv);    
    vec4 col = colorBkg;
    float X = mod(id.y, 64.0);
    if (X<16.) col = vec4(vec3(mix(0.1, mod(id.x+id.y, 2.0), X*0.1)), 1.);

    float levels = 2. * pow(2., float(iterations));
    uv = uv / levels;
    for(int i=0; i<iterations; ++i) {
        id = floor(uv);
        vec2 rnd = hash22(id);
        //float rndA = hash21(id);
        float d = max2(abs(fract(uv)-0.5));
        //if (rndA<0.01) d = 0.5-length(fract(uv)-0.5);
        float d1 = round(rnd.x*levels)/(levels*2.);
        float d2 = rnd.y*.5;

        if (hash21(id)<coverage && d>max(1./levels, d1)) {
            col = vec4(fract(rnd.x*10.), rnd.y, fract(rnd.y*10.), 1.);
            col = mix(col, round(col), 0.5);
            col = mergeColor(col, color);
        }
        uv = uv * 2.;
        levels /= 2.;
    }
        
    if (source_specified==1) return mergeColor(__source__(outPos), col);
    else return col;

}
