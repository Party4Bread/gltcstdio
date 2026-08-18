vec4 ripples_to_globe(vec2 uv, vec2 outPos, float time,
    float spacing, float ripplesIntensity, int count, float dampening,
    float intensity, vec2 sourceDim, float power, float shadows, vec4 colorShadow,
    mat3 modelTransform, mat3 shadowTransform) {

    mat3 t = inverse(modelTransform);

    // Smoothly introduce Globe's aspect-ratio correction
    float ratio = sourceDim.x / sourceDim.y;
    float ratioScale = ratio < 1.0 ? mix(1.0, 1.0 / ratio, time) : 1.0;
    vec2 u = uv * ratioScale;
    vec2 v = tf(t, u);

    // Blend distance metric: Euclidean (Ripples) → Minkowski (Globe)
    float dCircle = length(v);
    float dShape = measure(v, power);
    float d = mix(dCircle, dShape, time);

    float kShadow = 0.0;

    if (d < 1.0) {
        // --- Ripples dilation ---
        float dampen = dampening >= 0.0
            ? pow(1.0 - d, dampening * 2.0)
            : pow(d, -dampening * 5.0);
        float dd = spacing <= 0.0
            ? d - 1.0
            : log((d - 1.0) * spacing + 1.0) / spacing;
        float ripplesDilation = 1.0
            + ripplesIntensity * sin(dd * float(count) * PI) * dampen;

        // --- Globe dilation ---
        float hh = sqrt(1.0 - d * d);
        float globeDilation = 1.0;
        if (hh != 0.0) {
            float h = 1.0 + hh;
            float s = (-d * intensity) / hh;
            globeDilation = 1.0 + (h * s) / d;
        }

        // Morph between the two distortion fields
        float dilation = mix(ripplesDilation, globeDilation, time);
        u = tf(modelTransform, dilation * v);

        // Fade in Globe's inner shadows
        if (shadows < 0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = measure(vs, power);
            kShadow = time * smoothstep(shadows, 0.0, ds - 1.0);
        }
    } else {
        // Outside the effect region — pass through, but fade in outer shadows
        if (shadows > 0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = measure(vs, power);
            kShadow = time * smoothstep(shadows, 0.0, ds - 1.0);
        }
    }

    // Undo aspect-ratio correction
    u = u / ratioScale;

    vec4 col = __source__(u);
    return mix(col, vec4(colorShadow.rgb, col.a), kShadow * colorShadow.a);
}
