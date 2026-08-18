float iridizeGetChannel(int select, vec4 rgb, vec4 hsl) {
    if (select==0) return rgb.r;
    else if (select==1) return rgb.g;
    else if (select==2) return rgb.b;
    else if (select==3) return hsl.r;
    else if (select==4) return hsl.g;
    else if (select==5) return hsl.b;
    else if (select==6) return 1.0-rgb.r;
    else if (select==7) return 1.0-rgb.g;
    else if (select==8) return 1.0-rgb.b;
    else if (select==9) return 1.0-hsl.r;
    else if (select==10) return 1.0-hsl.g;
    else return 1.0-hsl.b;
}

vec4 iridizeSwap(vec4 rgb, float mode) {
    float coding = floor(mode);
    bool toHsl = coding >= 1728.0;
    if (toHsl) coding = mod(coding, 1728.0);
    vec4 hsl = rgbToHsl(rgb);
    hsl.r /= 360.0;
    int rChannel = int(mod(coding, 12.0));
    int gChannel = int(mod(coding/12.0, 12.0));
    int bChannel = int(mod(coding/144.0, 12.0));
    vec4 color = vec4(
        iridizeGetChannel(rChannel, rgb, hsl) * (toHsl ? 360.0 : 1.0),
        iridizeGetChannel(gChannel, rgb, hsl),
        iridizeGetChannel(bChannel, rgb, hsl),
        rgb.a );
    return toHsl ? hslToRgb(color) : color;
}

vec4 iridizeModesGL(vec2 pos, vec2 outPos, int source2_specified, float intensity, float balance, float mode, float mode2, float backgroundOnly) {
    vec4 rgb = __source__(pos);
    vec4 mapRgb = source2_specified==0 ? rgb : __source2__(pos);
    if (mode >= 0.0) { rgb = iridizeSwap(rgb, mode); mapRgb = iridizeSwap(mapRgb, mode); }

    // Pap's locus background = the mode-swapped source (mix(rgb, outCol, locus)).
    // When used as LocusBlend's `source`, emit exactly that and skip the rest.
    if (backgroundOnly >= 0.5) return rgb;

    vec4 hsl = rgbToHsl(rgb);
    vec4 mapHsl = rgbToHsl(mapRgb);

    float saturation = mapHsl.g;
    float satBal = 0.5-balance*0.5;
    hsl.g = saturation * smoothstep(0.0, 1.0, (saturation-satBal)*4.0+0.5);

    hsl.r = mapHsl.r * (1.0 + saturation*intensity*40.);

    vec4 outCol = hslToRgb(hsl);
    if (mode2 >= 0.0) { outCol = iridizeSwap(outCol, mode2); }
    return outCol;
}
