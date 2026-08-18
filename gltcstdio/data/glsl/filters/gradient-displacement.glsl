vec4 gradientDisplacement(vec2 pos, vec2 outPos, int displacement_specified, float intensity, float delta, float angle, mat3 modelTransform) {
    vec2 step = vec2(delta/2., 0.);

    vec2 uv = tf(inverse(modelTransform), pos);
    vec2 grad = displacement_specified==1 ? vec2(
        luma(__displacement__(uv+step).rgb) - luma(__displacement__(uv-step).rgb) ,
        luma(__displacement__(uv+step.yx).rgb) - luma(__displacement__(uv-step.yx).rgb) ) / delta
        : vec2(
        luma(__source1__(uv+step).rgb) - luma(__source1__(uv-step).rgb) ,
        luma(__source1__(uv+step.yx).rgb) - luma(__source1__(uv-step.yx).rgb) ) / delta;
    
    //float l = length(grad);
    mat2 rot = rotation2(angle);
    vec2 disp = (rot*grad) * intensity*0.01;
    return __source1__(pos+disp);
}
