// Glyph count for a value laid out by rulerNumDist — needed at the call site to place the label
// box before measuring it. Mirrors the layout hudNumDist/rulerNumDist perform internally.
int rulerNumGlyphs(float value, int decimals) {
    bool neg = value < 0.0;
    float av = abs(value);
    float ipart = (decimals == 0) ? floor(av + 0.5) : floor(av);
    int nint = 1;
    float tt = ipart;
    for (int i = 0; i < 6; i++) { if (tt >= 10.0) { tt = floor(tt / 10.0); nint++; } }
    return nint + (neg ? 1 : 0) + ((decimals > 0) ? (1 + decimals) : 0);
}
// Continuous distance to a centred number laid out around rel=(0,0) — Hud's hudNumDist with the
// font fixed to curved and alignment dropped (the call site positions the box explicitly, so the
// glyphs are always centred in their own frame and the readability flip is a pure mirror of it).
// Outside the box it returns a conservative lower bound rather than a sentinel, so the glow field
// stays continuous; the 0.35*gscale floor holds that bound above the coverage threshold, else the
// box perimeter renders as a hairline rectangle around every label.
float rulerNumDist(vec2 rel, float value, int decimals, float gscale) {
    bool neg = value < 0.0;
    float av = abs(value);
    float ipart = (decimals == 0) ? floor(av + 0.5) : floor(av);
    if (decimals == 0) av = ipart;
    int nint = 1;
    float tt = ipart;
    for (int i = 0; i < 6; i++) { if (tt >= 10.0) { tt = floor(tt / 10.0); nint++; } }
    int ng = nint + (neg ? 1 : 0) + ((decimals > 0) ? (1 + decimals) : 0);
    float gadv = 0.88;
    float w = float(ng) * gadv * gscale;
    float x = rel.x + w * 0.5;
    float dx = max(max(-x, x - w), 0.0);
    float dy = max(abs(rel.y) - 0.75 * gscale, 0.0);
    if (dx > 0.0 || dy > 0.0) return length(vec2(dx, dy)) + 0.35 * gscale;
    float lx = x / gscale;
    int slot = int(floor(lx / gadv));
    if (slot < 0 || slot >= ng) return 0.35 * gscale;
    int ch = ndfCharForSlot(slot, nint, neg, decimals, ipart, av);
    if (ch == 12) return 0.35 * gscale;
    vec2 gp = vec2(lx - (float(slot) + 0.5) * gadv, -rel.y / gscale);
    return ndfCurved(ch, gp) * gscale;
}

