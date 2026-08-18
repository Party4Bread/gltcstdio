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
#define u_dampening (U[6].x)
#define u_lighting (U[7].x)
#define u_variability (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 waves(vec2 uv, vec2 outPos, float intensity, float dampening, float lighting, float variability, mat3 modelTransform) {
    //float intensity = dot(modelTransform[2].xy, mat2(modelTransform)*vec2(0., 1.)) / length(modelTransform[0].xy);

    vec2 v = tf(inverse(modelTransform), uv);
    float d = dampening==0.0 ? 1.0 : smoothstep(5.0/dampening, 0.5/dampening, abs(v.x));

    // Per-wave amplitude variability: segment v.x by half-cosine periods (PI),
    // offset by PI/2 so segment boundaries land on cosine zeros — that way
    // the magnitude jump between segments happens where cos is 0 and is
    // therefore invisible. Same structure as PAP/MirrorLab's wave shader.
    float xx = (v.x - 1.5707963) / 3.14159265;
    float i = floor(xx);
    float di = xx - i;
    float r0 = rand2(vec2(i, i)).x;
    float rNeighbor;
    if (di < 0.5) {
        rNeighbor = rand2(vec2(i - 1.0, i - 1.0)).x;
        di = 0.5 - di;
    } else {
        rNeighbor = rand2(vec2(i + 1.0, i + 1.0)).x;
        di = di - 0.5;
    }
    float vary = mix(r0, rNeighbor, di * di * 2.0);
    float magnitude = intensity * (1.0 + variability * (vary - 0.5) * 2.0);

    vec2 w = vec2(v.x, v.y + magnitude * cos(v.x) * d);
    vec2 u = tf(modelTransform,  w);

    vec4 outCol = __source__(u);

    if (lighting>0.0) {
        float offset = magnitude * cos(v.x) * d;
        vec2 grad = vec2(dFdx(offset)/dFdx(uv.x), dFdy(offset)/dFdy(uv.y)) ;
        float light = 1. + lighting * dot(grad, (mat2(modelTransform) * vec2(1., 0.)));
        outCol.rgb *= light;
    }

    return outCol;
}

void main() {
    fragColor = waves((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_dampening, u_lighting, u_variability, u_modelTransform);
}
