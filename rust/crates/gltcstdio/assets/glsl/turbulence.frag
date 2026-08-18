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
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_iterations (int(U[6].x))
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_translation (U[10].x)
#define u_angle (U[11].x)

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

float nextRot(int i, float angle) {
    return 1.507+sin(angle)+sin(float(i)*0.01);
}

mat3 rotation3(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat3(ca, sa, 0., -sa, ca, 0., 0., 0., 1.);
}

mat3 scaling3(float s) {
    return mat3(s, 0., 0., 0., s, 0., 0., 0., 1.);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

mat3 translation3(vec2 t) {
    return mat3(1., 0., 0., 0., 1., 0., t.x, t.y, 1.);
}

vec2 wave(vec2 u, float k) {
    return 5.*vec2(k*sin(u.y*(1.5+sin(u.y*1.1))+0.44)/(abs(u.y)+1.0), k*(sin(u.x)/(abs(u.x)+1.0)));
}

vec4 turbulence(vec2 uv, vec2 outPos, float intensity, int iterations, mat3 modelTransform, float translation, float angle) {
    mat3 t = inverse(modelTransform);

    for(int i=0; i<iterations; ++i) {
        uv = tf(t, uv);
        uv += wave(uv, intensity);
        uv = tf(inverse(t), uv);
        vec2 p = vec2(0.);
        //vec2 p = wave(uv, 1.0);
        float tt = pow(translation, 3.);
        t *= translation3(vec2(tt+0.01*cos(angle), tt+0.02*sin(angle)))
            * rotation3(nextRot(i, angle)+.5*p.y)
            * scaling3(1.);
    }

    return __source__(uv);
}

void main() {
    fragColor = turbulence((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_iterations, u_modelTransform, u_translation, u_angle);
}
