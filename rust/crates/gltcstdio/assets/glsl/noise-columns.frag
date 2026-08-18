#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_shapeAspectRatio (U[5].x)
#define u_count (int(U[6].x))
#define u_coverage (U[7].x)
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_color (U[10])
#define u_highlightColor (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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

vec4 noiseColumns(vec2 uv, vec2 outPos, float shapeAspectRatio, int count, float coverage, float variability, float randomSeed, vec4 color, vec4 highlightColor, mat3 modelTransform) {
    vec4 bkg = __source__(uv);

    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;

    // Bounding rectangle: height 2 (|y|<=1), width 2*shapeAspectRatio, centred on the origin.
    float ar = max(shapeAspectRatio, 0.01);
    if (abs(u.x) > ar || abs(u.y) > 1.0) return bkg;

    float n = float(max(count, 1));
    float cw = 2.0 * ar / n;
    float c = min(floor((u.x + ar) / cw), n - 1.0);

    // Per-column character: chunkiness (row height) and own density around `coverage`.
    vec2 rc = rand2relSeeded(vec2(c * 7.13 + 3.7, c * 1.77 - 8.1), randomSeed) + 0.5;
    float chunk = pow(4.0, (rc.x - 0.5) * 2.0 * variability);
    float density = clamp(coverage * pow(3.0, (rc.y - 0.5) * 2.0 * variability), 0.0, 1.0);

    float rh = chunk * 2.0 / 24.0;                    // row height (base 24 rows)
    float r = floor((u.y + 1.0) / rh);
    float fy = fract((u.y + 1.0) / rh);

    // Above variability 0.5, columns may subdivide horizontally into dash cells (~2:1 wide);
    // ticks always fill their cell's full width, so the grid stays offset-free.
    float nx = 1.0;
    float pSub = clamp((variability - 0.5) * 2.0, 0.0, 1.0);
    if (pSub > 0.0) {
        vec2 rs = rand2relSeeded(vec2(c * 3.31 + 1.7, c * 9.87 + 2.3), randomSeed) + 0.5;
        if (rs.x < pSub) nx = clamp(floor(cw / (rh * 2.0)), 1.0, 64.0);
    }
    float xw = cw / nx;
    float k = min(floor((u.x + ar - c * cw) / xw), nx - 1.0);

    vec2 rd = rand2relSeeded(vec2(c * 13.7 + k * 5.91, r * 2.23 + 4.9), randomSeed) + 0.5;
    if (rd.x > density) return bkg;                   // cell off

    // Tick: full cell width, hashed height fraction, vertically centred in its row
    // (hard edges on purpose — the reference look is NEAREST).
    vec2 rg = rand2relSeeded(vec2(r * 3.17 + k * 9.13, c * 4.79 + 8.31), randomSeed) + 0.5;
    float h = mix(0.35, 0.8, rg.y);
    float y0 = (1.0 - h) * 0.5;
    if (fy < y0 || fy > y0 + h) return bkg;

    vec4 col = fract(rd.y * 13.0) < 0.08 ? highlightColor : color;
    return mergeColor(bkg, col);
}

void main() {
    fragColor = noiseColumns((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_shapeAspectRatio, u_count, u_coverage, u_variability, u_randomSeed, u_color, u_highlightColor, u_modelTransform);
}
