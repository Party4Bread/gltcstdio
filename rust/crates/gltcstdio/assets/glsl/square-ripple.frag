#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_thickness (U[7].x)
#define u_color1 (U[8])
#define u_color2 (U[9])
#define u_color3 (U[10])
#define u_color4 (U[11])





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















































































































































































































































































































































vec4 squareRippleIllusion(vec2 uv, vec2 outPos, int source_specified, int count, float thickness, vec4 color1, vec4 color2, vec4 color3, vec4 color4) {
    vec2 u = abs(fract(uv-0.5)-0.5);
    vec2 id = floor(uv-0.5);
    
    vec2 uv2 = uv;
    //vec2 u2 = fract(uv2);
    vec2 id2 = floor(uv2);
    
    float crossLen = mix(0.15, 0.5, thickness);
    thickness *= 0.2;
    
    if ((u.x<crossLen && u.y<thickness) || (u.y<crossLen && u.x<thickness)) {
        int k = int(id.x + id.y);
        bool invert = (k/count)%2 == 0;
        if (k%3==0 ^^ invert) return color3; else return color4;
    }
    else {
        int k = int(id2.x + id2.y);
        if (k%2==0) return color1; else return color2;
    }
}

void main() {
    fragColor = squareRippleIllusion((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_count, u_thickness, u_color1, u_color2, u_color3, u_color4);
}
