const int MAX_ITER = 30;

const float RAND_AMP = 0.2;

const int MAX_ITER = 30;

const float RAND_AMP = 0.2;

vec2 invert(vec2 p, vec2 c, float r) {
    vec2 v = p - c;
    float l2 = dot(v, v);
    if (l2 < 1e-12) return c + normalize(v) * 1e18;
    return c + v * (r * r / l2);
}

vec3 getCircle(vec2 a, vec2 b, vec2 c) {
    float det = (a.x - b.x) * (a.y - c.y) - (a.x - c.x) * (a.y - b.y);
    if (abs(det) < 1e-9) return vec3(1e9, 1e9, 1e9);
    float x12 = a.x - b.x;
    float x13 = a.x - c.x;
    float x31 = c.x - a.x;
    float x21 = b.x - a.x;
    float y12 = a.y - b.y;
    float y13 = a.y - c.y;
    float y31 = c.y - a.y;
    float y21 = b.y - a.y;
    float sx13 = a.x*a.x - c.x*c.x;
    float sy13 = a.y*a.y - c.y*c.y;
    float sx21 = b.x*b.x - a.x*a.x;
    float sy21 = b.y*b.y - a.y*a.y;
    float denom_f = 2.0 * (y31 * x12 - y21 * x13);
    float denom_g = 2.0 * (x31 * y12 - x21 * y13);
    if (abs(denom_f) < 1e-9 || abs(denom_g) < 1e-9) return vec3(1e9, 1e9, 1e9);
    float f = (sx13*x12 + sy13*x12 + sx21*x13 + sy21*x13) / denom_f;
    float g = (sx13*y12 + sy13*y12 + sx21*y13 + sy21*y13) / denom_g;
    vec2 center = vec2(-g, -f);
    return vec3(center, length(a - center));
}

vec3 getCircleForArc(vec2 a, vec2 b) {
    if (length(a) < 1e-9) return vec3(1e9, 1e9, 1e9);
    vec2 a_inv = invert(a, vec2(0.0), 1.0);
    return getCircle(a, b, a_inv);
}

float getInitD3_7() {
    float pi = 3.14159265;
    float angle_q = pi * 0.5 - pi / 7.0;
    float angle_p = pi / 3.0;
    float tan_q = tan(angle_q);
    float tan_p = tan(angle_p);
    float sum_tan = tan_q + tan_p;
    if (abs(sum_tan) < 1e-9) return 1.0;
    float ratio = (tan_q - tan_p) / sum_tan;
    if (ratio < 0.0) return 0.0;
    return sqrt(ratio);
}

vec2[3] makeInitial37(float d, float offset) {
    vec2[3] pts;
    float ang = 3.14159265 * 2.0 / 3.0;
    for (int i = 0; i < 3; ++i) {
        pts[i] = d * vec2(cos(ang * float(i) + offset), sin(ang * float(i) + offset));
    }
    return pts;
}

bool inStraightPolygon3(vec2[3] pts, vec2 u) {
    float s = 0.0;
    bool sign_set = false;
    for (int i = 0; i < 3; ++i) {
        vec2 a = pts[i];
        vec2 b = pts[(i + 1) % 3];
        vec2 edge_vec = b - a;
        if (length(edge_vec) < 1e-9) continue;
        vec2 delta = normalize(edge_vec);
        vec2 normal = vec2(-delta.y, delta.x);
        float newS = dot(normal, u - a);
        if (!sign_set && abs(newS) > 1e-9) { s = sign(newS); sign_set = true; }
        if (sign_set && sign(newS) * s < -1e-9) return false;
    }
    return true;
}

vec2 polyCenter3(vec2[3] pts) {
    return (pts[0] + pts[1] + pts[2]) / 3.0;
}

int getClosestEdge3(vec2[3] pts, vec2 u) {
    float max_proj = -1e9;
    int maxI = -1;
    vec2 c = polyCenter3(pts);
    for (int i = 0; i < 3; ++i) {
        vec2 a = pts[i];
        vec2 b = pts[(i + 1) % 3];
        vec2 dir = b - a;
        if (length(dir) < 1e-9) continue;
        vec2 ort = vec2(-dir.y, dir.x);
        float dc = dot(ort, c - a);
        float du = dot(ort, u - a);
        if (abs(dc) < 1e-9) continue;
        float d = -du / dc;
        if (d > max_proj) { max_proj = d; maxI = i; }
    }
    return maxI;
}

