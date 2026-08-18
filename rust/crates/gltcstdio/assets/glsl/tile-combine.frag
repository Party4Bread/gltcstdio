#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source1Dim (U[4].xy)
#define u_source2Dim (U[5].xy)
#define u_outDim (U[6].xy)
#define u_mode (int(U[7].x))
#define u_thickness (U[8].x)
#define u_colorBorder (U[9])
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) texture(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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















































































































































































































































































































































vec4 tileCombine(vec2 uv, vec2 outPos, 
int mode, float thickness, vec4 colorBorder, 
vec2 source1Dim, vec2 source2Dim, mat3 modelTransform) {
    if (mode==0) {
        float id = round(uv.y * 0.5);
        float y = mod(uv.y+1.0, 2.0) - 1.0;                   
        if (mod(id, 2.0)==0.0) {
            float ratio1 = source1Dim.x/source1Dim.y;
            float ratio = (ratio1+thickness)/(1.0+thickness);
            float x = mod(uv.x + ratio, 2.0*ratio) - ratio; 
            float b = 1./(1.0+thickness);
            if (abs(x)>ratio-1.0+b || abs(y)>b) return colorBorder;
            return __source1__(vec2(x, y) / b);
        } else {
            float ratio1 = source2Dim.x/source2Dim.y;
            float ratio = (ratio1+thickness)/(1.0+thickness);
            float x = mod(uv.x + ratio, 2.0*ratio) - ratio; 
            float b = 1./(1.0+thickness);
            if (abs(x)>ratio-1.0+b || abs(y)>b) return colorBorder;
            return __source2__(vec2(x, y) / b);
        }                    
    }
    else if (mode==1) {
        float id = round(uv.x* 0.5);
        float x = mod(uv.x+1.0, 2.0) - 1.0;
        if (mod(id, 2.0)==0.0) return __source1__(vec2(x, uv.y) * source1Dim.x/source1Dim.y); else return __source2__(vec2(x, uv.y) * source2Dim.x/source2Dim.y);                    
    }
    else {
        vec2 id = round(uv * 0.5);
        vec2 u = mod(uv+1.0, 2.0) - 1.0;
        float b = 1.0 - thickness;
        if (abs(u.x)>b || abs(u.y)>b) return colorBorder;
        u /= b;
        if (mod(id.x+id.y, 2.) == 0.0) return __source1__(u); else return __source2__(u);
    }
}

void main() {
    fragColor = tileCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_thickness, u_colorBorder, u_source1Dim, u_source2Dim, u_modelTransform);
}
