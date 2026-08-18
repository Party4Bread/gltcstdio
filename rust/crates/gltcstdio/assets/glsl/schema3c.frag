#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[27];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_source2Dim (U[5].xy)
#define u_outDim (U[6].xy)
#define u_source2_specified (int(U[7].x))
#define u_aspectRatio (U[8].x)
#define u_intensity (U[9].x)
#define u_iterations (int(U[10].x))
#define u_pixelation (U[11].x)
#define u_balance (U[12].x)
#define u_proximity (U[13].x)
#define u_variability (U[14].x)
#define u_randomSeed (U[15].x)
#define u_color (U[16])
#define u_thickness (U[17].x)
#define u_modelTransform (mat3(U[18].xyz, U[19].xyz, U[20].xyz))
#define u_windowTransform (mat3(U[21].xyz, U[22].xyz, U[23].xyz))
#define u_windowTransform2 (mat3(U[24].xyz, U[25].xyz, U[26].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 distort9(vec2 pos, vec4 rect, vec2 splits, float intensity, float seed) {
    vec2 rnd = rand2relSeeded(splits, seed+122.1);
    float dx = rect.z-rect.x;
    float dy = rect.w-rect.y;
    if (dx>dy) return pos + vec2(sign(rnd.x)*dx/dy*intensity*0.0005, 0.0);
    else       return pos + vec2(0.0, sign(rnd.y)*dy/dx*intensity*0.0005);
}

vec4 inscribedRect(mat3 wt, float srcRatio) {
    float ws = length(wt[1].xy);
    float winA = srcRatio * length(wt[0].xy), winB = ws;
    vec2 wax = normalize(wt[0].xy);
    float c1 = abs(wax.x), s1 = abs(wax.y), sin2 = 2.0*c1*s1;
    float W, H;
    if (winA <= winB*sin2)      { W = winA/(2.0*c1); H = winA/(2.0*s1); }
    else if (winB <= winA*sin2) { W = winB/(2.0*s1); H = winB/(2.0*c1); }
    else { float det = c1*c1 - s1*s1; W = (winA*c1 - winB*s1)/det; H = (winB*c1 - winA*s1)/det; }
    W = max(W, 0.0); H = max(H, 0.0);
    vec2 wc = wt[2].xy;
    return vec4(wc.x-W, wc.y-H, wc.x+W, wc.y+H);
}

