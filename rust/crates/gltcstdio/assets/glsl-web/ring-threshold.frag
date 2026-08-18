#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_scale (U[6].x)
#define u_ringRatio (U[7].x)
#define u_threshold (U[8].x)

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

vec4 ringThreshold(vec2 uv, vec2 outPos, vec2 sourceDim, float scale, float ringRatio, float threshold) {
    float ratio = sourceDim.x / sourceDim.y;
    vec2 sp = uv / scale;                                         // undo the downscale to sample the source
    if (abs(sp.x) > ratio || abs(sp.y) > 1.0) return vec4(0.0, 0.0, 0.0, 1.0);   // black frame
    vec4 col = __source__(sp);
    float q = max(abs(sp.x) / ratio, abs(sp.y));                 // 0 = centre, 1 = image edge (rectangular)
    if (q > 0.0) {
        float ring = max(ceil(log(q) / log(ringRatio)), 1.0);   // ring 1 = outermost band
        float t = threshold * pow(0.5, ring - 1.0);             // 0.5, 0.25, 0.125, ...
        if (luma(col.rgb) < t) return vec4(0.0, 0.0, 0.0, col.a);
    }
    return col;
}

void main() {
    fragColor = ringThreshold((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_scale, u_ringRatio, u_threshold);
}
