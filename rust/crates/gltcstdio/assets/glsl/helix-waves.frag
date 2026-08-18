#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_intensity (U[7].x)
#define u_frequency (U[8].x)
#define u_lighting (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 helixWaves(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, float intensity, float frequency, float lighting, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    float ratio = sourceDim.x / sourceDim.y;
    
    float X = v.x/ratio+1.0;
    float mirror = mode == 0 ? 1.0 : (sign(mod(X, 4.0)-2.0));
    intensity = mirror * intensity;

    float d = mod(X, 2.0)-1.0;          
    float xx = sin(v.y * 2.0*frequency)*intensity;
    float delta1 = (mix(-1.0, 0.0, (d+1.0)/(xx+1.0)) - d);
    float delta2 = ((d-xx)/(1.0-xx) - d);
    float k = d<xx? 0.0 : 1.0;
    float delta = mix(delta1, delta2, k);
    v.x += delta * ratio;
    
    u = tf(modelTransform, v);
    
    float light = 1.0;
    if (lighting>0.0) {
        float pixel = 2.0/sourceDim.y;
        vec2 grad = vec2(dFdx(delta)/dFdx(u.x), dFdy(delta)/dFdy(u.y)) * 4.;
        //float scaling = length(modelTransform[0].xy); // scaling now integrated in lightDir
        vec2 lightDir = mat2(modelTransform) * vec2(0., -1.);
        light = 1. + lighting * 0.2 * /*scaling */ dot(grad, lightDir);
    }
    vec4 outCol = __source__(u);
    outCol.rgb *= light;
    return outCol;
}

void main() {
    fragColor = helixWaves((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_mode, u_intensity, u_frequency, u_lighting, u_modelTransform);
}
