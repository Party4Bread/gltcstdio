float getChannelLegacy(int select, vec4 rgb, vec4 hsl) {
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

vec4 channelSwapLegacy(vec2 pos, vec2 outPos, float intensity, int mode) {
    float coding = float(mode);
    bool toHsl = coding >= 1728.0;
    if (toHsl) coding = coding - 1728.0;

    vec4 rgb = __source__(pos);
    vec4 hsl = rgbToHsl(rgb);
    hsl.r /= 360.0;

    int rChannel = int(mod(coding, 12.0));
    int gChannel = int(mod(coding / 12.0, 12.0));
    int bChannel = int(mod(coding / 144.0, 12.0));

    vec4 color = vec4(
        getChannelLegacy(rChannel, rgb, hsl) * (toHsl ? 360.0 : 1.0),
        getChannelLegacy(gChannel, rgb, hsl),
        getChannelLegacy(bChannel, rgb, hsl),
        rgb.a);

    vec4 outCol = toHsl ? hslToRgb(color) : color;
    return mix(rgb, outCol, intensity);
}
