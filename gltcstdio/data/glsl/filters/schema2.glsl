vec4 schema2(vec2 uv, vec2 outPos, vec2 sourceDim, vec2 outDim, float intensity, vec4 insideColor, vec4 borderColor, vec4 highlightColor, float thickness, float thicknessVar, int detail, float variability, float randomSeed, float coverage, float edgeJitter, float colorVariability, mat3 modelTransform) {
    vec4 bg = __source__(uv);

    // placement (disc size/position)
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;

    // --- polar: map screen coord u -> pattern coord `pos` (normal mode, intensity 0.15) ---
    float d = length(u);
    float pw = 1.0 + (intensity > 0.0 ? intensity*3.0 : intensity*0.99);
    float angle = mod(atan(u.y, u.x), PI2);
    float xp = angle/PI - 1.0;             // [-1, 1)
    float sx = xp;                          // pattern spans [-1,1] in x (ratio ~1)
    float sy = 1.0 - pow(d*0.5, pw)*2.0;    // +1 at disc center ... -1 at rim
    vec2 pos = vec2(sx, sy);
    if (pos.y < -1.0) return bg;            // outside the disc -> transparent

    // --- dichotomic subdivision at `pos` -> cell `rect` + cell id `splits` ---
    float ratio = 1.0;
    float pixel = 2.0/sourceDim.y;
    float scale = float(detail);
    vec2 p = pos;
    vec4 rect = vec4(-ratio, -1.0, ratio, 1.0);
    bool horSplit = true;
    vec2 splits = vec2(0.0, 0.0);
    float sPos = 0.0;
    float sscale = 0.5;
    float inverter = 0.0;
    float regularity = 1.0-variability;

    for (float i=0.0; i+sPos<scale; ++i) {
        vec2 rnd = rand2relSeeded(splits, randomSeed+122.1);
        vec2 size = rect.zw-rect.xy;
        if (size.x<pixel || size.y<pixel) break;

        if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
        float var2 = 1.0-max(0.0, (regularity*2.0-1.0));

        if (horSplit) {
            float Y = mix(rect.y, rect.w, var2*rnd.y+0.5);
            if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
        }
        else {
            float X = mix(rect.x, rect.z, var2*rnd.x+0.5);
            if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
        }
        horSplit = !horSplit;
        inverter = 1.0-inverter;
        sscale *= 0.5;
    }

    // --- per-cell randoms ---
    vec2 cellRnd = rand2relSeeded(splits, randomSeed+55.5);
    vec2 colorRnd = rand2relSeeded(splits, randomSeed+77.7);

    // coverage eviction. cellY = cell radial position (rect midpoint; +1 centre, -1 rim), so
    // whole squares evict. The two signs are DIFFERENT algorithms:
    float acov = abs(coverage);
    float cellY = (rect.y + rect.w) * 0.5;
    float j = cellRnd.x + 0.5;                                    // [0,1] per-cell

    if (coverage >= 0.0) {
        // POSITIVE: rim erosion FRONT (good 0..0.1 spread over 0..0.2, then FROZEN — keeps
        // evicted rectangles, stops eating structure) + squared probabilistic scatter fading
        // in 0.2..1.0 on top. Falloff is full-disc ^1.5 (reaches inward) so it bites more.
        float frontCoverage = min(coverage*0.5, 0.1);
        float frontJitter = (j*j*j - 0.5) * 2.0 * edgeJitter;    // cubed boundary jitter
        float front = mix(-1.0-edgeJitter, 1.0+edgeJitter, frontCoverage);
        bool evictFront = cellY < front + frontJitter;

        vec2 evictRnd = rand2relSeeded(splits, randomSeed+33.3);
        float squaredStrength = clamp((coverage-0.2)/0.8, 0.0, 1.0);
        float t = (1.0 - cellY) * 0.5;                           // 0 centre .. 1 rim (full disc)
        float topFactor = pow(t, 1.5);                          // reaches inward -> erodes more
        bool evictSquared = (evictRnd.x+0.5) < squaredStrength*topFactor;

        if (evictFront || evictSquared) return bg;
    } else {
        // NEGATIVE: one clean radial rim->centre wipe over the whole range (no scatter). At -1
        // the front reaches the centre and the disc fully erodes. Linear jitter edge.
        float frontJitter = (j - 0.5) * 2.0 * edgeJitter;
        float front = mix(-1.0-edgeJitter, 1.0+edgeJitter, acov);
        if (cellY < front + frontJitter) return bg;
    }

    // --- per-cell colour variability: inject `highlight` (color3) ---
    //   0.0..0.3 : grow fraction of full-highlight cells to 25%
    //   0.3..0.7 : add random intermediate mixes (cell colour -> highlight)
    //   0.7..1.0 : grow fraction of full-highlight cells again
    float cv = colorVariability;
    float q1 = colorRnd.x + 0.5;    // [0,1]
    float q2 = colorRnd.y + 0.5;    // [0,1]
    float highlightFrac = cv<0.3 ? (cv/0.3)*0.25 : (cv<0.7 ? 0.25 : mix(0.25, 1.0, (cv-0.7)/0.3));
    float interStrength = clamp((cv-0.3)/0.4, 0.0, 1.0);
    vec4 cellColor = insideColor;
    if (q1 < highlightFrac) cellColor = highlightColor;
    else cellColor = mix(cellColor, highlightColor, q2*interStrength);

    // --- border (quadratic per-cell thickness jitter), anti-aliased over ~1px ---
    float r = cellRnd.y + 0.5;                       // per-cell random [0,1]
    float jitter = mix(1.0, r*r, thicknessVar);      // quadratic thickness scale
    float th = thickness * jitter * 0.1;             // /10 -> thinner
    // Per-axis distance to the cell edges, in pattern (pos) space. pos.x edges render as
    // radial spokes on the disc, pos.y edges as concentric arcs — the polar map stretches
    // the two axes by DIFFERENT amounts, so each axis is anti-aliased with its own Jacobian
    // (a shared max() Jacobian over-blurred spokes ~9x at the rim).
    float distX = min(p.x-rect.x, rect.z-p.x);
    float distY = min(p.y-rect.y, rect.w-p.y);
    float du = 2.0/outDim.y / length(modelTransform[0].xy);   // screen pixel -> u space
    float dd = max(d, 1e-4);
    float Jr = pw*pow(dd*0.5, pw-1.0);        // radial:  |d(pos.y)/d(u)|
    float Ja = 1.0/(PI*dd);                   // angular: |d(pos.x)/d(u)|
    float aaX = max(Ja*du, 1e-6);             // pixel footprint along pos.x
    float aaY = max(Jr*du, 1e-6);             // pixel footprint along pos.y
    // Box-filter coverage of the border band (half-width th, centred on the edge) by the
    // pixel footprint: |[dist-aa/2, dist+aa/2] n [-th, th]| / aa. Reduces to a crisp 1-px
    // ramp when aa << th, and — unlike smoothstep, which saturates at 0.5 — tends to the
    // true sub-pixel coverage 2*th/aa -> 0 where Ja explodes (disc centre), so spokes fade
    // out there instead of smearing into a grey blob.
    float covX = max(0.0, min(distX + 0.5*aaX, th) - max(distX - 0.5*aaX, -th)) / aaX;
    float covY = max(0.0, min(distY + 0.5*aaY, th) - max(distY - 0.5*aaY, -th)) / aaY;
    float borderMix = max(covX, covY);
    vec4 fg = mix(cellColor, borderColor, borderMix);

    return mergeColor(bg, fg);
}
