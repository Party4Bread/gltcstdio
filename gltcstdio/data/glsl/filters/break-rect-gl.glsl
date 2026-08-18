// Pap's colorize(): split the tint's alpha into a colorize-region (kCol)
// and a flat-mate-region (kMate). Equivalent to the original byte-for-byte.
vec4 breakRectColorize(vec4 base, vec4 tint) {
    vec4 hslBase = rgbToHsl(base);
    vec4 hslTint = rgbToHsl(tint);
    float kCol = clamp(tint.a * 2.0, 0.0, 1.0);
    hslTint.z = hslBase.z;
    vec4 tintLum = hslToRgb(hslTint);
    vec3 colorized = mix(base.rgb, tintLum.rgb, kCol);
    float kMate = clamp((tint.a - 0.5) * 2.0, 0.0, 1.0);
    return vec4(mix(colorized, tint.rgb, kMate), base.a);
}

vec4 breakRect(vec2 pos, vec2 outPos, vec4 color, mat3 modelTransform) {
    // Pap's filter: doInverseModelTransform=true AND supplyInverseModelTransform=true.
    //   - u_ModelTransform   = inverse(forwardModel)   (the "forward" uniform IS the inverse)
    //   - u_InverseModelTransform = forwardModel       (the "inverse" uniform IS the forward)
    // In pap2mp we receive the forward matrix; reproduce both sides:
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;

    vec4 inCol = __source__(pos);
    if (abs(u.y) < 1.0) {
        // Pap: u.x += u_ModelTransform[2][0]  — note u_ModelTransform
        //   here is the inverse matrix's third column (translation of
        //   the inverse), not the forward translation.
        u.x += invM[2][0];
        // Pap: p = u_InverseModelTransform * vec3(u, 1.0)
        //   — u_InverseModelTransform IS the forward matrix.
        vec2 p = (modelTransform * vec3(u, 1.0)).xy;
        vec4 outCol = breakRectColorize(__source__(p), color);
        // Locus stripped: Pap returns mix(inCol, outCol, getLocus(...));
        // here the external `.withLocusHandling()` wrapper supplies the
        // locus blend on top of our `outCol` return.
        return outCol;
    }
    else {
        return inCol;
    }
}
