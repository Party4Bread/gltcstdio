vec4 spiral(vec2 uv, vec2 outPos, vec2 sourceDim, int count, float intensity, mat3 texTransform) {
    vec2 u = uv;

    float d = length(u);

    // Pap Spiral3GL hardcodes MIRROR=false and never exposes it (non-mirror branch only).
    float angle = atan(u.y, u.x);
    angle = mod(angle, PI2);

    float ratio = sourceDim.x/sourceDim.y;
    float scale360 = 1000.0/(intensity*intensity);
    float a = angle/PI2;
    float s = pow(scale360, a);
    vec2 w = vec2(
        (ratio<1.0?1.0:ratio)*angle/PI,
        (ratio<1.0?1.0/ratio:1.0) * log(d*s) / log(scale360));

    float fcount = float(count);
    vec2 coord = vec2(
        4.0*fcount*w.x,
        2.0*mod(w.y*fcount, (ratio<1.0?1.0/ratio:1.0) * fcount)-(ratio<1.0?1.0/ratio:1.0) *1.0);

    return __source__(tf(inverse(texTransform), coord));
}