vec2 kaleidMap3(vec2[3] pts, vec2 u, float offang) {
    vec2 c = polyCenter3(pts);
    vec2 delta = u - c;
    for (int i = 0; i < 3; ++i) {
        vec2 t1 = pts[i];
        vec2 t2 = pts[(i + 1) % 3];
        vec2 side1 = t1 - c;
        vec2 side2 = t2 - c;
        float det = side1.x * side2.y - side1.y * side2.x;
        if (abs(det) < 1e-9) continue;
        float k = (delta.x * side2.y - delta.y * side2.x) / det;
        float l = (delta.y * side1.x - delta.x * side1.y) / det;
        if (k >= -1e-6 && l >= -1e-6 && k + l <= 1.0 + 1e-6) {
            float angle = 3.14159265 * 2.0 / 3.0;
            vec2 w = l < k ? vec2(k, l) : vec2(l, k);
            return w.x * vec2(cos(offang), sin(offang))
                 + w.y * vec2(cos(offang + angle), sin(offang + angle));
        }
    }
    return u - c;
}

vec3 makeDispCircle(vec2 u) {
    float l = length(u);
    if (l < 1e-9) return vec3(0.0, 0.0, 1e9);
    float d = 1.0 / l;
    float x = 1.0 + d;
    float r_sq = x * x - 1.0;
    if (r_sq < 0.0) r_sq = 0.0;
    return vec3(x * normalize(u), sqrt(r_sq));
}

// Nearest-center lookup on a hex lattice with basis
//   a = (2r, 0), b = (r, r·√3)
// Each center has six equidistant neighbours at distance 2r — i.e.
// non-overlapping circles of radius r in the densest packing.
// Standard cube-coord rounding: round the three axial coords, then
// fix the one with the largest rounding error so x+y+z stays 0.
vec2 hexNearestCenter(vec2 p, float r) {
    float jc = p.y / (r * SQRT3);
    float ic = (p.x / r - jc) * 0.5;
    vec3 cube = vec3(ic, jc, -ic - jc);
    vec3 rounded = floor(cube + 0.5);
    vec3 diff = abs(rounded - cube);
    if (diff.x > diff.y && diff.x > diff.z) {
        rounded.x = -rounded.y - rounded.z;
    } else if (diff.y > diff.z) {
        rounded.y = -rounded.x - rounded.z;
    } else {
        rounded.z = -rounded.x - rounded.y;
    }
    return vec2((2.0 * rounded.x + rounded.y) * r, rounded.y * r * SQRT3);
}

// NOTE: do NOT factor the kaleid eval into a helper here.
// FunctionalProgram.getDependentCode() only scans the MAIN shader
// function for identifier(…) deps and emits those helpers — with
// dependencies = emptySet(). Helper-to-helper deps are NEVER
// transitively discovered, so any function only reachable via a
// helper (not directly from main) is silently dropped from the final
// shader. GLSL then sees the helper calling an undefined function,
// marks the helper malformed, and the call site reports "no matching
// overloaded function". The kaleid eval is inlined in
// getProgramString below so every helper it uses appears in main's
// dependency scan.

