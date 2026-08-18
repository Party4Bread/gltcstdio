#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_legacy_0;

#define u_Source sampler2D(t_legacy_0, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_SourceDim (U[5].xy)
#define u_SourceTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_radius (U[9].x)





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















































































































































































































































































































































float gaussian(float x) {
    return (x>0.5) ? (1.0-x)*(1.0-x)*2.0 : 1.0 - x*x*2.0;
}

vec4 blur(vec2 uv, vec2 outPos, float radius) {
    float pixel = 2.0 / u_SourceDim.y;
    float sizing = radius/(80.0*pixel);
    if (sizing>1.0) pixel *= sizing;
    float baseLod = log(sizing);
    vec4 total = texture(u_Source, vec2(u_SourceTransform * vec3(uv, 1.0)));
    total *= total;
    float div = 1.0;
    float d = pixel;
    float step = pixel;
    float lod = baseLod;
    float gInv = 1.0;
    while (d<radius) {
        vec2 u1 = uv-vec2(0.0, d);
        vec2 u2 = uv+vec2(0.0, d);
        float g = gaussian(d/radius);
        vec4 col1 = texture(u_Source, vec2(u_SourceTransform * vec3(u1, 1.0)), lod);
        vec4 col2 = texture(u_Source, vec2(u_SourceTransform * vec3(u2, 1.0)), lod);
        total += (col1*col1 + col2*col2);
        div += 2.0;
        gInv = 1.0/g;
        step = pixel*gInv;
        lod = baseLod + log(gInv);
        d+=step;
    }
    return sqrt(total/div);
}

void main() {
    fragColor = blur((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_radius);
}
