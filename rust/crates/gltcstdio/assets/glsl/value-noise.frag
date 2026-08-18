#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_octaves (int(U[5].x))
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_contrast (U[8].x)





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















































































































































































































































































































































float rand21(vec2 v) {
    return fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float interpolatedRand21(vec2 v) {
    float fractY = fract(v.y);
    return mix(
        mix(rand21(floor(v)), rand21(vec2(floor(v.x), ceil(v.y))), fractY),
        mix(rand21(vec2(ceil(v.x), floor(v.y))), rand21(ceil(v)), fractY),
        fract(v.x) );
}

float fractalValueNoise(vec2 v, int count, float intensity) {
    float s = 1.0;
    float k = intensity;
    float total;
    float totalMul = 0.;

    for(int i = 0; i<count; ++i) {
        total += k * interpolatedRand21(v*s);
        totalMul += k;
        k *= 0.5;
        s *= 2.1055472;
    }

    return total / totalMul;
}

vec4 valueNoise(vec2 pos, vec2 outPos, mat3 viewTransform, int octaves, vec4 color1, vec4 color2, float contrast) {
    float x = fractalValueNoise(pos, octaves, 1.0);
//    float x = abs(sin(pos.x*pos.y*1.));
    vec4 col = mix(color1, color2, x);
    if (contrast != 0.) {
        float c = abs(contrast)>1.0 ? sign(contrast) * pow(abs(contrast), 2.0) : contrast;
        col.rgb = (col.rgb - 0.5) * c + 0.5;
    }
    return col;
}

void main() {
    fragColor = valueNoise((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_viewTransform, u_octaves, u_color1, u_color2, u_contrast);
}
