vec4 hueGrad(vec2 uv, vec2 outPos, float delta, float power) {
    vec2 step = vec2(delta/2., 0.);
    
    vec2 grad = vec2(
        luma(__source__(uv+step).rgb) - luma(__source__(uv-step).rgb) ,
        luma(__source__(uv+step.yx).rgb) - luma(__source__(uv-step.yx).rgb) ) / delta;
    
    float l = length(grad);            
    float angle = atan(grad.y, grad.x);
    vec4 hsluv = vec4((angle+PI)*180.0, 100., 10.0*pow(l, power), 1.);
     
    return hsluvToRgb4(hsluv);
}
