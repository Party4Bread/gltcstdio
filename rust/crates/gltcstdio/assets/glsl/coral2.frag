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
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_angle (U[6].x)
#define u_power (U[7].x)
#define u_balance (U[8].x)
#define u_offset (U[9].x)

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


















































































































































































































































































































































mat3 getRGBCoefficients(float k, float offset) {
    float offset1 = PI/3.0;
    float offset2 = offset1*2.0;
    float kk = k + offset*PI;
    float a = sin(kk);
    float b = sin(kk+offset1);
    float c = sin(kk+offset2);
    return mat3(vec3(a, b, c), vec3(b, c, a), vec3(0.));
}

mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}

vec4 coral2(vec2 uv, vec2 outPos, float intensity, float angle, float power, float balance, float offset) {
    vec2 p = uv;
    float delta = 0.001;
    vec2 d = vec2(delta, 0.0);
    int N = int(abs(intensity)*500.0); 
    mat2 rot = rotation2(angle);
    float exponent = pow(4., power);
    for(int i=0; i<N; ++i) {
        vec3 rgb = __source__(p).rgb;
        vec2 dir = (getRGBCoefficients(float(i)*balance, offset) * (rgb-vec3(.5))).xy;
        p += sign(intensity) * delta*(pow(length(rgb), exponent)) * (rot*dir);
    }

    vec4 outColor = __source__(p);
    return outColor;
}

void main() {
    fragColor = coral2((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_angle, u_power, u_balance, u_offset);
}
