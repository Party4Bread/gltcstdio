vec4 pixelate(vec2 uv, vec2 outPos) {
    return __source__(uv);// * fract(uv.x*4.0) * fract(uv.y*4.0);
}
