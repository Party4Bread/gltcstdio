#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_thickness (U[6].x)
#define u_radius (U[7].x)
#define u_radiusVariability (U[8].x)
#define u_colorIn (U[9])
#define u_colorDots (U[10])
#define u_colorBorder (U[11])

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















































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}

vec4 scintillatingIllusion(vec2 uv, vec2 outPos, int source_specified, float thickness, float radius, float radiusVariability, vec4 colorIn, vec4 colorDots, vec4 colorBorder) {
    vec2 u = fract(uv)-0.5;
    vec2 id = vec2(0.0);
    if (radiusVariability!=0.0) id = floor(uv);
    
    float d = length(u);
    vec4 col;
    radius *= 0.5;
    radius *= 1.0 + (rand2rel(id).x * radiusVariability);
    if (d<radius) {
        col = colorDots;
    }
    else {        
        if (abs(u.x)<thickness || abs(u.y)<thickness) col = colorBorder;
        else col = colorIn;
    }
    
    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}

void main() {
    fragColor = scintillatingIllusion((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_thickness, u_radius, u_radiusVariability, u_colorIn, u_colorDots, u_colorBorder);
}
