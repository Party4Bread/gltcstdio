vec4 triangleTilesLegacy(vec2 pos, vec2 outPos, float intensity, float distortion, float pixelation, mat3 modelTransform) {
    mat3 invMT = inverse(modelTransform);
    vec2 u = (invMT * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;
    float halfTileWidth = 1.0;
    float tileHeight = 2.0 * SQRT3_2;
    float centerHeight = tileWidth / (2.0 * SQRT3);

    vec2 tileSize = vec2(
        length(vec2(modelTransform[0][0], modelTransform[1][0])) * tileWidth,
        length(vec2(modelTransform[0][1], modelTransform[1][1])) * tileHeight
    );

    float s = 1.0 + intensity * 0.01 * (max(2.0 / tileSize.x, 2.0 / tileSize.y) - 1.0);

    float row = floor(u.y / tileHeight);
    float column = floor(u.x / halfTileWidth);
    float dx0 = u.x - column * halfTileWidth;
    float dy0 = u.y - row * tileHeight;

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

    vec2 tileCenter = vec2(cx, cy);
    vec2 v = u - tileCenter;
    vec2 p = (modelTransform * vec3(v * s + tileCenter, 1.0)).xy;

    if (distortion > 0.0) {
        float ori = down ? -1.0 : 1.0;
        float d = distortion * 0.01;
        float dx = -v.x / centerHeight;
        float dy = -v.y / centerHeight;
        float scaleK = 2.0 / sqrt(invMT[0][0] * invMT[0][0] + invMT[0][1] * invMT[0][1]);
        float r0 = ori * dy;
        if (1.0 - r0 < d) {
            r0 = (1.0 - r0) / d;
            p.y += ori * tileWidth * (1.0 - r0) / (0.5 + r0) * scaleK;
        }
        float r1 = -dx * SQRT3_2 - ori * dy * 0.5;
        if (1.0 - r1 < d) {
            r1 = (1.0 - r1) / d;
            float dp = tileWidth * (1.0 - r1) / (0.5 + r1) * scaleK;
            p.x += -SQRT3_2 * dp;
            p.y += -ori * 0.5 * dp;
        }
        float r2 = dx * SQRT3_2 - ori * dy * 0.5;
        if (1.0 - r2 < d) {
            r2 = (1.0 - r2) / d;
            float dp = tileWidth * (1.0 - r2) / (0.5 + r2) * scaleK;
            p.x += SQRT3_2 * dp;
            p.y += -ori * 0.5 * dp;
        }
    }

    vec4 outColor = __source__(p);
    if (pixelation != 0.0) {
        vec2 tileCenterTex = (modelTransform * vec3(tileCenter, 1.0)).xy;
        vec4 pixelColor = __source__(tileCenterTex);
        outColor = mix(outColor, pixelColor, pixelation);
    }
    return outColor;
}
