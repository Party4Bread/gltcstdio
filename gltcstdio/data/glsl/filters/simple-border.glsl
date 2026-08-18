vec4 simpleBorder(vec2 uv, vec2 outPos, float border, vec2 sourceDim, float shadows, vec2 outDim, vec4 colorOut, vec4 colorShadow, mat3 viewTransform, mat3 shadowTransform, mat3 modelTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    float borderSize = border * 2. * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 threshold = vec2(outDim.x/outDim.y * ratio/newBounds.x, 1./newBounds.y);
    vec2 u = uv;
    float d = sdRectangle(u, threshold);
    bool inside = d<0.0; //abs(u.x)<=threshold.x && abs(u.y)<=threshold.y;
    float shadow = 0.0;
    
    vec2 v = tf(inverse(modelTransform), uv);
    if (inside) {
        if (shadows<0.0) {
            vec2 v = tf(inverse(shadowTransform), u);
            d = sdRectangle(v, threshold);
            shadow = smoothstep(shadows, 0., d); // d is shadow d here
        }
    }
    else {
        if (shadows>0.0) {
            vec2 v = tf(inverse(shadowTransform), u);
            d = sdRectangle(v, threshold);
            shadow = smoothstep(shadows, 0., d); // d is shadow d here
        }
    }
    
    vec4 outCol = inside ? __source__(v) : mergeColor(__source__(v), colorOut);
    return mix(outCol, mergeColor(outCol, colorShadow), shadow);
}
