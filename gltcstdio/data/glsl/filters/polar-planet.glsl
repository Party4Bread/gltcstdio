vec4 polarPlanet(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float dampening, float blend, int mirrorMode, mat3 texTransform) {
    vec2 u = uv;
    mat3 inverseTexTransform = inverse(texTransform);

    float d = length(u);

    float angle = atan(u.y, u.x);

    float phase = 0.0;

    if (mirrorMode==1) {
        angle = 2.0*(angle + phase);
        angle = mod(angle, PI4);
        if (angle > PI2) { angle = PI4-angle; }
    }
    else {
        angle = angle + phase;
        angle = mod(angle, PI2);
    }

    float blendedWidth = sourceDim.x * (1.0-blend*0.5);
    float fullRatio = sourceDim.x / sourceDim.y;
    float blendedRatio = blendedWidth / sourceDim.y;
    float xp = angle/PI - 1.0;
    float sx = blendedRatio * xp;

    float I = intensity;
    float sy = d <= I
        ? 1.0 - d*2.0
        : I < 1.0
            ? 1.0 - (2.0*I + ((2.0-2.0*I)/log(2.0-I)) * log(1.0+d-I))
            : 1.0 - (2.0 + 2.0*log(d));

    float xpp = xp/fullRatio*blendedRatio;
    float blendStart = 1.0-blend;
    if (abs(xpp) <= blendStart) {
        vec2 pos = vec2(sx, sy);
        return __source__(tf(inverseTexTransform, pos));
    }
    else {
        float k = (abs(xpp)-blendStart) / blend;
        vec2 pos1 = vec2(sx, sy);
        float sx2 = xp>=0.0 ? sx - blendedRatio*2.0 : sx + blendedRatio*2.0;
        vec2 pos2 = vec2(sx2, sy);
        return mix(__source__(tf(inverseTexTransform, pos1)), __source__(tf(inverseTexTransform, pos2)), k);
    }
}
