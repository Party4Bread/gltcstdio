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
#define u_intensity (U[5].x)
#define u_dampening (U[6].x)
#define u_count (int(U[7].x))
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

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

vec4 iteratedRipplesGL(vec2 pos, vec2 outPos, float intensity, float dampening, int count, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec4 color = __source__(pos);

    vec2 u = (invM * vec3(pos, 1.0)).xy;
    float rippleCount = float(count);

    // 6-iteration cascade: hardcoded in the Pap shader; preserved.
    for (int i = 0; i < 6; ++i) {
        float d = length(u);
        if (d >= 1.0) {
            return color;
        } else {
            // Pap: dampening>=0 ? pow(1-d, dampening*0.02) : pow(d, -dampening*0.05)
            //   with dampening in -1..1 (pap2mp) instead of -100..100 (Pap):
            float dampen = dampening >= 0.0
                ? pow(1.0 - d, dampening * 2.0)
                : pow(d, -dampening * 5.0);
            // Pap: intensity*0.01 * sin(d * rippleCount * PI) * dampen
            //   with intensity 0..1 (pap2mp): drop the *0.01.
            float dilation = 1.0 + intensity * sin(d * rippleCount * PI) * dampen;
            u *= dilation;
        }
    }

    if (intensity < 0.0) u = -u;
    u = (modelTransform * vec3(u, 1.0)).xy;
    return __source__(u);
}

void main() {
    fragColor = iteratedRipplesGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_dampening, u_count, u_modelTransform);
}
