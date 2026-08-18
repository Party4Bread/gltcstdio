vec4 pixelate(vec2 uv, vec2 outPos, mat3 modelTransform, float dithering, vec2 paletteDim, vec2 ditheringPatternDim, float pixelAspectRatio) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    vec2 pixDim = pixelAspectRatio>=1.0 ? vec2(pixelAspectRatio, 1.0) : vec2(1.0, 1.0/pixelAspectRatio);
    vec2 iPos = round(u/pixDim);
    vec2 pix = iPos * pixDim; //floor(u+0.5);
    vec2 v = (modelTransform * vec3(pix.xy, 1.0)).xy;
    vec4 col = __source__(v);
    
    // dithering
    if (dithering!=0.0) {
        ivec2 dPos = ivec2(int(mod(iPos.x, ditheringPatternDim.x)), int(mod(iPos.y, ditheringPatternDim.y)));
        vec4 patternCol = __ditheringPattern__texelFetch__(dPos);
        col.rgb += dithering * (patternCol.rgb - .5);
    }
    
    int n = int(paletteDim.x);
    float minDist = 1e9;
    vec4 bestColor = col;

    for(int i=0; i<n; ++i) {
        vec4 target = __palette__texelFetch__(ivec2(i, 0));

        float dist = length((col-target).rgb);
        if (dist < minDist) {
            minDist = dist;
            bestColor = target;
        }
    }
    
    return bestColor;

}
