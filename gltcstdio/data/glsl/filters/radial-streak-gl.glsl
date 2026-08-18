vec4 radialStreak(vec2 uv, vec2 outPos, float intensity, int count, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = (inverseModelTransform * vec3(uv, 1.0)).xy;
    
    float d = length(u);

    if (d == 0.0) return __source__(uv);

    float ang = acos(u.x/d);
    if (u.y < 0.0) ang = PI2 - ang;

    ang -= (PI/2.0);

    float sector = PI2/float(count);
    float streakAngle = intensity*sector;
    float mang = mod(ang, sector);
    float n = floor(ang/sector);
    float sang;
    if (abs(mang-sector/2.0)>(sector-streakAngle)/2.0) {
        sang = PI_2 + (mang<=sector/2.0 ? n : n+1.0)*sector;
    }
    else {
        float angleCompression = 1.0 - intensity;
        sang = PI_2 + n*sector + sector/2.0 + (mang-sector/2.0)/angleCompression;
    }
    vec2 uv2 = (modelTransform * vec3(d*cos(sang), d*sin(sang), 1.0)).xy;
    return __source__(uv2);
}
