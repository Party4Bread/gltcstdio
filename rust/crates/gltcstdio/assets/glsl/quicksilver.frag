#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_displacement;
layout(binding = 3) uniform texture2D t_source1;

#define u_displacement sampler2D(t_displacement, samp)
#define u_source1 sampler2D(t_source1, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_displacement_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

#define __displacement__texelFetch__(c) texelFetch(u_displacement, (c), 0)
#define __displacement__(p) texture(u_displacement, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) texture(u_source1, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 quicksilver(vec2 pos, vec2 outPos, float intensity, mat3 modelTransform, int displacement_specified) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 delta = displacement_specified==1 ? __displacement__(tf(inverseModelTransform, pos)).xy * intensity : __source1__(tf(inverseModelTransform, pos)).xy * intensity;
    vec4 outCol = __source1__(pos+delta);                
    return outCol;
}

void main() {
    fragColor = quicksilver((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_modelTransform, u_displacement_specified);
}
