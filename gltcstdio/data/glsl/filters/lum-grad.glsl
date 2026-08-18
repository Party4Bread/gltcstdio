vec4 lumGrad(vec2 uv, vec2 outPos, float delta, float mode, float intensity) {
    vec2 step = vec2(delta/2., 0.);
    
    vec2 grad = vec2(
        luma(__source__(uv+step).rgb) - luma(__source__(uv-step).rgb) ,
        luma(__source__(uv+step.yx).rgb) - luma(__source__(uv-step.yx).rgb) ) / delta;
    
    float l = length(grad);
    vec2 ngrad = grad / l;
    
    vec3 rgb = vec3(0.5 + 0.5*ngrad, l*intensity);
    float k = fract(mode);
    mode = mod(mode, 6.0);
    if (mode<=1.0) return vec4(mix(rgb, rgb.rbg, k), 1.);
    if (mode<=2.0) return vec4(mix(rgb.rbg, rgb.brg, k), 1.);
    if (mode<=3.0) return vec4(mix(rgb.brg, rgb.bgr, k), 1.);
    if (mode<=4.0) return vec4(mix(rgb.bgr, rgb.gbr, k), 1.);
    if (mode<=5.0) return vec4(mix(rgb.gbr, rgb.grb, k), 1.);
    else return vec4(mix(rgb.grb, rgb, k), 1.);
}
