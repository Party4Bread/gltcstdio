const int MAX_ITER = 30;

const int MAX_POLY_SIDES = 12;

vec2 invert(vec2 p, vec2 c, float r) {
    vec2 v = p - c;
    float l2 = dot(v, v); // Use dot product for squared length (often faster)
    // Avoid division by zero or very small numbers
    if (l2 < 1e-12) {
        // Handle inversion of center point or points very close to it
        // Return a point far away as a convention
        return c + normalize(v) * 1e18; // Or handle as needed
    }
    return c + v * (r * r / l2);
}

// getCircle and getCircleForArc remain the same as in the original code provided.
// We need them to calculate the reflection circles for the canonical polygon edges.
vec3 getCircle(vec2 a, vec2 b, vec2 c) {
    // Check for collinear points (determinant check)
    float det = (a.x - b.x) * (a.y - c.y) - (a.x - c.x) * (a.y - b.y);
    if (abs(det) < 1e-9) {
        // Return representation of a line (e.g., center at infinity, very large radius)
        // Or handle appropriately based on how reflection across a line is defined.
        // Returning a large radius circle centered far away is one approach.
        // Normalizing the normal and storing offset might be better for line reflection.
        // For now, return large radius circle as a placeholder for non-line reflection case.
        return vec3(1e9, 1e9, 1e9); // Indicates a line or near-collinear case
    }

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

    // Should theoretically be non-zero if det is non-zero, but check for safety
     if (abs(denom_f) < 1e-9 || abs(denom_g) < 1e-9) {
          return vec3(1e9, 1e9, 1e9);
     }

    float f = (sx13*x12 + sy13*x12 + sx21*x13 + sy21*x13) / denom_f;
    float g = (sx13*y12 + sy13*y12 + sx21*y13 + sy21*y13) / denom_g;

    vec2 center = vec2(-g, -f);
    return vec3(center, length(a - center));
}

vec3 getCircleForArc(vec2 a, vec2 b) {
    // Invert point 'a' across the unit circle centered at origin
    // Handle cases where a or b is the origin if necessary (invert is problematic)
    if (length(a) < 1e-9) { /* Need specific handling for origin */ return vec3(1e9,1e9,1e9); }
    vec2 a_inv = invert(a, vec2(0.0), 1.0);
    // If a_inv == b, points are collinear with origin -> results in a line.
    return getCircle(a, b, a_inv);
}

// makeInitial and getInitD remain the same. Used once to define the canonical polygon.
float getInitD(float p, float q) {
    float pi = 3.14159265;
    float angle_q = pi * 0.5 - pi / q;
    float angle_p = pi / p;
    // Add checks for invalid tan arguments if necessary
    float tan_q = tan(angle_q);
    float tan_p = tan(angle_p);
    float sum_tan = tan_q + tan_p;
    if (abs(sum_tan) < 1e-9) return 1.0; // Avoid division by zero
    float ratio = (tan_q - tan_p) / sum_tan;
    if (ratio < 0.0) return 0.0; // Avoid sqrt of negative
    return sqrt(ratio);
}

vec2[12] makeInitial(float d, float offset, int p) {
    vec2[12] pts;
    float ang = 3.14159265 * 2.0 / float(p);
    // Use min(p, 12) if p could exceed 12
    for(int i = 0; i < p; ++i) {
        pts[i] = d * vec2(cos(ang * float(i) + offset), sin(ang * float(i) + offset));
    }
    return pts;
}

// inStraightPolygon remains the same. Now checks point against the fixed canonical polygon.
bool inStraightPolygon(vec2[12] pts, vec2 u, int p) {
    float s = 0.0;
    bool sign_set = false;
    for(int i = 0; i < p; ++i) {
        vec2 a = pts[i];
        vec2 b = pts[int(mod(float(i + 1), float(p)))];
        vec2 edge_vec = b - a;
        if (length(edge_vec) < 1e-9) continue; // Skip degenerate edges
        vec2 delta = normalize(edge_vec);
        vec2 normal = vec2(-delta.y, delta.x); // Normal pointing "inwards" for CCW polygon
        float newS = dot(normal, u - a);

        // Use the sign of the first non-zero projection
        if (!sign_set && abs(newS) > 1e-9) {
            s = sign(newS);
            sign_set = true;
        }

        // If point is on the wrong side (and sign is established)
        if (sign_set && sign(newS) * s < -1e-9) { // Check negative sign with tolerance
            return false;
        }
    }
    // If loop completes, point is inside or on boundary (or sign never got set - e.g., u is center)
    return true;
}

// polyCenter might still be needed by getClosestEdge or kaleidMap
vec2 polyCenter(vec2[12] pts, int p) {
    vec2 total = vec2(0.0);
    if (p <= 0) return total;
    // Use min(p, 12) if p could exceed 12
    int count = p;
    for(int i = 0; i < count; ++i) {
        total += pts[i];
    }
    return total / float(count);
}

