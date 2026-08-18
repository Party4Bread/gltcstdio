vec2 perspectiveFit(vec2 u, float persp) {
    if (persp < 10000.0) {
        float Z = 4.0;
        float z = Z*u.y / (-Z*persp - u.y);

        float maxZ = -Z / (Z*-persp + 1.0);
        float minZ = Z / (Z*-persp - 1.0);
        float maxX = (maxZ + Z) / Z;
        float minY = maxZ * -persp;
        float maxY = minZ * -persp;

        float dy = z * -persp;
        dy = (dy-minY)/(maxY-minY)*2.0-1.0;

        float dx = u.x * (z + Z) / Z;
        dx = dx/maxX;

        return vec2(dx, dy);
    }
    return u;
}

vec4 perspectiveFloorGl(vec2 pos, vec2 outPos, float perspective, float viewAngle) {
    // pos = perspectiveFit(outCoord); then the VIEW_ANGLE 2D in-plane roll (R applied after
    // the warp, matching Pap's `u_ViewTransform * perspectiveFit(v_OutCoordinate)`).
    vec2 q = perspectiveFit(pos, perspective);
    float c = cos(viewAngle);
    float s = sin(viewAngle);
    vec2 r = vec2(c*q.x - s*q.y, s*q.x + c*q.y);
    return __source__(r);
}
