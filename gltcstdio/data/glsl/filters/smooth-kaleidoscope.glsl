float ww(vec2 u, float blend) {
            float d = (0.5-hexDist(u))*2.0;
            return smoothstep(-blend, blend, d);
        }

float vig(float w, float vignetting) {
    return mix(w, 1.0, 1.0-vignetting);
}

vec4 smoothKaleidoscope(vec2 uv, vec2 outPos, float blend, float offset, float vignetting, mat3 modelTransform, mat3 viewTransform) {
    vec2 u = uv;

    vec4 hex = hexCoords(u);
    mat3 inverseModelTransform = inverse(modelTransform);
    
    if (blend==0.0) {
        vec2 dv = offset*hex.zw;
        return __source__(tf(inverseModelTransform, hex.xy + dv));
    }
    else {
        vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
        float totalWeight = 0.0;
        vec4 black = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 hc = hex.xy;
        vec2 dv = offset*hex.zw;
        float wCenter = ww(hc, blend);
        total += wCenter*mix(black, __source__(tf(inverseModelTransform, hex.xy + dv)), vig(wCenter, vignetting));
        totalWeight += wCenter;

        vec2 delta = vec2(1.0, 0.0);
        vec2 hexRight = hc-delta;
        dv = offset*(hex.zw+delta);
        float wRight = ww(hexRight, blend);
        totalWeight += wRight;
        total += wRight*mix(black, __source__(tf(inverseModelTransform, hexRight.xy + dv)), vig(wRight, vignetting));

        delta = vec2(-1.0, 0.0);
        vec2 hexLeft = hc-delta;
        dv = offset*(hex.zw+delta);
        float wLeft = ww(hexLeft, blend);
        totalWeight += wLeft;
        total += wLeft*mix(black, __source__(tf(inverseModelTransform, hexLeft.xy + dv)), vig(wLeft, vignetting));

        delta = vec2(0.5, SQRT3_2);
        vec2 hexTopRight = hc-delta;
        dv = offset*(hex.zw+delta);
        float wTopRight = ww(hexTopRight, blend);
        totalWeight += wTopRight;
        total += wTopRight*mix(black, __source__(tf(inverseModelTransform, hexTopRight.xy + dv)), vig(wTopRight, vignetting));

        delta = vec2(-0.5, SQRT3_2);
        vec2 hexTopLeft = hc-delta;
        dv = offset*(hex.zw+delta);
        float wTopLeft = ww(hexTopLeft, blend);
        totalWeight += wTopLeft;
        total += wTopLeft*mix(black, __source__(tf(inverseModelTransform, hexTopLeft.xy + dv)), vig(wTopLeft, vignetting));

        delta = vec2(0.5, -SQRT3_2);
        vec2 hexBottomRight = hc-delta;
        dv = offset*(hex.zw+delta);
        float wBottomRight = ww(hexBottomRight, blend);
        totalWeight += wBottomRight;
        total += wBottomRight*mix(black, __source__(tf(inverseModelTransform, hexBottomRight.xy + dv)), vig(wBottomRight, vignetting));

        delta = vec2(-0.5, -SQRT3_2);
        vec2 hexBottomLeft = hc-delta;
        dv = offset*(hex.zw+delta);
        float wBottomLeft = ww(hexBottomLeft, blend);
        totalWeight += wBottomLeft;
        total += wBottomLeft*mix(black, __source__(tf(inverseModelTransform, hexBottomLeft.xy + dv)), vig(wBottomLeft, vignetting));

        return total/totalWeight;
    }        
}
