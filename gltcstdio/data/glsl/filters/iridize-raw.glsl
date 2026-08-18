vec4 iridize(vec2 pos, vec2 outPos, int source2_specified, float intensity, float balance) {
    vec4 rgb = __source__(pos);
    vec4 mapRgb = source2_specified==0 ? rgb : __source2__(pos);

    vec4 hsl = rgbToHsl(rgb);
    vec4 mapHsl = rgbToHsl(mapRgb);

    float saturation = mapHsl.g;
    float satBal = 0.5-balance*0.5;
    hsl.g = saturation * smoothstep(0.0, 1.0, (saturation-satBal)*4.0+0.5);

    hsl.r = mapHsl.r * (1.0 + saturation*intensity*40.);

    vec4 outCol = hslToRgb(hsl);
    return outCol;
}
