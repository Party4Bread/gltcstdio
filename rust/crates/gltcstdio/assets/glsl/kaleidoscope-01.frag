#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_spikeCount (int(U[5].x))
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_stretch (U[9].x)
#define u_variability (U[10].x)
#define u_randomSeed (U[11].x)

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

vec4 kaleidoscope(vec2 uv, vec2 outPos, int spikeCount, mat3 modelTransform, float stretch, float variability, float randomSeed) {
    vec2 u = uv;//(inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float a = (atan(u.x, u.y));
    float period = PI2 / float(spikeCount);
    float halfPeriod = period * 0.5;
    float index = floor(a/period);
    
    if (spikeCount!=1 && (variability==0.0 || spikeCount>100)) {
        a = mod(a, period);
        if (a>halfPeriod) {
            a = period - a;
        }
        else {
        }
    }
    else {
        //float debugA = a;
        float maxDisplacement = halfPeriod;
        float spikeAngle1 = -PI;
        float spikeAngle2 = spikeAngle1 + period + variability*maxDisplacement * 2.0*rand2relSeeded(vec2(0.0, 0.0), randomSeed).x;
        for(int i=0; i<spikeCount; ++i) {
            if ((i==spikeCount-1) || (a <= spikeAngle2)) {
                float deltaAng = spikeAngle2 - spikeAngle1;
                //float halfAlpha = deltaAng/2.0;
                a = a - spikeAngle1;
                if (a>deltaAng*0.5) {
                    a = deltaAng - a;
                }
                break;
            }
            else {
                spikeAngle1 = spikeAngle2;
                spikeAngle2 = -PI + float(i+2) * period;
                if (i!=spikeCount-2) spikeAngle2 = spikeAngle2 + variability*maxDisplacement * 2.0*rand2relSeeded(vec2(float(i), 0.0), randomSeed).x;
            }
        }
        //float da = debugA/PI*0.5+0.5;
        //return vec4(a*2., a, a*3., 1.);
    }
    float d = length(u);
    u = d*vec2(cos(a), sin(a));
    u = (inverse(modelTransform) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
    return __source__(u);
}

void main() {
    fragColor = kaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_spikeCount, u_modelTransform, u_stretch, u_variability, u_randomSeed);
}
