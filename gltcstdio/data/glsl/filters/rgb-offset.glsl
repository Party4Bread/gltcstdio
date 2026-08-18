vec2 getOffsetPos(mat3 transform, vec2 pos, float scale, float dampening) {
    vec2 tPos = (inverse(transform)*vec3(pos, 1.0)).xy;
    tPos = pos + scale * (tPos-pos);
    float dist = length(pos);
    if (dist<1.0) {
        tPos = mix(pos, tPos, 1.0-dampening*(1.0-dist*dist));
    }
    return tPos;
}

vec4 rgbOffset(vec2 pos, vec2 outPos, float dampening, float scale, mat3 redTransform, mat3 greenTransform, mat3 blueTransform) {
    vec4 red = __source__(getOffsetPos(redTransform, pos, scale, dampening));
    vec4 green = __source__(getOffsetPos(greenTransform, pos, scale, dampening));
    vec4 blue = __source__(getOffsetPos(blueTransform, pos, scale, dampening));
    vec4 outColor =  vec4(red.r, green.g, blue.b, (red.a+green.a+blue.a)/3.0);
    return outColor;
}
