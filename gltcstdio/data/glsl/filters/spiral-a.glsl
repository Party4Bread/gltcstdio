vec4 spiralA(vec2 uv, vec2 outPos, vec2 sourceDim, int count, float intensity, mat3 texTransform) {
    vec2 u = uv;

    float d = length(u);

    float p = intensity > 0.0 ? 1.0/(1.0+intensity*0.1) : 1.0+pow(-intensity, 0.75);

    // Pap Spiral1GL hardcodes MIRROR=false and never exposes it, so only the non-mirror
    // branch (angle = mod(angle + phase, 2PI), phase=texX=0) is reachable.
    float angle = atan(u.y, u.x);
    angle = mod(angle, PI2);

    float widthAngle = PI/4.0;

    float ratio = sourceDim.x/sourceDim.y;
    float theta = log(1.0 + d)/p;
    float lambda = float(count) * mod(angle + theta, PI2);
    theta = mod(theta, 2.0*widthAngle);

    float sx = 2.0 * theta/widthAngle * ratio;
    float sy = 2.0 * lambda/PI2;

    vec2 coord = vec2(sx, sy);
    return __source__(tf(inverse(texTransform), coord));
}
