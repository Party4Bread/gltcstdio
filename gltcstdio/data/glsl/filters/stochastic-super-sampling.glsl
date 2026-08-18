vec4 stochasticSuperSampling(vec2 uv, vec2 outPos, float radius, int count, vec2 sourceDim, vec2 outDim) {
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    float totalW = 0.0;
    float pixelSize = 2.0/outDim.y;
    float d = pixelSize * radius;
    vec2 outPixelCoord = (uv + vec2(outDim.x/outDim.y, 1.0)) / pixelSize;
    
    for(int i=0; i<count; ++i) {
        vec2 delta = (hash32(vec3(uv*100., float(i))) - .5) * d; 
        vec4 col = __source__(uv + delta);
        totalColor += col*col;
        totalW += 1.0;
    }

    vec4 avgColor = sqrt(totalColor / totalW); 

    return avgColor;
}