// getClosestEdge remains the same. Finds which edge of the canonical polygon to reflect the point across.
int getClosestEdge(vec2[12] pts, vec2 u, int p) {
    float max_proj = -1e9;
    int maxI = -1;
    vec2 c = polyCenter(pts, p); // Center of the canonical polygon
    for(int i = 0; i < p; ++i) {
        vec2 a = pts[i];
        vec2 b = pts[int(mod(float(i + 1), float(p)))];
        vec2 dir = b - a;
        if (length(dir) < 1e-9) continue; // Skip degenerate edge
        vec2 ort = vec2(-dir.y, dir.x); // Normal vector (unnormalized)

        float dc = dot(ort, c - a); // Projection of center vector onto normal
        float du = dot(ort, u - a); // Projection of point vector onto normal

        if (abs(dc) < 1e-9) {
            // Center is on the edge line extension - this edge might be problematic
            // Or it means the polygon is symmetric in a way that center projection is zero.
            // Skip or handle based on geometric interpretation. Skipping for now.
            continue;
        }

        // d = -du/dc measures how far 'u' is along the normal relative to 'c'.
        // Positive 'd' means 'u' is "further out" than 'c' relative to this edge's line.
        // We want the edge for which 'u' is furthest "outside" the polygon.
        float d = -du / dc;

        if (d > max_proj) {
            max_proj = d;
            maxI = i;
        }
    }
    return maxI; // Returns index of the edge closest (most outside) to u
}

// kaleidMap remains the same. Used after the loop to map the final point within the canonical polygon.
vec2 kaleidMap(vec2[12] pts, vec2 u, float offang, int p) {
    vec2 c = polyCenter(pts, p);
    vec2 delta = u - c;
    vec2[3] triangle;
    triangle[0] = c;
    for(int i = 0; i < p; ++i) {
        triangle[1] = pts[i];
        triangle[2] = pts[int(mod(float(i + 1), float(p)))];

        vec2 side1 = triangle[1] - c;
        vec2 side2 = triangle[2] - c;
        float det = side1.x * side2.y - side1.y * side2.x;

        if (abs(det) < 1e-9) continue; // Skip degenerate triangle

        // Barycentric coordinates k, l for delta = k*side1 + l*side2
        float k = (delta.x * side2.y - delta.y * side2.x) / det;
        float l = (delta.y * side1.x - delta.x * side1.y) / det;

        // Check if u is within the triangle sector (c, pts[i], pts[i+1])
        // Need k >= 0, l >= 0, k + l <= 1 (approximately, due to float errors)
        if (k >= -1e-6 && l >= -1e-6 && k + l <= 1.0 + 1e-6) {
            float angle = 3.14159265 * 2.0 / float(p);
            // Original GLSL folding logic:
            vec2 w = l < k ? vec2(k, l) : vec2(l, k);
            // Map using folded weights to canonical first sector's basis vectors
            // (This mapping's geometric meaning might need verification)
            return w.x * vec2(cos(offang), sin(offang)) + w.y * vec2(cos(offang + angle), sin(offang + angle));
        }
    }
    // Fallback if not found in any sector (should ideally not happen if u is inside polygon)
    // Returning the position relative to center might be a reasonable fallback.
    return u - c; // Or just u? Or vec2(0.0)? Original returned c+length(delta) ??
}

// makeDispCircle remains the same. Used for displacement.
vec3 makeDispCircle(vec2 u) {
    float l = length(u);
    if (l < 1e-9) {
        // Return identity transform (e.g., line at infinity, effectively no displacement)
        return vec3(0.0, 0.0, 1e9); // Large radius circle centered at origin? Check effect.
                                    // Or better: return a flag indicating no displacement.
                                    // Let's return something that makes invert do almost nothing far from origin.
                                    // A very large radius circle centered at origin. Invert(p, 0, R_large) ~ p if p is small.
    }
    float d = 1.0 / l;
    float x = 1.0 + d;
    float r_sq = x * x - 1.0;
    if (r_sq < 0.0) r_sq = 0.0;
    float r = sqrt(r_sq);
    return vec3(x * normalize(u), r); // Center = x*normalize(u), radius = r
}

// Nearest hex-lattice centre (Circle Pack mode). Cube-coord rounding on the
// basis a=(2r,0), b=(r, r·√3); SQRT3 is a shader-prelude #define. Ported from
// HyperbolicCirclePack.
vec2 hexNearestCenter(vec2 p, float r) {
    float jc = p.y / (r * SQRT3);
    float ic = (p.x / r - jc) * 0.5;
    vec3 cube = vec3(ic, jc, -ic - jc);
    vec3 rounded = floor(cube + 0.5);
    vec3 diff = abs(rounded - cube);
    if (diff.x > diff.y && diff.x > diff.z) rounded.x = -rounded.y - rounded.z;
    else if (diff.y > diff.z) rounded.y = -rounded.x - rounded.z;
    else rounded.z = -rounded.x - rounded.y;
    return vec2((2.0 * rounded.x + rounded.y) * r, rounded.y * r * SQRT3);
}

