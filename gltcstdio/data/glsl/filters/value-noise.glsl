vec4 valueNoise(vec2 pos, vec2 outPos, mat3 viewTransform, int octaves, vec4 color1, vec4 color2, float contrast) {
    float x = fractalValueNoise(pos, octaves, 1.0);
//    float x = abs(sin(pos.x*pos.y*1.));
    vec4 col = mix(color1, color2, x);
    if (contrast != 0.) {
        float c = abs(contrast)>1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast;
        col.rgb = (col.rgb - 0.5) * c + 0.5;
    }
    return col;
}
