vec4 emboss(vec2 pos, vec2 outPos, float intensity, float balance, float delta, float angle) {
    vec2 step = vec2(delta/2., 0.);

    vec2 uv = pos;
    vec2 grad = vec2(
        luma(__source__(uv+step).rgb) - luma(__source__(uv-step).rgb) ,
        luma(__source__(uv+step.yx).rgb) - luma(__source__(uv-step.yx).rgb) ) / delta;
    
    float diff = dot(grad, rotation2(angle)*vec2(0., 1.0));
    float absDiff = abs(diff);
    float k = 1.0 + mix(diff, absDiff, balance) * intensity * 0.2;
    vec4 col = __source__(pos);
    return vec4(col.rgb*k, col.a);
}
