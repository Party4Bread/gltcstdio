#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[27];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_style (int(U[6].x))
#define u_fill (int(U[7].x))
#define u_randomness (U[8].x)
#define u_randomSeed (U[9].x)
#define u_levels (int(U[10].x))
#define u_threshold (U[11].x)
#define u_precizion (int(U[12].x))
#define u_thickness (U[13].x)
#define u_border (U[14].x)
#define u_maskAR (U[15].x)
#define u_colorOutline (U[16])
#define u_colorBkg (U[17])
#define u_colorR (U[18])
#define u_colorG (U[19])
#define u_colorB (U[20])
#define u_modelTransform (mat3(U[21].xyz, U[22].xyz, U[23].xyz))
#define u_maskTransform (mat3(U[24].xyz, U[25].xyz, U[26].xyz))

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

// Filled axis-aligned box SDF (iq): negative inside. lo/hi are opposite corners.


// Diagonal hatch mask in cell-local units: ~1 on a stripe, ~0 in the gap (50% duty), AA'd.


// Radial hatch: spokes at a fixed angular spacing (for gauge rings). AA scales with radius.







float chBox(vec2 p, vec2 lo, vec2 hi) {
    vec2 ctr = (lo + hi) * 0.5;
    vec2 hlf = (hi - lo) * 0.5;
    vec2 q = abs(p - ctr) - hlf;
    return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0);
}

float chHatch(vec2 p, float aa) {
    float period = 0.07;
    float t = fract((p.x + p.y) / period);
    float d = 0.25 - abs(t - 0.5);      // >0 inside the stripe half of each period
    float w = aa / period;
    return smoothstep(-w, w, d);
}

float chHatchRadial(vec2 p, float aa) {
    float spokes = 22.0;
    float rho = max(length(p), 1e-3);
    float t = fract((atan(p.y, p.x) / PI2) * spokes);
    float d = 0.25 - abs(t - 0.5);
    float w = aa * spokes / (PI2 * rho);
    return smoothstep(-w, w, d);
}

