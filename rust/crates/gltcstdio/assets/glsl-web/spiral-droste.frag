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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_distortion (U[7].x)
#define u_thickness (U[8].x)
#define u_shadows (U[9].x)
#define u_colorShadow (U[10])
#define u_colorBorder (U[11])
#define u_texTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 spiralDroste(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float distortion, float thickness, float shadows, vec4 colorShadow, vec4 colorBorder, mat3 texTransform) {
    vec2 u = uv;

    float d = length(u);

    float p = intensity > 0.0 ? 1.0/(1.0+intensity*10.0) : 1.0+pow(-intensity*100.0, 0.75);

    float angle = atan(u.y, u.x); //getVecAngle(u, d);

    float widthAngle = PI/4.0;

    angle = mod(angle, PI2);

    float scale360 = intensity*intensity * 0.1; 
    float a = angle/PI2;
    float s = pow(scale360, a);
    float dd = log(d*s) / log(scale360);
    float ddd = mod(dd, 1.0);
    if (ddd<thickness) return colorBorder;
    vec2 coord = mix(ddd, exp(ddd)/exp(1.0), 1.0-distortion) * vec2(cos(angle), sin(angle));

    //float shadowing = (u_Shadows==0.0 ? 1.0 : (u_Shadows<0.0 ? 1.0/pow(ddd, u_Shadows*0.02) : pow(ddd, u_Shadows*0.02)));

    //float winding = dd-ddd - a;
    //float shadowing = u_Shadows==0.0 ? 1.0 : min(1.0, 1.0 + winding*u_Shadows*0.01);

    float winding = dd-ddd - a;
    vec2 scoord = coord - shadows*vec2(1.0, 1.0) * mix(1.0, pow(scale360, -winding), shadows*0.1);
    float ds = length(scoord);
    float shadowing = 1.0 - (ds>1.0 ? mix(1.0, max(0.0, 6.0-5.0*ds), 0.5+shadows*0.5): 1.0);

    return mix(__source__(tf(inverse(texTransform), coord)), colorShadow, shadowing); // * vec4(vec3(shadowing), 1.0);
}

void main() {
    fragColor = spiralDroste((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_distortion, u_thickness, u_shadows, u_colorShadow, u_colorBorder, u_texTransform);
}
