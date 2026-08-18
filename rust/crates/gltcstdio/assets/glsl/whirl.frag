#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_modelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_intensity (U[8].x)
#define u_unwind (U[9].x)
#define u_highFreqColor (U[10])

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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 whirl(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity, float unwind, vec4 highFreqColor) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, pos);

    float d = length(u);

    if (d>=1.0) {
        return __source__(pos);
    }
    else {
        float bal = unwind;
        if (bal != 0.5) {
            if (bal==1.0 || d < bal) {
                float ratio2 = d/bal;
                d = 0.5 * ratio2;
            }
            else {
                float ratio2 = (d-bal)/(1.0-bal);
                d = 0.5 * (1.0-ratio2);
            }
        }
        
        float dangle = intensity * 10. * (1.0-cos(d*2.0*PI));
        float ca = cos(dangle);
        float sa = sin(dangle);
        vec2 rotated = vec2(ca*u.x - sa*u.y, ca*u.y + sa*u.x);

        float darken = 0.0;
        if (highFreqColor.a!=0.0) {
            float d = length(rotated*vec2(min(1.5, 1.00+abs(intensity*3.0)), 1.0));
            float sHeight = highFreqColor.a*4.0;
            float sSlope = 1.0+highFreqColor.a*3.0;
            darken = clamp(sHeight-d*sSlope, 0.0, 1.0);
//            darken *= u_Shadows*0.01;
        }
        vec2 coord = tf(modelTransform, rotated);
        vec4 col = __source__(coord);
        
        return mix(col, vec4(highFreqColor.rgb, col.a), darken);
    }
}

void main() {
    fragColor = whirl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_intensity, u_unwind, u_highFreqColor);
}
