#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_octaves (int(U[5].x))
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_hardness (U[8].x)
#define u_balance (U[9].x)
#define u_shapeAspectRatio (U[10].x)
#define u_variability (U[11].x)
#define u_randomSeed (U[12].x)
#define u_styleSeed (U[13].x)





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















































































































































































































































































































































vec2 aRatio(float a) {
	return vec2(a, 1.0)/(1.0+a)*2.0;
}

vec3 rndUnit3(vec3 p) {
    vec3 u = fract(p * vec3(.1031, .1030, .0973));
    u += dot(u, u.yxz+33.33);
    vec3 h = fract((u.xxy + u.yxx)*u.zyx);
    return normalize(h-0.5);
}

float dotGridGradient3(vec3 g, vec3 u) {
    return dot(u-g, rndUnit3(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinRelNoise3(vec3 p) {
    vec3 s = vec3(1.0, 0.0, 0.0);
    vec3 f = floor(p);
    vec3 d = p-f;
    float ix00 = smix(dotGridGradient3(f, p), dotGridGradient3(f+s, p), d.x);
    float ix10 = smix(dotGridGradient3(f+s.yxz, p), dotGridGradient3(f+s.xxz, p), d.x);
    float ix01 = smix(dotGridGradient3(f+s.yyx, p), dotGridGradient3(f+s.xyx, p), d.x);
    float ix11 = smix(dotGridGradient3(f+s.yxx, p), dotGridGradient3(f+s.xxx, p), d.x);
    float iy0 = smix(ix00, ix10, d.y);
    float iy1 = smix(ix01, ix11, d.y);
    return smix(iy0, iy1, d.z);
}

float perlinNoise3(vec3 p) {
    return 0.5+perlinRelNoise3(p)*0.5;
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

vec4 perlinNoise2(vec2 pos, vec2 outPos, mat3 viewTransform, int octaves, vec4 color1, vec4 color2, float hardness, float balance, float shapeAspectRatio, float variability, float randomSeed, float styleSeed) {
    vec2 uv = pos / aRatio(shapeAspectRatio);
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));

    float k = 1.;
    float x = 0.;
    float total = 0.0;

    for(int i=0; i<octaves; ++i) {
        // variability: per-octave random rotation + area-preserving aspect stretch, seeded.
        vec2 r = rand2relSeeded(vec2(float(i) + 17.3), styleSeed * 0.1);  // [-0.5, 0.5]
        float angle = r.x * PI2 * variability;
        float ar = pow(20.0, r.y * 2.0 * variability);  // up to 20, down to 1/20 at variability 1
        mat2 rot = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
        mat2 stretch = mat2(ar, 0.0, 0.0, 1.0 / ar);
        vec2 suv = stretch * rot * uv;

        x += k * perlinNoise3(vec3(suv, randomSeed));
        total += k;
        float scaleVar = variability * (fract(r.x*3.4)-0.5) * 2.0;
        k *= 0.5 * pow(2., scaleVar);
        uv = transform * uv;
    }

    x /= total;

    // balance: bias x toward 0 (color1) or 1 (color2); 0 leaves it unchanged.
    x = balance >= 0.0 ? mix(x, 1.0, balance) : mix(x, 0.0, -balance);

    // hardness: sharpen an S-curve around 0.5, becoming a hard step at hardness 1.
    float w = 1.0 - hardness;
    if (w <= 0.0) {
        x = step(0.5, x);
    } else {
        float e = 1.0 / w;
        float a = 0.5 * pow(2.0 * (x < 0.5 ? x : 1.0 - x), e);
        x = x < 0.5 ? a : 1.0 - a;
    }

    return mix(color1, color2, x);
}

void main() {
    fragColor = perlinNoise2((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_viewTransform, u_octaves, u_color1, u_color2, u_hardness, u_balance, u_shapeAspectRatio, u_variability, u_randomSeed, u_styleSeed);
}
