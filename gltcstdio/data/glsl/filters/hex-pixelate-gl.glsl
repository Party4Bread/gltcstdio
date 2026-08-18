vec4 hexPixelate(vec2 uv, vec2 outPos, float pixelation, float thickness, vec4 color, mat3 modelTransform) {
    float streaking = pixelation;
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    vec4 hex = hexPolarBorderCoords(u);
    vec2 v = (modelTransform * vec3(hex.zw, 1.0)).xy;
    if (hex.y<thickness*0.5) {
        vec4 col = __source__(v);
        return mergeColor(col, color);
    }
    else {
        if (streaking>=0.0) {
            float l = length(modelTransform[0].xy);
            return __source__(v + streaking * l * vec2(0.0, hex.y));
        }
        else {
            vec4 hex2 = hexPolarCoords(u);
            float ang = mod(hex.x+PI/6.0, PI/3.0) - PI/6.0;
            float k = 1.0 / cos(ang);
            vec2 v2 = tf(modelTransform, hex.zw - streaking * 0.5 * k * vec2(cos(hex.x), sin(hex.x)));
            return __source__(v2);
        }
    }   
}
