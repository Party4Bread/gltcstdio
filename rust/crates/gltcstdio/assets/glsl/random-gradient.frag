#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[8];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_color1 (U[5])
#define u_colorVariability (U[6].x)
#define u_randomSeed (U[7].x)





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






























































































































































































































































































































































vec3 rgRand3(vec2 v) {
    float x = fract(sin(dot(v.xy, vec2(12.9898, 78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x), vec2(12.9898, 78.233))) * 43758.5453);
    float z = fract(sin(dot(vec2(y, v.y), vec2(12.9898, 78.233))) * 43758.5453);
    return vec3(x, y, z);
}

float rgVaryNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise - 1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0 + cos(phase + freq*k)) * 0.5;
}

vec3 rgVaryVec3NoiseSmoothly(vec3 n, float k) {
    return vec3(rgVaryNoiseSmoothly(n.x, k), rgVaryNoiseSmoothly(n.y, k), rgVaryNoiseSmoothly(n.z, k));
}

vec3 rgRand3relSeeded(vec2 co, float seed) {
    return rgVaryVec3NoiseSmoothly(rgRand3(co), seed) - 0.5;
}

vec3 rgInterpolatedRand3Seeded(vec2 v, float seed) {
    float sfractY = smoothstep(0.0, 1.0, fract(v.y));
    return mix(
        mix(rgRand3relSeeded(floor(v), seed), rgRand3relSeeded(vec2(floor(v.x), ceil(v.y)), seed), sfractY),
        mix(rgRand3relSeeded(vec2(ceil(v.x), floor(v.y)), seed), rgRand3relSeeded(ceil(v), seed), sfractY),
        smoothstep(0.0, 1.0, fract(v.x)));
}

vec4 randomGradient(vec2 pos, vec2 outPos, vec4 color1, float colorVariability, float randomSeed) {
    vec3 rndCol = rgInterpolatedRand3Seeded(vec2(0.0, pos.y), randomSeed) * colorVariability + color1.rgb;
    return vec4(rndCol, 1.0);
}

void main() {
    fragColor = randomGradient((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color1, u_colorVariability, u_randomSeed);
}
