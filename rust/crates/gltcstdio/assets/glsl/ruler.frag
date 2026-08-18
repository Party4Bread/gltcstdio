#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_elements (int(U[5].x))
#define u_justify (int(U[6].x))
#define u_numbers (int(U[7].x))
#define u_size (U[8].x)
#define u_numberSize (U[9].x)
#define u_color1 (U[10])
#define u_value (U[11].x)
#define u_range (U[12].x)
#define u_glow (U[13].x)
#define u_thickness (U[14].x)
#define u_modelTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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











































































































































































































































































































































// Glyph count for a value laid out by rulerNumDist — needed at the call site to place the label
// box before measuring it. Mirrors the layout hudNumDist/rulerNumDist perform internally.


// Continuous distance to a centred number laid out around rel=(0,0) — Hud's hudNumDist with the
// font fixed to curved and alignment dropped (the call site positions the box explicitly, so the
// glyphs are always centred in their own frame and the readability flip is a pure mirror of it).
// Outside the box it returns a conservative lower bound rather than a sentinel, so the glow field
// stays continuous; the 0.35*gscale floor holds that bound above the coverage threshold, else the
// box perimeter renders as a hairline rectangle around every label.







vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

int ndfCharForSlot(int slot, int nint, bool neg, int decimals, float ipart, float av) {
    if (slot < 0) return 12;
    if (neg && slot == 0) return 11;
    int idx = slot - (neg ? 1 : 0);
    if (idx < 0) return 12;
    if (idx < nint) {
        int posFromRight = (nint - 1) - idx;
        float dv = floor(ipart / pow(10.0, float(posFromRight)));
        return int(mod(dv, 10.0));
    } else if (decimals > 0 && idx == nint) {
        return 10;
    } else {
        int fpos = idx - nint - 1;
        if (fpos < 0 || fpos >= decimals) return 12;
        float dv = floor(av * pow(10.0, float(fpos + 1)));
        return int(mod(dv, 10.0));
    }
}

float ndfSdBezier(vec2 pos, vec2 A, vec2 B, vec2 C) {
    vec2 a = B - A;
    vec2 b = A - 2.0*B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    float bb = dot(b,b);
    if (bb < 1e-7) return length(pos - mix(A, C, clamp(dot(pos-A, C-A)/max(dot(C-A,C-A),1e-7), 0.0, 1.0)));
    float kk = 1.0 / bb;
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);
    float res = 0.0;
    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
    float h = q*q + 4.0*p3;
    if (h >= 0.0) {
        h = sqrt(h);
        vec2 x = (vec2(h,-h) - q) / 2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        float t = clamp(uv.x+uv.y-kx, 0.0, 1.0);
        vec2 dd = d + (c + b*t)*t;
        res = dot(dd, dd);
    } else {
        float z = sqrt(-p);
        float v = acos(clamp(q/(p*z*2.0), -1.0, 1.0)) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        vec3 t = clamp(vec3(m+m, -n-m, n-m)*z - kx, 0.0, 1.0);
        vec2 d1 = d + (c + b*t.x)*t.x;
        vec2 d2 = d + (c + b*t.y)*t.y;
        res = min(dot(d1,d1), dot(d2,d2));
    }
    return sqrt(res);
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

