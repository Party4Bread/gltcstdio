#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_color (U[6])
#define u_colorBkg (U[7])
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_coverage (U[11].x)
#define u_len (U[12].x)
#define u_variability (U[13].x)
#define u_randomSeed (U[14].x)





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















































































































































































































































































































































float hash11(float x) {
    return fract(sin(x*45.34+123.131)*94.434);
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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 scratches(vec2 uv, vec2 outPos, vec4 color, vec4 colorBkg, mat3 modelTransform, float coverage, float len, float variability, float randomSeed, vec2 sourceDim) {
    // Elongated Voronoi scratch pass. Edit live via setTestGlsl / loadTestGlsl.
    vec2 t = tf(inverse(modelTransform), uv);
    vec2 p = (t * 20.0) * vec2(0.1, 1.0);   // base density x the (0.1,1.0) elongation twist

    float ci = floor(p.x);
    float cj = floor(p.y);
    float d2min = 1e9;
    vec2 minId = vec2(0.0);
    for (int j = -1; j <= 1; ++j) {
        for (int i = -1; i <= 1; ++i) {
            vec2 id = vec2(ci + float(i), cj + float(j));
            vec2 center = id + vec2(0.5) + rand2relSeeded(id, randomSeed) * variability;
            vec2 d = p - center;
            float dd = dot(d, d);
            if (dd < d2min) { d2min = dd; minId = id; }
        }
    }

    // coverage: fraction of rows that carry a scratch
    bool scratchRow = hash11(minId.y * 1.7 + randomSeed) < coverage;
    // len: fraction of each period filled along the long axis (random phase per row)
    float PERIOD = 8.0;
    float phase = floor(hash11(minId.y * 2.3 + randomSeed + 5.0) * PERIOD);
    float seg = mod(minId.x + phase, PERIOD);
    bool inLen = seg < len * PERIOD;

    return (scratchRow && inLen) ? color : colorBkg;
}

void main() {
    fragColor = scratches((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color, u_colorBkg, u_modelTransform, u_coverage, u_len, u_variability, u_randomSeed, u_sourceDim);
}
