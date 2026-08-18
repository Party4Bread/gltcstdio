#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source1Dim (U[4].xy)
#define u_source2Dim (U[5].xy)
#define u_outDim (U[6].xy)
#define u_thickness (U[7].x)
#define u_borderColor (U[8])
#define u_viewTransform1 (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_viewTransform2 (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) textureLod(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































mat3 getCoverFitTransform(float aspectRatio, vec2 imageDims) {
    float srcAr = imageDims.x / imageDims.y;
    float h = min(1.0, srcAr / aspectRatio);
    return mat3(h, 0.0, 0.0, 0.0, h, 0.0, 0.0, 0.0, 1.0);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 checkerboardCombine(vec2 pos, vec2 outPos, float thickness, vec4 borderColor, vec2 source1Dim, vec2 source2Dim, mat3 viewTransform1, mat3 viewTransform2) {
    vec2 u = pos;

    float choice = mod(floor(u.x)+floor(u.y), 2.);
    vec2 v = (fract(u)-0.5)*2.;
 
    float d = min(abs(abs(v.x)-1.), abs(abs(v.y)-1.));
    if (d<thickness*0.1) return vec4(borderColor.rgb, 1.);
    
    v /= (1.-thickness*0.1);

    // each checker cell is a square viewport, so cover-fit each source with aspectRatio = 1.
    // fit is the base; the per-source viewTransform pans/zooms within the fitted cell.
    mat3 fit1 = getCoverFitTransform(1.0, source1Dim);
    mat3 fit2 = getCoverFitTransform(1.0, source2Dim);

    vec4 col = (choice>0.0) ? __source1__(tf(fit1 * inverse(viewTransform1), v)) : __source2__(tf(fit2 * inverse(viewTransform2), v));
      
    return col;
}

void main() {
    fragColor = checkerboardCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_thickness, u_borderColor, u_source1Dim, u_source2Dim, u_viewTransform1, u_viewTransform2);
}
