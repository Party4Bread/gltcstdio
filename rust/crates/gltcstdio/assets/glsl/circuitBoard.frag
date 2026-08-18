#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_coverage (U[6].x)
#define u_population (U[7].x)
#define u_integration (U[8].x)
#define u_variability (U[9].x)
#define u_randomSeed (U[10].x)
#define u_colorBkg (U[11])
#define u_color (U[12])
#define u_color1 (U[13])
#define u_thickness (U[14].x)
#define u_roundness (U[15].x)
#define u_modelTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))





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








float cb_withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x + 0.5, pow(2.0, -s * ab)) - 0.5;
}

float hash11(float x) {
    return fract(sin(x*45.34+123.131)*94.434);
}

float hash21(vec2 p) {
    vec2 a = fract(-45.3277*p.xy);
    vec2 b = a + dot(a, a+123.3371);
	return fract(b.x*b.y);  
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

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec4 circuitBoard(vec2 uv, vec2 outPos, vec2 outDim,
        int count, float coverage, float population, float integration, float variability, float randomSeed,
        vec4 colorBkg, vec4 color, vec4 color1, float thickness, float roundness, mat3 modelTransform) {

    float cnt = max(2.0, float(count));
    float ar = outDim.x / outDim.y;

    // ---- grid space: canvas y in [-1,1] spans `cnt` units; integers land on grid lines ----
    float g = 2.0 / cnt;
    vec2 gp = uv / g;
    float aaG = (cnt / outDim.y) * 0.75;                     // one screen pixel, in grid units (AA half-width)

    // ---- root cell: integer bounding box centred on the canvas ----
    float halfW = ar * cnt * 0.5;
    float halfH = cnt * 0.5;
    vec4 rect = vec4(floor(-halfW), floor(-halfH), ceil(halfW), ceil(halfH)); // ix0, iy0, ix1, iy1

    // ---- ModelTransform: scale ⇒ recursion depth, translation ⇒ split bias ----
    vec2 biasBase = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;
    float mtScale = 1.0 / max(1e-4, length(vec2(modelTransform[0][0], modelTransform[0][1])));

    vec2 splits = vec2(0.0);
    bool horSplit = true;
    vec2 bias = biasBase;
    float sPos = 0.0, sscale = 0.5, inverter = 0.0;
    float regularity = 1.0 - variability;

    // ---- dichotomic descent, every split snapped to the integer grid ----
    for (float i = 0.0; i + sPos < mtScale; ++i) {
        float w = rect.z - rect.x;
        float h = rect.w - rect.y;
        bool canV = w >= 2.0;                                // a vertical split (cut x) needs width >= 2
        bool canH = h >= 2.0;                                // a horizontal split (cut y) needs height >= 2
        if (!canV && !canH) break;

        vec2 rnd = rand2relSeeded(splits, randomSeed + 122.1);

        // early stop => larger terminal cells (chips); integration biases toward stopping.
        float area = w * h;
        float aspect = max(w, h) / max(1.0, min(w, h));
        float sizePref = smoothstep(3.0, 8.0, area) * (1.0 - smoothstep(70.0, 150.0, area));
        float pStop = integration * sizePref;
        bool guard = (aspect > 7.0) || (max(w, h) > 13.0);   // avoid slivers / screen-filling blanks
        float sh = hash21(splits * 0.317 + randomSeed * 0.019 + 7.7);
        if (!guard && area >= 4.0 && sh < pStop) break;

        // prefer terminating component-sized strips (1×n, n=3..7) so passives are common.
        if (!guard && min(w, h) == 1.0 && max(w, h) >= 3.0 && max(w, h) <= 7.0
            && hash21(splits * 0.51 + randomSeed * 0.041 + 2.2) < 0.5) break;

        // pick the split axis: clean grid at low variability, alternating h/v as variability rises.
        if (rnd.x + 0.5 < regularity * 2.0) horSplit = h > w;
        if (horSplit && !canH) horSplit = false;
        if (!horSplit && !canV) horSplit = true;

        float posVar = 1.0 - max(0.0, regularity * 2.0 - 1.0);

        if (horSplit) {
            float lo = rect.y + 1.0, hi = rect.w - 1.0;
            float Yf = mix(rect.y, rect.w, posVar * cb_withBias(rnd.y, bias.y) + 0.5);
            float Y = clamp(floor(Yf + 0.5), lo, hi);        // snap the split to the grid
            if (gp.y < Y) { rect.w = Y; splits.y += 1.0;   sPos += inverter * sscale; }
            else          { rect.y = Y; splits.y += 100.0; sPos += (1.0 - inverter) * sscale; }
        } else {
            float lo = rect.x + 1.0, hi = rect.z - 1.0;
            float Xf = mix(rect.x, rect.z, posVar * cb_withBias(rnd.x, bias.x) + 0.5);
            float X = clamp(floor(Xf + 0.5), lo, hi);
            if (gp.x < X) { rect.z = X; splits.x += 1.0;   sPos += inverter * sscale; }
            else          { rect.x = X; splits.x += 100.0; sPos += (1.0 - inverter) * sscale; }
        }
        horSplit = !horSplit;
        inverter = 1.0 - inverter;
        sscale *= 0.5;
        bias *= 0.5;
    }

    // ---- terminal cell ----
    float ix0 = rect.x, iy0 = rect.y, ix1 = rect.z, iy1 = rect.w;
    float w = ix1 - ix0, h = iy1 - iy0;
    float cx = 0.5 * (ix0 + ix1), cy = 0.5 * (iy0 + iy1);
    float cellHash = hash21(splits * 0.713 + randomSeed * 0.037 + 1.3);
    float pinSeed = randomSeed + 313.7;

    float dTrace = 1e9;      // wires / traces / stubs / spines (drawn in `color`)
    float dBody  = 1e9;      // component body (filled `color1`, rimmed `color`)
    float dPin1  = 1e9;      // chip pin-1 marker (drawn in `color`)
    float dPadO  = 1e9;      // via/pad outer disc (`color`)
    float dPadI  = 1e9;      // via/pad hole (`colorBkg`)
    float dComp  = 1e9;      // passive-component body (resistor pill / packaged part), filled `compColor`
    float dCompMk = 1e9;     // component markings (resistor bands / polarity stripe), filled `markColor`
    float dGap   = 1e9;      // dielectric gap that erases the trace between capacitor plates
    float dCapPlate = 1e9;   // capacitor plates (drawn in `color`, over the gap)
    vec4 compColor = vec4(0.0);
    vec4 markColor = vec4(0.0);

    float traceHalf = thickness * 0.22;                      // trace half-width, grid units (0 ⇒ no traces)
    float minWH = min(w, h);
    float maxWH = max(w, h);

    // A fraction (1 - population) of cells are left as bare board for breathing room. Incoming
    // wires still terminate cleanly (in a via pad) so the edge-pin contract is never broken.
    bool populated = hash21(splits * 0.911 + randomSeed * 0.053 + 4.4) < population;
    float mxE = clamp(floor(gp.x) + 0.5, ix0 + 0.5, ix1 - 0.5);
    float myE = clamp(floor(gp.y) + 0.5, iy0 + 0.5, iy1 - 0.5);

    if (!populated) {
        // ===== UNPOPULATED CELL: bare board; terminate any incoming wire in a via pad =====
        float lead = 0.32;
        if (rand2relSeeded(vec2(mxE, iy0), pinSeed).x + 0.5 < coverage) { vec2 e = vec2(mxE, iy0 + lead); dTrace = min(dTrace, sdSegment(gp, vec2(mxE, iy0), e)); dPadO = min(dPadO, length(gp - e) - 0.20); dPadI = min(dPadI, length(gp - e) - 0.09); }
        if (rand2relSeeded(vec2(mxE, iy1), pinSeed).x + 0.5 < coverage) { vec2 e = vec2(mxE, iy1 - lead); dTrace = min(dTrace, sdSegment(gp, vec2(mxE, iy1), e)); dPadO = min(dPadO, length(gp - e) - 0.20); dPadI = min(dPadI, length(gp - e) - 0.09); }
        if (rand2relSeeded(vec2(ix0, myE), pinSeed).x + 0.5 < coverage) { vec2 e = vec2(ix0 + lead, myE); dTrace = min(dTrace, sdSegment(gp, vec2(ix0, myE), e)); dPadO = min(dPadO, length(gp - e) - 0.20); dPadI = min(dPadI, length(gp - e) - 0.09); }
        if (rand2relSeeded(vec2(ix1, myE), pinSeed).x + 0.5 < coverage) { vec2 e = vec2(ix1 - lead, myE); dTrace = min(dTrace, sdSegment(gp, vec2(ix1, myE), e)); dPadO = min(dPadO, length(gp - e) - 0.20); dPadI = min(dPadI, length(gp - e) - 0.09); }
    } else if (minWH >= 2.0) {
        // ===== BODY CELL: an IC chip, or — when elongated — a packaged passive =====
        float inset = (minWH >= 3.0) ? 0.72 : 0.42;
        vec2 bc = vec2(cx, cy);
        vec2 bhalf = vec2(w, h) * 0.5 - vec2(inset);
        float rr = min(0.28, roundness * 0.35);
        float dB = sdRectangle(gp - bc, bhalf) - rr;
        float aspectB = maxWH / minWH;
        float pkgHash = hash11(cellHash * 7.7 + 1.1);
        vec2 pc = gp - bc;
        vec2 ap = (h >= w) ? pc.yx : pc.xy;                  // ap.x along the long axis
        float along = maxWH * 0.5 - inset;                   // half body length

        if (aspectB >= 2.2 && pkgHash < 0.30) {
            // electrolytic capacitor: blue can with a silver polarity stripe near one end.
            dComp = dB; compColor = vec4(0.12, 0.30, 0.63, 1.0); markColor = vec4(0.80, 0.83, 0.88, 1.0);
            dCompMk = max(sdRectangle(vec2(ap.x + along - 0.30, ap.y), vec2(0.13, 1000.0)), dB + 0.02);
        } else if (aspectB >= 2.2 && pkgHash < 0.55) {
            // power resistor: beige block with colour bands.
            dComp = dB; compColor = vec4(0.74, 0.57, 0.35, 1.0); markColor = colorBkg;
            for (int b = 0; b < 3; ++b)
                dCompMk = min(dCompMk, max(sdRectangle(vec2(ap.x - (float(b) - 1.0) * 0.55, ap.y), vec2(0.08, 1000.0)), dB + 0.03));
        } else if (aspectB >= 2.2 && pkgHash < 0.80) {
            // molded inductor: dark body with a gold coil squiggle (chain of loops along its length).
            dComp = dB; compColor = vec4(0.20, 0.21, 0.24, 1.0); markColor = color;
            float cspan = along * 2.0 - 0.5;
            int ch = int(clamp(floor(cspan / 0.9), 3.0, 7.0));
            float csp = cspan / float(ch);
            float cr = min(csp * 0.6, minWH * 0.5 - inset * 0.5 - 0.05);
            float dcoil = 1e9;
            for (int c = 0; c < ch; ++c) { float o = -cspan * 0.5 + (float(c) + 0.5) * csp; dcoil = min(dcoil, abs(length(vec2(ap.x - o, ap.y)) - cr)); }
            dCompMk = max(dcoil - 0.11, dB + 0.05);
        } else {
            // IC chip (with pin-1 dot + notch when big enough).
            dBody = dB;
            if (minWH >= 3.0) {
                vec2 notchC = vec2(cx, cy + bhalf.y);
                dBody = max(dBody, -(length(gp - notchC) - 0.35));
                dPin1 = length(gp - vec2(cx - bhalf.x + 0.5, cy + bhalf.y - 0.5)) - 0.18;
            }
        }

        // stubs: nearest active segment on each edge, straight into the body/package edge.
        float mx = clamp(floor(gp.x) + 0.5, ix0 + 0.5, ix1 - 0.5);
        float my = clamp(floor(gp.y) + 0.5, iy0 + 0.5, iy1 - 0.5);
        if (rand2relSeeded(vec2(mx, iy0), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(mx, iy0), vec2(mx, iy0 + inset)));
        if (rand2relSeeded(vec2(mx, iy1), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(mx, iy1), vec2(mx, iy1 - inset)));
        if (rand2relSeeded(vec2(ix0, my), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(ix0, my), vec2(ix0 + inset, my)));
        if (rand2relSeeded(vec2(ix1, my), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(ix1, my), vec2(ix1 - inset, my)));
    } else {
        // ===== SPINE CELL (1×n): Manhattan spine between extreme active pins + stubs =====
        bool vertical = h >= w;
        float activeCount = 0.0;
        float hx0 = cx, hx1 = cx;                            // horizontal spine (y = cy) x-extent
        float vy0 = cy, vy1 = cy;                            // vertical spine (x = cx) y-extent

        int wc = int(min(16.0, w));
        for (int s = 0; s < wc; ++s) {
            float mx = ix0 + float(s) + 0.5;
            if (rand2relSeeded(vec2(mx, iy0), pinSeed).x + 0.5 < coverage) { activeCount += 1.0; hx0 = min(hx0, mx); hx1 = max(hx1, mx); }
            if (rand2relSeeded(vec2(mx, iy1), pinSeed).x + 0.5 < coverage) { activeCount += 1.0; hx0 = min(hx0, mx); hx1 = max(hx1, mx); }
        }
        int hc = int(min(16.0, h));
        for (int s = 0; s < hc; ++s) {
            float my = iy0 + float(s) + 0.5;
            if (rand2relSeeded(vec2(ix0, my), pinSeed).x + 0.5 < coverage) { activeCount += 1.0; vy0 = min(vy0, my); vy1 = max(vy1, my); }
            if (rand2relSeeded(vec2(ix1, my), pinSeed).x + 0.5 < coverage) { activeCount += 1.0; vy0 = min(vy0, my); vy1 = max(vy1, my); }
        }

        if (activeCount >= 1.0) {
            dTrace = min(dTrace, sdSegment(gp, vec2(hx0, cy), vec2(hx1, cy)));
            dTrace = min(dTrace, sdSegment(gp, vec2(cx, vy0), vec2(cx, vy1)));

            // stubs from the nearest active pin on each edge to its spine arm.
            float mx = clamp(floor(gp.x) + 0.5, ix0 + 0.5, ix1 - 0.5);
            float my = clamp(floor(gp.y) + 0.5, iy0 + 0.5, iy1 - 0.5);
            if (rand2relSeeded(vec2(mx, iy0), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(mx, iy0), vec2(mx, cy)));
            if (rand2relSeeded(vec2(mx, iy1), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(mx, iy1), vec2(mx, cy)));
            if (rand2relSeeded(vec2(ix0, my), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(ix0, my), vec2(cx, my)));
            if (rand2relSeeded(vec2(ix1, my), pinSeed).x + 0.5 < coverage) dTrace = min(dTrace, sdSegment(gp, vec2(ix1, my), vec2(cx, my)));

            // junction solder dot at a T/X crossing.
            if (activeCount >= 3.0) dTrace = min(dTrace, length(gp - vec2(cx, cy)) - traceHalf * 1.7);

            // dead-end via/pad terminator.
            if (activeCount < 1.5) { dPadO = length(gp - vec2(cx, cy)) - 0.24; dPadI = length(gp - vec2(cx, cy)) - 0.11; }

            // inline 2-terminal component on a through-trace (needs both long-axis ends live).
            bool endA, endB;
            if (vertical) {
                endA = rand2relSeeded(vec2(cx, iy0), pinSeed).x + 0.5 < coverage;
                endB = rand2relSeeded(vec2(cx, iy1), pinSeed).x + 0.5 < coverage;
            } else {
                endA = rand2relSeeded(vec2(ix0, cy), pinSeed).x + 0.5 < coverage;
                endB = rand2relSeeded(vec2(ix1, cy), pinSeed).x + 0.5 < coverage;
            }
            if (endA && endB) {
                vec2 pc2 = gp - vec2(cx, cy);
                vec2 ap = vertical ? pc2.yx : pc2.xy;        // ap.x = along long axis, ap.y = perpendicular
                if (maxWH <= 2.5) {
                    // capacitor: two plates with a real dielectric GAP (the trace stops at each plate).
                    dGap = sdRectangle(ap, vec2(0.17, 0.62));
                    dCapPlate = min(sdRectangle(vec2(ap.x - 0.22, ap.y), vec2(0.055, 0.5)),
                                    sdRectangle(vec2(ap.x + 0.22, ap.y), vec2(0.055, 0.5)));
                } else if (hash11(cellHash * 43.1 + 2.0) < 0.35) {
                    // resistor: beige pill on the trace, banded (leads run out both ends).
                    float pillHalf = clamp(maxWH * 0.5 - 0.9, 0.5, 1.4);
                    dComp = sdRectangle(ap, vec2(pillHalf, 0.30)) - 0.26; compColor = vec4(0.74, 0.57, 0.35, 1.0); markColor = colorBkg;
                    for (int b = 0; b < 3; ++b)
                        dCompMk = min(dCompMk, max(sdRectangle(vec2(ap.x - (float(b) - 1.0) * min(0.42, pillHalf * 0.55), ap.y), vec2(0.06, 0.34)), dComp + 0.03));
                } else {
                    // inductor: a run of coil humps riding the trace (classic squiggle symbol).
                    float span = maxWH - 1.3;
                    int humps = int(clamp(floor(span / 0.8), 2.0, 6.0));
                    float sp = span / float(humps);
                    float r = min(sp * 0.62, 0.45);
                    float dc = 1e9;
                    for (int c = 0; c < humps; ++c) {
                        float off = -span * 0.5 + (float(c) + 0.5) * sp;
                        dc = min(dc, abs(length(vec2(ap.x - off, ap.y)) - r));
                    }
                    dTrace = min(dTrace, max(dc, -ap.y));   // upper half ⇒ bumps riding the spine
                }
            }
        }
    }

    // ---- composite: board → traces → vias → chip body/rim → resistor pill/bands → pin-1 ----
    vec4 col = colorBkg;

    float tCov = 1.0 - smoothstep(traceHalf - aaG, traceHalf + aaG, dTrace);
    col = mix(col, color, tCov * color.a);

    // capacitor: erase the trace in the dielectric gap, then lay the plates over it.
    float gapCov = 1.0 - smoothstep(-aaG, aaG, dGap);
    col = mix(col, colorBkg, gapCov);
    float capCov = 1.0 - smoothstep(-aaG, aaG, dCapPlate);
    col = mix(col, color, capCov * color.a);

    float padO = 1.0 - smoothstep(-aaG, aaG, dPadO);
    col = mix(col, color, padO * color.a);
    float padI = 1.0 - smoothstep(-aaG, aaG, dPadI);
    col = mix(col, colorBkg, padI);

    float bodyCov = 1.0 - smoothstep(-aaG, aaG, dBody);
    col = mix(col, color1, bodyCov * color1.a);
    float rimHalf = max(traceHalf * 0.8, aaG);
    float rimCov = 1.0 - smoothstep(rimHalf - aaG, rimHalf + aaG, abs(dBody));
    col = mix(col, color, rimCov * color.a);

    // passive-component body (resistor pill / packaged part), over its leads, plus its markings.
    float compCov = 1.0 - smoothstep(-aaG, aaG, dComp);
    col = mix(col, compColor, compCov * compColor.a);
    float mkCov = 1.0 - smoothstep(-aaG, aaG, dCompMk);
    col = mix(col, markColor, mkCov * compCov);

    float p1Cov = 1.0 - smoothstep(-aaG, aaG, dPin1);
    col = mix(col, color, p1Cov * color.a);

    col.a = colorBkg.a;
    return col;
}

void main() {
    fragColor = circuitBoard((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_outDim, u_count, u_coverage, u_population, u_integration, u_variability, u_randomSeed, u_colorBkg, u_color, u_color1, u_thickness, u_roundness, u_modelTransform);
}
