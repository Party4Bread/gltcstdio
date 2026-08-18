// Rectangle OUTLINE distance (same shape as hudRect in Hud.kt).
float tcdRect(vec2 rel, vec2 hlf) {
    vec2 q = abs(rel) - hlf;
    return abs(length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0));
}
// SDF for a number laid out around rel=(0,0) — same layout logic as hudNumDist (Hud.kt); see
// there for the bounding-box lower-bound rationale (keeps the glow field continuous outside).
// align: 0 centered, 1 ends at x=0, 2 starts at x=0. decimals: fractional digits shown.
float tcdNum(vec2 rel, float value, int decimals, int nintForce, int align, int font, float gscale) {
    bool neg = value < 0.0;
    float av = abs(value);
    float ipart = (decimals == 0) ? floor(av + 0.5) : floor(av);
    if (decimals == 0) av = ipart;
    int nint = 1;
    float tt = ipart;
    for (int i = 0; i < 6; i++) { if (tt >= 10.0) { tt = floor(tt / 10.0); nint++; } }
    if (nintForce > 0) nint = nintForce;
    int ng = nint + (neg ? 1 : 0) + ((decimals > 0) ? (1 + decimals) : 0);
    float gadv = 0.88;
    float w = float(ng) * gadv * gscale;
    float x = rel.x + ((align == 1) ? w : ((align == 2) ? 0.0 : w * 0.5));
    float dx = max(max(-x, x - w), 0.0);
    float dy = max(abs(rel.y) - 0.75 * gscale, 0.0);
    if (dx > 0.0 || dy > 0.0) return length(vec2(dx, dy)) + 0.35 * gscale;
    float lx = x / gscale;
    int slot = int(floor(lx / gadv));
    if (slot < 0 || slot >= ng) return 0.35 * gscale;
    int ch = ndfCharForSlot(slot, nint, neg, decimals, ipart, av);
    if (ch == 12) return 0.35 * gscale;
    vec2 gp = vec2(lx - (float(slot) + 0.5) * gadv, rel.y / gscale);   // +y-up space (Hud uses -rel.y)
    return ((font == 0) ? ndfDigital(ch, gp) : ndfCurved(ch, gp)) * gscale;
}
// Dimension line a->b with stroke arrowheads at both ends (tips at a and b, barbs inward).
float tcdArrow(vec2 p, vec2 a, vec2 b, float ah) {
    vec2 ab = b - a;
    float l = max(length(ab), 1e-6);
    vec2 dir = ab / l;
    vec2 pp = vec2(-dir.y, dir.x);
    float d = sdSegment(p, a, b);
    d = min(d, sdSegment(p, a, a + dir * ah + pp * ah * 0.38));
    d = min(d, sdSegment(p, a, a + dir * ah - pp * ah * 0.38));
    d = min(d, sdSegment(p, b, b - dir * ah + pp * ah * 0.38));
    d = min(d, sdSegment(p, b, b - dir * ah - pp * ah * 0.38));
    return d;
}
// Print registration mark: circle + full cross through it.
float tcdReg(vec2 rel, float r) {
    float d = abs(length(rel) - r);
    vec2 pa = abs(rel);
    d = min(d, sdSegment(pa, vec2(0.0, 0.0), vec2(r * 1.8, 0.0)));
    d = min(d, sdSegment(pa, vec2(0.0, 0.0), vec2(0.0, r * 1.8)));
    return d;
}
// Crosshair (centre mark): small circle + 4 hairs starting OUTSIDE the circle.
float tcdCross(vec2 rel, float r) {
    float d = abs(length(rel) - r);
    vec2 pa = abs(rel);
    d = min(d, sdSegment(pa, vec2(r * 0.45, 0.0), vec2(r * 1.8, 0.0)));
    d = min(d, sdSegment(pa, vec2(0.0, r * 0.45), vec2(0.0, r * 1.8)));
    return d;
}

