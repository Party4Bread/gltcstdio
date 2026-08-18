float distToTarget7(vec2 p, vec2 center, float r, float m) {
    float d = 1e10;
    vec2 c = vec2(0.0, 0.0);
    p = abs(p-center);
    if (mod(m, 2.0)>=1.0) d = min(d, distToCrossPartial(p, c, r*0.3, r));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToRadialTicks2(p, c, 32, r*0.3, r*0.45, -PI, PI));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToRadialTicks2(p, c, 8, r*0.3, r*0.6, -PI, PI));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToSquare(p, c, r*0.5));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToSquare(p, c, r*0.3));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToArc(p, c, r*0.5, -PI, PI));
    m /= 2.0;
    if (mod(m, 2.0)>=1.0) d = min(d, distToArc(p, c, r*0.3, -PI, PI));
    m /= 2.0;
    if (mod(m, 3.0)>=2.0) d = min(d, distToSquare(p, vec2(r*0.5, r*0.5), r*0.1));
    else if (mod(m, 3.0)>=1.0) d = min(d, distToArc(p, vec2(r*0.5, r*0.5), r*0.1, -PI, PI));
    m /= 3.0;
    if (mod(m, 3.0)>=2.0) d = min(d, distToSquare(p, vec2(r*0.8, 0.0), r*0.1));
    else if (mod(m, 3.0)>=1.0) d = min(d, distToArc(p, vec2(r*0.8, 0.0), r*0.1, -PI, PI));
    m /= 3.0;

    return d;
}

float distToArc(vec2 p, vec2 center, float radius, float angBegin, float angEnd) {
    vec2 centerToP = p-center;
    float angle = atan(centerToP.y, centerToP.x);
    if (angle>=angBegin && angle<=angEnd) {
        return abs(length(p-center)-radius);
    }
    else {
        vec2 a = center + radius*vec2(cos(angBegin), sin(angBegin));
        vec2 b = center + radius*vec2(cos(angEnd), sin(angEnd));
        return min(length(p-a), length(p-b));
    }
}

float distToCrossPartial(vec2 p, vec2 center, float r1, float r2 ) {
    p = abs(p);
    p = vec2(max(p.x, p.y), min(p.x, p.y));
    return length(p - center - vec2(clamp(r1, r2, p.x), 0.0));
}

float distToRadialTicks2(vec2 p, vec2 center, int n, float r1, float r2, float angBegin, float angEnd) {
    float d = 1e10;
    vec2 centerToP = p-center;
    float ang = atan(centerToP.y, centerToP.x);
    float dAng = (angEnd-angBegin)/float(n);
    float nd = floor(ang/dAng);

    vec2 dir1 = vec2(cos((nd)*dAng), sin((nd)*dAng));
    vec2 dir2 = vec2(cos((nd+1.0)*dAng), sin((nd+1.0)*dAng));
    d = min(d, distToSegment(p, center+r1*dir1, center+r2*dir1));
    d = min(d, distToSegment(p, center+r1*dir2, center+r2*dir2));

    return d;
}

float distToSegment(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b-a;
    float abLen = length(ab);
    if (abLen==0.0) return length(p-a);
    vec2 abNorm = ab/abLen;
    vec2 ap = p-a;
    float abProj = dot(ap, abNorm);
    if (abProj>=0.0 && abProj<=abLen) {
        return abs(dot(ap, vec2(abNorm.y, -abNorm.x)));
    }
    else {
        return min(length(ap), length(p-b));
    }
}

float distToSquare(vec2 p, vec2 center, float radius) {
    p = abs(p-center);
    p = vec2(max(p.x, p.y), min(p.x, p.y));
    return length(p - vec2(radius, clamp(0.0, radius, p.y)));
}

float response(float d, float thickness, float blur) {
    return  pow(smoothstep(thickness, thickness+blur, d), 0.3);
}

