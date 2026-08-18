vec4 glassTriangleTiles(vec2 uv, vec2 outPos, float intensity, float distortion, float outAspectRatio, float pixelation, vec4 highFreqColor, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float tileSize = length(modelTransform[0].xy) * 1./SQRT3_2;
    float maxTileViewSize = min(outAspectRatio, 1.0);
    float viewSize = mix(tileSize, maxTileViewSize, intensity);
    
    TriangleTile tile = triangleTile(v);
    float distort = max(1.0, distortion/tile.borderDist);

    vec2 center = tf(modelTransform, tile.center) * (tileSize>=maxTileViewSize ? vec2(1.) : (vec2(outAspectRatio, 1.)-viewSize*.5)/(vec2(outAspectRatio, 1.)-tileSize*.5));
    float scale = viewSize/tileSize;
    
    vec4 pixColor = __source__(center);
    vec2 w = center + mat2(modelTransform)*tile.pos*distort*scale;
    vec4 col = __source__(w);
    
    float hf = 0.;
    if (highFreqColor.a>0.) {
        float hfThreshold = 2./highFreqColor.a;
        hf = smoothstep(hfThreshold, hfThreshold*10.0, distort);
    }
    
    return mergeColor(mix(col, pixColor, pixelation), vec4(highFreqColor.rgb, hf));
}