vec4 callouts(vec2 uv, vec2 outPos, int elements, int font, float size, float shapeAspectRatio, vec4 color1, int count, float randomSeed, float glow, float thickness, mat3 modelTransform, mat3 axisTransform, vec2 outDim) {
    mat3 im = inverse(modelTransform);
    vec2 u = tf(im, uv);
    vec4 bkg = __source__(uv);

    float pixel = 2.0 / outDim.y;
    float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;
    u.y = -u.y;   // work in +y-up drafting space (screen V2 has +y down); aa computed pre-flip
    float ar = shapeAspectRatio;

    bool showFrame  = (elements & 1) != 0;
    bool showDims   = (elements & 2) != 0;
    bool showCalls  = (elements & 4) != 0;
    bool showReg    = (elements & 8) != 0;
    bool showTitle  = (elements & 16) != 0;
    bool showCross  = (elements & 32) != 0;
    bool showFig    = (elements & 64) != 0;
    bool showRulers = (elements & 128) != 0;

    float modelScale = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    if (modelScale < 1e-5) modelScale = 1e-5;
    float vb = 1.0 / modelScale;
    float thickHalf = thickness * 0.020 * vb;
    float thinHalf  = thickness * 0.011 * vb;
    float digitHalf = 0.0028 * vb;
    float gscale    = 0.042 * vb * size;

    // Subject region from axisTransform: translation = centre, scale = size. The dimensions
    // measure this region and the callout targets live inside it.
    float rs = length(vec2(axisTransform[0][0], axisTransform[0][1]));
    if (rs < 1e-5) rs = 1.0;
    vec2 rc = vec2(axisTransform[2][0], -axisTransform[2][1]);   // y negated: drag up = region up
    vec2 rh = vec2(0.52, ar * 0.42) * rs;

    float glowMargin = (glow > 0.006) ? clamp(log(glow / 0.006) * 0.125, 0.15, 1.0) : 0.15;
    bool inBox = abs(u.x) <= 1.0 + glowMargin + aa && abs(u.y) <= ar + glowMargin + aa;

    float dThick = 1e9;
    float dThin  = 1e9;
    float dDigit = 1e9;

    if (inBox) {
        // ---- Sheet frame: outer+inner border, zone ticks, zone digits along the top ----
        if (showFrame) {
            dThick = min(dThick, tcdRect(u, vec2(0.98, ar * 0.98)));
            dThin  = min(dThin,  tcdRect(u, vec2(0.94, ar * 0.94)));
            vec2 pv = vec2(u.x, abs(u.y));
            for (int iz = 1; iz < 4; iz++) {
                float xz = -0.98 + 0.49 * float(iz);
                dThin = min(dThin, sdSegment(pv, vec2(xz, ar * 0.94), vec2(xz, ar * 0.98)));
            }
            vec2 ph = vec2(abs(u.x), u.y);
            for (int iz = 1; iz < 3; iz++) {
                float yz = -ar * 0.98 + ar * 0.6533 * float(iz);
                dThin = min(dThin, sdSegment(ph, vec2(0.94, yz), vec2(0.98, yz)));
            }
            for (int iz = 0; iz < 4; iz++) {
                float cx = -0.735 + 0.49 * float(iz);
                dDigit = min(dDigit, tcdNum(vec2(u.x - cx, u.y - ar * 0.96), float(iz + 1), 0, 0, 0, font, gscale * 0.45));
            }
        }

        // ---- Dimension lines: horizontal below + vertical right of the subject region ----
        if (showDims) {
            vec2 a = rc - rh;
            vec2 b = rc + rh;
            float yD = a.y - 0.14;
            dThin = min(dThin, sdSegment(u, vec2(a.x, a.y - 0.02), vec2(a.x, yD - 0.03)));
            dThin = min(dThin, sdSegment(u, vec2(b.x, a.y - 0.02), vec2(b.x, yD - 0.03)));
            dThin = min(dThin, tcdArrow(u, vec2(a.x, yD), vec2(b.x, yD), 0.035));
            float valW = floor((b.x - a.x) * 100.0 + 0.5);
            dDigit = min(dDigit, tcdNum(vec2(u.x - rc.x, u.y - (yD + 0.045)), valW, 0, 0, 0, font, gscale * 0.7));
            float xD = b.x + 0.14;
            dThin = min(dThin, sdSegment(u, vec2(b.x + 0.02, a.y), vec2(xD + 0.03, a.y)));
            dThin = min(dThin, sdSegment(u, vec2(b.x + 0.02, b.y), vec2(xD + 0.03, b.y)));
            dThin = min(dThin, tcdArrow(u, vec2(xD, a.y), vec2(xD, b.y), 0.035));
            float valH = floor((b.y - a.y) * 100.0 + 0.5);
            vec2 pr = vec2(u.y - rc.y, xD + 0.065 - u.x);
            dDigit = min(dDigit, tcdNum(pr, valH, 0, 0, 0, font, gscale * 0.7));
        }

        // ---- Leader-line callouts (45-degree elbow out to the margin, circled number) ----
        if (showCalls || showCross) {
            for (int i = 0; i < 12; i++) {
                if (i >= count) break;
                vec2 h = rand2relSeeded(vec2(float(i) * 1.61 + 2.3, 5.1), randomSeed) + vec2(0.5);
                vec2 t = rc + (h - 0.5) * 2.0 * rh * 0.82;
                if (showCross) {
                    dThin = min(dThin, tcdCross(u - t, 0.028));
                }
                if (showCalls) {
                    float side = (t.x >= rc.x) ? 1.0 : -1.0;
                    // margin slot: rank of this target among same-side targets by height (top first);
                    // ranked ends mean leaders never cross and the number circles never overlap.
                    int slot = 0;
                    int nSide = 0;
                    for (int j = 0; j < 12; j++) {
                        if (j >= count) break;
                        vec2 hj = rand2relSeeded(vec2(float(j) * 1.61 + 2.3, 5.1), randomSeed) + vec2(0.5);
                        vec2 tj = rc + (hj - 0.5) * 2.0 * rh * 0.82;
                        if (((tj.x >= rc.x) ? 1.0 : -1.0) == side) {
                            nSide++;
                            if (tj.y > t.y || (tj.y == t.y && j < i)) slot++;
                        }
                    }
                    float ey = ar * 0.55 - (float(slot) + 0.5) * ar * 1.1 / float(nSide);
                    float xEnd = side * 0.80;
                    // 45-degree elbow: diagonal from the target to the slot row, then horizontal out.
                    float ex = t.x + side * abs(ey - t.y);
                    if (side > 0.0) ex = min(ex, xEnd - 0.02); else ex = max(ex, xEnd + 0.02);
                    vec2 e = vec2(ex, ey);
                    dThin = min(dThin, sdSegment(u, t, e));
                    dThin = min(dThin, sdSegment(u, e, vec2(xEnd, ey)));
                    dThick = min(dThick, sdDisk(u - t, 0.011));
                    vec2 cc = vec2(xEnd + side * 0.052, ey);
                    dThin = min(dThin, abs(sdDisk(u - cc, 0.048)));
                    dDigit = min(dDigit, tcdNum(u - cc, float(i + 1), 0, 0, 0, font, gscale * 0.65));
                }
            }
        }

        // ---- Registration marks (4 corners of the drawing area) ----
        if (showReg) {
            dThin = min(dThin, tcdReg(vec2(abs(u.x) - 0.885, abs(u.y) - ar * 0.885), 0.026));
        }

        // ---- Title block (bottom-right, against the inner frame) ----
        if (showTitle) {
            vec2 tc = vec2(0.62, -ar * 0.83);
            vec2 th = vec2(0.32, ar * 0.11);
            dThick = min(dThick, tcdRect(u - tc, th));
            dThin = min(dThin, sdSegment(u, vec2(0.30, -ar * 0.83), vec2(0.94, -ar * 0.83)));
            dThin = min(dThin, sdSegment(u, vec2(0.52, -ar * 0.72), vec2(0.52, -ar * 0.83)));
            dThin = min(dThin, sdSegment(u, vec2(0.76, -ar * 0.72), vec2(0.76, -ar * 0.83)));
            float h3 = rand2relSeeded(vec2(3.7, 9.2), randomSeed).x + 0.5;
            dDigit = min(dDigit, tcdNum(vec2(u.x - 0.41, u.y + ar * 0.775), floor(10.0 + h3 * 89.0), 0, 0, 0, font, gscale * 0.55));
            dDigit = min(dDigit, tcdNum(vec2(u.x - 0.64, u.y + ar * 0.775), float(count), 0, 0, 0, font, gscale * 0.55));
            dDigit = min(dDigit, tcdNum(vec2(u.x - 0.85, u.y + ar * 0.775), 1.2, 1, 0, 0, font, gscale * 0.55));
            float h4 = rand2relSeeded(vec2(8.1, 2.6), randomSeed).y + 0.5;
            dDigit = min(dDigit, tcdNum(vec2(u.x - 0.62, u.y + ar * 0.885), floor(1000.0 + h4 * 8999.0), 0, 0, 0, font, gscale * 0.8));
        }

        // ---- Figure number (top-left, underlined) ----
        if (showFig) {
            float h5 = rand2relSeeded(vec2(6.4, 4.9), randomSeed).x + 0.5;
            dDigit = min(dDigit, tcdNum(vec2(u.x + 0.80, u.y - ar * 0.84), floor(1.0 + h5 * 8.9), 0, 0, 0, font, gscale * 1.1));
            dThin = min(dThin, sdSegment(u, vec2(-0.86, ar * 0.775), vec2(-0.74, ar * 0.775)));
        }

        // ---- Rulers (top + left, hanging off the inner frame) ----
        if (showRulers) {
            float rstep = 0.05;
            float xr = floor(u.x / rstep + 0.5) * rstep;
            if (abs(xr) <= 0.9) {
                bool maj = mod(floor(abs(xr) / rstep + 0.5), 5.0) < 0.5;
                dThin = min(dThin, sdSegment(u, vec2(xr, ar * 0.94), vec2(xr, ar * (maj ? 0.885 : 0.91))));
            }
            float yr = floor(u.y / rstep + 0.5) * rstep;
            if (abs(yr) <= ar * 0.9) {
                bool majy = mod(floor(abs(yr) / rstep + 0.5), 5.0) < 0.5;
                dThin = min(dThin, sdSegment(u, vec2(-0.94, yr), vec2(majy ? -0.885 : -0.91, yr)));
            }
        }
    }

    float covThick = (thickHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(thickHalf - aa, thickHalf + aa, dThick));
    float covThin  = (thinHalf  <= 0.0) ? 0.0 : (1.0 - smoothstep(thinHalf - aa, thinHalf + aa, dThin));
    float covDigit = 1.0 - smoothstep(digitHalf - aa, digitHalf + aa, dDigit);
    float cov = max(covThick, max(covThin, covDigit));

    float dmin = min(dDigit, (thickHalf <= 0.0) ? 1e9 : min(dThick, dThin));
    float g = (glow > 0.0) ? glow * exp(-max(dmin - max(thickHalf, digitHalf), 0.0) * 8.0) * (1.0 - cov) : 0.0;

    if (cov <= 0.0 && g <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
    outc.rgb += color1.rgb * g;
    outc.a = max(outc.a, min(g, 1.0));
    return outc;
}
