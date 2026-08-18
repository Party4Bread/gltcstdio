vec4 chromaOffset(vec2 pos, vec2 outPos, float intensity, mat3 modelTransform) {
    // Pap's filter doInverseModelTransform() = true → u_ModelTransform
    // is the INVERSE of the forward matrix. In pap2mp modelTransform
    // is the FORWARD matrix; we apply inverse() in-shader at every
    // site Pap uses u_ModelTransform to preserve identical math.
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;

    vec4 col = __source__(pos);
    vec4 hsl = rgbToHsl(col);
    vec4 offHsl = rgbToHsl(__source__(u));
    // Hue + saturation come from the offset sample; lightness stays
    // from the un-offset pixel (Pap signature behaviour).
    hsl[0] = offHsl[0];
    hsl[1] = offHsl[1];
    vec4 outCol = hslToRgb(hsl);
    return mix(col, outCol, intensity);
}
