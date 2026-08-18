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
#define u_len (U[5].x)
#define u_shadows (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

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















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 streakExpand(vec2 uv, vec2 outPos, float len, float shadows, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, uv);

    float lightness = 1.0;
    vec4 col = __source__(uv);
    vec4 outColor = col;
    if (u.y>0.0) {
        float scale = length(inverseModelTransform[0].xy);
        if (abs(u.x)<1.0) {
            float step = scale*len;
            u.y = len==0.0? 0.0 : mod(u.y /*+ step*0.5*/, step);
            vec2 p = tf(modelTransform, u);
            outColor = __source__(p);
        }
        else if (shadows>0.0) {
            float dx = (abs(u.x)-1.0) / scale;
            float dy = abs(u.y) / scale;
            float maxDx = 0.25;
            float maxDy = 1.0;
//            if (dy<maxD) dx *= dy/maxD; //extends shadow horizontally
            if (dy<maxDy) dx += (maxDy-dy)/maxDy*shadows*maxDx;
            lightness = 1.0 - clamp(shadows*maxDx-dx, 0.0, 1.0)/maxDx;
            if (lightness>1.0) lightness=1.0;
            outColor = col*vec4(lightness, lightness, lightness, 1.0);
        }
    }
    return outColor;
}

void main() {
    fragColor = streakExpand((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_len, u_shadows, u_modelTransform);
}
