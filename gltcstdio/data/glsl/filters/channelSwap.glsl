float getChannelTest(vec4 color, int channel) {
        if (channel==0) return color.r;
        else if (channel==1) return color.g;
        else if (channel==2) return color.b;
//        else if (channel==3) return color.r;
//        else if (channel==4) return color.g;
//        else if (channel==5) return color.b;
        else if (channel==3) return rgbToHsl(color).r / 360.0;
        else if (channel==4) return rgbToHsl(color).y;
        else if (channel==5) return rgbToHsl(color).z;
        else if (channel==6) return rgbToHsluv(color.rgb).x / 360.0;
        else if (channel==7) return rgbToHsluv(color.rgb).y * 0.01;
        else if (channel==8) return rgbToHsluv(color.rgb).z * 0.01;
        else return 0.0;
    }

vec4 channelSwap(vec2 pos, vec2 outPos, float intensity, int channels_red, int channels_green, int channels_blue, int channels_hue, int channels_saturation, int channels_luminance) {
    vec4 col = __source__(pos);
    col.rgb = vec3(getChannelTest(col, channels_red), getChannelTest(col, channels_green), getChannelTest(col, channels_blue));
    vec4 hsl = rgbToHsl(col);
    hsl.xyz = vec3(getChannelTest(col, channels_hue)*360.0, getChannelTest(col, channels_saturation), getChannelTest(col, channels_luminance));
    return mix(col, hslToRgb(hsl), intensity);
}
