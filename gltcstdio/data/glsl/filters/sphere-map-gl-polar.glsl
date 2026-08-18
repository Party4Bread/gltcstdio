vec4 sphereMapGlPolar(vec2 pos, vec2 outPos, vec2 sourceDim, int count, mat4 model3DTransform) {
    vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
    mat4 inv = inverse(model3DTransform);
    dir = mat3(inv[0].xyz, inv[1].xyz, inv[2].xyz) * dir;
    vec2 longLat = projEquirectangular(dir);  // (atan(dir.z, dir.x), asin(dir.y))
    float nX = float(count) * 2.0;
    float nY = float(count);
    vec2 u = vec2(-longLat.x / PI * 0.5 * nX, 0.5 + longLat.y * nY / PI);

    // mirror-wrap both axes into [0,1] (triangle wave, period 2 = GL_MIRRORED_REPEAT)
    vec2 w = abs(u);
    w = w - 2.0 * floor(w * 0.5);
    w = mix(w, 2.0 - w, step(1.0, w));

    // map each cell's [0,1] coord to the full source (centered V2 space)
    float ratio = sourceDim.x / sourceDim.y;
    vec2 srcPos = vec2((w.x - 0.5) * 2.0 * ratio, (w.y - 0.5) * 2.0);
    return __source__(srcPos);
}
