vec4 cubeMapGl(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim) {
    vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
    mat4 inv = inverse(model3DTransform);
    dir = mat3(inv[0].xyz, inv[1].xyz, inv[2].xyz) * dir;
    float ratio = sourceDim.y / sourceDim.x;
    float X = 0.5;
    float Y = 0.5;
    if (abs(dir.y) > abs(dir.z) * ratio && abs(dir.y) > abs(dir.x) * ratio) {
        X += -dir.x / dir.y * 0.5;
        Y += -dir.z / dir.y * 0.5;
    }
    else if (abs(dir.x) < abs(dir.z)) {
        X += dir.x / abs(dir.z) * ratio * 0.5 * -sign(dir.z);
        Y += dir.y / abs(dir.z) * 0.5;
    }
    else {
        X += dir.z / abs(dir.x) * ratio * 0.5 * -sign(dir.x);
        Y += dir.y / abs(dir.x) * 0.5;
    }
    return __source__(vec2(X, Y));
}
