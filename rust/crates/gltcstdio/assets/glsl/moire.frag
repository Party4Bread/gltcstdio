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
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_Tex0Dim (U[6].xy)
#define u_intensity1 (U[7].x)
#define u_intensity2 (U[8].x)
#define u_intensity3 (U[9].x)
#define u_intensity4 (U[10].x)
#define u_intensity5 (U[11].x)
#define u_color1 (U[12])
#define u_color2 (U[13])
#define u_thickness (U[14].x)

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

vec4 moire(vec2 uv, vec2 outPos, int source_specified, float intensity1, float intensity2, float intensity3, float intensity4, float intensity5, vec4 color1, vec4 color2, float thickness, mat3 viewTransform) {
    vec2 u = uv;
    float scale = 1./length(vec2(viewTransform[0][0], viewTransform[0][1]));
    float t = (1.0-thickness)*5000.0/scale;
    //float pixel = 2.0/u_Tex0Dim.y;
    u = floor(u*t+0.5)/t;

    float k1 = intensity1*intensity1;
    float k2 = intensity2*intensity2;
    float k3 = intensity3*intensity3;
    float k4 = intensity4*intensity4;
    float k5 = intensity5*intensity5;
    float d = u.y*u.x*k1
        + length(u)*k2
        + u.y*u.y*k3
        + u.x*u.x*k4
        + u.y*k5;
    float f = fract(d)*2.0;

    vec4 outColor = f<=1.0 ? color1 : color2;
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}

void main() {
    fragColor = moire((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_intensity1, u_intensity2, u_intensity3, u_intensity4, u_intensity5, u_color1, u_color2, u_thickness, u_viewTransform);
}
