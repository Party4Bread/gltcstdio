vec4 palettePosterizeFromImage(vec2 pos, vec2 outPos, vec2 paletteDim) {
    vec4 color = __source__(pos);
    int bestIndex = 0;
    float bestDistance = 1e9;
    vec4 bestColor = color;
    
    int n = int(paletteDim.x);
    
    for(int i=0; i<n; ++i) {
        vec4 pCol = __palette__texelFetch__(ivec2(i, 0));
        float distance = colorDistance(color.rgb, pCol.rgb);
        if (distance < bestDistance) {
            bestDistance = distance;
            bestIndex = i;
            bestColor = pCol;
        }
    }
    return bestColor;
}
