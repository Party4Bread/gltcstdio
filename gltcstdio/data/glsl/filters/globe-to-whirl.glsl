vec4 globe_to_whirl(vec2 uv, vec2 outPos, float time,
    float globeIntensity, vec2 sourceDim, float power, float shadows, vec4 colorShadow,
    float whirlIntensity, float unwind, vec4 highFreqColor,
    mat3 modelTransform, mat3 shadowTransform) {

    mat3 t = inverse(modelTransform);

    // Fade out Globe's aspect-ratio correction
    float ratio = sourceDim.x / sourceDim.y;
    float ratioScale = ratio < 1.0 ? mix(1.0 / ratio, 1.0, time) : 1.0;
    vec2 u = uv * ratioScale;
    vec2 v = tf(t, u);

    // Blend distance metric: Minkowski (Globe) → Euclidean (Whirl)
    float dCircle = length(v);
    float dShape = measure(v, power);
    float d = mix(dShape, dCircle, time);

    float kShadow = 0.0;
    float darken = 0.0;

    if (d < 1.0) {
        // --- Globe radial dilation ---
        float hh = sqrt(1.0 - d * d);
        float globeDilation = 1.0;
        if (hh != 0.0) {
            float h = 1.0 + hh;
            float s = (-d * globeIntensity) / hh;
            globeDilation = 1.0 + (h * s) / d;
        }
        vec2 globeUV = globeDilation * v;

        // --- Whirl angular rotation ---
        float dWhirl = dCircle;
        float bal = unwind;
        if (bal != 0.5) {
            if (bal == 1.0 || dWhirl < bal) {
                dWhirl = 0.5 * dWhirl / bal;
            } else {
                dWhirl = 0.5 * (1.0 - (dWhirl - bal) / (1.0 - bal));
            }
        }
        float dangle = whirlIntensity * 10.0 * (1.0 - cos(dWhirl * 2.0 * PI));
        float ca = cos(dangle);
        float sa = sin(dangle);
        vec2 whirlUV = vec2(ca * v.x - sa * v.y, ca * v.y + sa * v.x);

        // Morph between Globe's dilation and Whirl's rotation
        vec2 blended = mix(globeUV, whirlUV, time);
        u = tf(modelTransform, blended);

        // Fade out Globe's inner shadows
        if (shadows < 0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = measure(vs, power);
            kShadow = (1.0 - time) * smoothstep(shadows, 0.0, ds - 1.0);
        }

        // Fade in Whirl's darkening
        if (highFreqColor.a != 0.0) {
            float dRot = length(whirlUV * vec2(min(1.5, 1.0 + abs(whirlIntensity * 3.0)), 1.0));
            float sHeight = highFreqColor.a * 4.0;
            float sSlope = 1.0 + highFreqColor.a * 3.0;
            darken = clamp(sHeight - dRot * sSlope, 0.0, 1.0) * time;
        }
    } else {
        // Outside the effect region — fade out Globe's outer shadows
        if (shadows > 0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = measure(vs, power);
            kShadow = (1.0 - time) * smoothstep(shadows, 0.0, ds - 1.0);
        }
    }

    // Undo aspect-ratio correction
    u = u / ratioScale;

    vec4 col = __source__(u);
    // Globe shadow (fading out)
    col = mix(col, vec4(colorShadow.rgb, col.a), kShadow * colorShadow.a);
    // Whirl darkening (fading in)
    col = mix(col, vec4(highFreqColor.rgb, col.a), darken);
    return col;
}
