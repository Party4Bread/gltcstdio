vec4 channelMultiplier(vec2 pos, vec2 outPos, float intensity, int style, float channels_red, float channels_green, float channels_blue, float channels_hue, float channels_saturation, float channels_luminance) {
    int mode = style;
    vec4 col = __source__(pos);
    vec4 inCol = col;
    
    col.rgb *= vec3(channels_red, channels_green, channels_blue);
    
    if (mode==0) {
        col.rgb = fract(col.rgb);          
    }
    else if (mode==1) {
        col.rgb = 1.0 - abs(fract(col.rgb*0.5)*2.0-1.0);
    } 
    else {
        col.rgb = clamp(col.rgb, 0.0, 1.0);
    }

    vec4 hsl = rgbToHsl(col);
    hsl.xyz *= vec3(channels_hue, channels_saturation, channels_luminance);
    if (mode==0) {
        hsl.x = mod(hsl.x, 360.0); 
        hsl.yz = fract(hsl.yz);          
    }
    else if (mode==1) {
        hsl.x = mod(hsl.x, 360.0); 
        hsl.yz = 1.0 - abs(fract(hsl.yz*0.5)*2.0-1.0);
    } 
    else {
        hsl.x = mod(hsl.x, 360.0); 
        hsl.yz = clamp(hsl.yz, 0.0, 1.0);
    }
    
    vec4 rgb = hslToRgb(hsl);
    return mix(inCol, rgb, intensity);
}