vec4 ruler(vec2 uv, vec2 outPos, int elements, int justify, int numbers, float size, float numberSize, vec4 color1, float value, float range, float glow, float thickness, mat3 modelTransform, vec2 outDim) {
    mat3 im = inverse(modelTransform);
    vec2 u = tf(im, uv);
    vec4 bkg = __source__(uv);

    float pixel = 2.0 / outDim.y;
    float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;

    bool showMajors = (elements & 1) != 0;
    bool showSpine  = (elements & 2) != 0;

    float modelScale = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    if (modelScale < 1e-5) modelScale = 1e-5;
    float vb = 1.0 / modelScale;

    // Legacy parity at identity transform / size 1: minor half-extent 0.05, majors 1.5x longer and
    // 1.5x thicker, stroke half-width 0.0015 at the default thickness of 0.2.
    float minorHalf = thickness * 0.0075 * vb;
    float majorHalf = minorHalf * 1.5;      // the spine is drawn at this weight too
    float digitHalf = 0.003 * vb;
    float gscale    = 0.042 * vb * numberSize;
    float gadv      = 0.88;
    float gap       = 0.012 * vb * numberSize;
    float tickMinor = 0.05 * vb * size;
    float tickMajor = 0.075 * vb * size;
    // The edge the ticks align on (and the numbers hang off). With majors off every tick is
    // minor-length, so the reference edge collapses to the minor extent.
    float edgeRef   = showMajors ? tickMajor : tickMinor;

    // How far the glow reaches past a stroke (glow*exp(-8d) < ~0.006 beyond this). Sizes the
    // per-label gates so they sit exactly at the halo's fade distance.
    float glowReach = (glow > 0.006) ? min(log(glow / 0.006) * 0.125, 1.0) : 0.0;

    // ---- Adaptive step (Graph's rule): snap to 1/2/5 x 10^n so labels never collide. Unlike
    // Graph we do NOT clamp the step to >= 1, so a small range still labels sensibly; the decimals
    // shown then follow the step.
    if (range < 1e-4) range = 1e-4;
    // NEGATIVE: +y points DOWN in uv space, so the value axis is flipped to make the rule read
    // upward (larger values toward the top) -- the same correction Graph makes by negating its
    // axisTransform Y column.
    float dataToU  = -2.0 / range;                // local y per data unit
    float unitV    = abs(dataToU) * modelScale;   // screen units per data unit
    // Minimum on-screen spacing between labels: their run direction decides whether successive
    // labels are separated by their height (along ticks) or their width (along the spine).
    float minLabelV = (numbers == 2) ? max(0.20 * numberSize, 0.05) : max(0.10 * numberSize, 0.03);
    float raw = minLabelV / max(unitV, 1e-6);
    float b   = pow(10.0, floor(log(max(raw, 1e-9)) / log(10.0)));
    float m   = raw / b;
    float L      = ((m <= 1.0) ? 1.0 : (m <= 2.0) ? 2.0 : (m <= 5.0) ? 5.0 : 10.0) * b;
    float minorL = L / 5.0;
    int decimals = int(clamp(ceil(-log(L) / log(10.0)), 0.0, 3.0));

    float vv = value + u.y / dataToU;             // data value at this pixel's height

    float dMinor = 1e9;
    float dMajor = 1e9;
    float dSpine = 1e9;
    float dDigit = 1e9;

    // ---- Ticks. Five minor slots span one major period, so a fixed window around the pixel sees
    // every tick that could be nearest -- O(1)/pixel. Majors REPLACE minors on the 5-cadence
    // (legacy behaviour), so each candidate lands in exactly one of the two distance fields.
    float k0 = floor(vv / minorL + 0.5);
    for (int dk = -2; dk <= 2; dk++) {
        float kk = k0 + float(dk);
        float vk = kk * minorL;
        float yk = (vk - value) * dataToU;
        if (abs(yk) > 1.0) continue;
        bool isMaj = showMajors && (mod(abs(kk), 5.0) < 0.5);
        float halfLen = isMaj ? tickMajor : tickMinor;
        float x0, x1;
        if (justify == 1) {                        // shared left edge
            x0 = -edgeRef;          x1 = x0 + 2.0 * halfLen;
        } else if (justify == 2) {                 // shared right edge
            x1 =  edgeRef;          x0 = x1 - 2.0 * halfLen;
        } else {                                   // centred on the spine
            x0 = -halfLen;          x1 = halfLen;
        }
        float d = sdSegment(u, vec2(x0, yk), vec2(x1, yk));
        if (isMaj) dMajor = min(dMajor, d); else dMinor = min(dMinor, d);
    }

    // ---- Spine, on the alignment edge (through the middle when the ticks are centred).
    if (showSpine) {
        float xs = (justify == 1) ? -edgeRef : ((justify == 2) ? edgeRef : 0.0);
        dSpine = sdSegment(u, vec2(xs, -1.0), vec2(xs, 1.0));
    }

    // ---- Numbers, at the major cadence regardless of whether majors are DRAWN.
    if (numbers >= 1) {
        // Numbers sit on the aligned side; centred ticks have no aligned side, so they go left.
        float side  = (justify == 2) ? 1.0 : -1.0;
        float edgeX = side * edgeRef;

        // Glyph frame: baseline runs the way the ticks point (1) or along the spine (2), then is
        // flipped 180 degrees if that would read right-to-left (or top-down) on screen. The test is
        // on the baseline's SCREEN direction, so the labels track modelTransform's rotation and snap
        // once per turn rather than going upside down. Screen +y is DOWN, so "reads bottom-up" is
        // sB.y < 0 and it is sB.y > 0 (running downward) that must flip.
        vec2 eB = (numbers == 2) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
        vec2 sB = normalize((modelTransform * vec3(eB, 0.0)).xy);
        if (sB.x < -1e-3 || (abs(sB.x) <= 1e-3 && sB.y > 0.0)) eB = -eB;
        vec2 eU = vec2(-eB.y, eB.x);

        float j0 = floor(vv / L + 0.5);
        for (int dj = -1; dj <= 1; dj++) {
            float kk = j0 + float(dj);
            float vk = kk * L;
            float yk = (vk - value) * dataToU;
            if (abs(yk) > 1.0) continue;
            float labelW = float(rulerNumGlyphs(vk, decimals)) * gadv * gscale;
            // Extent along local x, i.e. away from the rule -- the label's width when it runs with
            // the ticks, its height when it runs along the spine.
            float halfX = (numbers == 2) ? (0.75 * gscale) : (labelW * 0.5);
            float halfY = (numbers == 2) ? (labelW * 0.5)  : (0.75 * gscale);
            vec2 c = vec2(edgeX + side * (gap + halfX), yk);
            vec2 rel0 = u - c;
            if (abs(rel0.x) > halfX + glowReach) continue;      // loose gates: cover the halo's fade
            if (abs(rel0.y) > halfY + glowReach) continue;
            vec2 rel = vec2(dot(rel0, eB), dot(rel0, eU));
            dDigit = min(dDigit, rulerNumDist(rel, vk, decimals, gscale));
        }
    }

    // ---- Composite (Hud's glow model exactly).
    float dStroke = min(min(dMinor, dMajor), dSpine);
    float covMinor = (minorHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(minorHalf - aa, minorHalf + aa, dMinor));
    float covMajor = (majorHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(majorHalf - aa, majorHalf + aa, dMajor));
    float covSpine = (majorHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(majorHalf - aa, majorHalf + aa, dSpine));
    float covDigit = 1.0 - smoothstep(digitHalf - aa, digitHalf + aa, dDigit);
    float cov = max(max(covMinor, covMajor), max(covSpine, covDigit));

    float dmin = (minorHalf <= 0.0) ? dDigit : min(dStroke, dDigit);
    float g = (glow > 0.0) ? glow * exp(-max(dmin - max(majorHalf, digitHalf), 0.0) * 8.0) * (1.0 - cov) : 0.0;

    if (cov <= 0.0 && g <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
    outc.rgb += color1.rgb * g;
    outc.a = max(outc.a, min(g, 1.0));
    return outc;
}
