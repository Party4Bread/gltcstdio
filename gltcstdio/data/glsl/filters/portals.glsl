vec4 portals(vec2 pos, vec2 outPos, vec2 sourceDim, vec4 colorFog, float thickness, int count, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = pos;
    float ratio = sourceDim.x/sourceDim.y;
    float intensity = 1.0 - thickness;
    int i = 0;
    for(; i<count; ++i) {
        vec2 m = vec2(mod(u.x/ratio+1.0, 2.0), mod(u.y+1.0,2.0)) - vec2(1.0, 1.0);
        if (max(abs(m.x), abs(m.y))> intensity) break;
        u = (invModelTransform * vec3(u, 1.0)).xy;
    }
    vec4 color = __source__(u);
    if (colorFog.a!=0.) {
        float k = float(i)/float(count);
        float alpha = k*colorFog.a;
        color = mergeColor(color, vec4(colorFog.rgb, alpha));
    }
    return color;
}
