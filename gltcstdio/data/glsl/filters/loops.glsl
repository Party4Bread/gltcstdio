vec4 layer(vec2 uv, vec4 col, int count, float offset, float thickness, float glow, float neon, float randomSeed, float variability, float colorVariability, vec4 color) {
    //vec4 col = vec4(0., 0., 0., 1.);
    
    float D = offset;
    float T = thickness*0.1;
    float MAXR = 1.5;
    vec4 hex = hexCoords(uv);
    vec2 id = floor(hex.zw*100.+.5);
    uv = hex.xy * 15.;
    vec2 relCenter = (rand2relSeeded(id, randomSeed)) * 6.;
    float radius = (MAXR-D) - 0.5*fract((relCenter.x+relCenter.y)*11.);
    for(int i=0; i<count; ++i) {
        float k = float(i);
        vec2 rnd = rand2relSeeded(id+k, randomSeed);
        vec2 c = relCenter + D * rnd;
        float d = abs(length(uv-c)-radius);
        float alpha = 0.;
        if (d<T) alpha = 1.;
        else if (glow>0.0) alpha = smoothstep(T*(10.*glow), T*(5.*glow), d) *  T/d * .75;
        
//        vec3 colLoop = mix(color, vec3(rnd+.5, fract(rnd.x*4.434+rnd.y*7.565)), colorVariability);
        vec3 colLoop = color.rgb + vec3(rnd, fract(rnd.x*4.434+rnd.y*7.565)-.5)*colorVariability;
        if (alpha>0.) col = mergeColor(col, vec4(colLoop+neon, alpha));
    }
    return col;
}

vec4 loops(vec2 uv, vec2 outPos, int count, int layerCount, mat3 modelTransform, vec4 color, float colorVariability, float glow, float neon, float thickness, float offset, float randomSeed, float variability, int source_specified) {
    mat3 inverseModelTransform = inverse(modelTransform);
        
    vec4 bkg = vec4(0., 0., 0., 1.);
    if (source_specified==1) {
        bkg = __source__(outPos);
    }
    vec4 col = bkg;
    
    for(int i=0; i<layerCount; ++i) {        
        col = layer(uv, col, count, offset, thickness, glow, neon, randomSeed, variability, colorVariability, color);
        uv = tf(inverseModelTransform, uv);
    }
    
    return col;
}
