vec4 halftoneCombine(vec2 uv, vec2 outPos, float smoothen, float intensity, mat3 modelTransform, vec4 color1, vec4 color2) {
    float threshold = luma(__pattern__(tf(inverse(modelTransform), uv)).rgb);
    
    vec2 samplePos = uv;
    
    vec4 color = vec4(0.0);
    if (smoothen>0.0) {
        int N = 5;
        float r = length(modelTransform[0].xy) * smoothen * 3.0;
        float step = r/float(N);
        for(int j=-N; j<=N; ++j) {
            for(int i=-N; i<=N; ++i) {
                color += __source__(samplePos + vec2(float(i), float(j)) * step);
            }
        }
        color /= float((2*N+1)*(2*N+1));
    }
    else {
        color = __source__(samplePos);
    }
    
    float k = luma(color.rgb)>threshold ? 1.0 : 0.0;
    
    return mix(color2, color1, k);
}
