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
#define u_outDim (U[4].xy)
#define u_spikeCount (int(U[5].x))
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_offset (U[9].x)
#define u_stretch (U[10].x)

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

vec4 kaleidoscope(vec2 uv, vec2 outPos, int spikeCount, mat3 modelTransform, float offset, float stretch) {
            vec2 u = uv;//(inverse(modelTransform) * vec3(uv, 1.0)).xy;
            float a = abs(atan(u.x, u.y));
            float period = PI2 / float(spikeCount);
            float halfPeriod = period * 0.5;
            float index = floor(a/period);
            a = mod(a, period);
            if (a>halfPeriod) {
                a = period - a;
                a = mix(offset*(index+1.0), halfPeriod+offset*(index+1.0), a/halfPeriod);
            }
            else {
                a = mix(offset*index, halfPeriod+offset*(index+1.0), a/halfPeriod);
            }
//            if (a>halfPeriod) {
//                a = period - a;
//                a = mix(0.0, halfPeriod, a/halfPeriod);
//            }
//            else {
//                a = mix(0.0, halfPeriod, a/halfPeriod);
//            }
            float d = length(u);
            u = d*vec2(cos(a), sin(a));
            u = (inverse(modelTransform) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
            return __source__(u);
        }

void main() {
    fragColor = kaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_spikeCount, u_modelTransform, u_offset, u_stretch);
}
