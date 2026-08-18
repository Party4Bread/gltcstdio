#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[26];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_variability (U[6].x)
#define u_randomSeed (U[7].x)
#define u_colorBkg (U[8])
#define u_color (U[9])
#define u_thickness (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_transform1 (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_transform2 (mat3(U[17].xyz, U[18].xyz, U[19].xyz))
#define u_transform3 (mat3(U[20].xyz, U[21].xyz, U[22].xyz))
#define u_transform4 (mat3(U[23].xyz, U[24].xyz, U[25].xyz))

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

vec4 dichotomicTransforms(vec2 uv, vec2 outPos, vec2 sourceDim,
        float variability, float randomSeed,
        vec4 colorBkg, vec4 color, float thickness, mat3 modelTransform,
        mat3 transform1, mat3 transform2, mat3 transform3, mat3 transform4) {

    float ratio = sourceDim.x / sourceDim.y;      // real source aspect (used only for sampling)
    float pixel = 2.0 / sourceDim.y;              // one texel, in canonical Y units

    // ModelTransform drives the subdivision (as in DichotomicBreak/Streak):
    //   scale       => recursion depth (loop runs while i + sPos < scale)
    //   translation => directional bias of every bisection (decays x0.5 per level)
    vec2 biasBase = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0 / length(vec2(modelTransform[0][0], modelTransform[0][1]));

    // Canonical frame aspect comes from the source; cells subdivide this rect.
    vec2 p = uv;
    float regularity = 1.0 - variability;

    // --- dichotomic subdivision: descend to the cell containing p ---
    vec4 rect = vec4(-ratio, -1.0, ratio, 1.0);
    vec2 splits = vec2(0.0, 0.0);
    bool horSplit = true;
    vec2 bias = biasBase;
    float sPos = 0.0;
    float sscale = 0.5;
    float inverter = 0.0;

    for (float i = 0.0; i + sPos < scale; ++i) {
        vec2 rnd = rand2relSeeded(splits, randomSeed + 122.1);   // in [-0.5, 0.5]
        vec2 size = rect.zw - rect.xy;
        if (size.x < pixel || size.y < pixel) break;

        if (rnd.x + 0.5 < regularity * 2.0) horSplit = size.y > size.x;
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
        bias *= 0.5;
    }

    float cw = rect.z - rect.x;
    float ch = rect.w - rect.y;

    // --- pick one of the 4 transforms for this cell (coherent per cell path) ---
    float r = rand2relSeeded(splits, randomSeed + 55.5).x + 0.5;   // [0, 1]
    int k = int(min(3.0, floor(r * 4.0)));
    mat3 tf = (k == 0) ? transform1 : (k == 1) ? transform2 : (k == 2) ? transform3 : transform4;

    // --- 1:1 target: fit as many square copies as possible in one row OR column ---
    float a = 1.0;   // assume a 1:1 target image
    float nH = cw / (ch * a);
    bool horizontal = nH >= 1.0;
    int n = horizontal ? int(floor(nH)) : int(floor(1.0 / nH));
    n = max(n, 1);

    // The centred row/column of n square copies determines tile size. The former
    // centre-fit margin (that used to show colorBkg) is filled by CLAMPING the in-band
    // position to the tile row/column, so the nearest copy's edge pixels are repeated
    // (clamp-to-edge) rather than the tiling continuing.
    float u = 0.0, v = 0.0;
    if (horizontal) {
        float tileW = ch * a;
        float rowW = tileW * float(n);
        float startX = rect.x + (cw - rowW) * 0.5;
        float lx = clamp(p.x - startX, 0.0, rowW);           // clamp into the row band
        float idx = min(floor(lx / tileW), float(n) - 1.0);
        u = (lx - idx * tileW) / tileW;                      // stays in [0,1]
        v = (p.y - rect.y) / ch;
    } else {
        float tileH = cw / a;
        float colH = tileH * float(n);
        float startY = rect.y + (ch - colH) * 0.5;
        float ly = clamp(p.y - startY, 0.0, colH);           // clamp into the column band
        float idx = min(floor(ly / tileH), float(n) - 1.0);
        u = (p.x - rect.x) / cw;
        v = (ly - idx * tileH) / tileH;                      // stays in [0,1]
    }

    // --- optional per-cell border ---
    bool border = false;
    if (thickness > 0.0) {
        float t = thickness * 0.1;
        if (p.x - rect.x < t || rect.z - p.x < t || p.y - rect.y < t || rect.w - p.y < t) border = true;
    }

    if (border) return color;   // colorBkg kept as a param but no longer used

    // Square tile space [-1,1]^2. Sampling uses the INVERSE so each transformN describes
    // the transform applied to the IMAGE (as elsewhere: sample via inverse(transform)).
    vec2 c = vec2((u - 0.5) * 2.0, (v - 0.5) * 2.0);
    vec2 ct = (inverse(tf) * vec3(c, 1.0)).xy;
    vec2 X = vec2(ct.x * ratio, ct.y);   // stretch the source into the 1:1 tile
    return __source__(X);
}

void main() {
    fragColor = dichotomicTransforms((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_variability, u_randomSeed, u_colorBkg, u_color, u_thickness, u_modelTransform, u_transform1, u_transform2, u_transform3, u_transform4);
}
