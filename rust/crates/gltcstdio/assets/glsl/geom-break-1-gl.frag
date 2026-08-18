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











































































































































































































































































































































// Per-iteration quadrant warp — mirrors Pap's `f1()` in glitch_broken_geom1.glsl.
// Note: `s` is the per-tile seed (`floor(u)`), so `rnd` is computed once at
// entry and reused across iterations — matches the Pap shader exactly.
// GLSL ES has no `fmod` — `mod(a, b)` is the spec-compliant equivalent for the
// non-negative-base case used here.







vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}

vec2 geomBreak1F1(vec2 u, vec2 split, vec2 s, int N, float intensity) {
    vec2 rnd = rand2rel(s);
    for(int i=0; i<N; ++i) {
        if (u.x > split.x && u.y > split.y) {
            u *= 1.0 + rnd.x;
            // u.x += 0.02*u.y;  // preserved as a commented-out Pap quirk
        }
        else if (u.x <= split.x && u.y > split.y) {
            float ox = u.x;
            u.x = sign(rnd.x) * u.y;
            u.y = sign(rnd.y) * ox;
        }
        else if (u.x > split.x) {
            u.x += rnd.y * 2.0;
        }
        else {
            u.x = mod(sign(u.x) * pow(abs(u.x), rnd.y), 1.0);
            u.y = mod(sign(u.y) * pow(abs(u.y), rnd.x), 1.0);
        }

        if (max(abs(u.x), abs(u.y)) > 1.5) {
            u *= pow(2.0, intensity);
        }
    }
    return u;
}

vec4 geomBreak1GL(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, mat3 modelTransform) {
    // Inverse-sampling convention (codebase norm, same fix as HexRadialInterpolateGL):
    // Pap forward-applied `u = u_ModelTransform * pos` (the filter does NOT override
    // doInverseModelTransform), which makes M's scale INVERSE to on-screen feature size —
    // so the holistic touch client ran the whole transform (pinch/pan/rotate) backwards
    // ("inverted touch transform"). Enter the tiling grid via `inverse(modelTransform)*pos`
    // instead: `modelTransform` becomes a plain placement transform (scale ∝ feature size)
    // and the standard inPlace=false client inverts it holistically. Pap's default here is
    // MODEL_SCALE=1/ANGLE=0 → identity, whose inverse is identity, so `u` is byte-identical
    // to Pap at the default look (no default change needed).
    vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    // Pap: split = fract(u)*4.0 - 2.0   (per-tile quadrant boundary in [-2, 2]).
    vec2 split = fract(u) * 4.0 - 2.0;

    // sourceDim is the auto-supplied `${name}Dim` (width, height).
    float ratio = sourceDim.x / sourceDim.y;
    vec2 vRatio = vec2(ratio, 1.0);

    // f1 operates in [-1, 1]^2 space (`pos/vRatio`), per-tile seeded by
    // `floor(u)` (same coord space as Pap).
    vec2 warped = geomBreak1F1(pos / vRatio, split, floor(u), count, intensity) * vRatio;

    return __source__(warped);
}

void main() {
    fragColor = geomBreak1GL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_sourceDim, u_modelTransform);
}
