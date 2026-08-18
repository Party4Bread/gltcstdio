float hudRect(vec2 rel, vec2 hlf) {
    vec2 q = abs(rel) - hlf;
    return abs(length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0));
}
// SDF for a number laid out around rel=(0,0). align: 0 centered, 1 ends at x=0, 2 starts at x=0.
// nintForce > 0 pads/clips the integer part to that many digits (leading zeros, e.g. headings).
// Outside the number's bounding box it returns a conservative lower-bound distance instead of a
// sentinel, so the glow field stays continuous (no rectangular seams).
float hudNumDist(vec2 rel, float value, int decimals, int nintForce, int align, int font, float gscale) {
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
    // The 0.35*gscale floor keeps the bound above the digit coverage threshold right at the box
    // edge (else the perimeter itself renders as a hairline rectangle around every number).
    if (dx > 0.0 || dy > 0.0) return length(vec2(dx, dy)) + 0.35 * gscale;
    float lx = x / gscale;
    int slot = int(floor(lx / gadv));
    if (slot < 0 || slot >= ng) return 0.35 * gscale;
    int ch = ndfCharForSlot(slot, nint, neg, decimals, ipart, av);
    if (ch == 12) return 0.35 * gscale;
    vec2 gp = vec2(lx - (float(slot) + 0.5) * gadv, -rel.y / gscale);
    return ((font == 0) ? ndfDigital(ch, gp) : ndfCurved(ch, gp)) * gscale;
}
// One pitch-ladder rung in rung-local coords (qa.x already mirrored). v>0: solid bar + end tick
// toward the horizon (below); v<0: dashed bar + tick up; v==0: plain horizon bar.
float hudLadderBar(vec2 qa, float v, float gap, float W, float tick) {
    float d = 1e9;
    if (v > 0.5) {
        d = sdSegment(qa, vec2(gap, 0.0), vec2(W, 0.0));
        d = min(d, sdSegment(qa, vec2(W, 0.0), vec2(W, tick)));
    } else if (v < -0.5) {
        float dashP = 0.085, dashOn = 0.05;
        float idx = floor((qa.x - gap) / dashP);
        for (int di = 0; di < 2; di++) {
            // Clamp to the innermost dash so pixels in the center gap (qa.x < gap) measure their
            // distance to the first dash at x=gap instead of falling through to the far end tick at
            // x=W. Without this the dashed (below-horizon) rungs report ~W at the center, punching a
            // hard black glow slot straight down the middle — the solid/plain rungs don't, because
            // their sdSegment(gap..W) already reports ~gap there. No effect on the visible dashes
            // (those pixels have idx >= 0 already) or on coverage (the gap has none regardless).
            float ii = max(idx - float(di), 0.0);
            float s0 = gap + ii * dashP;
            if (s0 < W) d = min(d, sdSegment(qa, vec2(s0, 0.0), vec2(min(s0 + dashOn, W), 0.0)));
        }
        d = min(d, sdSegment(qa, vec2(W, 0.0), vec2(W, -tick)));
    } else {
        d = sdSegment(qa, vec2(gap, 0.0), vec2(W, 0.0));
    }
    return d;
}
float hudRollTick(vec2 px, float R, float deg, float len) {
    float a = deg * 0.017453292;
    vec2 dir = vec2(sin(a), -cos(a));
    return sdSegment(px, R * dir, (R + len) * dir);
}
float hudRollTicks(vec2 px, float R) {
    float d =        hudRollTick(px, R,  0.0, 0.055);
    d = min(d, hudRollTick(px, R, 10.0, 0.030));
    d = min(d, hudRollTick(px, R, 20.0, 0.030));
    d = min(d, hudRollTick(px, R, 30.0, 0.045));
    d = min(d, hudRollTick(px, R, 45.0, 0.030));
    d = min(d, hudRollTick(px, R, 60.0, 0.045));
    return d;
}

