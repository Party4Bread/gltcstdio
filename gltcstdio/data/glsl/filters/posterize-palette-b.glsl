vec4 posterizePalette(vec2 pos, vec2 outPos, vec2 paletteDim, float intensity, float saturation, float brightness, float hue) {
    vec4 col = adjustColor(__source__(pos), brightness, 1.0, 0.0, 0.0, saturation, hue, vec4(0.0));
                
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

    return mix(col, bestColor, intensity);
}
