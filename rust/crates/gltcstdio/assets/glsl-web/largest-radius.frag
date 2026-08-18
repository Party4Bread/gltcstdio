#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[8];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_delta (U[6].x)
#define u_threshold (U[7].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}

vec4 hueGrad(vec2 uv, vec2 outPos, vec2 sourceDim, float delta, float threshold) {
    float g = luma(__source__(uv).rgb);
    
    float pixel = 2.0/sourceDim.y;
    float radius = pixel;
    float maxRadius = 0.0;
    vec2 dir = vec2(0.0, 1.0);
    mat2 rot = rotation2(1.0);
    float deltaRadius = pixel*0.3333;
    
    int MAX_ITER = 2000;
    int i = 0;
    vec2 u = uv + radius * dir;
    while (i<MAX_ITER) {
        float g2 = luma(__source__(u).rgb);
        if ((abs(g-g2)) > threshold) break;
        maxRadius = radius;
        radius += deltaRadius;
        dir = rot * dir;
        u = uv + radius * dir;
        ++i;
    }
    return vec4(vec3(maxRadius), 1.0);
}

void main() {
    fragColor = hueGrad((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_delta, u_threshold);
}
