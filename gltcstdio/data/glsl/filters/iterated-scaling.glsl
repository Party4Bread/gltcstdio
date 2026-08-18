vec4 iteratedScaling(vec2 pos, vec2 outPos, vec2 sourceDim, int iterations, float offset, mat3 texTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    vec2 u = pos / vec2(ratio, 1.0);
    u = vec2(mod(u.x+1.0, 2.0), mod(u.y+1.0, 2.0))-vec2(1.0, 1.0);

    float len = 3.0-pow(0.5, float(iterations)-1.0)*2.0;
    u *= len;

    vec2 indexes = floor(-log(3.0-abs(u))/log(2.0));
    float index = max(indexes.x, indexes.y);

    vec2 s = sign(u);
    u = abs(u);

    float shift = pow(0.5, index);
    u = vec2(2.0, 2.0) - vec2(shift) - u;
    u = vec2(1.0, 1.0) - u;
    u = vec2(mod(u.x, 1.0), mod(u.y, 1.0));
    if (index==-2.0) u *= s;
    else u =u*pow(2.0, index+2.0)*s-1.0;
    u *= vec2(ratio, 1.0);

    return __source__(tf(inverse(texTransform), u) + offset*pos);
}
