#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source2_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_balance (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) texture(u_source1, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 reduce3_2(vec3 v, float k) {
    float a = 1.0/3.0;
    float b = 2.0/3.0;
    if (k<a) {
        float kk = k * 3.0;
        return vec2(mix(v.x, v.y, kk), mix(v.y, v.z, kk));
    }
    else if (k<b) {
        float kk = (k-a) * 3.0;
        return vec2(mix(v.y, v.z, kk), mix(v.z, v.x, kk));
    }
    else {
        float kk = (k-b) * 3.0;
        return vec2(mix(v.z, v.x, kk), mix(v.x, v.y, kk));
    }
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 quickcopper(vec2 pos, vec2 outPos, float balance, int source2_specified, mat3 modelTransform) {
    //vec4 col = source2_specified==0 ? __source1__(pos) : __source2__(pos);
    vec4 col = __source1__(pos);
    vec2 uv = (reduce3_2(col.rgb, balance)-.5) * 2.;
    return source2_specified==0 ? __source1__(tf(inverse(modelTransform), uv)) : __source2__(tf(inverse(modelTransform), uv));
}

void main() {
    fragColor = quickcopper((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_balance, u_source2_specified, u_modelTransform);
}
