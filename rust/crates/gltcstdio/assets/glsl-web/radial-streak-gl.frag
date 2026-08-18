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
#define u_count (int(U[6].x))
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

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















































































































































































































































































































































vec4 radialStreak(vec2 uv, vec2 outPos, float intensity, int count, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = (inverseModelTransform * vec3(uv, 1.0)).xy;
    
    float d = length(u);

    if (d == 0.0) return __source__(uv);

    float ang = acos(u.x/d);
    if (u.y < 0.0) ang = PI2 - ang;

    ang -= (PI/2.0);

    float sector = PI2/float(count);
    float streakAngle = intensity*sector;
    float mang = mod(ang, sector);
    float n = floor(ang/sector);
    float sang;
    if (abs(mang-sector/2.0)>(sector-streakAngle)/2.0) {
        sang = PI_2 + (mang<=sector/2.0 ? n : n+1.0)*sector;
    }
    else {
        float angleCompression = 1.0 - intensity;
        sang = PI_2 + n*sector + sector/2.0 + (mang-sector/2.0)/angleCompression;
    }
    vec2 uv2 = (modelTransform * vec3(d*cos(sang), d*sin(sang), 1.0)).xy;
    return __source__(uv2);
}

void main() {
    fragColor = radialStreak((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_modelTransform);
}
