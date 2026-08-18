vec4 cairoPixelate(vec2 uv, vec2 outPos, float pixelation, float shape, float thickness, vec4 color, mat3 modelTransform) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    CairoTile cairo = cairoTile(u, shape);
    vec2 v = (modelTransform * vec3(cairo.center, 1.0)).xy;
    if (cairo.borderDist<thickness*0.5) {
        vec4 col = __source__(v);
        return mergeColor(col, color);
    }
    else {
        float l = length(modelTransform[0].xy);
        return __source__(v + pixelation * l * vec2(0.0, cairo.borderDist));            
    }   
}
