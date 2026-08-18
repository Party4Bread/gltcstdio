vec4 iteratedRectTilesGL(vec2 pos, vec2 outPos, float intensity, int iterations, float shapeAspectRatio, float distortion, float pixelation, mat3 modelTransform) {
    // Pap's RectTiles shader (unlike IteratedRipples) applies the
    // forward `u_ModelTransform` to enter tile space and uses the
    // inverse only as the back-transform for sampling. pap2mp's
    // `modelTransform` parameter is the user-visible forward matrix
    // (Pap MODEL_SCALE=5 → pap2mp scale(5.0)); the shader inverts
    // internally for the sampling step.
    mat3 invM = inverse(modelTransform);

    // Pap: u = u_ModelTransform * pos  (forward).
    vec2 u = (modelTransform * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;
    float tileHeight = 2.0 * shapeAspectRatio;

    // Pap: tileSize = length(u_InverseModelTransform[0/1][0]) * tile*.
    //   → in pap2mp our invM is exactly Pap's u_InverseModelTransform.
    vec2 tileSize = vec2(length(vec2(invM[0][0], invM[1][0])) * tileWidth,
                         length(vec2(invM[0][1], invM[1][1])) * tileHeight);

    // Pap: intensity_local = u_Intensity * 0.1   (u_Intensity in -100..100)
    //   then s = 1 + intensity_local*0.01 * locusStrength * (max(...) - 1)
    // pap2mp intensity in -1..1 (= u_Intensity/100), so the combined
    // factor becomes `intensity * 0.1` (= u_Intensity * 0.001).
    // locusStrength = 1.0 here — external `.withLocusHandling()` wrap
    // applies the mask blend after this shader returns.
    float locusStrength = 1.0;
    float intEff = intensity * 0.1;
    float s = 1.0 + intEff * locusStrength * (max(2.0 / tileSize.x, 2.0 / tileSize.y) - 1.0);

    vec2 tileCenter = vec2(0.0, 0.0);
    vec2 p = vec2(0.0, 0.0);

    for (int i = 0; i < iterations; ++i) {
        float row = floor(u.y / tileHeight);
        float column = floor(u.x / tileWidth);

        tileCenter = vec2((column + 0.5) * tileWidth, (row + 0.5) * tileHeight);

        vec2 v = u - tileCenter;

        // Pap: p = u_InverseModelTransform * vec3(v*s + tileCenter, 1.0).
        p = (invM * vec3(v * s + tileCenter, 1.0)).xy;

        vec2 r;
        bool borderX = false;
        bool borderY = false;
        if (distortion > 0.0) {
            // Pap: d = u_Distortion * 0.01 (u_Distortion 0..100)
            //   → with distortion in 0..1: d = distortion.
            float d = distortion;
            r = v / vec2(tileWidth, tileHeight) + vec2(0.5, 0.5);

            if (r.x < d / 2.0) {
                r.x = 2.0 * r.x / d;
                borderX = true;
                p.x -= tileSize.x * (1.0 - r.x) / (0.5 + r.x);
            } else if (r.x > 1.0 - d / 2.0) {
                r.x = 2.0 * (1.0 - r.x) / d;
                borderX = true;
                p.x += tileSize.x * (1.0 - r.x) / (0.5 + r.x);
            }

            if (r.y < d / 2.0) {
                r.y = 2.0 * r.y / d;
                borderY = true;
                p.y -= tileSize.y * (1.0 - r.y) / (0.5 + r.y);
            } else if (r.y > 1.0 - d / 2.0) {
                r.y = 2.0 * (1.0 - r.y) / d;
                borderY = true;
                p.y += tileSize.y * (1.0 - r.y) / (0.5 + r.y);
            }
        }
        // Pap: u = u_ModelTransform * vec3(p, 1.0) — forward, for next iteration.
        u = (modelTransform * vec3(p, 1.0)).xy;
    }

    vec4 outColor = __source__(p);

    // Pap: `if (u_LowResColorBleed != 0.0) outColor = mix(..., u_LowResColorBleed*0.01)`.
    //   pap2mp pixelation in 0..1: drop the *0.01.
    if (pixelation != 0.0) {
        // Pap: tileCenterTexSpace = u_InverseModelTransform * vec3(tileCenter, 1.0).
        vec2 tileCenterTexSpace = (invM * vec3(tileCenter, 1.0)).xy;
        vec4 pixelColor = __source__(tileCenterTexSpace);
        outColor = mix(outColor, pixelColor, pixelation);
    }

    return outColor;
}
