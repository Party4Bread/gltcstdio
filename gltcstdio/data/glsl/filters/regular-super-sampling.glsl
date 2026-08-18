vec4 stochasticSuperSampling(vec2 uv, vec2 outPos, float radius, int count, vec2 sourceDim, vec2 outDim) {
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    float totalW = 0.0;
    float pixelSize = 2.0/outDim.y;
    float N = float(count);
    float cellSize = pixelSize/N * radius;
    vec2 start = vec2(-(cellSize * (N-1.0)) * 0.5);

    for(int j=0; j<count; ++j) {            
        for(int i=0; i<count; ++i) {
            vec2 delta = start + cellSize * vec2(float(i), float(j));
            vec4 col = __source__(uv + delta);
            totalColor += col*col;
            totalW += 1.0;
        }
    }

    vec4 avgColor = sqrt(totalColor / totalW); 

    return avgColor;
}
