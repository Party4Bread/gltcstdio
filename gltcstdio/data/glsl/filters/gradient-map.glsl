vec4 gradientMap(vec2 pos, vec2 outPos, vec2 gradientDim, float intensity, int mode) {
    vec4 inc = __source__(pos);           
    float lum = luma(inc.rgb);
    float ratio = gradientDim.x / gradientDim.y;
    float x = mode==0 ? ratio * (1.-1./gradientDim.x): ratio;
    vec4 gradCol = __gradient__(vec2(mix(-x, x, lum), 0.));
    return mix(inc, gradCol, intensity);
}
