vec4 perlinNoise(vec2 pos, vec2 outPos, mat3 viewTransform, int octaves, vec4 color1, vec4 color2, float contrast) {
    vec2 uv = pos;
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
    
    float k = 1.;
    float x = 0.;
    float total = 0.0;
    
    for(int i=0; i<octaves; ++i) {
        x += k * perlinNoise(uv);
        total += k;
        k *= 0.5;
        uv = transform * uv;
    }
    
    x /= total;
    vec4 col = mix(color1, color2, x);
    if (contrast != 0.) {
        float c = abs(contrast)>1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast;
        col.rgb = (col.rgb - 0.5) * c + 0.5;
    }
    return col;
}
