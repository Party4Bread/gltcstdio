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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_ModelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_count (int(U[9].x))
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

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











































































































































































































































































































































// Per-iteration recursive quadrant-zoom — mirrors Pap's `f1()` in
// glitch_broken_geom3.glsl. The pixel's quadrant (relative to `split`)
// selects scale + center such that the chosen quadrant fills [-1, 1]^2
// for the next iteration.







vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec2 geomBreak3F1(vec2 u, vec2 split, int N) {
    for(int i=0; i<N; ++i) {
        vec2 sc;
        vec2 center;
        if (u.x > split.x && u.y > split.y) {
            sc = 2.0 / vec2(1.0 - split.x, 1.0 - split.y);
            center = vec2(1.0 + split.x, 1.0 + split.y) / 2.0;
        }
        else if (u.x <= split.x && u.y > split.y) {
            sc = 2.0 / vec2(1.0 + split.x, 1.0 - split.y);
            center = vec2(-1.0 + split.x, 1.0 + split.y) / 2.0;
        }
        else if (u.x > split.x) {
            sc = 2.0 / vec2(1.0 - split.x, 1.0 + split.y);
            center = vec2(1.0 + split.x, -1.0 + split.y) / 2.0;
        }
        else {
            sc = 2.0 / vec2(1.0 + split.x, 1.0 + split.y);
            center = vec2(-1.0 + split.x, -1.0 + split.y) / 2.0;
        }
        u = u * sc - center * sc;
    }
    return u;
}

vec4 geomBreak3GL(vec2 pos, vec2 outPos, int count, vec2 sourceDim, mat3 modelTransform) {
    // Pap: u = u_ModelTransform * vec3(pos, 1.0)  (forward — Pap does NOT
    // override doInverseModelTransform()).
    vec2 u = (modelTransform * vec3(pos, 1.0)).xy;

    // Pap: split = fract(u)*2.0 - 1.0   (per-tile split point in [-1, 1]).
    vec2 split = fract(u) * 2.0 - 1.0;

    float ratio = sourceDim.x / sourceDim.y;
    vec2 vRatio = vec2(ratio, 1.0);

    // f1 operates in [-1, 1]^2 space, rescaled back via vRatio for sampling.
    vec2 warped = geomBreak3F1(pos / vRatio, split, count) * vRatio;

    return __source__(warped);
}

void main() {
    fragColor = geomBreak3GL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_sourceDim, u_modelTransform);
}
