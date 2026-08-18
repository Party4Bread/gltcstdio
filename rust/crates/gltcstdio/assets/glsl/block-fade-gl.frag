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
#define u_outDim (U[4].xy)
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_intensity (U[8].x)
#define u_dampening (U[9].x)
#define u_regularity (U[10].x)
#define u_randomSeed (U[11].x)
#define u_color1 (U[12])
#define u_color2 (U[13])
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

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

vec4 blockFadeGL(vec2 pos, vec2 outPos,
                 float intensity, float dampening, float regularity,
                 float randomSeed, vec4 color1, vec4 color2,
                 mat3 modelTransform) {
    // Plain Pap-faithful form: u = inverse(modelTransform) * pos (mirrors Pap's
    // `u = u_ModelTransform * pos`; we store the inverse). The pap2mp y-up ↔ Pap y-down
    // reflection is baked into the modelTransform DEFAULT (via flipY(), see constructor),
    // NOT here — so there are no coordinate hacks and the touch handles stay natural
    // (decompose() carries the reflection as a negative scale-y).
    mat3 forwardM = inverse(modelTransform);
    vec2 u = (forwardM * vec3(pos, 1.0)).xy;
    // Pap: scaleX = length(vec2(u_ModelTransform[0][0], u_ModelTransform[1][0]))
    // (first column of the forward matrix → scale factor for uniform scale+rotation).
    float scaleX = length(vec2(forwardM[0][0], forwardM[1][0]));

    vec2 rnd1 = rand2relSeeded(floor(vec2(u.y, u.y)), randomSeed);
    float xOffset = floor(15.0 * rnd1.x + 0.5);

    vec4 col = __source__(pos);
    float dx = floor(xOffset - u.x);
    vec2 rnd2 = rand2relSeeded(vec2(dx, floor(u.y)), randomSeed);

    // Pap: u_Variability = 100 - u_Regularity; with both 0..100,
    //     dx + rnd2.y * u_Variability * 4.0 / abs(dx)
    //   → with regularity in 0..1: variability = 1 - regularity;
    //     dx + rnd2.y * (1 - regularity) * 400.0 / abs(dx)
    float variability = 1.0 - regularity;
    if (dx + rnd2.y * variability * 400.0 / abs(dx) <= 0.0) return col;

    // Pap: clamp(1.0 - dx/scaleX, 0.0, 1.0)  (Pap's clamp(min, max, val) order)
    float kx = clamp(1.0 - dx / scaleX, 0.0, 1.0);
    float scanIntensity = 0.3;
    float scanK = (1.0 - scanIntensity + scanIntensity * cos(PI * fract(u.x) * 8.0));
    vec4 overCol = mix(color1, color2, kx) * vec4(scanK, scanK, scanK, 1.0);

    // Pap: clamp(1.0 - (1.0-kx) * u_Dampening * 0.01, 0.0, 1.0)
    //   → with dampening in -1..1 (DampeningRel): drop the *0.01.
    float alpha = clamp(1.0 - (1.0 - kx) * dampening, 0.0, 1.0);
    // Pap: intensity = getMaskedParameter(u_Intensity, outPos) * 0.01 * alpha
    //   → bare intensity (no per-pixel mask in pap2mp) * alpha. The
    //   `*0.01` collapses because pap2mp intensity is already 0..1.
    float blend = intensity * alpha;
    vec4 outCol = mix(col, overCol, blend);

    // Locus mix `mix(col, outCol, getLocus(...))` stripped — chained
    // externally via `.withLocusHandling()` at the wire site.
    return outCol;
}

void main() {
    fragColor = blockFadeGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_dampening, u_regularity, u_randomSeed, u_color1, u_color2, u_modelTransform);
}
