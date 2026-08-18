vec2 getPoint(float x, float y, float variability, float seed) {
    vec2 u = vec2(x, y);
    return u + variability * 4.0 * rand2relSeeded(u, seed);
}

vec4 squareSegments(vec2 uv, vec2 outPos, float variability, float randomSeed, int count, float step, float thickness, vec4 color, mat3 modelTransform, mat3 outerTransform, mat3 innerTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    vec2 a = vec2(0., 0.);
    vec2 b = a;
    float k = 0.0;
    float th = thickness / length(modelTransform[0].xy);
    
    vec2 o11 = tf(outerTransform, getPoint(-1.0, -1.0, variability, randomSeed));
    vec2 o21 = tf(outerTransform, getPoint(1.0, -1.0, variability, randomSeed));
    vec2 o12 = tf(outerTransform, getPoint(-1.0, 1.0, variability, randomSeed));
    vec2 o22 = tf(outerTransform, getPoint(1.0, 1.0, variability, randomSeed));
    
    vec2 i11 = tf(innerTransform, getPoint(-1.0, -1.0, variability, randomSeed));
    vec2 i21 = tf(innerTransform, getPoint(1.0, -1.0, variability, randomSeed));
    vec2 i12 = tf(innerTransform, getPoint(-1.0, 1.0, variability, randomSeed));
    vec2 i22 = tf(innerTransform, getPoint(1.0, 1.0, variability, randomSeed));
    
    for(int i=0; i<count; ++i) {
        float l = float(i)/float(count);
        
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o11, o21, l), mix(i11, i21, l))));
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o21, o22, l), mix(i21, i22, l))));
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o22, o12, l), mix(i22, i12, l))));
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o12, o11, l), mix(i12, i11, l))));
        if (k>=1.0) break;
        a = b;
    }
    vec4 inCol = __source__(uv);
    vec4 mergeCol = mergeColor(inCol, color);
    return mix(inCol, mergeCol, k);
}