vec2 hash22(vec2 u) {
    return vec2(
        fract(sin(u.x*776.45+u.y*453.24)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24)*88.77) );
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 charts(vec2 uv, vec2 outPos, int style, int fill, float randomness, float randomSeed,
        int levels, float threshold, int precizion, float thickness, float border, float maskAR,
        vec4 colorOutline, vec4 colorBkg, vec4 colorR, vec4 colorG, vec4 colorB,
        mat3 modelTransform, mat3 maskTransform, vec2 sourceDim, vec2 outDim) {

    mat3 im = inverse(modelTransform);
    vec2 vg = tf(im, uv);              // fragment position in grid space (cells at integers, R=1)

    // ---- Dichotomic subdivision (SquareMosaic): split a cell while its colour variance is high.
    int N = precizion;
    float n = float(N);
    float st = 1.0 / n;
    float s2 = st * 0.5;
    float thr = threshold * threshold;
    float R = 1.0;
    for (int k = 0; k < levels - 1; ++k) {
        vec2 cid = floor(vg * R);
        vec3 ccol = __source__(tf(modelTransform, (cid + 0.5) / R)).rgb;
        float var = 0.0;
        for (float j = 0.0; j < n; ++j) {
            for (float i = 0.0; i < n; ++i) {
                vec2 uu = vec2(s2 + i * st, s2 + j * st);
                vec3 col = __source__(tf(modelTransform, (cid + uu) / R)).rgb;
                var += dot(ccol - col, ccol - col);
            }
        }
        if (var / (n * n) < thr) break;
        R *= 2.0;
    }

    // ---- Final cell: id, centred local coord, representative colour.
    vec2 vv = vg * R;
    vec2 id = floor(vv);

    // ---- Reveal mask: display a cell only if it intersects the maskTransform rectangle. The rect
    // is centred, half-extents (H*maskAR, H) with H = max(1, outputAR) so at maskAR=1 (identity
    // transform) it is a square of side 2*max(1, outputAR) covering the whole image. Cells that
    // don't intersect it show the source photo untouched.
    {
        mat3 imask = inverse(maskTransform);
        float H = max(1.0, outDim.x / outDim.y);
        vec2 mh = vec2(H * maskAR, H);
        vec2 ml = tf(imask, tf(modelTransform, (id + 0.5) / R));   // cell centre in mask-local space
        float mScale = length(vec2(modelTransform[0][0], modelTransform[0][1]));
        float kScale = length(vec2(imask[0][0], imask[0][1]));
        float hc = (0.5 / R) * mScale * kScale;                    // cell half-size in mask-local units
        if (abs(ml.x) > mh.x + hc || abs(ml.y) > mh.y + hc) return __source__(uv);
    }

    vec2 cell = vv - id - 0.5;
    cell.y = -cell.y;   // screen V2 has +y DOWN; draw glyphs in +y-up (bars grow up, gauges from top)

    // Representative colour = average of a precision x precision grid over the FINAL cell (not a
    // single centre texel), so each chart's R/G/B reflects the whole cell.
    vec3 csum = vec3(0.0);
    for (float j = 0.0; j < n; ++j) {
        for (float i = 0.0; i < n; ++i) {
            vec2 uu = vec2(s2 + i * st, s2 + j * st);
            csum += __source__(tf(modelTransform, (id + uu) / R)).rgb;
        }
    }
    vec3 c = csum / (n * n);
    float vals[3];
    vals[0] = clamp(c.r, 0.0, 1.0);
    vals[1] = clamp(c.g, 0.0, 1.0);
    vals[2] = clamp(c.b, 0.0, 1.0);
    vec4 chan[3];
    chan[0] = colorR;
    chan[1] = colorG;
    chan[2] = colorB;

    // AA half-width, expressed in cell-local units (one screen pixel -> grid -> cell via *R).
    float pixel = 2.0 / outDim.y;
    float aa = max(length(tf(im, uv + vec2(pixel, 0.0)) - vg) * R, 1e-4);
    float strokeLw = thickness * 0.05;   // chart glyph stroke half-width (0 => no stroke)
    float frameLw  = border * 0.06;      // square cell-border half-width (0 => no border)

    // ---- Per-cell style: base `style`, or a hash-random one for a `randomness` fraction of cells.
    int styleCell = clamp(style, 0, 3);
    vec2 hh = hash22(id + vec2(randomSeed, randomSeed * 1.7 + 3.1));
    if (hh.x < randomness) {
        styleCell = min(int(floor(hh.y * 4.0)), 3);
    }

    // Cell background: `colorBkg`, its alpha letting the source photo bleed through.
    vec4 bkg = __source__(uv);
    vec3 acc = mix(bkg.rgb, colorBkg.rgb, colorBkg.a);

    float dStroke = 1e9;                                          // chart glyph outlines
    float dFrame = abs(0.5 - max(abs(cell.x), abs(cell.y)));      // cell square border (its own width)

    // Fill modulation: 1 everywhere for solid, or a diagonal hatch that lets background through.
    float hatch = (fill == 1) ? chHatch(cell, aa) : 1.0;

    if (styleCell == 0) {
        // ---- PIE: three wedges, angular size proportional to R/G/B.
        float r = 0.34;
        float dDisc = length(cell) - r;
        dStroke = min(dStroke, abs(dDisc));   // rim always drawn
        float rawSum = vals[0] + vals[1] + vals[2];
        if (rawSum > 1e-4) {   // all channels 0 => leave the disc as background
            float f0 = vals[0] / rawSum;
            float f1 = f0 + vals[1] / rawSum;
            if (dDisc < aa) {
                float discCov = 1.0 - smoothstep(-aa, aa, dDisc);
                float ang = fract(atan(cell.y, cell.x) / PI2 + 1.0);   // [0,1) CCW from +x
                vec3 wcol; float wa;
                if (ang < f0)      { wcol = chan[0].rgb; wa = chan[0].a; }
                else if (ang < f1) { wcol = chan[1].rgb; wa = chan[1].a; }
                else               { wcol = chan[2].rgb; wa = chan[2].a; }
                acc = mix(acc, wcol, discCov * wa * hatch);
            }
            dStroke = min(dStroke, sdSegment(cell, vec2(0.0), r * vec2(1.0, 0.0)));                       // start cut
            dStroke = min(dStroke, sdSegment(cell, vec2(0.0), r * vec2(cos(f0 * PI2), sin(f0 * PI2))));   // R|G cut
            dStroke = min(dStroke, sdSegment(cell, vec2(0.0), r * vec2(cos(f1 * PI2), sin(f1 * PI2))));   // G|B cut
        }
    } else if (styleCell == 1) {
        // ---- BARS: three vertical bars, heights = R/G/B, on a baseline.
        float base = -0.36;
        float maxH = 0.72;
        for (int b = 0; b < 3; ++b) {
            float bx = -0.24 + float(b) * 0.24;
            float h = vals[b] * maxH;
            float d = chBox(cell, vec2(bx - 0.085, base), vec2(bx + 0.085, base + max(h, 0.004)));
            acc = mix(acc, chan[b].rgb, (1.0 - smoothstep(-aa, aa, d)) * chan[b].a * hatch);
            dStroke = min(dStroke, abs(d));
        }
        dStroke = min(dStroke, sdSegment(cell, vec2(-0.40, base), vec2(0.40, base)));   // baseline axis
    } else if (styleCell == 2) {
        // ---- RINGS: concentric gauge arcs; the coloured arc fully overlays the thin track ring.
        float startAng = 1.5707963;   // +y (top in the +y-up frame)
        float hatchR = (fill == 1) ? chHatchRadial(cell, aa) : 1.0;   // radial spokes, not diagonal
        for (int b = 0; b < 3; ++b) {
            float ri = 0.14 + float(b) * 0.10;
            float dTrack = abs(length(cell) - ri);
            float covTrack = (strokeLw <= 0.0) ? 0.0 : (1.0 - smoothstep(strokeLw - aa, strokeLw + aa, dTrack));
            acc = mix(acc, colorOutline.rgb, covTrack * colorOutline.a);   // thin full track ring first
            float hw = max(0.03, strokeLw + 2.0 * aa);                     // band >= track, so colour covers it
            float dRing = abs(length(cell) - ri) - hw;
            float ang = fract((startAng - atan(cell.y, cell.x)) / PI2 + 1.0);   // [0,1) clockwise from top
            float angAA = aa / max(PI2 * ri, 1e-3);
            float angMask = 1.0 - smoothstep(vals[b] - angAA, vals[b] + angAA, ang);
            acc = mix(acc, chan[b].rgb, (1.0 - smoothstep(-aa, aa, dRing)) * angMask * chan[b].a * hatchR);
        }
    } else {
        // ---- DOTS: 3x3 grid. Row = channel (R top, G mid, B bottom); columns grow left->right;
        //      the channel value lights the first 0..3 dots of its row.
        float cy[3]; cy[0] = 0.30; cy[1] = 0.0; cy[2] = -0.30;
        float cx[3]; cx[0] = -0.30; cx[1] = 0.0; cx[2] = 0.30;
        float rr[3]; rr[0] = 0.05; rr[1] = 0.085; rr[2] = 0.12;
        for (int r = 0; r < 3; ++r) {
            int cnt = clamp(int(floor(vals[r] * 3.0 + 0.5)), 0, 3);
            for (int cc = 0; cc < 3; ++cc) {
                float dCirc = length(cell - vec2(cx[cc], cy[r])) - rr[cc];
                if (cc < cnt) {
                    acc = mix(acc, chan[r].rgb, (1.0 - smoothstep(-aa, aa, dCirc)) * chan[r].a * hatch);
                }
                dStroke = min(dStroke, abs(dCirc));   // outline every slot
            }
        }
    }

    // Glyph strokes, then the square cell border on top — both use the outline colour, own widths.
    // Either width at 0 draws nothing at all.
    float covStroke = (strokeLw <= 0.0) ? 0.0 : (1.0 - smoothstep(strokeLw - aa, strokeLw + aa, dStroke));
    acc = mix(acc, colorOutline.rgb, covStroke * colorOutline.a);
    float covFrame = (frameLw <= 0.0) ? 0.0 : (1.0 - smoothstep(frameLw - aa, frameLw + aa, dFrame));
    acc = mix(acc, colorOutline.rgb, covFrame * colorOutline.a);

    return vec4(acc, 1.0);
}

void main() {
    fragColor = charts((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_style, u_fill, u_randomness, u_randomSeed, u_levels, u_threshold, u_precizion, u_thickness, u_border, u_maskAR, u_colorOutline, u_colorBkg, u_colorR, u_colorG, u_colorB, u_modelTransform, u_maskTransform, u_sourceDim, u_outDim);
}
