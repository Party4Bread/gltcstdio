vec4 squareNoise(vec2 uv, vec2 outPos, float depth, int count, float coverage, float variability, float randomSeed, float colorScheme, mat3 modelTransform) {
    vec4 col = __source__(uv);
                
    float baseScale = 10.0;
    int N = count;
    float noiseSize = coverage*0.5;
    
    mat3 invModelTransform = inverse(modelTransform);
    
    for(int i=0; i<N; ++i) {
        float s = N<=1 ? 1.0 : pow(depth, 1.0-2.0*float(i)/float(N-1));
        vec2 u = (invModelTransform * (mat3(s, 0.0, 0.0, 0.0, s, 0.0, 0.0, 0.0, 1.0)) * vec3(uv, 1.0)).xy;
        vec2 id = round(u);
        vec2 v = u-id;
        vec2 rnd = rand2relSeeded(id+float(i)*vec2(4.43, -5.434), randomSeed);
        if (abs(rnd.x-rnd.y)>1.0 - 0.75*variability) rnd = rand2relSeeded(floor(id*0.25)+float(i)*vec2(4.43, -5.434), randomSeed);
        if (abs(rnd.x-rnd.y)>1.0 - 0.75*variability) rnd = rand2relSeeded(floor(id*0.0625)+float(i)*vec2(4.43, -5.434), randomSeed);
        
        bool hide = fract(rnd.x*10.0)>1.0 - 0.5*variability;
        
        if (fract(rnd.x*20.)>1.0 - 0.25*variability) v = abs(v-.12);
        
        vec2 center = variability < 0.01 ? v : v + sign(rnd) * vec2(pow(rnd.x, 1./variability), pow(rnd.y, 1./variability));
        float nSize = noiseSize * pow(4.0, variability * (fract(rnd.y*10.)-.5));
        if (!hide && abs(center.x)<nSize && abs(center.y)<nSize) {
            float k = colorScheme*5.;
            vec4 col1, col2;         
            float rc = fract(rnd.y*10.0+.33);
            if (colorScheme<0.2) {
                col = rc>=k ? vec4(0., 0., 0., 1.) : vec4(1., 1., 1., 1.);
            }
            else if (colorScheme<0.4) {
                k -= 1.;
                col = rc>=k ? vec4(1., 1., 1., 1.) : __source__(u);
            }
            else if (colorScheme<0.6) {
                k -= 2.;
                col = rc>=k ? __source__(u) : __source__(id * 0.731344);
            }
            else if (colorScheme<0.8) {
                k -= 3.;
                col = rc>=k ? __source__(id * 0.731344) : vec4(0., 0., 0., 1.);
            }
            else {
                k -= 4.;
                col = rc>=k ? vec4(0., 0., 0., 1.) : vec4(1., 1., 1., 1.);
            }
        }      
    }
    
    return col;
}
