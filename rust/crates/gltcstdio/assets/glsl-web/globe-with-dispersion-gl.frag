#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_dispersion (U[6].x)
#define u_perturbation (U[7].x)
#define u_randomSeed (U[8].x)
#define u_power (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec4 gwdGetRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0 - abs(w)),
        max(0.0, w),
        1.0
    );
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

vec2 sineMix(vec2 val1, vec2 val2, float k) {
    return val1*(1.0+cos(k*PI))*0.5 + val2*(1.0+cos((1.0-k)*PI))*0.5;
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 sineSurfaceRand2Seeded(vec2 v, float seed) {
    vec2 u00 = floor(v);
    vec2 u01 = vec2(floor(v.x), ceil(v.y));
    vec2 u10 = vec2(ceil(v.x), floor(v.y));
    vec2 u11 = ceil(v);

    vec2 r00 = varyVec2NoiseSmoothly(rand2(u00), seed)-vec2(0.5, 0.5);
    vec2 r01 = varyVec2NoiseSmoothly(rand2(u01), seed)-vec2(0.5, 0.5);
    vec2 r10 = varyVec2NoiseSmoothly(rand2(u10), seed)-vec2(0.5, 0.5);
    vec2 r11 = varyVec2NoiseSmoothly(rand2(u11), seed)-vec2(0.5, 0.5);

    return sineMix(
            sineMix(r00, r01, fract(v.y)),
            sineMix(r10, r11, fract(v.y)),
            fract(v.x));
}

vec4 globeWithDispersionGL(vec2 pos, vec2 outPos, float intensity, float dispersion, float perturbation, float randomSeed, float power, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;
    if (perturbation > 0.0) {
        // Pap: sineSurfaceRand2Seeded(u*(1+u_Perturbation*0.01), u_Seed) * 0.01*u_Perturbation
        //   with perturbation in 0..1 (pap2mp): drop both *0.01 collapses.
        u += sineSurfaceRand2Seeded(u * (1.0 + perturbation), randomSeed) * perturbation;
    }

    float p = power;
    float d = pow(pow(abs(u.x), p) + pow(abs(u.y), p), 1.0 / p);

    if (d == 0.0 || d >= 1.0) {
        return __source__(pos);
    } else {
        float hh = sqrt(1.0 - d * d);
        if (hh == 0.0) {
            return __source__(pos);
        }

        float h = 1.0 + hh;

        if (dispersion == 0.0) {
            // Single-sample path: matches Globe.kt's per-pixel math
            // (sans shadows). intensity*0.01 in Pap → intensity in pap2mp.
            float s = (-d * intensity) / hh;
            float dilation = 1.0 + (h * s) / d;
            vec2 coord = (modelTransform * vec3(dilation * u, 1.0)).xy;
            return __source__(coord);
        } else {
            // Dispersion: integrate intensity-perturbed samples across
            // w in -1..1 with RGB-weighted accumulation. 41-sample loop
            // hardcoded in Pap; preserved.
            float wStep = 0.05;
            vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
            vec4 totalWeight = vec4(0.0, 0.0, 0.0, 0.0);
            for (float w = -1.0; w <= 1.0; w += wStep) {
                // Pap: (intensity*(1+w*dispersion))*0.01  (intensity in -100..100, dispersion in 0..100 → *0.01)
                //   with intensity in -1..1 and dispersion in 0..1 (pap2mp):
                //   inner *0.01 on intensity collapses; outer *0.01 on dispersion collapses.
                float s = (-d * (intensity * (1.0 + w * dispersion))) / hh;
                float dilation = 1.0 + (h * s) / d;
                vec2 coord = (modelTransform * vec3(dilation * u, 1.0)).xy;
                vec4 weight = gwdGetRGBWeights(w);
                totalColor += weight * __source__(coord);
                totalWeight += weight;
            }
            return totalColor / totalWeight;
        }
    }
}

void main() {
    fragColor = globeWithDispersionGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_dispersion, u_perturbation, u_randomSeed, u_power, u_modelTransform);
}
