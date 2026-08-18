// Per-stripe hue/luminance tweak — mirrors Pap's getColor().
// colorVariability is normalised (0..1); original used (u_ColorVariability * 0.02)
// where u_ColorVariability was 0..100, so the compensated constant is 2.0.
vec4 coloredStripesGetColor(vec4 baseColor, vec2 delta, float colorVariability) {
    float deltaHue = delta.x * colorVariability * 2.0;
    vec4 hsl = rgbToHsl(baseColor);
    hsl.x += deltaHue * 180.0;
    hsl.z *= (1.0 + 0.3 * delta.y);
    return hslToRgb(hsl);
}

// Pap's colorize(): split the tint's alpha into a colorize-region (kCol)
// and a flat-mate-region (kMate). Equivalent to the original byte-for-byte.
vec4 coloredStripesColorize(vec4 base, vec4 tint) {
    vec4 hslBase = rgbToHsl(base);
    vec4 hslTint = rgbToHsl(tint);
    float kCol = clamp(tint.a * 2.0, 0.0, 1.0);
    hslTint.z = hslBase.z;
    vec4 tintLum = hslToRgb(hslTint);
    vec3 colorized = mix(base.rgb, tintLum.rgb, kCol);
    float kMate = clamp((tint.a - 0.5) * 2.0, 0.0, 1.0);
    return vec4(mix(colorized, tint.rgb, kMate), base.a);
}

vec4 coloredStripesGL(vec2 pos, vec2 outPos, vec4 color, float regularity, float colorVariability, float randomSeed, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = tf(invM, pos);

    vec4 inCol = __source__(pos);
    float index = floor(u.y / 2.0);
    vec2 delta = rand2relSeeded(vec2(index, index), randomSeed);

    // Pap: u_Variability = 100 - regularity (0..100), shader: u_Variability * 0.01
    //   → with regularity normalised to 0..1, this becomes (1.0 - regularity).
    float variability = 1.0 - regularity;
    float var_ = variability * delta.x * 2.0;
    float inside = (mod(u.y, 2.0) < 1.0 + var_) ? 1.0 : 0.0;

    if (inside > 0.0) {
        vec4 stripeColor = coloredStripesGetColor(color, delta, colorVariability);
        vec4 outCol = coloredStripesColorize(inCol, stripeColor);
        return outCol;
    } else {
        return inCol;
    }
}