vec4 hyperbolicCirclePack(vec2 uv, vec2 outPos, mat3 viewTransform, mat3 modelTransform, mat3 texTransform, float size, float thickness, float variability) {
    vec2 B = modelTransform[2].xy;
    mat3 invTexTransform = inverse(texTransform);

    // Border ring: outer `thick` fraction of each cell is a black ring;
    // the kaleid renders into the inner disc of radius (1 - thick) and
    // is scaled UP by 1/innerR so it fills the visible interior.
    float thick = clamp(thickness, 0.0, 0.99);
    float innerR = 1.0 - thick;
    float innerRSq = innerR * innerR;
    float origR2 = dot(uv, uv);

    // -------- Dispatch --------
    // Three branches (main disc / L1 cell / L2 gap circle) each set
    // (cellLocal, cellTexOff) and dispatchStatus to drop into the
    // shared kaleid eval below. statuses: 0 = no cell hit (wedge gap),
    // 1 = inside cell, 2 = inside cell's border ring.
    vec2 cellLocal = vec2(0.0);
    vec2 cellTexOff = vec2(0.0);
    int dispatchStatus = 0;

    if (origR2 < 1.0) {
        // Main disc.
        if (origR2 > innerRSq) dispatchStatus = 2;
        else { cellLocal = uv / innerR; dispatchStatus = 1; }
    } else {
        // L1 hex pack.
        float l1R = size;
        vec2 l1Center = hexNearestCenter(uv, l1R);
        vec2 l1Local = (uv - l1Center) / l1R;
        float l1Sq = dot(l1Local, l1Local);
        if (l1Sq < 1.0) {
            if (l1Sq > innerRSq) dispatchStatus = 2;
            else {
                cellLocal = l1Local / innerR;
                // Shared hash22 returns [0,1]; recenter to [-1,1].
                cellTexOff = (hash22(l1Center) - 0.5) * 2.0 * RAND_AMP * variability;
                dispatchStatus = 1;
            }
        } else {
            // L2 gap circles: 6 per L1 cell at angles 30°+60°k, radius
            // (2−√3)/√3 · L1R, at distance 2/√3 · L1R from L1 centre.
            float l2R = l1R * (2.0 - SQRT3) / SQRT3;
            float gapDist = l1R * 2.0 / SQRT3;
            for (int i = 0; i < 6; ++i) {
                float ang = 3.14159265 / 6.0 + 3.14159265 / 3.0 * float(i);
                vec2 gapCenter = l1Center + gapDist * vec2(cos(ang), sin(ang));
                vec2 l2Local = (uv - gapCenter) / l2R;
                float l2Sq = dot(l2Local, l2Local);
                if (l2Sq < 1.0) {
                    if (l2Sq > innerRSq) { dispatchStatus = 2; break; }
                    // Snap the gap key — each L2 gap is shared by 3
                    // host L1 cells; the indirect (l1Center + offset)
                    // computation gives FP-equal but bit-different
                    // gap centers across the 3 paths, and hash22
                    // amplifies that into 3 visible quadrants inside
                    // each L2 circle. Snapping collapses the 3 paths
                    // onto one hash key.
                    vec2 gapKey = floor(gapCenter * 1000.0 + 0.5) * 0.001;
                    cellLocal = l2Local / innerR;
                    cellTexOff = (hash22(gapKey) - 0.5) * 2.0 * RAND_AMP * variability;
                    dispatchStatus = 1;
                    break;
                }
            }
        }
    }

    if (dispatchStatus != 1) {
        // Wedge gap (status 0) or border ring (status 2) — both black.
        return vec4(0.0, 0.0, 0.0, 1.0);
    }

    // -------- Kaleid eval (inlined — see comment in getLocalFunctions
    // explaining why we can't put this in a helper). --------
    float initAngle = 3.14159265 * 0.25;
    float initD_val = getInitD3_7();
    vec2[3] P_canonical = makeInitial37(initD_val, initAngle);
    vec3[3] edgeCircles;
    for (int i = 0; i < 3; ++i) {
        vec2 a = P_canonical[i];
        vec2 b = P_canonical[(i + 1) % 3];
        edgeCircles[i] = getCircleForArc(a, b);
    }
    vec3 dispCircle = makeDispCircle(B);
    vec2 u = cellLocal;
    if (dispCircle.z < 1e8) u = invert(cellLocal, dispCircle.xy, dispCircle.z);

    bool found = false;
    for (int i = 0; i < MAX_ITER; ++i) {
        if (inStraightPolygon3(P_canonical, u)) { found = true; break; }
        int edgeIdx = getClosestEdge3(P_canonical, u);
        if (edgeIdx < 0) break;
        vec3 reflectCircle = edgeCircles[edgeIdx];
        if (reflectCircle.z > 1e8) break;
        u = invert(u, reflectCircle.xy, reflectCircle.z);
    }
    vec2 mapped_pos = found ? kaleidMap3(P_canonical, u, 0.0) : vec2(0.0);
    vec2 v = tf(invTexTransform, mapped_pos) + cellTexOff;
    return __source__(v);
}
