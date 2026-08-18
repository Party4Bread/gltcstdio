// Signed distance to a triangle (iq); negative inside. Solid arrowheads.
float vfTriangle(vec2 p, vec2 p0, vec2 p1, vec2 p2) {
    vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
    vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0);
    float s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
                     vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
                     vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x)));
    return -sqrt(d.x) * sign(d.y);
}
// Filled arrowhead: tip at rel=0, pointing along unit `od`.
float vfArrowFill(vec2 rel, vec2 od, float ah) {
    vec2 perp = vec2(-od.y, od.x);
    vec2 base = -od * ah;
    return vfTriangle(rel, vec2(0.0), base + perp * ah * 0.42, base - perp * ah * 0.42);
}

vec4 vectorField(vec2 uv, vec2 outPos, int mode, int count, float size, float scaling, vec4 color1, float thickness, float glow, mat3 modelTransform, vec2 outDim) {
    vec4 bkg = __source__(uv);

    float pixel = 2.0 / outDim.y;

    // Grid space: inverse model transform; modelScale converts grid distances back to output units.
    mat3 im = inverse(modelTransform);
    float modelScale = max(length(vec2(modelTransform[0][0], modelTransform[0][1])), 1e-6);
    vec2 g = (im * vec3(uv, 1.0)).xy;

    float cs = 2.0 / float(max(count, 1));   // cell size in grid space (count cells per V2 height)
    vec2 cell = floor(g / cs);
    vec2 gc = (cell + 0.5) * cs;             // own cell centre (arrows never leave their cell)
    vec2 rel = g - gc;

    // Gradient of source luma at the cell centre, sampled in OUTPUT space (half-cell offsets).
    // (__source__ is only rewritten in this main function, so the taps stay inline here.)
    vec2 wc = (modelTransform * vec3(gc, 1.0)).xy;
    float eps = cs * 0.5 * modelScale;
    vec3 lw = vec3(0.299, 0.587, 0.114);
    float gx = dot(__source__(wc + vec2(eps, 0.0)).rgb, lw) - dot(__source__(wc - vec2(eps, 0.0)).rgb, lw);
    float gy = dot(__source__(wc + vec2(0.0, eps)).rgb, lw) - dot(__source__(wc - vec2(0.0, eps)).rgb, lw);
    vec2 grad = vec2(gx, gy);
    float mag = length(grad);

    // Direction: uphill toward bright (0/2), or rotated 90° for flow/iso-lines (1).
    vec2 dir = (mag > 1e-5) ? grad / mag : vec2(1.0, 0.0);
    if (mode == 1) dir = vec2(-dir.y, dir.x);

    // Arrow half-length: uniform vs magnitude-proportional; flat cells fade out entirely.
    float magN = clamp(mag * 2.5, 0.0, 1.0);
    float h = cs * 0.42 * size * mix(1.0, magN, scaling);
    float fade = smoothstep(0.015, 0.06, mag);

    float aa = pixel * 0.75;
    float thinHalf = thickness * 0.011;

    float dThin = 1e9;
    float dFill = 1e9;
    if (fade > 0.0 && h > 1e-4) {
        vec2 tip = dir * h;
        if (mode == 2) {
            // Needle: full shaft + pivot dot, no head.
            dThin = sdSegment(rel, -tip, tip) * modelScale;
            dFill = (sdDisk(rel, cs * 0.07) ) * modelScale;
        } else {
            float ah = min(cs * 0.30 * size, h * 0.9);   // head length
            dThin = sdSegment(rel, -tip, tip - dir * ah * 0.5) * modelScale;
            dFill = vfArrowFill(rel - tip, dir, ah) * modelScale;
        }
    }

    float covThin = (thinHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(thinHalf - aa, thinHalf + aa, dThin));
    float covFill = 1.0 - smoothstep(-aa, aa, dFill);
    float cov = max(covThin, covFill) * fade;

    float dmin = min(dThin, dFill);
    float g2 = (glow > 0.0) ? glow * exp(-max(dmin - thinHalf, 0.0) * 8.0) * (1.0 - cov) * fade : 0.0;

    if (cov <= 0.0 && g2 <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
    outc.rgb += color1.rgb * g2;
    outc.a = max(outc.a, min(g2, 1.0));
    return outc;
}
