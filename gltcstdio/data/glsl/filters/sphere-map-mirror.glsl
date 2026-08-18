vec4 sphereMapMirror(vec2 pos, vec2 outPos, int countX, int countY, mat4 model3DTransform) {
    vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
    mat4 inv = inverse(model3DTransform);
    dir = mat3(inv[0].xyz, inv[1].xyz, inv[2].xyz) * dir;
    vec2 longLat = projEquirectangular(dir);
    vec2 u = vec2(-longLat.x/PI*0.5*float(countX), 0.5+longLat.y*float(countY)/PI);
    return __source__(u);
}
