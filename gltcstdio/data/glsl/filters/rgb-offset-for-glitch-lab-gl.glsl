// Pap GLSL: getOffsetPos from glitch_rgb_channel_offset.glsl.
// pap2mp's mat3 is the forward (user-facing) transform, so we invert in-shader
// — matches the bank's RGBOffset convention. Scale fixed at 1.0 (the original
// has no scale param).
vec2 rgbOffsetGlitchLabGetOffsetPos(mat3 transform, vec2 pos, float vignetting) {
    vec2 tPos = (inverse(transform) * vec3(pos, 1.0)).xy;
    float dist = length(pos);
    if (dist < 1.0) {
        tPos = mix(pos, tPos, 1.0 - vignetting * (1.0 - dist * dist));
    }
    return tPos;
}

vec4 rgbOffsetForGlitchLabGl(vec2 pos, vec2 outPos, float vignetting, mat3 redTransform, mat3 greenTransform, mat3 blueTransform) {
    vec4 red   = __source__(rgbOffsetGlitchLabGetOffsetPos(redTransform,   pos, vignetting));
    vec4 green = __source__(rgbOffsetGlitchLabGetOffsetPos(greenTransform, pos, vignetting));
    vec4 blue  = __source__(rgbOffsetGlitchLabGetOffsetPos(blueTransform,  pos, vignetting));
    return vec4(red.r, green.g, blue.b, (red.a + green.a + blue.a) / 3.0);
}
