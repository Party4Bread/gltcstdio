#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[8];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_radius (U[6].x)
#define u_count (int(U[7].x))

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















































































































































































































































































































































vec2 hash32(vec3 u) {
    return vec2(
        fract(sin(u.x*776.45+u.y*453.24+u.z*553.25)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24+u.z*153.84)*88.77) );
}

vec4 stochasticSuperSampling(vec2 uv, vec2 outPos, float radius, int count, vec2 sourceDim, vec2 outDim) {
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    float totalW = 0.0;
    float pixelSize = 2.0/outDim.y;
    float d = pixelSize * radius;
    vec2 outPixelCoord = (uv + vec2(outDim.x/outDim.y, 1.0)) / pixelSize;
    
    for(int i=0; i<count; ++i) {
        vec2 delta = (hash32(vec3(uv*100., float(i))) - .5) * d; 
        vec4 col = __source__(uv + delta);
        totalColor += col*col;
        totalW += 1.0;
    }

    vec4 avgColor = sqrt(totalColor / totalW); 

    return avgColor;
}

void main() {
    fragColor = stochasticSuperSampling((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_radius, u_count, u_sourceDim, u_outDim);
}
