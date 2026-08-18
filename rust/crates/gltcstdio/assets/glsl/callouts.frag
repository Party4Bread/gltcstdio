#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[20];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_elements (int(U[5].x))
#define u_font (int(U[6].x))
#define u_size (U[7].x)
#define u_shapeAspectRatio (U[8].x)
#define u_color1 (U[9])
#define u_count (int(U[10].x))
#define u_randomSeed (U[11].x)
#define u_glow (U[12].x)
#define u_thickness (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_axisTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))

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











































































































































































































































































































































// Rectangle OUTLINE distance (same shape as hudRect in Hud.kt).


// SDF for a number laid out around rel=(0,0) — same layout logic as hudNumDist (Hud.kt); see
// there for the bounding-box lower-bound rationale (keeps the glow field continuous outside).
// align: 0 centered, 1 ends at x=0, 2 starts at x=0. decimals: fractional digits shown.


// Dimension line a->b with stroke arrowheads at both ends (tips at a and b, barbs inward).


// Print registration mark: circle + full cross through it.


// Crosshair (centre mark): small circle + 4 hairs starting OUTSIDE the circle.







vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

float sdDisk(vec2 u, float r) {
    return length(u)-r;
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

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

float tcdCross(vec2 rel, float r) {
    float d = abs(length(rel) - r);
    vec2 pa = abs(rel);
    d = min(d, sdSegment(pa, vec2(r * 0.45, 0.0), vec2(r * 1.8, 0.0)));
    d = min(d, sdSegment(pa, vec2(0.0, r * 0.45), vec2(0.0, r * 1.8)));
    return d;
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

int ndfSevenSeg(int ch) {
    if (ch==0) return 63;
    if (ch==1) return 6;
    if (ch==2) return 91;
    if (ch==3) return 79;
    if (ch==4) return 102;
    if (ch==5) return 109;
    if (ch==6) return 125;
    if (ch==7) return 7;
    if (ch==8) return 127;
    if (ch==9) return 111;
    if (ch==11) return 64;
    return 0;
}

float ndfDigital(int ch, vec2 p) {
    if (ch==10) return length(p - vec2(0.0, -0.66));
    int m = ndfSevenSeg(ch);
    float X = 0.24, Yt = 0.66, Ym = 0.0, Yb = -0.66;
    float d = 1e9;
    if ((m &  1)!=0) d = min(d, sdSegment(p, vec2(-X,Yt), vec2( X,Yt)));
    if ((m &  2)!=0) d = min(d, sdSegment(p, vec2( X,Ym), vec2( X,Yt)));
    if ((m &  4)!=0) d = min(d, sdSegment(p, vec2( X,Yb), vec2( X,Ym)));
    if ((m &  8)!=0) d = min(d, sdSegment(p, vec2(-X,Yb), vec2( X,Yb)));
    if ((m & 16)!=0) d = min(d, sdSegment(p, vec2(-X,Yb), vec2(-X,Ym)));
    if ((m & 32)!=0) d = min(d, sdSegment(p, vec2(-X,Ym), vec2(-X,Yt)));
    if ((m & 64)!=0) d = min(d, sdSegment(p, vec2(-X,Ym), vec2( X,Ym)));
    return d;
}

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

float tcdRect(vec2 rel, vec2 hlf) {
    vec2 q = abs(rel) - hlf;
    return abs(length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0));
}

float tcdReg(vec2 rel, float r) {
    float d = abs(length(rel) - r);
    vec2 pa = abs(rel);
    d = min(d, sdSegment(pa, vec2(0.0, 0.0), vec2(r * 1.8, 0.0)));
    d = min(d, sdSegment(pa, vec2(0.0, 0.0), vec2(0.0, r * 1.8)));
    return d;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
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

void main() {
    fragColor = callouts((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_elements, u_font, u_size, u_shapeAspectRatio, u_color1, u_count, u_randomSeed, u_glow, u_thickness, u_modelTransform, u_axisTransform, u_outDim);
}
