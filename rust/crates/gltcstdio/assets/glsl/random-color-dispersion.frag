#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_randomSeed (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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


















































































































































































































































































































































vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec4 getRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0-abs(w)),
        max(0.0, w),
        1.0
    );
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

vec2 smoothmix2(vec2 a, vec2 b, float k) {
    return vec2(mix(a.x, b.x, smoothstep(0.0, 1.0, k)), mix(a.y, b.y, smoothstep(0.0, 1.0, k)));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 randomColorDispersion(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float randomSeed, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), pos);

    vec2 f = floor(t);
    vec2 r = fract(t);
    float v = 2.0;
    vec2 delta00 = rand2relSeeded(f, randomSeed) * v;
    vec2 delta10 = rand2relSeeded(f+vec2(1.0, 0.0), randomSeed) * v;
    vec2 delta01 = rand2relSeeded(f+vec2(0.0, 1.0), randomSeed) * v;
    vec2 delta11 = rand2relSeeded(f+vec2(1.0, 1.0), randomSeed) * v;

    float stepLen = 2.0/sourceDim.y;
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    vec4 totalWeight = vec4(0.0, 0.0, 0.0, 0.0);
    float dispersion = intensity;
    vec2 delta = smoothmix2(smoothmix2(delta00, delta10, r.x), smoothmix2(delta01, delta11, r.x), r.y);
    vec2 range = dispersion*delta;
    float N = ceil(0.1+length(range)/stepLen);
    float wStep = 1.0/N;//length(range)==0.0 ? 1.0 : stepLen/length(range);//0.05;
    //for(float w=-1.0; w<=1.0; w+=wStep) {
    vec4 col;
    for(float i=-N; i<=N; ++i) {
        float w = i*wStep;
//        vec4 dcol = vec4(delta.x, delta.y, 0.5, 1.0);
        vec4 scol = __source__(pos+w*range);
        if (i==0.0) col = scol;
        vec4 outColor = scol;//mix(scol, dcol, 0.0);
        vec4 weight = getRGBWeights(w);
        totalColor += weight*outColor;
        totalWeight += weight;
    }
    vec4 outCol = totalColor / totalWeight;
    return outCol;   
}

void main() {
    fragColor = randomColorDispersion((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_randomSeed, u_modelTransform);
}
