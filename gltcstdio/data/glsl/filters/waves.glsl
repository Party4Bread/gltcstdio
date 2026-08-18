vec4 waves(vec2 uv, vec2 outPos, float intensity, float dampening, float lighting, float variability, mat3 modelTransform) {
    //float intensity = dot(modelTransform[2].xy, mat2(modelTransform)*vec2(0., 1.)) / length(modelTransform[0].xy);

    vec2 v = tf(inverse(modelTransform), uv);
    float d = dampening==0.0 ? 1.0 : smoothstep(5.0/dampening, 0.5/dampening, abs(v.x));

    // Per-wave amplitude variability: segment v.x by half-cosine periods (PI),
    // offset by PI/2 so segment boundaries land on cosine zeros — that way
    // the magnitude jump between segments happens where cos is 0 and is
    // therefore invisible. Same structure as PAP/MirrorLab's wave shader.
    float xx = (v.x - 1.5707963) / 3.14159265;
    float i = floor(xx);
    float di = xx - i;
    float r0 = rand2(vec2(i, i)).x;
    float rNeighbor;
    if (di < 0.5) {
        rNeighbor = rand2(vec2(i - 1.0, i - 1.0)).x;
        di = 0.5 - di;
    } else {
        rNeighbor = rand2(vec2(i + 1.0, i + 1.0)).x;
        di = di - 0.5;
    }
    float vary = mix(r0, rNeighbor, di * di * 2.0);
    float magnitude = intensity * (1.0 + variability * (vary - 0.5) * 2.0);

    vec2 w = vec2(v.x, v.y + magnitude * cos(v.x) * d);
    vec2 u = tf(modelTransform,  w);

    vec4 outCol = __source__(u);

    if (lighting>0.0) {
        float offset = magnitude * cos(v.x) * d;
        vec2 grad = vec2(dFdx(offset)/dFdx(uv.x), dFdy(offset)/dFdy(uv.y)) ;
        float light = 1. + lighting * dot(grad, (mat2(modelTransform) * vec2(1., 0.)));
        outCol.rgb *= light;
    }

    return outCol;
}
