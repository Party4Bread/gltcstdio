#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[7];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_blend (U[6].x)

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















































































































































































































































































































































vec4 seamless(vec2 uv, vec2 outPos, vec2 sourceDim, float blend) {
    float inRatio = sourceDim.x/sourceDim.y;
    float margin = blend * min(inRatio, 1.0);
    float halfMargin = margin * .5;
    float outRatio = (2.*inRatio-margin) / (2.-margin);
    float outToInScale = (2. - margin) / 2.; 
    
    vec2 u = uv * outToInScale;
    
    vec2 u2 = u;
    vec2 k = vec2(1.);
    vec2 lim = vec2(inRatio, 1.0) - halfMargin;
    vec2 mlim = vec2(inRatio, 1.0) - margin;
    
    if (u.x<-mlim.x) { 
        u2.x = lim.x + (u.x+lim.x);
        k.x = 1.0 - (-mlim.x - u.x)/margin;
    }
    else if (u.x>mlim.x) {
        u2.x = -inRatio + (u.x-mlim.x);
        k.x = 1.0 - (u.x - mlim.x)/margin;
    }

    if (u.y<-mlim.y) { 
        u2.y = lim.y + (u.y+lim.y);
        k.y = 1.0 - (-mlim.y - u.y)/margin;
    }
    else if (u.y>mlim.y) {
        u2.y = -1.0 + (u.y-mlim.y);
        k.y = 1.0 - (u.y - mlim.y)/margin;
    }
    
    if (k.x!=1.0 || k.y!=1.0) {
        return mix(
            mix(__source__(vec2(u2.x, u2.y)), __source__(vec2(u.x, u2.y)), k.x), 
            mix(__source__(vec2(u2.x, u.y)), __source__(u), k.x),
            k.y
        );
    }
    else {            
        return __source__(u);
    }
}

void main() {
    fragColor = seamless((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_blend);
}
