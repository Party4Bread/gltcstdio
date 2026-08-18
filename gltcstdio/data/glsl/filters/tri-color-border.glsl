vec4 triColorBorder(vec2 uv, vec2 outPos, float border, float thickness, float offset, vec2 sourceDim, float shadows, vec2 outDim, vec4 color1, vec4 color2, vec4 color3, vec4 colorShadow, mat3 viewTransform, mat3 shadowTransform, mat3 modelTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    float borderSize = border * 2. * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 threshold = vec2(outDim.x/outDim.y * ratio/newBounds.x, 1./newBounds.y);
    vec2 u = uv;
    vec2 ur = abs(u)-threshold;
    float d = max(ur.x, ur.y);
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
    
    vec4 borderColor = vec4(0.0);
    if (!inside) {
        float b = 1.0 - threshold.y;
        float dRel = d/b;
        float o = offset*0.5+0.5;
        if (abs(dRel-o) < thickness*0.5) borderColor = color2;
        else if (dRel>o) borderColor = color3;
        else borderColor = color1;
        
        /*if (dRel<0.0) borderColor = vec4(1.0, 0.0, 0.0, 1.0);
        else if (dRel>1.0) borderColor = vec4(0.0, 0.5, 1.0, 1.0);
        else borderColor = mix(color1, color2, dRel);*/
    }
    vec4 outCol = inside ? __source__(v) : mergeColor(__source__(v), borderColor);
    return mix(outCol, mergeColor(outCol, colorShadow), shadow);
}