vec4 targetLine(vec2 uv, vec2 outPos, int count, float randomSeed, float thickness, vec4 color, float glow, mat3 modelTransform) {
    mat3 invModelTransform = inverse(modelTransform);
    vec2 u = tf(invModelTransform, uv);

    float scale = length(invModelTransform[0].xy);
    thickness = pow(thickness, 2.0) * 0.25 * scale;

    // Packed column: `count` cells sharing a fixed total height, centred on the origin.
    float n = float(max(count, 1));
    float colH = 1.65;
    float ch = colH / n;               // cell height (spacing +10%, target size unchanged)
    float r = ch * 0.56;               // target radius — parts of neighbours nearly touch

    float fy = u.y / ch + (n - 1.0) * 0.5;
    float idx = floor(fy + 0.5);

    // Evaluate the nearest cell AND its two neighbours: strokes/glow reach past a cell's own
    // boundary (r > ch/2, glow halo wider still), so a single-cell test clips them.
    float d = 1e10;
    float pm = 1.0;
    for (int dk = -1; dk <= 1; dk++) {
        float cidx = idx + float(dk);
        if (cidx < 0.0 || cidx > n - 1.0) continue;
        vec2 rel = vec2(u.x, (fy - cidx) * ch);

        // Build the distToTarget7 part mask from per-(index, seed) hash draws. Probabilities
        // are biased low so targets stay simple; variability scales them (0.5 = default mix).
        float m = 0.0;
        float parts = 0.0;
        float b;
        b = fract(sin(cidx * 12.9898 + 1.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.55 * pm) { m += 1.0; parts += 1.0; }     // cross
        b = fract(sin(cidx * 12.9898 + 2.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.15 * pm) { m += 2.0; parts += 1.0; }     // fine radial ticks
        b = fract(sin(cidx * 12.9898 + 3.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.20 * pm) { m += 4.0; parts += 1.0; }     // coarse radial ticks
        b = fract(sin(cidx * 12.9898 + 4.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.22 * pm) { m += 8.0; parts += 1.0; }     // square 0.5
        b = fract(sin(cidx * 12.9898 + 5.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.22 * pm) { m += 16.0; parts += 1.0; }    // square 0.3
        b = fract(sin(cidx * 12.9898 + 6.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.35 * pm) { m += 32.0; parts += 1.0; }    // circle 0.5
        b = fract(sin(cidx * 12.9898 + 7.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.35 * pm) { m += 64.0; parts += 1.0; }    // circle 0.3
        b = fract(sin(cidx * 12.9898 + 8.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.30 * pm) m += 128.0 * ((b < 0.15 * pm) ? 2.0 : 1.0);   // corner marks (circle/square)
        b = fract(sin(cidx * 12.9898 + 9.0 * 78.233 + randomSeed * 37.719) * 43758.5453);
        if (b < 0.30 * pm) m += 384.0 * ((b < 0.15 * pm) ? 2.0 : 1.0);   // side marks (circle/square)
        if (parts < 1.0) m += 33.0;                        // fallback: cross + circle 0.5

        d = min(d, distToTarget7(rel, vec2(0.0, 0.0), r, m));
    }

    float blur = glow;
    float k = response(d, thickness, blur * 0.2 * scale);
    float gg = 0.025 * max(0.0, blur * 100.0 - 50.0) * pow(1.0 - k, 10.0);
    float addK = smoothstep(0.5, 1.0, blur);
    vec4 bkgCol = __source__(uv);
    vec3 shapeRgb = (color.rgb + vec3(gg, gg, gg)) * (gg + 1.0);
    // k is 0 on the shape and 1 outside it, so coverage is 1-k.
    vec4 overCol = mergeColor(bkgCol, vec4(shapeRgb, color.a * (1.0 - k)));
    // Additive branch: weight the shape colour away from a transparent source's
    // meaningless rgb, and let the added light carry its own alpha.
    vec3 addRgb = mix(bkgCol.rgb, shapeRgb, color.a + (1.0 - bkgCol.a) * (1.0 - color.a));
    vec4 addCol = vec4(addRgb * (1.0 - k) + bkgCol.rgb * bkgCol.a, min(1.0, bkgCol.a + color.a * (1.0 - k)));
    vec4 outCol = mix(overCol, addCol, addK);

    return outCol;
}
