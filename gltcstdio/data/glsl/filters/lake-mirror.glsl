vec4 lakeMirror(vec2 pos, vec2 outPos, vec2 sourceDim, float aspectRatio, mat3 modelTransform) {
    float srcRatio = sourceDim.x / sourceDim.y;
    float halfRatio = 2.0 * aspectRatio;             // each half's aspect (w/h) in V2 units
    float coverScale = max(halfRatio / srcRatio, 1.0);

    // half-local centered coordinate; the two halves mirror across the waterline
    // (pos.y == 0) and are seamless there for any modelTransform.
    vec2 h;
    h.x = 2.0 * pos.x;                               // spans [-halfRatio, halfRatio]
    if (pos.y >= 0.0) h.y = 1.0 - 2.0 * pos.y;       // top half (upright)     (waterline -> +1, top edge -> -1)
    else              h.y = 1.0 + 2.0 * pos.y;       // bottom half (reflection)(waterline -> +1, bottom edge -> -1)

    vec2 base = h / coverScale;                      // cover-fit into source space (crops overflow)
    vec2 src = tf(inverse(modelTransform), base);    // pan/zoom (default identity)
    return __source__(src);
}
