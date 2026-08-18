vec4 channelMixBW(vec2 pos, vec2 outPos, float intensity, float red, float green, float blue, int normalize) {
    vec4 col = __source__(pos);
    
    float grey = (red*col.r + green*col.g + blue*col.b);
    if (normalize==0) {
        float sum = red+green+blue;
        if (sum==0.0) grey = 0.0; else grey /= sum;
    }
    else if (normalize==2) {
        grey /= 3.0;
    }

    return mix(col, vec4(grey, grey, grey, col.a), intensity);
}
