vec4 presetTv(vec2 pos, vec2 outPos, float intensity, float balance, float brightness, vec2 sourceDim, mat3 modelTransform) {
    // ---- crtContrast(pos, 0.8, 0.025) ----------------------------------
    float radius = 0.025;
    float k0 = 0.8;
    vec4 color = __source__(pos);

    // blurH(pos + vec2(radius/2, 0), radius), inlined from Pap's blurH().
    vec2 bpos = pos + vec2(radius / 2.0, 0.0);
    float pixel = 2.0 / sourceDim.y;
    int n = int(ceil(radius / pixel)) + 1;
    vec4 total = vec4(0.0);
    vec2 bp = bpos - vec2(float(n) * pixel, 0.0);
    float div = 0.0;
    for (int i = -64; i <= 64; ++i) {
        if (i < -n || i > n) continue;
        float d = length(vec2(float(i), 0.0)) * pixel / radius;
        if (d <= 1.0) {
            float kk = (d > 0.5) ? (1.0 - d) * (1.0 - d) * 2.0 : 1.0 - d * d * 2.0;
            total += kk * __source__(bp);
            div += kk;
            bp.x += pixel;
        }
    }
    vec4 blur = total / div;
    color = (1.0 + k0) * color - k0 * blur;

    // ---- chromaOffset(color, pos) --------------------------------------
    // Pap: u = vec2(pos.x + 0.05, pos.y);  (u_ModelTransform line commented out)
    vec2 cu = vec2(pos.x + 0.05, pos.y);
    vec4 chsl = rgbToHsl(color);
    vec4 cOffHsl = rgbToHsl(__source__(cu));
    chsl[0] = cOffHsl[0];
    chsl[1] = cOffHsl[1];
    color = hslToRgb(chsl);

    // ---- scanlines(color, pos) -----------------------------------------
    vec4 shsl = rgbToHsl(color);
    vec4 sOrigHsl = shsl;
    // pincushion(pos, 0.15): p*(1 + k*dot(p,p)*dot(p,p))  (4th-power barrel)
    float pk = 0.15;
    float dd = dot(pos, pos);
    vec2 pinc = pos * (1.0 + pk * dd * dd);
    shsl[0] += pinc.y * 1000.0;
    float brightnessRaw = -brightness * 100.0;   // Pap: brightness = -u_Brightness
    float b = pow(1.04, brightnessRaw);
    shsl[2] *= pow((1.0 + sin(pinc.y * 600.0)) * (brightnessRaw * 0.001 + 0.5), b);

    vec4 shslD = sOrigHsl;
    shslD[2] = shsl[2];
    vec4 srgbD = hslToRgb(shslD);
    vec4 srgb = hslToRgb(shsl);
    srgb = mix(srgb, srgbD, 0.0);     // Pap no-op (factor 0.0): yields srgb
    color = mix(color, srgb, 0.4);

    // ---- ray darkening -------------------------------------------------
    // Pap filter doInverseModelTransform()=true → u_ModelTransform is the
    // inverse of the forward matrix. pap2mp passes forward → apply inverse.
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;

    // fmod(u.y+2, 2) → mod(u.y+2, 2) (non-negative base; GLSL ES has no fmod)
    float k = mod(u.y + 2.0, 2.0) * 0.5;

    // intensity: Pap getMaskedParameter(u_Intensity*0.01, outPos) → bare intensity.
    float base = pow(10.0, intensity * 20.0);
    k = balance + 0.5 * pow(base, k) / (base / 10.0);  // Pap u_Balance*0.01 → balance

    vec4 outCol = color * vec4(k, k, k, 1.0);
    // Pap literal arg order: clamp(0.0, 1.0, intensity*3.0) = min(1.0, intensity*3.0).
    return mix(color, outCol, clamp(0.0, 1.0, intensity * 3.0));
}
