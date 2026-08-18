vec4 geomBreak6GL(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, mat3 modelTransform) {
    // Pap rep(): u starts at pos; advance through the model step while the
    // pixel remains inside the central band.
    vec2 u = pos;

    // Inverse-sampling convention (codebase norm, same fix as GeomBreak1GL): step by
    // inverse(modelTransform) — which equals Pap's forward step — so `modelTransform`
    // is a plain placement transform and the standard touch client is natural. Hoisted
    // out of the loop (constant across iterations).
    mat3 gridStep = inverse(modelTransform);

    // sourceDim is the auto-supplied `${name}Dim` (width, height).
    float ratio = sourceDim.x / sourceDim.y;

    // Pap: intensity = getMaskedParameter(u_Intensity*0.01, outPos).
    // pap2mp `intensity` is already 0..1 — no per-pixel masking.

    for (int i = 0; i < count; ++i) {
        // Pap: m = vec2(fmod(u.x/ratio+1.0, 2.0), fmod(u.y+1.0, 2.0)) - vec2(1.0, 1.0)
        // GLSL ES has no `fmod` — use `mod` (equal to fmod for the
        // non-negative central-cell inputs; see header for the edge case).
        vec2 m = vec2(mod(u.x / ratio + 1.0, 2.0), mod(u.y + 1.0, 2.0)) - vec2(1.0, 1.0);
        if (max(abs(m.x), abs(m.y)) > intensity) break;
        // Pap: u = (u_ModelTransform * vec3(u, 1.0)).xy (forward). pap2mp steps by
        // inverse(modelTransform) (== Pap forward step), hoisted to `gridStep` above.
        u = (gridStep * vec3(u, 1.0)).xy;
    }

    return __source__(u);
}
