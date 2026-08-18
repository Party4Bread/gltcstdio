float graphCurveY(int mode, float xl) {
    if (mode == 2) return log(max(xl, 1e-4));
    if (mode == 3) return exp(clamp(xl, -30.0, 7.0));
    if (mode == 4) return sin(xl) + 0.5 * sin(2.0 * xl) + 0.333 * sin(3.0 * xl) + 0.25 * sin(4.0 * xl);
    return sin(xl);
}
float graphCurveEval(int mode, float x, mat3 ct) {
    float cSx = ct[0][0]; if (abs(cSx) < 1e-5) cSx = 1e-5;
    return ct[1][1] * graphCurveY(mode, (x - ct[2][0] * 3.0) / cSx) + (-ct[2][1] * 3.0);
}
// f(x) evaluated the way the curve is DRAWN, so the diff area edges line up:
//   segments -> linear interp between major samples; histogram -> step at bin; else -> continuous.
float graphCurveYAt(int mode, int render, float x, mat3 ct, float minorX, float Lx) {
    if (render >= 5) {
        float xa = floor(x / Lx) * Lx;
        return mix(graphCurveEval(mode, xa, ct), graphCurveEval(mode, xa + Lx, ct), (x - xa) / Lx);
    } else if (render >= 2 && render <= 4) {
        return graphCurveEval(mode, floor(x / minorX + 0.5) * minorX, ct);
    }
    return graphCurveEval(mode, x, ct);
}
vec2 graphCurve(int mode, int render, mat3 atF, vec2 u, vec2 dpos, float minorX, float Lx, mat3 ct) {
    float dCurve = 1e9, dDot = 1e9;
    if (render >= 2 && render <= 4) {                    // histogram family
        float xc = floor(dpos.x / minorX + 0.5) * minorX;
        float val = graphCurveEval(mode, xc, ct);
        float barW = minorX * 0.4;
        vec2 c0 = tf(atF, vec2(xc - barW, 0.0));
        vec2 c1 = tf(atF, vec2(xc + barW, val));
        vec2 lo = min(c0, c1), hi = max(c0, c1);
        vec2 ctr = (lo + hi) * 0.5, hlf = (hi - lo) * 0.5;
        vec2 q = abs(u - ctr) - hlf;
        dCurve = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0);
    } else if (render >= 5) {                            // segments (+ dots for 6/7)
        float j0 = floor(dpos.x / Lx);
        for (int s = -1; s <= 1; s++) {
            float xa = (j0 + float(s)) * Lx;
            float xb = xa + Lx;
            vec2 A = tf(atF, vec2(xa, graphCurveEval(mode, xa, ct)));
            vec2 C = tf(atF, vec2(xb, graphCurveEval(mode, xb, ct)));
            dCurve = min(dCurve, sdSegment(u, A, C));
        }
        if (render >= 6) {
            float kx = floor(dpos.x / Lx + 0.5) * Lx;
            vec2 P = tf(atF, vec2(kx, graphCurveEval(mode, kx, ct)));
            dDot = (render == 6) ? length(u - P) : max(abs(u.x - P.x), abs(u.y - P.y));
        }
    } else {                                             // line (render == 1)
        float j0 = floor(dpos.x / minorX);
        for (int s = -1; s <= 1; s++) {
            float xa = (j0 + float(s)) * minorX;
            float xm = xa + minorX * 0.5;
            float xb = xa + minorX;
            vec2 A = tf(atF, vec2(xa, graphCurveEval(mode, xa, ct)));
            vec2 M = tf(atF, vec2(xm, graphCurveEval(mode, xm, ct)));
            vec2 C = tf(atF, vec2(xb, graphCurveEval(mode, xb, ct)));
            vec2 Bc = 2.0 * M - 0.5 * (A + C);
            dCurve = min(dCurve, ndfSdBezier(u, A, Bc, C));
        }
    }
    return vec2(dCurve, dDot);
}
vec2 graphCurveCov(int render, float dCurve, float dDot, float curveHalf, float lineHalf, vec2 u, float aa, float vb) {
    float covCurve = 0.0, covB = 0.0;
    if (render == 1 || render == 5) {                    // line / plain segments
        covCurve = 1.0 - smoothstep(curveHalf - aa, curveHalf + aa, dCurve);
    } else if (render == 2) {                            // histogram fill
        covCurve = 1.0 - smoothstep(-aa, aa, dCurve);
    } else if (render == 3) {                            // histogram + axis-color border
        covCurve = 1.0 - smoothstep(-aa, aa, dCurve);
        covB = 1.0 - smoothstep(lineHalf - aa, lineHalf + aa, abs(dCurve));
    } else if (render == 4) {                            // curveColor box + hatch
        float outline = 1.0 - smoothstep(curveHalf - aa, curveHalf + aa, abs(dCurve));
        float hs = 0.025 * vb;
        float t = (u.x - u.y);
        float hd = abs(t - floor(t / hs + 0.5) * hs) / 1.41421356;
        float hatch = (dCurve < 0.0) ? (1.0 - smoothstep(curveHalf - aa, curveHalf + aa, hd)) : 0.0;
        covCurve = max(outline, hatch);
    } else {                                             // 6/7 segments + dots
        covCurve = 1.0 - smoothstep(curveHalf - aa, curveHalf + aa, dCurve);
        float dotR = curveHalf * 2.5;
        covCurve = max(covCurve, 1.0 - smoothstep(dotR - aa, dotR + aa, dDot));
    }
    return vec2(covCurve, covB);
}
// Continuous distance to a centered signed-integer label laid out around rel=(0,0) — ported from
// Hud's hudNumDist so the glow halo around numbers stays smooth instead of hard-clipping to the
// glyph box (which left rectangular halos). Inside the box it returns the true glyph SDF; outside,
// a conservative lower bound; and in the inter-glyph gaps / spaces a 0.35*gscale floor that holds
// the bound above the coverage threshold (else the box perimeter renders as a hairline rectangle).
// Coverage is unaffected: the floor is well above digitHalf, so gaps still read as no-coverage.
float graphNumDist(vec2 rel, int value, int font, float gscale) {
    bool neg = value < 0;
    int av = neg ? -value : value;
    int nint = 1; int tt = av;
    for (int i = 0; i < 6; i++) { if (tt >= 10) { tt = tt / 10; nint++; } }
    int ng = nint + (neg ? 1 : 0);
    float gadv = 0.88;
    float w = float(ng) * gadv * gscale;
    float x = rel.x + w * 0.5;
    float dx = max(max(-x, x - w), 0.0);
    float dy = max(abs(rel.y) - 0.75 * gscale, 0.0);
    if (dx > 0.0 || dy > 0.0) return length(vec2(dx, dy)) + 0.35 * gscale;
    float lx = x / gscale;
    int slot = int(floor(lx / gadv));
    if (slot < 0 || slot >= ng) return 0.35 * gscale;
    int ch = ndfCharForSlot(slot, nint, neg, 0, float(av), float(av));
    if (ch == 12) return 0.35 * gscale;
    vec2 gp = vec2(lx - (float(slot) + 0.5) * gadv, -rel.y / gscale);
    return ((font == 0) ? ndfDigital(ch, gp) : ndfCurved(ch, gp)) * gscale;
}

