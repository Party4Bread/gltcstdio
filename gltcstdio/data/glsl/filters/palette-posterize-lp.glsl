vec4 palettePosterize(vec2 pos, vec2 outPos, vec4[64] palette) {
    vec4 color = __source__(pos);
    int bestIndex = 0;
    float bestDistance = 1e9;
    for(int i=0; i<palette.length(); ++i) {
        float distance = colorDistance(color.rgb, palette[i].rgb);
        if (distance < bestDistance) {
            bestDistance = distance;
            bestIndex = i;
        }
    }
    return palette[bestIndex];
}
