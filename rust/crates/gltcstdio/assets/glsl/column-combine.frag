#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_shadows (U[5].x)
#define u_thickness (U[6].x)
#define u_color (U[7])
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_viewTransform1 (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_viewTransform2 (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) texture(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 columnCombine(vec2 pos, vec2 outPos, float shadows, float thickness, vec4 color, mat3 modelTransform, mat3 viewTransform1, mat3 viewTransform2) {
    vec2 u = tf(inverse(modelTransform), pos);   
    float d = abs(u.x) - 0.3;
    vec4 col = (d>0.0) ? __source1__(tf(inverse(viewTransform1), pos)) : __source2__(tf(inverse(viewTransform2), pos));
    float dd = d*length(modelTransform[0].xy);
    
    if (abs(dd)<thickness*0.1) return vec4(color.rgb, 1.);
    
    if (sign(shadows)==sign(d) && shadows!=0.0) {
        float sh = smoothstep(shadows, 0.0, dd);
        col = mergeColor(col, vec4(color.rgb, color.a*sh));                
    }       
    return col;
}

void main() {
    fragColor = columnCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_shadows, u_thickness, u_color, u_modelTransform, u_viewTransform1, u_viewTransform2);
}
