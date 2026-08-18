#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_displacement;
layout(binding = 3) uniform texture2D t_source;

#define u_displacement sampler2D(t_displacement, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_displacement_specified (int(U[4].x))
#define u_sourceDim (U[5].xy)
#define u_outDim (U[6].xy)
#define u_border (U[7].x)
#define u_intensity (U[8].x)
#define u_balance (U[9].x)
#define u_colorOut (U[10])
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_borderTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

#define __displacement__texelFetch__(c) texelFetch(u_displacement, (c), 0)
#define __displacement__(p) textureLod(u_displacement, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 displacedBorder(vec2 uv, vec2 outPos, float border, int displacement_specified, vec2 sourceDim, vec2 outDim, float intensity, float balance, vec4 colorOut, mat3 viewTransform, mat3 modelTransform, mat3 borderTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    float borderSize = border * 2. * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 threshold = vec2(outDim.x/outDim.y * ratio/newBounds.x, 1./newBounds.y);
    vec2 u = uv;
    u += intensity * ((displacement_specified==1 ? __displacement__(tf(inverse(borderTransform), uv)) : __source__(tf(inverse(borderTransform), uv))).xy - 0.5 + balance);
    bool inside = abs(u.x)<=threshold.x && abs(u.y)<=threshold.y;
    vec2 v = tf(inverse(modelTransform), uv);
    return inside ? __source__(v) : mergeColor(__source__(v), colorOut);
}

void main() {
    fragColor = displacedBorder((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_border, u_displacement_specified, u_sourceDim, u_outDim, u_intensity, u_balance, u_colorOut, u_viewTransform, u_modelTransform, u_borderTransform);
}