float rounded(float x, float prec) {
    return floor(x/prec+0.5)*prec;
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

vec4 schema3c(vec2 uv, vec2 outPos, vec2 sourceDim, vec2 source2Dim, vec2 outDim, int source2_specified, float intensity, int iterations, float pixelation, float balance, float proximity, float variability, float randomSeed, vec4 color, float thickness, float aspectRatio, mat3 modelTransform, mat3 windowTransform, mat3 windowTransform2) {
    float srcRatio  = rounded(sourceDim.x/sourceDim.y, 0.01);   // source 1 AR (drives window 1)
    float outAR     = rounded(outDim.x/outDim.y, 0.01);         // output AR (drives the subdivision)
    float pixel = 2.0/outDim.y;
    bool has2 = source2_specified != 0;
    float src2Ratio = has2 ? rounded(source2Dim.x/source2Dim.y, 0.01) : srcRatio;   // window 2 AR

    // subdivision controls (modelTransform sets depth+bias, as in dichotomic-break)
    vec2 bias = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0/length(vec2(modelTransform[0][0], modelTransform[0][1]));
    float th = thickness*0.1;

    // --- window 1 (source): inside -> clean source at its own AR ---
    float ws1 = length(windowTransform[1].xy);
    vec2 wl1 = (inverse(windowTransform) * vec3(uv, 1.0)).xy;
    float sxg1 = (srcRatio - abs(wl1.x)) * ws1, syg1 = (1.0 - abs(wl1.y)) * ws1;
    if (sxg1>0.0 && syg1>0.0) return __source__(wl1);
    bool frame = (abs(sxg1)<th && syg1>-th) || (abs(syg1)<th && sxg1>-th);

    // --- window 2 (source2, optional): inside -> clean source2 ---
    if (has2) {
        float ws2 = length(windowTransform2[1].xy);
        vec2 wl2 = (inverse(windowTransform2) * vec3(uv, 1.0)).xy;
        float sxg2 = (src2Ratio - abs(wl2.x)) * ws2, syg2 = (1.0 - abs(wl2.y)) * ws2;
        if (sxg2>0.0 && syg2>0.0) return __source2__(wl2);
        frame = frame || (abs(sxg2)<th && syg2>-th) || (abs(syg2)<th && sxg2>-th);
    }

    if (frame) { vec4 col = __source__(uv); return vec4(mix(col.rgb, color.rgb, color.a), col.a); }

    // --- exclusion rectangles for both windows (E2 empty when source2 absent) ---
    vec4 E1 = inscribedRect(windowTransform, srcRatio);
    vec4 E2 = has2 ? inscribedRect(windowTransform2, src2Ratio) : vec4(1e30, 1e30, -1e30, -1e30);

    // (2) shatter: dichotomic-break (mode 9), parting around E1 and E2.
    vec2 p = uv;
    bool border = false;
    vec4 rect;
    vec2 cellId = vec2(0.0);
    float regularity = 1.0-variability;

    for (int j=0; j<iterations; ++j) {
        rect = vec4(-outAR, -1.0, outAR, 1.0);
        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0);
        float sPos = 0.0;
        float sscale = 0.5;
        float inverter = 0.0;
        vec2 b = bias;

        for (float i=0.0; i+sPos<scale; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed+122.1);   // mode 9 -> rndStep 0
            vec2 size = rect.zw-rect.xy;
            if (size.x<pixel || size.y<pixel) break;

            if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
            float var2 = 1.0-max(0.0, (regularity*2.0-1.0));

            if (horSplit) {
                float Y = mix(rect.y, rect.w, var2*withBias(rnd.y, b.y)+0.5);
                // part around each window: a split crossing E snaps to E's nearer horizontal edge.
                if (rect.x<E1.z && rect.z>E1.x && Y>E1.y && Y<E1.w) Y = (Y-E1.y<E1.w-Y) ? E1.y : E1.w;
                if (rect.x<E2.z && rect.z>E2.x && Y>E2.y && Y<E2.w) Y = (Y-E2.y<E2.w-Y) ? E2.y : E2.w;
                if (abs(Y-p.y)<th) { border = true; break; }
                if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            else {
                float X = mix(rect.x, rect.z, var2*withBias(rnd.x, b.x)+0.5);
                if (rect.y<E1.w && rect.w>E1.y && X>E1.x && X<E1.z) X = (X-E1.x<E1.z-X) ? E1.x : E1.z;
                if (rect.y<E2.w && rect.w>E2.y && X>E2.x && X<E2.z) X = (X-E2.x<E2.z-X) ? E2.x : E2.z;
                if (abs(X-p.x)<th) { border = true; break; }
                if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            horSplit = !horSplit;
            inverter = 1.0-inverter;
            sscale *= 0.5;
            b *= 0.5;
        }
        if (border) break;
        cellId = splits;   // per-cell id for the source choice below
        p = distort9(p, rect, splits, intensity, randomSeed);
    }

    // (3) pixelate the sample coordinate (folds the `pixelate` stage in).
    vec2 ps = p;
    if (pixelation>1e-4) ps = floor(p/pixelation+0.5)*pixelation;

    if (border) { vec4 col = __source__(uv); return vec4(mix(col.rgb, color.rgb, color.a), col.a); }

    // (4) per-cell source choice: balance (bias) + window proximity, blended with per-cell random.
    if (!has2) return __source__(ps);
    vec2 cc = 0.5*(rect.xy+rect.zw);                            // cell centre (per-cell)
    float d1 = length(cc - windowTransform[2].xy);
    float d2 = length(cc - windowTransform2[2].xy);
    float prox = (d1 - d2) / (d1 + d2 + 1e-4);                  // -1 near window 1 .. +1 near window 2
    float rnd2 = rand2relSeeded(cellId, randomSeed+77.7).x * 2.0;   // [-1,1] per cell
    float biasTerm = (balance - 0.5) * 2.0;                     // -1 (source) .. +1 (source2)
    float score = biasTerm + mix(rnd2, prox, proximity);       // proximity 0 = random, 1 = proximity
    return (score>0.0) ? __source2__(ps) : __source__(ps);
}

void main() {
    fragColor = schema3c((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_source2Dim, u_outDim, u_source2_specified, u_intensity, u_iterations, u_pixelation, u_balance, u_proximity, u_variability, u_randomSeed, u_color, u_thickness, u_aspectRatio, u_modelTransform, u_windowTransform, u_windowTransform2);
}
