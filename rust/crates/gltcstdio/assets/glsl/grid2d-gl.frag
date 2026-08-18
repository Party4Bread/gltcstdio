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
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_count (int(U[8].x))
#define u_thickness (U[9].x)
#define u_glow (U[10].x)
#define u_color (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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





















































































































































































































































































































































float grid2dDistance1d(float x, float count) {
    if (abs(x) > 0.5) return abs(x) - 0.5;
    float normalized = ((x + 0.5) * count + 0.5);
    return abs(fract(normalized) - 0.5) / count;
}

float grid2dResponse(float d, float thickness, float blur) {
    return pow(smoothstep(thickness, thickness + blur, d), 0.3);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 grid2dGl(vec2 pos, vec2 outPos, int count, float thickness, float glow, vec4 color, mat3 modelTransform) {
    // Pap uploads the FORWARD matrix (`(u_ModelTransform * vec3(pos, 1.0)).xy`),
    // but its manipulator drives the handle inverted. pap2mp stores the INVERSE as
    // `modelTransform` (intuitive drag), so re-invert here to recover Pap's forward
    // application: inverse(modelTransform) == Pap's forward matrix.
    vec2 u = tf(inverse(modelTransform), pos);

    // Pap rescaling: Pap u_Thickness ∈ 0..100; (u_Thickness*0.01)^2 * 0.25
    // → in pap2mp 0..1, simply thickness^2 * 0.25.
    float th = thickness * thickness * 0.25;

    // Pap rescaling: Pap u_Blur ∈ 0..100; u_Blur*0.002
    // → in pap2mp 0..1, glow * 0.2.
    float blur = glow * 0.2;

    float fCount = float(count);
    float d;
    if (abs(u.x) > 0.5 || abs(u.y) > 0.5) {
        d = max(abs(u.x) - 0.5, abs(u.y) - 0.5);
    } else {
        d = min(grid2dDistance1d(u.x, fCount), grid2dDistance1d(u.y, fCount));
    }

    float k = grid2dResponse(d, th, blur);
    vec4 bkgCol = __source__(pos);
    // Pap composite: mix(vec4(mix(bkgCol.rgb, color.rgb, color.a), bkgCol.a), bkgCol, k)
    // — over k blends back to bkgCol (i.e. k=1 means "no line here", k=0 = "on the line").
    // Coverage is 1-k. mergeColor is equivalent on an opaque source, since
    // mix(mix(bkg,C,a), bkg, k) == mix(bkg, C, a*(1-k)); see the alpha divergence note.
    return mergeColor(bkgCol, vec4(color.rgb, color.a * (1.0 - k)));
}

void main() {
    fragColor = grid2dGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_thickness, u_glow, u_color, u_modelTransform);
}
