float grid2dDistance1d(float x, float count) {
    if (abs(x) > 0.5) return abs(x) - 0.5;
    float normalized = ((x + 0.5) * count + 0.5);
    return abs(fract(normalized) - 0.5) / count;
}

float grid2dResponse(float d, float thickness, float blur) {
    return pow(smoothstep(thickness, thickness + blur, d), 0.3);
}

vec4 grid2dGl(vec2 pos, vec2 outPos, int count, float thickness, float glow, vec4 color, mat3 modelTransform) {
    // Pap uploads the FORWARD matrix (`(u_ModelTransform * vec3(pos, 1.0)).xy`),
    // but its manipulator drives the handle inverted. pap2mp stores the INVERSE as
    // `modelTransform` (intuitive drag), so re-invert here to recover Pap's forward
    // application: inverse(modelTransform) == Pap's forward matrix.
    vec2 u = tf(inverse(modelTransform), pos);

    // Pap rescaling: Pap u_Thickness ∈ 0..100; (u_Thickness*0.01)^2 * 0.25
    // → in pap2mp 0..1, simply thickness^2 * 0.25.
    float th = thickness * thickness * 0.25;

    // Pap rescaling: Pap u_Blur ∈ 0..100; u_Blur*0.002
    // → in pap2mp 0..1, glow * 0.2.
    float blur = glow * 0.2;

    float fCount = float(count);
    float d;
    if (abs(u.x) > 0.5 || abs(u.y) > 0.5) {
        d = max(abs(u.x) - 0.5, abs(u.y) - 0.5);
    } else {
        d = min(grid2dDistance1d(u.x, fCount), grid2dDistance1d(u.y, fCount));
    }

    float k = grid2dResponse(d, th, blur);
    vec4 bkgCol = __source__(pos);
    // Pap composite: mix(vec4(mix(bkgCol.rgb, color.rgb, color.a), bkgCol.a), bkgCol, k)
    // — over k blends back to bkgCol (i.e. k=1 means "no line here", k=0 = "on the line").
    // Coverage is 1-k. mergeColor is equivalent on an opaque source, since
    // mix(mix(bkg,C,a), bkg, k) == mix(bkg, C, a*(1-k)); see the alpha divergence note.
    return mergeColor(bkgCol, vec4(color.rgb, color.a * (1.0 - k)));
}
