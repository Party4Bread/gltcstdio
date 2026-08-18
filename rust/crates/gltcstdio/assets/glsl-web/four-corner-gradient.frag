#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_color3 (U[8])
#define u_color4 (U[9])

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















































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 fourCornerGradient(vec2 u, vec2 outPos, int source_specified, vec4 color1, vec4 color2, vec4 color3, vec4 color4) {
    float k1 = length(u-vec2(-1.0, -1.0));
    if (k1==0.0) return color1;

    float k2 = length(u-vec2(-1.0, 1.0));
    if (k2==0.0) return color2;

    float k3 = length(u-vec2(1.0, -1.0));
    if (k3==0.0) return color3;

    float k4 = length(u-vec2(1.0, 1.0));
    if (k4==0.0) return color4;

//    if (u_PosterizeCount<256.0) {
//        k1 = min(floor(k1*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//        k2 = min(floor(k2*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//        k3 = min(floor(k3*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//        k4 = min(floor(k4*u_PosterizeCount) / (u_PosterizeCount-1.0), 1.0);
//    }

    float inv1 = 1.0/k1;
    float inv2 = 1.0/k2;
    float inv3 = 1.0/k3;
    float inv4 = 1.0/k4;
    float tot = inv1 + inv2 + inv3 + inv4;
    inv1 /= tot;
    inv2 /= tot;
    inv3 /= tot;
    inv4 /= tot;

    vec4 outColor = color1*inv1 + color2*inv2 + color3*inv3 + color4*inv4;
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}

void main() {
    fragColor = fourCornerGradient((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_color1, u_color2, u_color3, u_color4);
}
