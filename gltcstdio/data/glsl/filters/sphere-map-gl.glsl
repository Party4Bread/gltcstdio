vec4 sphereMapGl(vec2 pos, vec2 outPos, vec2 sourceDim, mat4 model3DTransform) {
    vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
    mat4 inv = inverse(model3DTransform);
    dir = mat3(inv[0].xyz, inv[1].xyz, inv[2].xyz) * dir;
    vec2 longLat = projEquirectangular(dir);
    float nX = 2.0;
    float nY = 1.0;
    vec2 u = vec2(-longLat.x / PI * 0.5 * nX, 0.5 + longLat.y * nY / PI);

    // mirror-wrap longitude into [0,1] (source on one hemisphere, mirror on the other)
    float xa = abs(u.x);
    xa = xa - 2.0 * floor(xa * 0.5);
    float x = (xa > 1.0) ? (2.0 - xa) : xa;
    float y = clamp(u.y, 0.0, 1.0);

    // map hemisphere coord (x,y) in [0,1]^2 to the full source (centered V2 space)
    float ratio = sourceDim.x / sourceDim.y;
    vec2 srcPos = vec2((x - 0.5) * 2.0 * ratio, (y - 0.5) * 2.0);
    return __source__(srcPos);
}
