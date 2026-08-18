vec4 bentRowsIllusion(vec2 uv, vec2 outPos, int source_specified, int count, float offset, float thickness, vec4 color1, vec4 color2, vec4 color3) {
    vec2 u = abs(fract(uv-0.5)-0.5);

    thickness *= 0.2;
    vec4 outColor;
    
    if (u.y<thickness) {
        outColor = color3;
    }
    else {
        float row = floor(uv.y);
        float N = float(count);
        float rowIndex = mod(row, 2.*N-2.);
        float offsetMul = count==1 ? 0.0 : rowIndex>=N ? 2.*N-2. - rowIndex : rowIndex;
        int k = int(floor(uv.x + offset*offsetMul));
        if (k%2==0) outColor =  color1; else outColor =  color2;
    }
    
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;

}
