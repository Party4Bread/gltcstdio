#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_ModelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_intensity (U[9].x)
#define u_count (int(U[10].x))
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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















































































































































































































































































































































vec4 geomBreak6GL(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, mat3 modelTransform) {
    // Pap rep(): u starts at pos; advance through the model step while the
    // pixel remains inside the central band.
    vec2 u = pos;

    // Inverse-sampling convention (codebase norm, same fix as GeomBreak1GL): step by
    // inverse(modelTransform) — which equals Pap's forward step — so `modelTransform`
    // is a plain placement transform and the standard touch client is natural. Hoisted
    // out of the loop (constant across iterations).
    mat3 gridStep = inverse(modelTransform);

    // sourceDim is the auto-supplied `${name}Dim` (width, height).
    float ratio = sourceDim.x / sourceDim.y;

    // Pap: intensity = getMaskedParameter(u_Intensity*0.01, outPos).
    // pap2mp `intensity` is already 0..1 — no per-pixel masking.

    for (int i = 0; i < count; ++i) {
        // Pap: m = vec2(fmod(u.x/ratio+1.0, 2.0), fmod(u.y+1.0, 2.0)) - vec2(1.0, 1.0)
        // GLSL ES has no `fmod` — use `mod` (equal to fmod for the
        // non-negative central-cell inputs; see header for the edge case).
        vec2 m = vec2(mod(u.x / ratio + 1.0, 2.0), mod(u.y + 1.0, 2.0)) - vec2(1.0, 1.0);
        if (max(abs(m.x), abs(m.y)) > intensity) break;
        // Pap: u = (u_ModelTransform * vec3(u, 1.0)).xy (forward). pap2mp steps by
        // inverse(modelTransform) (== Pap forward step), hoisted to `gridStep` above.
        u = (gridStep * vec3(u, 1.0)).xy;
    }

    return __source__(u);
}

void main() {
    fragColor = geomBreak6GL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_sourceDim, u_modelTransform);
}
