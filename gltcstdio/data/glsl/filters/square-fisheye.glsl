vec4 fisheye(vec2 uv, vec2 outPos, float intensity, vec4 highFreqColor) {
    float a = atan(uv.y, uv.x);
    float d = tan(max(abs(uv.x), abs(uv.y)) * intensity) / tan(intensity);
    uv = d*vec2(cos(a), sin(a));
    float kCol = smoothstep(0.5, 5.0, abs(d)*highFreqColor.a);
    return mix(__source__(uv), vec4(highFreqColor.rgb, 1.0), kCol);
}
