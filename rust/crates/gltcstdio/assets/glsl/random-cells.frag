#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[7];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_detail (int(U[5].x))
#define u_randomSeed (U[6].x)





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


















































































































































































































































































































































float hash21(vec2 p) {
    vec2 a = fract(-45.3277*p.xy);
    vec2 b = a + dot(a, a+123.3371);
	return fract(b.x*b.y);  
}

vec3 cellColor(vec2 id) {
    return vec3(hash21(id + 0.10), hash21(id + 3.70), hash21(id + 9.20));
}

vec4 randomCells(vec2 uv, vec2 outPos, vec2 outDim, int detail, float randomSeed) {
    float ar = outDim.x / outDim.y;
    vec2 halfRect = vec2(ar * 0.5, 0.5);                          // same-AR rectangle at half the frame size
    if (abs(uv.x) > halfRect.x || abs(uv.y) > halfRect.y) return vec4(0.0, 0.0, 0.0, 1.0);
    float n = max(1.0, float(detail));
    vec2 t = clamp(uv / halfRect * 0.5 + 0.5, 0.0, 0.999999);     // rectangle -> [0,1]^2
    vec2 id = floor(t * n);                                       // cell index in [0,n-1]^2
    return vec4(cellColor(id + randomSeed * 13.0), 1.0);
}

void main() {
    fragColor = randomCells((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_outDim, u_detail, u_randomSeed);
}
