#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_aspectRatio (U[4].x)
#define u_outDim (U[5].xy)
#define u_p (int(U[6].x))
#define u_q (int(U[7].x))
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_texTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_offset (U[14].x)
#define u_boundary (int(U[15].x))
#define u_vignetting (U[16].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))

const int MAX_ITER = 100;
const int MAX_POLY_SIDES = 12;



// gltcstdio GLSL support library.
// Every function below was verified to compile against GL 3.3.
// Prototypes precede bodies so intra-library call order is irrelevant.

#define INF 1e20
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI4 12.566370614359172
#define PI_2 1.5707963267948966
#define PI_3 1.0471975511965976
#define PI2_3 2.0943951023931953
#define SQRT3 1.7320508075688772
#define SQRT3_2 0.8660254037844386
#define SQRT3_6 0.288675134594813
#define SQRT2 1.4142135623730951
#define SQRT2_2 0.7071067811865476
#define THIRD 0.33333333333
#define TWO_THIRDS 0.666666666667

struct HexTile {
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct CairoTile {
    vec2 center;
    float borderDist;
};
struct TriangleTile {
    bool up;
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct Tile {
    float centerDist;
    vec2 tileId;
    float borderDist;
    vec2 center;
    vec2 borderNormal;
    float secondCenterDist;
    vec2 secondTileId;    
    float thirdCenterDist;
};

// ---- prototypes ----










































































































































































































// ---- bodies ----



















        























































































// allow vec4's

















































































































































































































































































































































































// Complex division: a / b = a · b̄ / |b|².



// Complete elliptic integral of the first kind K(m) via AGM.
// K(m) = π / (2·AGM(1, √(1−m))). N=8 iterations is well beyond
// machine precision for all m ∈ (0, 1).



// Newton-solve for k² (= m) such that K(m)/K(1−m) = aspect/2. The /2
// is geometric: sn's natural fundamental rectangle is 2K wide × K'
// tall (not K × K'), so uniform/conformal scaling vs the user rect
// (width 2·aspect, height 2) needs 2K/K' = aspect, i.e. K/K' = aspect/2.
// At aspect = 2 this lands on m = 0.5 (lemniscatic special case).



// Complex Jacobi sn(z, k²) via the addition formula. Two AGM-based
// real sncndn computations (inlined — helper-to-helper deps aren't
// auto-discovered in pap2mp's dependency parser) are combined.
// Maps the natural fundamental rect [-K, K] × [0, K'] → upper half
// plane. Reference: shadertoy Mlsfzs (Arcus).






// Triangle fold into [-1,1], mirroring every 2 units — the Reflection
// (Schwarz) boundary tiling folds each axis through this. (hash21, used for
// the per-tile texture variation, is a built-in shader-prelude function.)







vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec2 cdiv(vec2 a, vec2 b) {
    float d = dot(b, b);
    return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / d;
}

vec2 csn(vec2 z, float k2) {
    // First AGM block: sncndn(z.x, k²)
    float snu, cnu, dnu;
    {
        float emc = 1.0 - k2;
        float a, b, c;
        float em[4];
        float en[4];
        a = 1.0;
        dnu = 1.0;
        for (int i = 0; i < 4; ++i) {
            em[i] = a;
            emc = sqrt(emc);
            en[i] = emc;
            c = 0.5 * (a + emc);
            emc = a * emc;
            a = c;
        }
        float u = c * z.x;
        snu = sin(u);
        cnu = cos(u);
        if (snu != 0.0) {
            a = cnu / snu;
            c = a * c;
            for (int i = 3; i >= 0; --i) {
                b = em[i];
                a = c * a;
                c = dnu * c;
                dnu = (en[i] + a) / (b + a);
                a = c / b;
            }
            a = 1.0 / sqrt(c * c + 1.0);
            if (snu < 0.0) snu = -a;
            else snu = a;
            cnu = c * snu;
        }
    }
    // Second AGM block: sncndn(z.y, 1−k²)
    float snv, cnv, dnv;
    {
        float emc = k2;
        float a, b, c;
        float em[4];
        float en[4];
        a = 1.0;
        dnv = 1.0;
        for (int i = 0; i < 4; ++i) {
            em[i] = a;
            emc = sqrt(emc);
            en[i] = emc;
            c = 0.5 * (a + emc);
            emc = a * emc;
            a = c;
        }
        float u = c * z.y;
        snv = sin(u);
        cnv = cos(u);
        if (snv != 0.0) {
            a = cnv / snv;
            c = a * c;
            for (int i = 3; i >= 0; --i) {
                b = em[i];
                a = c * a;
                c = dnv * c;
                dnv = (en[i] + a) / (b + a);
                a = c / b;
            }
            a = 1.0 / sqrt(c * c + 1.0);
            if (snv < 0.0) snv = -a;
            else snv = a;
            cnv = c * snv;
        }
    }
    float A = 1.0 / (1.0 - dnu * dnu * snv * snv);
    return A * vec2(snu * dnv, cnu * dnu * snv * cnv);
}

float ellipticK_m(float m) {
    float a = 1.0;
    float b = sqrt(1.0 - m);
    for (int i = 0; i < 8; ++i) {
        float aNew = (a + b) * 0.5;
        b = sqrt(a * b);
        a = aNew;
    }
    return 3.14159265 / (2.0 * a);
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

vec2 invert(vec2 p, vec2 c, float r) {
    vec2 v = p - c;
    float l2 = dot(v, v);
    if (l2 < 1e-12) return c + normalize(v) * 1e18;
    return c + v * (r * r / l2);
}

vec3 getCircleForArc(vec2 a, vec2 b) {
    if (length(a) < 1e-9) return vec3(1e9, 1e9, 1e9);
    vec2 a_inv = invert(a, vec2(0.0), 1.0);
    return getCircle(a, b, a_inv);
}

vec2 polyCenter(vec2[MAX_POLY_SIDES] pts, int p) {
    vec2 total = vec2(0.0);
    for (int i = 0; i < p; ++i) total += pts[i];
    return total / float(p);
}

int getClosestEdge(vec2[MAX_POLY_SIDES] pts, vec2 u, int p) {
    float max_proj = -1e9;
    int maxI = -1;
    vec2 c = polyCenter(pts, p);
    for (int i = 0; i < p; ++i) {
        vec2 a = pts[i];
        int nxt = i + 1;
        if (nxt >= p) nxt = 0;
        vec2 b = pts[nxt];
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

float getInitD(float p, float q) {
    float pi = 3.14159265;
    float angle_q = pi * 0.5 - pi / q;
    float angle_p = pi / p;
    float tan_q = tan(angle_q);
    float tan_p = tan(angle_p);
    float sum_tan = tan_q + tan_p;
    if (abs(sum_tan) < 1e-9) return 1.0;
    float ratio = (tan_q - tan_p) / sum_tan;
    if (ratio < 0.0) return 0.0;
    return sqrt(ratio);
}

float hash21(vec2 p) {
    vec2 a = fract(-45.3277*p.xy);
    vec2 b = a + dot(a, a+123.3371);
	return fract(b.x*b.y);  
}

bool inStraightPolygon(vec2[MAX_POLY_SIDES] pts, vec2 u, int p) {
    float s = 0.0;
    bool sign_set = false;
    for (int i = 0; i < p; ++i) {
        vec2 a = pts[i];
        int nxt = i + 1;
        if (nxt >= p) nxt = 0;
        vec2 b = pts[nxt];
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

vec2 kaleidMap(vec2[MAX_POLY_SIDES] pts, vec2 u, float offang, int p) {
    vec2 c = polyCenter(pts, p);
    vec2 delta = u - c;
    for (int i = 0; i < p; ++i) {
        vec2 t1 = pts[i];
        int nxt = i + 1;
        if (nxt >= p) nxt = 0;
        vec2 t2 = pts[nxt];
        vec2 side1 = t1 - c;
        vec2 side2 = t2 - c;
        float det = side1.x * side2.y - side1.y * side2.x;
        if (abs(det) < 1e-9) continue;
        float k = (delta.x * side2.y - delta.y * side2.x) / det;
        float l = (delta.y * side1.x - delta.x * side1.y) / det;
        if (k >= -1e-6 && l >= -1e-6 && k + l <= 1.0 + 1e-6) {
            float angle = 3.14159265 * 2.0 / float(p);
            vec2 w = l < k ? vec2(k, l) : vec2(l, k);
            return w.x * vec2(cos(offang), sin(offang))
                 + w.y * vec2(cos(offang + angle), sin(offang + angle));
        }
    }
    return u - c;
}

float ksqFromAspect(float aspect) {
    float target = aspect * 0.5;
    float m = 0.5;
    for (int i = 0; i < 20; ++i) {
        float km = ellipticK_m(m);
        float kpm = ellipticK_m(1.0 - m);
        float ratio = km / kpm;
        float err = ratio - target;
        if (abs(err) < 1e-5) break;
        float eps = 1e-4;
        float mPlus = clamp(m + eps, 1e-4, 1.0 - 1e-4);
        float ratioPlus = ellipticK_m(mPlus) / ellipticK_m(1.0 - mPlus);
        float deriv = (ratioPlus - ratio) / (mPlus - m);
        if (abs(deriv) < 1e-9) break;
        m = clamp(m - err / deriv, 1e-4, 1.0 - 1e-4);
    }
    return m;
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

vec2[MAX_POLY_SIDES] makeInitial(float d, float offset, int p) {
    vec2[MAX_POLY_SIDES] pts;
    float ang = 3.14159265 * 2.0 / float(p);
    for (int i = 0; i < p; ++i) {
        pts[i] = d * vec2(cos(ang * float(i) + offset), sin(ang * float(i) + offset));
    }
    return pts;
}

float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, vec2(0.0))) - r;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float triFold(float t) {
    float a = mod(t + 1.0, 4.0);
    if (a > 2.0) a = 4.0 - a;
    return a - 1.0;
}

vec4 hyperbolicSquare(vec2 uv, vec2 outPos, int p, int q, mat3 viewTransform, mat3 modelTransform, mat3 texTransform, float aspectRatio, float offset, int boundary, float vignetting) {
    // Vignette anchor in normalized unit-square coords so its shape
    // hugs the frame at any aspect.
    vec2 rectUV = uv;
    vec2 normUV = vec2(uv.x / max(aspectRatio, 1e-3), uv.y);

    // --- Boundary mode: what to show outside the central square ---
    //   `suv` is the (possibly folded) rect coordinate fed to the conformal map;
    //   `n` is its unit-square-normalized form. Tiling/Droste set `texVar` (a
    //   per-tile/level texture tweak composed into the texture transform). See
    //   the BoundaryMode doc for the dial values (mirrors HyperbolicKaleidoscope).
    vec2 suv = uv;
    vec2 n = normUV;
    mat3 texVar = mat3(1.0);        // per-tile/level texture-transform tweak (identity = none)
    float vigAmt = 0.0;             // 1 = apply the square vignette (Frame only)
    float outsideSq = max(abs(normUV.x), abs(normUV.y)) > 1.0 ? 1.0 : 0.0;
    if (boundary == 0) {                 // Transparent — outside the square is clear
        if (outsideSq > 0.5) return vec4(0.0);
    } else if (boundary == 1) {          // Black — outside the square is opaque black
        if (outsideSq > 0.5) return vec4(0.0, 0.0, 0.0, 1.0);
    } else if (boundary == 2) {          // Frame (default) — squircle vignette to black
        vigAmt = 1.0;
    } else if (boundary == 3) {          // Droste — nested squares + Lissajous texture offset
        float m = max(abs(n.x), abs(n.y));
        if (m > 1.0) {
            float k = floor(log2(m));
            n /= exp2(k + 1.0);
            float lvl = k + 1.0;
            vec2 t = vec2(sin(0.49 * lvl), sin(0.77 * lvl + 1.5707963)) * 0.30;
            texVar = mat3(1.0, 0.0, 0.0,  0.0, 1.0, 0.0,  t.x, t.y, 1.0);
        }
        suv = vec2(n.x * max(aspectRatio, 1e-3), n.y);
    } else if (boundary == 4 || boundary == 5) {  // Lattice (repeat) / Reflection (mirror + tex)
        vec2 cell = floor((n + 1.0) * 0.5);
        vec2 loc = (boundary == 4)
            ? mod(n + 1.0, 2.0) - 1.0            // Lattice — plain repeat
            : vec2(triFold(n.x), triFold(n.y));  // Reflection — mirror (Schwarz)
        n = loc;
        if (boundary == 5) {         // per-tile TEXTURE variation (rotate + slide)
            float a = hash21(cell) * 6.28318530718;
            float ca = cos(a), sa = sin(a);
            vec2 t = vec2(hash21(cell + 11.3), hash21(cell + 27.9)) - 0.5;   // ±0.5 slide
            texVar = mat3(ca, sa, 0.0,  -sa, ca, 0.0,  t.x, t.y, 1.0);
        }
        suv = vec2(n.x * max(aspectRatio, 1e-3), n.y);
    }

    // --- Conformal rect → disc via Jacobi sn + Möbius ---
    // ksq = k² solved from aspect (K(m)/K(1−m) = aspect/2).
    // kp = K(1−k²) used as the uniform scaling factor for both axes.
    float ksq = ksqFromAspect(aspectRatio);
    float kp = ellipticK_m(1.0 - ksq);
    vec2 w = vec2(suv.x, suv.y + 1.0) * (kp * 0.5);
    vec2 z_uhp = csn(w, ksq);
    vec2 ci = vec2(0.0, 1.0);
    vec2 discZ = cdiv(ci - z_uhp, ci + z_uhp);

    // --- Pan reduction (kills the moving-cap-boundary effect) ---
    // Reduce the pan to the fundamental triangle. CRITICAL: operate
    // on the pan's DISC IMAGE P = B/(|B|+1), not on B itself —
    // makeDispCircle accepts |B|>1 (B is a translation param, not a
    // disc point), but the reduction loop's reflections only have
    // hyperbolic meaning inside the disc.
    vec2 inB = modelTransform[2].xy;
    float lInB = length(inB);
    vec2 P = (lInB < 1e-9) ? vec2(0.0) : inB / (lInB + 1.0);
    {
        vec2[MAX_POLY_SIDES] fund = makeInitial(getInitD(float(p), float(q)), 3.14159265 * 0.25, p);
        for (int i = 0; i < 100; ++i) {
            if (inStraightPolygon(fund, P, p)) break;
            int edge = getClosestEdge(fund, P, p);
            if (edge < 0) break;
            vec2 a = fund[edge];
            int nxt = edge + 1;
            if (nxt >= p) nxt = 0;
            vec2 b = fund[nxt];
            vec3 c = getCircleForArc(a, b);
            P = invert(P, c.xy, c.z);
        }
    }
    float lP = length(P);
    vec2 reducedB = (lP < 1e-9) ? vec2(0.0) : P / max(1.0 - lP, 1e-6);

    // --- Initialize canonical polygon, displace by reducedB ---
    vec2[MAX_POLY_SIDES] P_canonical = makeInitial(getInitD(float(p), float(q)), 3.14159265 * 0.25, p);
    vec3[MAX_POLY_SIDES] edgeCircles;
    for (int i = 0; i < p; ++i) {
        vec2 a = P_canonical[i];
        int nxt = i + 1;
        if (nxt >= p) nxt = 0;
        vec2 b = P_canonical[nxt];
        edgeCircles[i] = getCircleForArc(a, b);
    }
    if (length(reducedB) > 1e-5) {
        vec3 dispC = makeDispCircle(reducedB);
        for (int i = 0; i < p; ++i) {
            P_canonical[i] = invert(P_canonical[i], dispC.xy, dispC.z);
        }
        // Re-derive edge circles since vertices moved.
        for (int i = 0; i < p; ++i) {
            vec2 a = P_canonical[i];
            int nxt = i + 1;
            if (nxt >= p) nxt = 0;
            vec2 b = P_canonical[nxt];
            edgeCircles[i] = getCircleForArc(a, b);
        }
    }

    // --- Per-pixel polygon walk, tracking iteration count for fade ---
    vec2 u = discZ;
    bool found = false;
    int iterCount = 100;
    for (int i = 0; i < MAX_ITER; ++i) {
        if (inStraightPolygon(P_canonical, u, p)) {
            found = true;
            iterCount = i;
            break;
        }
        int edgeIdx = getClosestEdge(P_canonical, u, p);
        if (edgeIdx < 0 || edgeIdx >= p) { iterCount = i; break; }
        vec3 reflectCircle = edgeCircles[edgeIdx];
        if (reflectCircle.z > 1e8) { iterCount = i; break; }
        u = invert(u, reflectCircle.xy, reflectCircle.z);
    }

    vec4 col;
    mat3 invTexTransform = inverse(texTransform) * texVar;   // per-tile texture variation
    if (found) {
        vec2 mapped_pos = kaleidMap(P_canonical, u, 0.0, p);
        // Offset: bleed a fraction of the original rect coordinate into the
        // mapped position (matches HyperbolicKaleidoscope's `offset`). 0 = no-op.
        mapped_pos += suv * offset;
        vec2 v = tf(invTexTransform, mapped_pos);
        col = __source__(v);
    } else {
        vec2 v = tf(invTexTransform, vec2(0.0));
        col = __source__(v);
    }

    // Iteration-cap fade: bring cap-out pixels smoothly to black over
    // the last 20 iters. The texture-centre fallback above becomes
    // invisible after this multiplier (matches shadertoy Mlsfzs's
    // pure-black-background approach).
    float capFade = 1.0 - smoothstep(80.0, 100.0, float(iterCount));
    col.rgb *= capFade;

    // --- Two-mask vignette in normalized unit-square coords ---
    float t = vignetting;
    float s1 = clamp(t * 2.0, 0.0, 1.0);
    float s2 = clamp((t - 0.5) * 2.0, 0.0, 1.0);
    float cornerRadius = mix(0.0, 0.1, s1);
    float distSquare = 1.0 + sdRoundedBox(normUV, vec2(1.0), cornerRadius);
    float darknessCorner = smoothstep(0.99, 1.0, distSquare);
    vec2 a2 = normUV * normUV;
    vec2 a4 = a2 * a2;
    float sd = sqrt(sqrt(a4.x + a4.y));
    float innerSd = mix(1.2, 0.5, s2);
    float outerSd = mix(1.4, 1.0, s2);
    float darknessBody = smoothstep(innerSd, outerSd, sd);
    float cornerMask = (1.0 - darknessCorner) * (1.0 - darknessBody);
    cornerMask = mix(1.0, cornerMask, vigAmt);   // vignette only in Frame mode
    return vec4(col.rgb * cornerMask, col.a);
}

void main() {
    fragColor = hyperbolicSquare((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_p, u_q, u_viewTransform, u_modelTransform, u_texTransform, u_aspectRatio, u_offset, u_boundary, u_vignetting);
}
