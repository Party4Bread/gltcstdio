#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_vignetting (U[5].x)
#define u_redTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_greenTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_blueTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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











































































































































































































































































































































// Pap GLSL: getOffsetPos from glitch_rgb_channel_offset.glsl.
// pap2mp's mat3 is the forward (user-facing) transform, so we invert in-shader
// — matches the gltcstdio RGBOffset convention. Scale fixed at 1.0 (Pap original
// has no scale param).







vec2 rgbOffsetGlitchLabGetOffsetPos(mat3 transform, vec2 pos, float vignetting) {
    vec2 tPos = (inverse(transform) * vec3(pos, 1.0)).xy;
    float dist = length(pos);
    if (dist < 1.0) {
        tPos = mix(pos, tPos, 1.0 - vignetting * (1.0 - dist * dist));
    }
    return tPos;
}

vec4 rgbOffsetForGlitchLabGl(vec2 pos, vec2 outPos, float vignetting, mat3 redTransform, mat3 greenTransform, mat3 blueTransform) {
    vec4 red   = __source__(rgbOffsetGlitchLabGetOffsetPos(redTransform,   pos, vignetting));
    vec4 green = __source__(rgbOffsetGlitchLabGetOffsetPos(greenTransform, pos, vignetting));
    vec4 blue  = __source__(rgbOffsetGlitchLabGetOffsetPos(blueTransform,  pos, vignetting));
    return vec4(red.r, green.g, blue.b, (red.a + green.a + blue.a) / 3.0);
}

void main() {
    fragColor = rgbOffsetForGlitchLabGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_vignetting, u_redTransform, u_greenTransform, u_blueTransform);
}