vec4 hud(vec2 uv, vec2 outPos, int elements, int font, float size, float shapeAspectRatio, vec4 color1, float speed, float altitude, float glow, float thickness, mat3 modelTransform, mat3 axisTransform, vec2 outDim) {
    mat3 im = inverse(modelTransform);
    vec2 u = tf(im, uv);
    vec4 bkg = __source__(uv);

    float pixel = 2.0 / outDim.y;
    float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;

    float ar = shapeAspectRatio;

    bool showLadder   = (elements & 1)   != 0;
    bool showHeading  = (elements & 2)   != 0;
    bool showRoll     = (elements & 4)   != 0;
    bool showSpeed    = (elements & 8)   != 0;
    bool showAlt      = (elements & 16)  != 0;
    bool showFpm      = (elements & 32)  != 0;
    bool showBrackets = (elements & 64)  != 0;
    bool showData     = (elements & 128) != 0;

    float modelScale = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    if (modelScale < 1e-5) modelScale = 1e-5;
    float vb = 1.0 / modelScale;
    float lineHalf  = thickness * 0.025 * vb;
    float digitHalf = 0.003 * vb;
    float gscale    = 0.042 * vb * size;

    // Attitude from axisTransform: rotation = bank, drag y = pitch, drag x = heading, pinch = ladder zoom.
    float roll = atan(axisTransform[0][1], axisTransform[0][0]);
    float attScale = length(vec2(axisTransform[0][0], axisTransform[0][1]));
    if (attScale < 1e-5) attScale = 1.0;
    float pitchDeg = -axisTransform[2][1] / attScale * 90.0;
    float hdg = axisTransform[2][0] / attScale * 120.0;

    float cr = cos(roll), sr = sin(roll);
    vec2 ur = vec2(cr * u.x + sr * u.y, -sr * u.x + cr * u.y);   // ladder frame (counter-rotated by bank)

    // Soft clipping: instead of hard if-clips (which tear the distance field and leave rectangular
    // glow seams), out-of-window geometry gets a continuous distance penalty — coverage dies within
    // a few thousandths of a unit but the glow field stays seamless.
    // The inBox cull is still a hard rectangle, so it must be wide enough that the glow has already
    // faded to nothing before it — otherwise the halo snaps off in a visible box. The outermost
    // symbology (corner brackets) sits at |u|≈1.0, and the glow glow·exp(-8·d) drops below the
    // perceptible ~0.006 at d≈ln(glow/0.006)/8 past it. Size the margin to exactly that: a tight
    // (cheap) box when glow is low or off, just enough room when it's high. Strokes live within
    // |u|≤1.0, so coverage is never affected by the margin.
    float glowMargin = (glow > 0.006) ? clamp(log(glow / 0.006) * 0.125, 0.15, 1.0) : 0.15;
    bool inBox = abs(u.x) <= 1.0 + glowMargin + aa && abs(u.y) <= ar + glowMargin + aa;

    float dLine  = 1e9;
    float dDigit = 1e9;

    if (inBox) {
        // ---- Corner brackets ----
        if (showBrackets) {
            vec2 p = abs(u);
            float el = 0.10;
            dLine = min(dLine, sdSegment(p, vec2(1.0, ar - el), vec2(1.0, ar)));
            dLine = min(dLine, sdSegment(p, vec2(1.0 - el, ar), vec2(1.0, ar)));
        }

        // ---- Gun cross (fixed) + flight-path marker (center) ----
        if (showFpm) {
            vec2 g = vec2(u.x, u.y + ar * 0.45);
            dLine = min(dLine, sdSegment(g, vec2(-0.045, 0.0), vec2(0.045, 0.0)));
            dLine = min(dLine, sdSegment(g, vec2(0.0, -0.045), vec2(0.0, 0.045)));
            float r = 0.045;
            dLine = min(dLine, abs(length(u) - r));
            vec2 pa = vec2(abs(u.x), u.y);
            dLine = min(dLine, sdSegment(pa, vec2(r, 0.0), vec2(2.6 * r, 0.0)));
            dLine = min(dLine, sdSegment(u, vec2(0.0, -r), vec2(0.0, -2.0 * r)));
        }

        // ---- Pitch ladder (in the bank-rotated frame) ----
        if (showLadder) {
            float ppd = 0.024 * attScale;                        // u units per degree of pitch
            float v = pitchDeg - ur.y / ppd;
            float k = floor(v / 10.0 + 0.5);
            float vk = clamp(k, -9.0, 9.0) * 10.0;
            float yk = (pitchDeg - vk) * ppd;
            vec2 q = vec2(ur.x, ur.y - yk);
            float W = (abs(vk) < 0.5) ? 0.60 : 0.34;
            // fade rungs approaching the heading tape / data rows and the side tapes.
            // Cap the penalty for distance-field purposes: coverage dies once dist exceeds lineHalf
            // (~0.007), so a small penalty already clips the stroke crisply — but the raw penalty
            // grows to ~0.7 near the box edges, and since glow = exp(-8·dmin) reads the same field
            // that craters the glow to a hard black hole wherever the (dashed) ladder is the only
            // symbology (below the horizon; mirrored but hidden above it by the FPM / roll / tape).
            // Two constants tune this. The steep SLOPE (12) makes the glow fade on nearly the same
            // schedule as coverage: coverage dies at pen≈lineHalf (~0.007) but a soft glow lingers
            // until pen≈0.3, so a gentle slope left a wide band where the stroke is gone yet the rung
            // still glows — a ghost "trace" of a line that isn't drawn (worst on the wide horizon bar
            // when the horizon sits just past the fade boundary). At slope 12 that ghost band is only
            // ~0.02 units (a few px), imperceptible; strokes are unaffected (they cut within ~0.001
            // of the boundary at any slope). The CAP (0.30) then stops the now-steep penalty from
            // cratering the glow to a hard black hole deep in the fade zone — it clamps a fully faded
            // rung's distance to ≈ the distance to the nearest genuinely-visible geometry, so the
            // lower ladder simply vignettes off smoothly instead of punching a hole.
            float pen = (max(abs(ur.y) - ar * 0.62, 0.0) + max(abs(u.x) - 0.60, 0.0)) * 12.0;
            float penG = min(pen, 0.30);
            dLine = min(dLine, hudLadderBar(vec2(abs(q.x), q.y), vk, 0.13, W, 0.045) + penG);
            if (abs(vk) > 0.5) {
                float side = (q.x >= 0.0) ? 1.0 : -1.0;
                dDigit = min(dDigit, hudNumDist(vec2(q.x - side * (W + 0.075), q.y), abs(vk), 0, 0, 0, font, gscale * 0.8) + penG);
            }
        }

        // ---- Heading tape (top): labels row, ticks below, caret pointing up at center ----
        if (showHeading) {
            float dpu = 0.030;                                   // u units per degree of heading
            float penH = max(abs(u.x) - 0.66, 0.0) * 3.0;        // fade the tape ends
            float hd = hdg + u.x / dpu;
            float km = floor(hd / 5.0 + 0.5);
            float xm = (km * 5.0 - hdg) * dpu;
            bool isMajor = mod(km, 2.0) < 0.5;
            dLine = min(dLine, sdSegment(vec2(u.x - xm, u.y), vec2(0.0, -ar * 0.885), vec2(0.0, isMajor ? -ar * 0.845 : -ar * 0.865)) + penH);
            float kM = floor(hd / 10.0 + 0.5);
            float xM = (kM * 10.0 - hdg) * dpu;
            float w = mod(mod(kM * 10.0, 360.0) + 360.0, 360.0);
            dDigit = min(dDigit, hudNumDist(vec2(u.x - xM, u.y + ar * 0.935), w, 0, 3, 0, font, gscale * 0.8) + penH);
            dLine = min(dLine, sdSegment(vec2(abs(u.x), u.y), vec2(0.0, -ar * 0.835), vec2(0.022, -ar * 0.795)));
        }

        // ---- Roll scale (fixed ticks) + bank chevron (rotates with the ladder frame) ----
        if (showRoll) {
            float R = 0.60;
            dLine = min(dLine, hudRollTicks(vec2(abs(u.x), u.y), R));
            vec2 pr = vec2(abs(ur.x), ur.y);
            dLine = min(dLine, sdSegment(pr, vec2(0.0, -(R - 0.012)), vec2(0.020, -(R - 0.058))));
            dLine = min(dLine, sdSegment(pr, vec2(0.0, -(R - 0.058)), vec2(0.020, -(R - 0.058))));
        }

        // ---- Speed tape (left): ticks every 10, labels every 50, boxed readout at center ----
        if (showSpeed) {
            float upu = 0.009;
            float xT = -0.74;
            // fade at the tape's vertical ends and around the readout box
            float penT = max(abs(u.y) - ar * 0.75, 0.0) * 3.0 + max(0.085 - abs(u.y), 0.0) * 3.0;
            float vv = speed - u.y / upu;
            float k = floor(vv / 10.0 + 0.5);
            float val = max(k, 0.0) * 10.0;
            float y = (speed - val) * upu;
            bool isMaj = mod(k, 5.0) < 0.5;
            dLine = min(dLine, sdSegment(vec2(u.x, u.y - y), vec2(xT, 0.0), vec2(xT + (isMaj ? 0.045 : 0.028), 0.0)) + penT);
            float k5 = floor(vv / 50.0 + 0.5);
            float val5 = max(k5, 0.0) * 50.0;
            float y5 = (speed - val5) * upu;
            dDigit = min(dDigit, hudNumDist(vec2(u.x - (xT - 0.025), u.y - y5), val5, 0, 0, 1, font, gscale * 0.8) + penT);
            vec2 bc = vec2(-0.875, 0.0);
            vec2 bh = vec2(0.105, 0.055);
            dLine = min(dLine, hudRect(u - bc, bh));
            dLine = min(dLine, sdSegment(u, vec2(bc.x + bh.x, 0.0), vec2(xT, 0.0)));
            dDigit = min(dDigit, hudNumDist(vec2(u.x - (bc.x + bh.x - 0.02), u.y), speed, 0, 0, 1, font, gscale * 0.9));
        }

        // ---- Altitude tape (right): ticks every 100, labels every 500, boxed readout ----
        if (showAlt) {
            float upu = 0.0009;
            float xT = 0.74;
            float penT = max(abs(u.y) - ar * 0.75, 0.0) * 3.0 + max(0.085 - abs(u.y), 0.0) * 3.0;
            float vv = altitude - u.y / upu;
            float k = floor(vv / 100.0 + 0.5);
            float val = max(k, 0.0) * 100.0;
            float y = (altitude - val) * upu;
            bool isMaj = mod(k, 5.0) < 0.5;
            dLine = min(dLine, sdSegment(vec2(u.x, u.y - y), vec2(xT - (isMaj ? 0.045 : 0.028), 0.0), vec2(xT, 0.0)) + penT);
            float k5 = floor(vv / 500.0 + 0.5);
            float val5 = max(k5, 0.0) * 500.0;
            float y5 = (altitude - val5) * upu;
            dDigit = min(dDigit, hudNumDist(vec2(u.x - (xT + 0.025), u.y - y5), val5, 0, 0, 2, font, gscale * 0.8) + penT);
            vec2 bc = vec2(0.875, 0.0);
            vec2 bh = vec2(0.105, 0.055);
            dLine = min(dLine, hudRect(u - bc, bh));
            dLine = min(dLine, sdSegment(u, vec2(xT, 0.0), vec2(bc.x - bh.x, 0.0)));
            dDigit = min(dDigit, hudNumDist(vec2(u.x - (bc.x + bh.x - 0.02), u.y), altitude, 0, 0, 1, font, gscale * 0.9));
        }

        // ---- Data block: mach (speed/661) bottom-left, pitch degrees bottom-right ----
        if (showData) {
            dDigit = min(dDigit, hudNumDist(vec2(u.x + 0.80, u.y - ar * 0.86), speed / 661.0, 2, 0, 0, font, gscale * 0.85));
            dDigit = min(dDigit, hudNumDist(vec2(u.x - 0.80, u.y - ar * 0.86), pitchDeg, 0, 0, 0, font, gscale * 0.85));
        }
    }

    float covLine  = (lineHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(lineHalf - aa, lineHalf + aa, dLine));
    float covDigit = 1.0 - smoothstep(digitHalf - aa, digitHalf + aa, dDigit);
    float cov = max(covLine, covDigit);

    float dmin = (lineHalf <= 0.0) ? dDigit : min(dLine, dDigit);
    float g = (glow > 0.0) ? glow * exp(-max(dmin - max(lineHalf, digitHalf), 0.0) * 8.0) * (1.0 - cov) : 0.0;

    if (cov <= 0.0 && g <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
    outc.rgb += color1.rgb * g;
    outc.a = max(outc.a, min(g, 1.0));
    return outc;
}
