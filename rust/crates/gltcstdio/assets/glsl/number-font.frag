#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode (int(U[5].x))
#define u_value (U[6].x)
#define u_decimals (int(U[7].x))
#define u_color1 (U[8])
#define u_thickness (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_glow (U[13].x)

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











































































































































































































































































































































#define AA 2





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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 numberFont(vec2 uv, vec2 outPos, int mode, float value, int decimals, vec4 color1, float thickness, mat3 modelTransform, vec2 outDim, float glow) {
    mat3 im = inverse(modelTransform);
    vec2 u = tf(im, uv);
    vec4 bkg = __source__(uv);
    // AA width = one output texel, measured in glyph space (derivative-free, zoom-independent).
    float pixel = 2.0 / outDim.y;
    float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;

    bool neg = value < 0.0;
    float av = abs(value);
    float ipart = floor(av);

    // integer digit count
    int nint = 1;
    float t2 = ipart;
    for (int i = 0; i < 9; i++) {
        if (t2 >= 10.0) { t2 = floor(t2 / 10.0); nint++; }
    }

    int nglyph = nint + (neg ? 1 : 0) + (decimals > 0 ? 1 + decimals : 0);

    float adv = 0.88;                        // advance width per glyph cell
    float total = float(nglyph) * adv;
    float left = -total * 0.5;
    float fx = u.x - left;
    int slot = int(floor(fx / adv));

    float halfW = 0.03 + thickness * 0.20;   // stroke half-width

    // Nearest glyph across this cell + its two neighbours (min) drives the ink; each glyph's glow
    // is summed (additive light) so adjacent haloes reinforce and merge instead of just clipping.
    float d = 1e9;
    float gsum = 0.0;
    for (int s = slot - 1; s <= slot + 1; s++) {
        if (s < 0 || s >= nglyph) continue;
        int sch = ndfCharForSlot(s, nint, neg, decimals, ipart, av);
        if (sch == 12) continue;
        vec2 sp = vec2(fx - (float(s) + 0.5) * adv, -u.y);
        float sd = (mode == 0) ? ndfDigital(sch, sp) : ndfCurved(sch, sp);
        d = min(d, sd);
        gsum += exp(-max(sd - halfW, 0.0) * 6.0);   // neon glow: soft falloff, summed over glyphs
    }

    float cov = 1.0 - smoothstep(halfW - aa, halfW + aa, d);
    float g = glow * gsum * (1.0 - cov);

    if (cov <= 0.0 && g <= 0.002) return bkg;

    vec4 outc = mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
    outc.rgb += color1.rgb * g;
    outc.a = max(outc.a, min(g, 1.0));
    return outc;
}

void main() {
    fragColor = numberFont((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_value, u_decimals, u_color1, u_thickness, u_modelTransform, u_outDim, u_glow);
}