const int MAX_ITER = 30;

const int MAX_POLY_SIDES = 12;

vec4 hyKaleidoscope(vec2 uv, vec2 outPos, int p, int q, mat3 viewTransform, mat3 modelTransform, mat3 texTransform, float offset,   float thickness, int boundary) {
    // --- 1. Boundary mode: what to show outside the unit disc ---
    //   0 Transparent · 1 Black · 2 Mirror (default) · 3 Droste · 4 Grid · 5 Circle Pack.
    //   `texVar` (composed into texTransform) and `texOff` (post-transform slide)
    //   carry the per-cell / per-level texture variation.
    float uv_len = length(uv);
    mat3 texVar = mat3(1.0);
    vec2 texOff = vec2(0.0);
    if (boundary == 0) {                 // Transparent — exterior alpha 0
        if (uv_len > 1.0) return vec4(0.0);
    } else if (boundary == 1) {          // Black — exterior opaque black
        if (uv_len > 1.0) return vec4(0.0, 0.0, 0.0, 1.0);
    } else if (boundary == 3) {          // Droste — nested discs + per-level Lissajous offset
        if (uv_len > 1.0) {
            float k = floor(log2(uv_len));
            uv /= exp2(k + 1.0);         // radial nesting into the disc
            float lvl = k + 1.0;
            vec2 t = vec2(sin(0.49 * lvl), sin(0.77 * lvl + 1.5707963)) * 0.30;
            texVar = mat3(1.0, 0.0, 0.0,  0.0, 1.0, 0.0,  t.x, t.y, 1.0);
        }
    } else if (boundary == 4) {          // Grid — lattice of discs (thickness border) + per-tile offset
        vec2 g = uv * 2.0;               // 2x2 discs across the frame
        vec2 cell = floor((g + 1.0) * 0.5);
        uv = mod(g + 1.0, 2.0) - 1.0;    // cell-local disc coord
        float lu = length(uv);
        if (lu > 1.0) {                  // per-cell border ring (same math as Mirror)
            if (lu < 1.0 + thickness) return vec4(0.0, 0.0, 0.0, 1.0);
            uv = invert(uv / (1.0 + thickness), vec2(0.0), 1.0);
        }
        float a = hash21(cell) * 6.28318530718;
        float ca = cos(a), sa = sin(a);
        vec2 t = vec2(hash21(cell + 11.3), hash21(cell + 27.9)) - 0.5;
        texVar = mat3(ca, sa, 0.0,  -sa, ca, 0.0,  t.x, t.y, 1.0);
    } else if (boundary == 5) {          // Circle Pack — hex packing (ported from HyperbolicCirclePack)
        float size = 0.3;                // L1 circle radius (hardcoded; was the `size` param)
        float variability = 0.5;         // per-cell texture spread (hardcoded; was `variability`)
        float thick = clamp(thickness, 0.0, 0.99);
        float innerR = 1.0 - thick;
        float innerRSq = innerR * innerR;
        float origR2 = dot(uv, uv);
        vec2 cellLocal = vec2(0.0);
        int status = 0;                  // 0 wedge · 1 cell · 2 border ring
        if (origR2 < 1.0) {              // main disc
            if (origR2 > innerRSq) status = 2;
            else { cellLocal = uv / innerR; status = 1; }
        } else {
            float l1R = size;            // L1 hex pack of circles radius `size`
            vec2 l1Center = hexNearestCenter(uv, l1R);
            vec2 l1Local = (uv - l1Center) / l1R;
            float l1Sq = dot(l1Local, l1Local);
            if (l1Sq < 1.0) {
                if (l1Sq > innerRSq) status = 2;
                else {
                    cellLocal = l1Local / innerR;
                    texOff = (hash22(l1Center) - 0.5) * 2.0 * 0.2 * variability;
                    status = 1;
                }
            } else {                     // L2 gap circles (6 per L1 cell)
                float l2R = l1R * (2.0 - SQRT3) / SQRT3;
                float gapDist = l1R * 2.0 / SQRT3;
                for (int i = 0; i < 6; ++i) {
                    float ang = 3.14159265 / 6.0 + 3.14159265 / 3.0 * float(i);
                    vec2 gapCenter = l1Center + gapDist * vec2(cos(ang), sin(ang));
                    vec2 l2Local = (uv - gapCenter) / l2R;
                    float l2Sq = dot(l2Local, l2Local);
                    if (l2Sq < 1.0) {
                        if (l2Sq > innerRSq) { status = 2; break; }
                        vec2 gapKey = floor(gapCenter * 1000.0 + 0.5) * 0.001;
                        cellLocal = l2Local / innerR;
                        texOff = (hash22(gapKey) - 0.5) * 2.0 * 0.2 * variability;
                        status = 1;
                        break;
                    }
                }
            }
        }
        if (status != 1) return vec4(0.0, 0.0, 0.0, 1.0);  // wedge gap / border ring → black
        uv = cellLocal;
    } else {                             // 2 Mirror (default) — original behaviour
        if (uv_len > 1.0) {
            if (uv_len < 1.0 + thickness) return vec4(0.0, 0.0, 0.0, 1.0); // border ring
            uv = invert(uv / (1.0 + thickness), vec2(0.0), 1.0);
        }
    }

    // Ensure p is within bounds for fixed-size arrays
    if (p <= 0 || p > MAX_POLY_SIDES) {
        return vec4(1.0, 0.0, 1.0, 1.0); // Error color (e.g., magenta)
    }

    // --- 2. Define Fixed Canonical Polygon & Reflection Circles ---
    float initAngle = atan(modelTransform[0][1], modelTransform[0][0]); // Angle from rotation/scale
    float initD_val = getInitD(float(p), float(q));
    vec2[MAX_POLY_SIDES] P_canonical = makeInitial(initD_val, initAngle, p);

    // Precompute reflection circles for the canonical polygon edges
    vec3[MAX_POLY_SIDES] edgeCircles;
    for (int i = 0; i < p; ++i) {
        vec2 a = P_canonical[i];
        vec2 b = P_canonical[int(mod(float(i + 1), float(p)))];
        edgeCircles[i] = getCircleForArc(a, b);
        // Optional: Add check here if edgeCircles[i] represents a line (large radius)
        // and handle line reflection if needed.
    }

    // --- 3. Handle Displacement (Apply Inverse to Point) ---
    vec2 B = modelTransform[2].xy; // Translation T_x, T_y
    vec3 dispCircle = makeDispCircle(B); // Circle for displacement transform T_disp

    // Start with the input point transformed by the *inverse* displacement
    // Inverse of inversion in dispCircle is inversion in the same circle.
    vec2 u = uv;
    // Only apply inversion if displacement is significant (large radius means ~identity)
    if (dispCircle.z < 1e8) {
       u = invert(uv, dispCircle.xy, dispCircle.z);
    }


    // --- 4. Iterative Point Reflection ---
    bool found = false;
    for (int i = 0; i < MAX_ITER; ++i) {
        // Check if the current point 'u' is inside the canonical polygon
        if (inStraightPolygon(P_canonical, u, p)) {
            found = true;
            break; // Point is inside, exit loop
        }

        // If outside, find the edge to reflect across
        int edgeIdx = getClosestEdge(P_canonical, u, p);

        if (edgeIdx < 0 || edgeIdx >= p) {
             // Error in edge finding or point is at center?
             // Break loop and potentially return error color
             found = false; // Indicate failure
             break;
        }

        // Get the precomputed reflection circle for this edge
        vec3 reflectCircle = edgeCircles[edgeIdx];

        // Check if the reflection "circle" is actually a line (large radius)
        if (reflectCircle.z > 1e8) {
            // Handle reflection across a line if necessary
            // Standard Euclidean reflection: u = u - 2.0 * dot(u - a, n) * n;
            // Where 'a' is a point on the line and 'n' is the line normal.
            // This requires getCircleForArc to return line parameters differently.
            // For now, break if line reflection is encountered without proper handling.
            found = false; // Indicate failure/unhandled case
            break;
        }

        // Reflect the point 'u' across the circle
        u = invert(u, reflectCircle.xy, reflectCircle.z);
    }

    // --- 5. Final Mapping & Texturing ---
    if (found) {
        // Point 'u' is now mapped into the canonical polygon's coordinate system.
        // Apply kaleidMap to potentially normalize position within the polygon/sector
        // Using offang = 0.0 as the canonical polygon is already oriented by initAngle
        vec2 mapped_pos = kaleidMap(P_canonical, u, 0.0, p);

        // Apply the offset parameter (as done in original code before tf)
        mapped_pos += uv * offset; // Uses original uv, as in the reference code

        // Apply texture transform (using assumed inverse matrix)
        mat3 invTexTransform = inverse(texTransform) * texVar; // per-tile/level texture variation
        vec2 v = tf(invTexTransform, mapped_pos) + texOff;     // + post-transform cell offset (Circle Pack)

        // Sample the texture/pattern
        return __source__(v);
    } else {
        // Point did not converge or encountered an error (e.g., line reflection)
        return vec4(0.2, 0.2, 0.2, 1.0); // Return background or error color
    }
}
