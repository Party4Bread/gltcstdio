vec4 glassRectTiles(vec2 uv, vec2 outPos, float intensity, float distortion, float outAspectRatio, float pixelation, vec4 highFreqColor, float shapeAspectRatio, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    vec2 tileDim = vec2(2.*shapeAspectRatio/(1.+shapeAspectRatio), 2./(1.+shapeAspectRatio));
    
    float tileSize = length(modelTransform[0].xy) * max(tileDim.x, tileDim.y);
    float maxTileViewSize = min(outAspectRatio, 1.0);
    float viewSize = mix(tileSize, maxTileViewSize, intensity);
    
    vec2 c = round(v/tileDim) * tileDim;
    vec2 pos = v - c;
    float borderDist = min(tileDim.x*.5-abs(pos.x), tileDim.y*.5-abs(pos.y));
    float distort = max(1.0, distortion/borderDist);

    vec2 center = tf(modelTransform, c) * (tileSize>=maxTileViewSize ? vec2(1.) : (vec2(outAspectRatio, 1.)-viewSize*.5)/(vec2(outAspectRatio, 1.)-tileSize*.5));
    float scale = viewSize/tileSize;
    
    vec4 pixColor = __source__(center);
    vec2 w = center + mat2(modelTransform)*pos*distort*scale;
    vec4 col = __source__(w);
    
    float hf = 0.;
    if (highFreqColor.a>0.) {
        float hfThreshold = 2./highFreqColor.a;
        hf = smoothstep(hfThreshold, hfThreshold*10.0, distort);
    }
    
    return mergeColor(mix(col, pixColor, pixelation), vec4(highFreqColor.rgb, hf));
}
