#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source1;
layout(binding = 4) uniform texture2D t_source2;
layout(binding = 5) uniform texture2D t_source3;

#define u_source sampler2D(t_source, samp)
#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_source3 sampler2D(t_source3, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source1Dim (U[4].xy)
#define u_source2Dim (U[5].xy)
#define u_source3Dim (U[6].xy)
#define u_outDim (U[7].xy)
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_colorBkg (U[10])
#define u_color (U[11])
#define u_thickness (U[12].x)
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) textureLod(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source3__texelFetch__(c) texelFetch(u_source3, (c), 0)
#define __source3__(p) textureLod(u_source3, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

vec4 dichotomicTiles(vec2 uv, vec2 outPos,
        vec2 source1Dim, vec2 source2Dim, vec2 source3Dim,
        float variability, float randomSeed,
        vec4 colorBkg, vec4 color, float thickness, mat3 modelTransform) {

    float ratio = source1Dim.x / source1Dim.y;   // canonical frame aspect (from source 1)
    float pixel = 2.0 / source1Dim.y;             // one texel, in canonical Y units

    // ModelTransform drives the subdivision (as in DichotomicBreak/Streak):
    //   scale       => recursion depth (loop runs while i + sPos < scale)
    //   translation => directional bias of every bisection (decays x0.5 per level)
    vec2 biasBase = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0 / length(vec2(modelTransform[0][0], modelTransform[0][1]));

    vec2 p = uv;
    float regularity = 1.0 - variability;

    // --- dichotomic subdivision: descend to the cell containing p ---
    // rect = current cell bounds; splits = unique-ish path id (also the per-cell RNG seed).
    vec4 rect = vec4(-ratio, -1.0, ratio, 1.0);
    vec2 splits = vec2(0.0, 0.0);
    bool horSplit = true;
    vec2 bias = biasBase;
    float sPos = 0.0;       // sub-cell position in 1D split space (preview coherence)
    float sscale = 0.5;
    float inverter = 0.0;

    for (float i = 0.0; i + sPos < scale; ++i) {
        vec2 rnd = rand2relSeeded(splits, randomSeed + 122.1);   // in [-0.5, 0.5]
        vec2 size = rect.zw - rect.xy;
        if (size.x < pixel || size.y < pixel) break;

        // low variability => split the longer side (clean grid); high => alternate h/v.
        if (rnd.x + 0.5 < regularity * 2.0) horSplit = size.y > size.x;
        // posVar: 0 => split at the centre, 1 => split anywhere in the middle half (biased).
        float posVar = 1.0 - max(0.0, regularity * 2.0 - 1.0);

        if (horSplit) {
            float Y = mix(rect.y, rect.w, posVar * withBias(rnd.y, bias.y) + 0.5);
            if (p.y < Y) { rect.w = Y; splits.y += 1.0;   sPos += inverter * sscale; }
            else         { rect.y = Y; splits.y += 100.0; sPos += (1.0 - inverter) * sscale; }
        } else {
            float X = mix(rect.x, rect.z, posVar * withBias(rnd.x, bias.x) + 0.5);
            if (p.x < X) { rect.z = X; splits.x += 1.0;   sPos += inverter * sscale; }
            else         { rect.x = X; splits.x += 100.0; sPos += (1.0 - inverter) * sscale; }
        }
        horSplit = !horSplit;
        inverter = 1.0 - inverter;
        sscale *= 0.5;
        bias *= 0.5;        // bias decays with depth, like DichotomicBreak
    }

    float cw = rect.z - rect.x;
    float ch = rect.w - rect.y;

    // --- pick one of the 3 images for this cell (coherent per cell path) ---
    float r = rand2relSeeded(splits, randomSeed + 55.5).x + 0.5;   // [0, 1]
    int k = int(min(2.0, floor(r * 3.0)));
    vec2 dimK = (k == 0) ? source1Dim : (k == 1) ? source2Dim : source3Dim;
    float a = dimK.x / dimK.y;   // image aspect (w/h) — never squished

    // --- fit as many copies as possible in one row OR one column ---
    // nH = how many full-cell-height copies span the width; its reciprocal is the vertical count.
    float nH = cw / (ch * a);
    bool horizontal = nH >= 1.0;
    int n = horizontal ? int(floor(nH)) : int(floor(1.0 / nH));
    n = max(n, 1);

    float u = 0.0, v = 0.0;
    bool inside;
    if (horizontal) {
        float tileW = ch * a;                         // each copy: full cell height, image-aspect width
        float rowW = tileW * float(n);
        float startX = rect.x + (cw - rowW) * 0.5;    // centre the row in the cell
        float lx = p.x - startX;
        float idx = floor(lx / tileW);
        inside = (lx >= 0.0 && lx <= rowW);
        u = (lx - idx * tileW) / tileW;
        v = (p.y - rect.y) / ch;
    } else {
        float tileH = cw / a;                         // each copy: full cell width, image-aspect height
        float colH = tileH * float(n);
        float startY = rect.y + (ch - colH) * 0.5;    // centre the column in the cell
        float ly = p.y - startY;
        float idx = floor(ly / tileH);
        inside = (ly >= 0.0 && ly <= colH);
        u = (p.x - rect.x) / cw;
        v = (ly - idx * tileH) / tileH;
    }

    // --- optional per-cell border ---
    bool border = false;
    if (thickness > 0.0) {
        float t = thickness * 0.1;
        if (p.x - rect.x < t || rect.z - p.x < t || p.y - rect.y < t || rect.w - p.y < t) border = true;
    }

    if (border) return color;
    if (!inside) return colorBkg;

    // sample image k at normalized (u,v) via the centered-V2 __source__ contract
    vec2 X = vec2((u - 0.5) * 2.0 * a, (v - 0.5) * 2.0);
    return (k == 0) ? __source1__(X) : (k == 1) ? __source2__(X) : __source3__(X);
}

void main() {
    fragColor = dichotomicTiles((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source1Dim, u_source2Dim, u_source3Dim, u_variability, u_randomSeed, u_colorBkg, u_color, u_thickness, u_modelTransform);
}
