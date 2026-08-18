vec4 displacedBorder(vec2 uv, vec2 outPos, float border, int displacement_specified, vec2 sourceDim, vec2 outDim, float intensity, float balance, vec4 colorOut, mat3 viewTransform, mat3 modelTransform, mat3 borderTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    float borderSize = border * 2. * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 threshold = vec2(outDim.x/outDim.y * ratio/newBounds.x, 1./newBounds.y);
    vec2 u = uv;
    u += intensity * ((displacement_specified==1 ? __displacement__(tf(inverse(borderTransform), uv)) : __source__(tf(inverse(borderTransform), uv))).xy - 0.5 + balance);
    bool inside = abs(u.x)<=threshold.x && abs(u.y)<=threshold.y;
    vec2 v = tf(inverse(modelTransform), uv);
    return inside ? __source__(v) : mergeColor(__source__(v), colorOut);
}