float ndfCurved(int ch, vec2 p) {
    float ym = 0.0, yt = 0.70, yb = -0.70;
    if (ch==10) return length(p - vec2(0.0, -0.56));
    if (ch==11) return sdSegment(p, vec2(-0.20, ym), vec2(0.20, ym));
    float d = 1e9;
    if (ch==0) {
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yt), vec2( 0.25, yt), vec2( 0.25, ym)));
        d = min(d, ndfSdBezier(p, vec2( 0.25, ym), vec2( 0.25, yb), vec2( 0.0,  yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb), vec2(-0.25, yb), vec2(-0.25, ym)));
        d = min(d, ndfSdBezier(p, vec2(-0.25, ym), vec2(-0.25, yt), vec2( 0.0,  yt)));
    } else if (ch==1) {
        d = min(d, sdSegment(p, vec2( 0.03, yt), vec2( 0.03, yb)));
        d = min(d, sdSegment(p, vec2(-0.16, 0.50), vec2( 0.03, yt)));
        d = min(d, sdSegment(p, vec2(-0.13, yb), vec2( 0.19, yb)));
    } else if (ch==2) {
        d = min(d, ndfSdBezier(p, vec2(-0.24, 0.36), vec2(-0.24, yt), vec2( 0.04, yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.04, yt), vec2( 0.30, yt), vec2( 0.30, 0.34)));
        d = min(d, ndfSdBezier(p, vec2( 0.30, 0.34), vec2( 0.30, 0.25), vec2( 0.07,-0.14)));
        d = min(d, sdSegment(p, vec2( 0.07,-0.14), vec2(-0.25, yb)));
        d = min(d, sdSegment(p, vec2(-0.25, yb), vec2( 0.30, yb)));
    } else if (ch==3) {
        d = min(d, ndfSdBezier(p, vec2(-0.14, 0.56), vec2( 0.14, 0.84), vec2( 0.28, 0.44)));
        d = min(d, ndfSdBezier(p, vec2( 0.28, 0.44), vec2( 0.30, 0.06), vec2(-0.04, ym)));
        d = min(d, ndfSdBezier(p, vec2(-0.04, ym),   vec2( 0.30,-0.06), vec2( 0.28,-0.44)));
        d = min(d, ndfSdBezier(p, vec2( 0.28,-0.44), vec2( 0.14,-0.84), vec2(-0.14,-0.56)));
    } else if (ch==4) {
        d = min(d, sdSegment(p, vec2( 0.19, yt), vec2(-0.26,-0.22)));
        d = min(d, sdSegment(p, vec2(-0.26,-0.22), vec2( 0.27,-0.22)));
        d = min(d, sdSegment(p, vec2( 0.19, yt), vec2( 0.19, yb)));
    } else if (ch==5) {
        d = min(d, sdSegment(p, vec2(-0.20, yt), vec2( 0.24, yt)));
        d = min(d, sdSegment(p, vec2(-0.20, yt), vec2(-0.20, 0.06)));
        d = min(d, ndfSdBezier(p, vec2(-0.20, 0.06), vec2( 0.30, 0.10), vec2( 0.28,-0.30)));
        d = min(d, ndfSdBezier(p, vec2( 0.28,-0.30), vec2( 0.28,-0.70), vec2( 0.0, yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb),   vec2(-0.22,-0.70), vec2(-0.22,-0.42)));
    } else if (ch==6) {
        d = min(d, ndfSdBezier(p, vec2( 0.0, -0.02), vec2( 0.25,-0.02), vec2( 0.25,-0.34)));
        d = min(d, ndfSdBezier(p, vec2( 0.25,-0.34), vec2( 0.25, yb),   vec2( 0.0,  yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb),   vec2(-0.25, yb),   vec2(-0.25,-0.34)));
        d = min(d, ndfSdBezier(p, vec2(-0.25,-0.34), vec2(-0.25,-0.02), vec2( 0.0, -0.02)));
        d = min(d, ndfSdBezier(p, vec2( 0.18, yt),   vec2(-0.22, 0.34), vec2(-0.25,-0.30)));
    } else if (ch==7) {
        d = min(d, sdSegment(p, vec2(-0.22, yt), vec2( 0.26, yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.26, yt), vec2( 0.06, 0.0), vec2(-0.10, yb)));
    } else if (ch==8) {
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yt),   vec2( 0.19, yt),   vec2( 0.19, 0.35)));
        d = min(d, ndfSdBezier(p, vec2( 0.19, 0.35), vec2( 0.19, ym),   vec2( 0.0,  ym)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  ym),   vec2(-0.19, ym),   vec2(-0.19, 0.35)));
        d = min(d, ndfSdBezier(p, vec2(-0.19, 0.35), vec2(-0.19, yt),   vec2( 0.0,  yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  ym),   vec2( 0.24, ym),   vec2( 0.24,-0.36)));
        d = min(d, ndfSdBezier(p, vec2( 0.24,-0.36), vec2( 0.24, yb),   vec2( 0.0,  yb)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yb),   vec2(-0.24, yb),   vec2(-0.24,-0.36)));
        d = min(d, ndfSdBezier(p, vec2(-0.24,-0.36), vec2(-0.24, ym),   vec2( 0.0,  ym)));
    } else if (ch==9) {
        d = min(d, ndfSdBezier(p, vec2( 0.0,  0.02), vec2( 0.25, 0.02), vec2( 0.25, 0.34)));
        d = min(d, ndfSdBezier(p, vec2( 0.25, 0.34), vec2( 0.25, yt),   vec2( 0.0,  yt)));
        d = min(d, ndfSdBezier(p, vec2( 0.0,  yt),   vec2(-0.25, yt),   vec2(-0.25, 0.34)));
        d = min(d, ndfSdBezier(p, vec2(-0.25, 0.34), vec2(-0.25, 0.02), vec2( 0.0,  0.02)));
        d = min(d, ndfSdBezier(p, vec2(-0.18, yb),   vec2( 0.22,-0.34), vec2( 0.25, 0.30)));
    }
    return d;
}

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

int rulerNumGlyphs(float value, int decimals) {
    bool neg = value < 0.0;
    float av = abs(value);
    float ipart = (decimals == 0) ? floor(av + 0.5) : floor(av);
    int nint = 1;
    float tt = ipart;
    for (int i = 0; i < 6; i++) { if (tt >= 10.0) { tt = floor(tt / 10.0); nint++; } }
    return nint + (neg ? 1 : 0) + ((decimals > 0) ? (1 + decimals) : 0);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
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

void main() {
    fragColor = ruler((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_elements, u_justify, u_numbers, u_size, u_numberSize, u_color1, u_value, u_range, u_glow, u_thickness, u_modelTransform, u_outDim);
}