vec4 graph(vec2 uv, vec2 outPos, int axisMode, int majorGrid, int minorGrid, int font, float size, float shapeAspectRatio, vec4 color1, int curveMode, int curveRender, vec4 curveColor, mat3 curveTransform, float curveThickness, int curveMode2, int curveRender2, vec4 curveColor2, mat3 curveTransform2, float curveThickness2, int diffMode, vec4 diffColor, float glow, float thickness, mat3 modelTransform, mat3 axisTransform, vec2 outDim) {
    mat3 im = inverse(modelTransform);
    vec2 u = tf(im, uv);
    vec4 bkg = __source__(uv);

    float pixel = 2.0 / outDim.y;
    float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;

    float ar = shapeAspectRatio;

    bool showX      = (axisMode & 1)  != 0;
    bool showY      = (axisMode & 2)  != 0;
    bool showNum    = (axisMode & 4)  != 0;
    bool largeTicks = (axisMode & 8)  != 0;
    bool showBorder = (axisMode & 16) != 0;

    float modelScale = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    if (modelScale < 1e-5) modelScale = 1e-5;
    float vb = 1.0 / modelScale;
    float lineHalf  = thickness * 0.025 * vb;
    float gridHalf  = lineHalf * 0.5;
    float digitHalf = 0.003 * vb;
    float gscale    = 0.042 * vb * size;
    float gadv      = 0.88;
    float glyphHalf = 0.7 * gscale;
    // How far the glow reaches past a glyph (glow·exp(-8d) < ~0.006 beyond this). Used to size the
    // per-label perf gates so they sit exactly at the halo's fade distance — tight/cheap when glow
    // is low, wide enough to never clip a visible halo when it's high (residual there is ~0.006).
    float glowReach = (glow > 0.006) ? min(log(glow / 0.006) * 0.125, 1.0) : 0.0;
    float gap       = 0.012 * vb * size;
    float tickMinor = 0.014 * vb * size;
    float tickMajor = 0.028 * vb * size;

    // axisTransform with Y column negated => data +y up
    mat3 atF = mat3(vec3(axisTransform[0][0], axisTransform[0][1], axisTransform[0][2]),
                    vec3(-axisTransform[1][0], -axisTransform[1][1], -axisTransform[1][2]),
                    vec3(axisTransform[2][0], axisTransform[2][1], axisTransform[2][2]));
    mat3 iat = inverse(atF);
    vec2 dpos = tf(iat, u);
    float sxLen = length(vec2(atF[0][0], atF[0][1]));
    float syLen = length(vec2(atF[1][0], atF[1][1]));
    if (sxLen < 1e-5) sxLen = 1.0;
    if (syLen < 1e-5) syLen = 1.0;
    vec2 dirX = vec2(atF[0][0], atF[0][1]) / sxLen;
    vec2 dirY = vec2(atF[1][0], atF[1][1]) / syLen;
    vec2 obox = tf(atF, vec2(0.0, 0.0));

    float minLabelV = max(0.3 * size, 0.04);
    float unitVx = sxLen * modelScale;
    float unitVy = syLen * modelScale;
    float rawx = minLabelV / max(unitVx, 1e-6);
    float bx = pow(10.0, floor(log(max(rawx, 1.0)) / log(10.0)));
    float mxn = rawx / bx;
    float Lx = max(((mxn <= 1.0) ? 1.0 : (mxn <= 2.0) ? 2.0 : (mxn <= 5.0) ? 5.0 : 10.0) * bx, 1.0);
    float rawy = minLabelV / max(unitVy, 1e-6);
    float by = pow(10.0, floor(log(max(rawy, 1.0)) / log(10.0)));
    float myn = rawy / by;
    float Ly = max(((myn <= 1.0) ? 1.0 : (myn <= 2.0) ? 2.0 : (myn <= 5.0) ? 5.0 : 10.0) * by, 1.0);
    float minorX = Lx / 5.0;
    float minorY = Ly / 5.0;

    bool inBox = abs(u.x) <= 1.0 + aa && abs(u.y) <= ar + aa;

    float dLine  = 1e9;
    float dGrid  = 1e9;
    float covGrid = 0.0;
    float dDigit = 1e9;
    float covDiff = 0.0;

    if (showBorder) {
        dLine = min(dLine, sdSegment(u, vec2(-1.0, -ar), vec2( 1.0, -ar)));
        dLine = min(dLine, sdSegment(u, vec2(-1.0,  ar), vec2( 1.0,  ar)));
        dLine = min(dLine, sdSegment(u, vec2(-1.0, -ar), vec2(-1.0,  ar)));
        dLine = min(dLine, sdSegment(u, vec2( 1.0, -ar), vec2( 1.0,  ar)));
    }

    if (inBox) {
        // ---- Grid ----
        for (int level = 0; level < 2; level++) {
            int el = (level == 0) ? majorGrid : minorGrid;
            if (el == 0) continue;
            if (level == 1 && (el == 2 || el == 6 || el == 7)) continue;
            float gLx = (level == 0) ? Lx : minorX;
            float gLy = (level == 0) ? Ly : minorY;
            float d; float w = gridHalf;
            if (el == 1 || el == 2) {
                float dx = abs(dpos.x - floor(dpos.x / gLx + 0.5) * gLx) * sxLen;
                float dy = abs(dpos.y - floor(dpos.y / gLy + 0.5) * gLy) * syLen;
                d = min(dx, dy);
                w = (el == 2) ? lineHalf : gridHalf;
            } else if (el >= 3 && el <= 7) {
                float arm = (el == 3 ? 0.005 : (el == 4 ? 0.01 : (el == 5 ? 0.02 : (el == 6 ? 0.045 : 0.09)))) * vb;
                vec2 ci = tf(atF, vec2(floor(dpos.x / gLx + 0.5) * gLx, floor(dpos.y / gLy + 0.5) * gLy));
                d = min(sdSegment(u, ci - dirY * arm, ci + dirY * arm), sdSegment(u, ci - dirX * arm, ci + dirX * arm));
                w = gridHalf;
            } else if (el == 8 || el == 9) {
                vec2 ci = tf(atF, vec2(floor(dpos.x / gLx + 0.5) * gLx, floor(dpos.y / gLy + 0.5) * gLy));
                d = length(u - ci);
                w = (el == 8) ? lineHalf : gridHalf;
            } else {
                vec2 ci = tf(atF, vec2(floor(dpos.x / gLx + 0.5) * gLx, floor(dpos.y / gLy + 0.5) * gLy));
                d = max(abs(u.x - ci.x), abs(u.y - ci.y));
                w = (el == 10) ? lineHalf : gridHalf;
            }
            covGrid = max(covGrid, 1.0 - smoothstep(w - aa, w + aa, d));
            dGrid = min(dGrid, d);
        }

        // ---- Diff area between the two curves (needs both defined) ----
        if (diffMode >= 1 && curveMode >= 1 && curveMode2 >= 1) {
            if (diffMode == 3) {                                       // histo: bar lo..hi per bin
                float xc = floor(dpos.x / minorX + 0.5) * minorX;
                float a = graphCurveYAt(curveMode, curveRender, xc, curveTransform, minorX, Lx);
                float b = graphCurveYAt(curveMode2, curveRender2, xc, curveTransform2, minorX, Lx);
                vec2 c0 = tf(atF, vec2(xc - minorX * 0.4, min(a, b)));
                vec2 c1 = tf(atF, vec2(xc + minorX * 0.4, max(a, b)));
                vec2 lo = min(c0, c1), hi = max(c0, c1);
                vec2 ctr = (lo + hi) * 0.5, hlf = (hi - lo) * 0.5;
                vec2 q = abs(u - ctr) - hlf;
                float dBar = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0);
                covDiff = 1.0 - smoothstep(-aa, aa, dBar);
            } else {                                                   // fill / hatch: band matching each render
                float a = graphCurveYAt(curveMode, curveRender, dpos.x, curveTransform, minorX, Lx);
                float b = graphCurveYAt(curveMode2, curveRender2, dpos.x, curveTransform2, minorX, Lx);
                float dBand = max(min(a, b) - dpos.y, dpos.y - max(a, b)) * syLen;
                float fill = 1.0 - smoothstep(-aa, aa, dBand);
                if (diffMode == 2) {
                    covDiff = fill;
                } else {                                               // hatch
                    float dhh = 0.004 * vb;
                    float t = (u.x - u.y);
                    float hd = abs(t - floor(t / (0.025 * vb) + 0.5) * (0.025 * vb)) / 1.41421356;
                    covDiff = (dBand < 0.0) ? (1.0 - smoothstep(dhh - aa, dhh + aa, hd)) : 0.0;
                }
            }
        }

        // ---- Axes ----
        if (showY && abs(obox.x) <= 1.0) dLine = min(dLine, abs(dpos.x) * sxLen);
        if (showX && abs(obox.y) <= ar)  dLine = min(dLine, abs(dpos.y) * syLen);

        // ---- Ticks ----
        if (showX && abs(obox.y) <= ar) {
            float kx = floor(dpos.x / minorX + 0.5) * minorX;
            bool atOrigin = abs(kx) < 1e-6;
            if (!atOrigin || !showY) {
                vec2 c = tf(atF, vec2(kx, 0.0));
                bool major = atOrigin || (largeTicks && abs(kx / Lx - floor(kx / Lx + 0.5)) < 0.01);
                float tl = major ? tickMajor : tickMinor;
                if (abs(c.x) <= 1.0) dLine = min(dLine, sdSegment(u, c - dirY * tl, c + dirY * tl));
            }
        }
        if (showY && abs(obox.x) <= 1.0) {
            float ky = floor(dpos.y / minorY + 0.5) * minorY;
            bool atOrigin = abs(ky) < 1e-6;
            if (!atOrigin || !showX) {
                vec2 c = tf(atF, vec2(0.0, ky));
                bool major = atOrigin || (largeTicks && abs(ky / Ly - floor(ky / Ly + 0.5)) < 0.01);
                float tl = major ? tickMajor : tickMinor;
                if (abs(c.y) <= ar) dLine = min(dLine, sdSegment(u, c - dirX * tl, c + dirX * tl));
            }
        }

        // ---- Numeric labels (continuous distance so the glow halo stays smooth) ----
        if (showNum && showX && abs(obox.y) <= ar) {
            float rowY = obox.y - tickMajor - glyphHalf - gap;
            if (abs(u.y - rowY) < glyphHalf + glowReach) {   // loose gate: covers the halo's fade past the glyph box
                float k0 = floor(dpos.x / Lx + 0.5);
                for (int dk = -1; dk <= 1; dk++) {
                    float kx = (k0 + float(dk)) * Lx;
                    int ival = int(floor(kx + 0.5));
                    if (ival == 0 && showY) continue;
                    vec2 c = tf(atF, vec2(kx, 0.0));
                    if (abs(c.x) > 1.0) continue;
                    dDigit = min(dDigit, graphNumDist(vec2(u.x - c.x, u.y - rowY), ival, font, gscale));
                }
            }
        }
        if (showNum && showY && abs(obox.x) <= 1.0) {
            float k0 = floor(dpos.y / Ly + 0.5);
            for (int dk = -1; dk <= 1; dk++) {
                float ky = (k0 + float(dk)) * Ly;
                int ival = int(floor(ky + 0.5));
                if (ival == 0 && showX) continue;
                vec2 c = tf(atF, vec2(0.0, ky));
                if (abs(c.y) > ar) continue;
                if (abs(u.y - c.y) > glyphHalf + glowReach) continue;
                bool ln = ival < 0; int av = ln ? -ival : ival;
                int nint = 1; int tt = av;
                for (int i = 0; i < 6; i++) { if (tt >= 10) { tt = tt / 10; nint++; } }
                int ng = nint + (ln ? 1 : 0);
                float labelW = float(ng) * gadv * gscale;
                float centerX = obox.x - tickMajor - gap - labelW * 0.5;
                if (abs(u.x - centerX) > labelW * 0.5 + glowReach) continue;
                dDigit = min(dDigit, graphNumDist(vec2(u.x - centerX, u.y - c.y), ival, font, gscale));
            }
        }
    }

    // ---- Curve coverages ----
    float covCurve = 0.0, covCB = 0.0, dC = 1e9;
    if (inBox && curveMode >= 1 && curveRender >= 1 && curveThickness > 0.0) {
        float curveHalf = curveThickness * 0.025 * vb;
        vec2 dd = graphCurve(curveMode, curveRender, atF, u, dpos, minorX, Lx, curveTransform);
        dC = dd.x;
        vec2 cc = graphCurveCov(curveRender, dd.x, dd.y, curveHalf, lineHalf, u, aa, vb);
        covCurve = cc.x; covCB = cc.y;
    }
    float covCurve2 = 0.0, covCB2 = 0.0, dC2 = 1e9;
    if (inBox && curveMode2 >= 1 && curveRender2 >= 1 && curveThickness2 > 0.0) {
        float curveHalf2 = curveThickness2 * 0.025 * vb;
        vec2 dd = graphCurve(curveMode2, curveRender2, atF, u, dpos, minorX, Lx, curveTransform2);
        dC2 = dd.x;
        vec2 cc = graphCurveCov(curveRender2, dd.x, dd.y, curveHalf2, lineHalf, u, aa, vb);
        covCurve2 = cc.x; covCB2 = cc.y;
    }

    float covLine  = (lineHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(lineHalf - aa, lineHalf + aa, dLine));
    if (lineHalf <= 0.0) covGrid = 0.0;
    float covDigit = 1.0 - smoothstep(digitHalf - aa, digitHalf + aa, dDigit);
    float cov = max(max(covLine, covGrid), covDigit);

    float dmin = (lineHalf <= 0.0) ? dDigit : min(dLine, min(dGrid, dDigit));
    float g   = (glow > 0.0) ? glow * exp(-max(dmin - max(lineHalf, digitHalf), 0.0) * 8.0) * (1.0 - cov) : 0.0;
    float gc1 = (glow > 0.0 && curveRender  >= 1 && curveThickness  > 0.0) ? glow * exp(-max(dC  - curveThickness  * 0.025 * vb, 0.0) * 8.0) * (1.0 - covCurve)  : 0.0;
    float gc2 = (glow > 0.0 && curveRender2 >= 1 && curveThickness2 > 0.0) ? glow * exp(-max(dC2 - curveThickness2 * 0.025 * vb, 0.0) * 8.0) * (1.0 - covCurve2) : 0.0;

    if (cov <= 0.0 && covCurve <= 0.0 && covCurve2 <= 0.0 && covCB <= 0.0 && covCB2 <= 0.0 && covDiff <= 0.0 && g <= 0.002 && gc1 <= 0.002 && gc2 <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(diffColor.rgb, diffColor.a * covDiff));       // diff first (behind)
    outc = mergeColor(outc, vec4(color1.rgb, color1.a * cov));                     // grid / axes / labels
    outc.rgb += color1.rgb * g;
    outc = mergeColor(outc, vec4(curveColor.rgb, curveColor.a * covCurve));        // curve 1
    outc.rgb += curveColor.rgb * gc1;
    outc = mergeColor(outc, vec4(color1.rgb, color1.a * covCB));
    outc = mergeColor(outc, vec4(curveColor2.rgb, curveColor2.a * covCurve2));     // curve 2
    outc.rgb += curveColor2.rgb * gc2;
    outc = mergeColor(outc, vec4(color1.rgb, color1.a * covCB2));
    outc.a = max(outc.a, min(max(g, max(gc1, gc2)), 1.0));
    return outc;
}
