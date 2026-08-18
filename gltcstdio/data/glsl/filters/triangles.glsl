vec4 triangles(vec2 uv, vec2 outPos, vec4 color, int count, float randomSeed) {
    vec3 col = color.rgb;
    
    float size = 1.;
    float N = float(count);
    
    for(float i=0.; i<N; ++i) {
        vec2 offset = rand2relSeeded(vec2(i*10., i+2.221), randomSeed) - .5;
        vec2 u = (uv + 200.*offset)*.5;
        vec2 id = floor(u);
        vec2 center = id + 0.5;
        vec2 rnd = rand2relSeeded(id, randomSeed);
        vec2 rnd2 = rand2relSeeded(vec2(id.x*1.15, id.y*2.55), randomSeed);
        vec2 a = center + size*(rnd);
        vec2 b = center + size*(fract(rnd*10.) - 0.5);
        vec2 c = center + size*(rnd2);

        if (inTriangle(u, a, b, c)) {
            col = 0.5+vec3(rnd, rnd2.x);
        }
    }

    return vec4(col, 1.);
}
