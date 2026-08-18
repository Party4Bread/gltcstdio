vec4 hueStripes(vec2 uv, vec2 outPos, float intensity, int spikeCount, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    float scale = length(invModelTransform[0].xy);
    vec2 tr = tf(invModelTransform, vec2(0.0, 0.0));
    vec4 inCol = __source__(uv);
    vec4 hsl = rgbToHsl(inCol);
    float lum = hsl[2];
    float d = 0.5 * intensity;
    float lum1 = lum+d;
    float lum2 = lum-d;
    float s = float(spikeCount);
    float angle = floor(hsl[0]/360.0*s)*360.0/s * PI/180.0;
    hsl[2] = fract(scale * (cos(angle)*(uv.x+tr.x) + sin(angle)*(uv.y+tr.y))) > 0.5  ? lum2 : lum1;
    vec4 outCol = hslToRgb(hsl);
    return outCol;
}
