vec4 hexTilesWithTextureTransformLegacy(vec2 pos, vec2 outPos, float intensity, float distortion, float pixelation, mat3 modelTransform, mat3 sampleTransform) {
    mat3 invMT = inverse(modelTransform);
    vec2 u = (invMT * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;
    float halfTileWidth = 1.0;
    float tileHeight = 2.0 * SQRT3_2;
    float centerHeight = tileWidth / (2.0 * SQRT3);

    float X = u.x;
    float Y = u.y;

    float row = floor(Y / tileHeight);
    float column = floor(X / halfTileWidth);
    float dx0 = X - column * halfTileWidth;
    float dy0 = Y - row * tileHeight;

    bool rectDown = mod(row + column, 2.0) == 0.0;
    float cx, cy;
    bool down;
    if (rectDown) {
        if (dy0 > tileHeight - dx0 * SQRT3) {
            cy = (row + 1.0) * tileHeight - centerHeight;
            cx = (column + 1.0) * halfTileWidth;
            down = true;
        } else {
            cy = row * tileHeight + centerHeight;
            cx = column * halfTileWidth;
            down = false;
        }
    } else {
        if (dy0 > dx0 * SQRT3) {
            cy = (row + 1.0) * tileHeight - centerHeight;
            cx = column * halfTileWidth;
            down = true;
        } else {
            cy = row * tileHeight + centerHeight;
            cx = (column + 1.0) * halfTileWidth;
            down = false;
        }
    }

    float hcx = 0.0;
    float hcy = 0.0;
    int tripos = int(mod(column + 3.0 * row, 6.0));
    if (tripos == 2) {
        hcx = column * halfTileWidth;
        hcy = (row + 1.0) * tileHeight;
    } else if (tripos == 1) {
        hcx = (column + 1.0) * halfTileWidth;
        hcy = (row + 1.0) * tileHeight;
    } else if (tripos == 0) {
        if (down) { hcx = (column + 2.0) * halfTileWidth; hcy = (row + 1.0) * tileHeight; }
        else      { hcx = (column - 1.0) * halfTileWidth; hcy =  row        * tileHeight; }
    } else if (tripos == 5) {
        hcx = column * halfTileWidth;
        hcy = row * tileHeight;
    } else if (tripos == 4) {
        hcx = (column + 1.0) * halfTileWidth;
        hcy = row * tileHeight;
    } else {
        if (down) { hcx = (column - 1.0) * halfTileWidth; hcy = (row + 1.0) * tileHeight; }
        else      { hcx = (column + 2.0) * halfTileWidth; hcy =  row        * tileHeight; }
    }

    float dx = X - hcx;
    float dy = Y - hcy;
    float ccx = cx - hcx;
    float ccy = cy - hcy;

    vec2 tileSize = vec2(
        length(vec2(modelTransform[0][0], modelTransform[1][0])) * tileWidth,
        length(vec2(modelTransform[0][1], modelTransform[1][1])) * tileHeight
    );
    float s = 1.0 + intensity * 0.01 * (max(2.0 / tileSize.x, 2.0 / tileSize.y) - 1.0);

    vec2 tileCenter = vec2(hcx, hcy);
    vec2 v = vec2(dx, dy);
    vec2 p = (modelTransform * vec3(v * s + tileCenter, 1.0)).xy;

    if (distortion > 0.0) {
        float d = distortion * 0.01;
        float ndx = dx / tileHeight;
        float ndy = dy / tileHeight;
        float ncx = ccx / (tileHeight - centerHeight);
        float ncy = ccy / (tileHeight - centerHeight);
        float r = ndx * ncx + ndy * ncy;
        if (1.0 - r < d) {
            float scaleK = 2.0 / sqrt(invMT[0][0] * invMT[0][0] + invMT[0][1] * invMT[0][1]);
            r = (1.0 - r) / d;
            float dp = tileWidth * (1.0 - r) / (0.5 + r) * scaleK;
            p.x += ncx * dp;
            p.y += ncy * dp;
        }
    }

    // proj0 / TEX layer: apply the source-sampling transform (inverted, like every other
    // proc) to the per-tile sample coordinate. Identity by default → same as HexTilesLegacy.
    mat3 invST = inverse(sampleTransform);
    vec4 outColor = __source__((invST * vec3(p, 1.0)).xy);
    if (pixelation != 0.0) {
        vec2 tileCenterTex = (modelTransform * vec3(tileCenter, 1.0)).xy;
        vec4 pixelColor = __source__((invST * vec3(tileCenterTex, 1.0)).xy);
        outColor = mix(outColor, pixelColor, pixelation);
    }
    return outColor;
}
