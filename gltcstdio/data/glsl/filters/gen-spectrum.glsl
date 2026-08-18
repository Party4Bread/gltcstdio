vec4 genSpectrum(vec2 uv, vec2 outPos, vec2 outDim, int mode, float luminosity, float saturation) {
    float ratio = outDim.x / outDim.y;
    float k = 360. * (uv.x+ratio) / (2.*ratio); 
    //float k = 360. * (uv.x+1.) / (2.); 
    return (mode==0) ? hslToRgb(vec4(k, saturation, luminosity, 1.0)) : hsluvToRgb4(vec4(k, saturation*100., luminosity*100., 1.0));
}
