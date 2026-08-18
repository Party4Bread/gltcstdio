#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_dampening (U[5].x)
#define u_scale (U[6].x)
#define u_redTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_greenTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_blueTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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


















































































































































































































































































































































vec2 getOffsetPos(mat3 transform, vec2 pos, float scale, float dampening) {
    vec2 tPos = (inverse(transform)*vec3(pos, 1.0)).xy;
    tPos = pos + scale * (tPos-pos);
    float dist = length(pos);
    if (dist<1.0) {
        tPos = mix(pos, tPos, 1.0-dampening*(1.0-dist*dist));
    }
    return tPos;
}

vec4 rgbOffset(vec2 pos, vec2 outPos, float dampening, float scale, mat3 redTransform, mat3 greenTransform, mat3 blueTransform) {
    vec4 red = __source__(getOffsetPos(redTransform, pos, scale, dampening));
    vec4 green = __source__(getOffsetPos(greenTransform, pos, scale, dampening));
    vec4 blue = __source__(getOffsetPos(blueTransform, pos, scale, dampening));
    vec4 outColor =  vec4(red.r, green.g, blue.b, (red.a+green.a+blue.a)/3.0);
    return outColor;
}

void main() {
    fragColor = rgbOffset((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_dampening, u_scale, u_redTransform, u_greenTransform, u_blueTransform);
}
