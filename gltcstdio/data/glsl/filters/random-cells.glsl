vec3 cellColor(vec2 id) {
    return vec3(hash21(id + 0.10), hash21(id + 3.70), hash21(id + 9.20));
}

vec4 randomCells(vec2 uv, vec2 outPos, vec2 outDim, int detail, float randomSeed) {
    float ar = outDim.x / outDim.y;
    vec2 halfRect = vec2(ar * 0.5, 0.5);                          // same-AR rectangle at half the frame size
    if (abs(uv.x) > halfRect.x || abs(uv.y) > halfRect.y) return vec4(0.0, 0.0, 0.0, 1.0);
    float n = max(1.0, float(detail));
    vec2 t = clamp(uv / halfRect * 0.5 + 0.5, 0.0, 0.999999);     // rectangle -> [0,1]^2
    vec2 id = floor(t * n);                                       // cell index in [0,n-1]^2
    return vec4(cellColor(id + randomSeed * 13.0), 1.0);
}
