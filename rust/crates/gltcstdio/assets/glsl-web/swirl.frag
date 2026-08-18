#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_modelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_centerTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_intensity (U[11].x)
#define u_power (U[12].x)
#define u_dampening (U[13].x)
#define u_highFreqColor (U[14])

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec2 getCenter(vec2 o, vec2 u) {
    float a = dot(o, o) - 1.0;
    float b = -2.0*dot(o, u) + 2.0;
    float c = dot(u, u) - 1.0;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        if (l1>=0.0 && l1<=1.0) return l1*o;
        else if (l2>=0.0 && l2<=1.0) return l2*o;
    }
    return vec2(INF, INF);
}

vec4 swirl(vec2 pos, vec2 outPos, mat3 modelTransform, mat3 centerTransform, float intensity, float power, float dampening, vec4 highFreqColor) {
            vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
        
            float d = length(u);
        
            if (d>=1.0) {
                return __source__(pos);
            }
            else {        
        //        float dangle = sign(intensity) * smoothstep(1.0, mix(0.9, -4.0, dampening), d) * 0.5/pow(d, abs(intensity)*0.04);
                //float dangle = (d==0.0) ? 0.0 : intensity * pow(d, power) * smoothstep(1.0, 0.0, d);//smoothstep(1.0, mix(0.9, -4.0, dampening), d) * intensity*5.0/pow(d, mix(0.01, 1.6, power));
        
                /////
                vec2 centerMax = (centerTransform*vec3(0.0, 0.0, 1.0)).xy;
                vec2 center = getCenter(centerMax, u);
                if (center.x==INF) return __source__(pos);
                float d2 = length(u-center);
//                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), d2) * intensity/pow(d2, mix(0.01, 1.6, power*0.01));
//                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), d2) * intensity/pow(d2, mix(-10., 10., power*0.01));
                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), d2) * intensity * pow(d2, -power); 
                /////
        
                float ca = cos(dangle);
                float sa = sin(dangle);
                u -= center;
                vec2 rotated = vec2(ca*u.x - sa*u.y, ca*u.y + sa*u.x)+center;
                //u += center;
        
                float darken = 0.0;
                if (highFreqColor.a!=0.0) {
                    darken = smoothstep(0.75*highFreqColor.a, 0.0, d2);
                }
                vec2 coord = (modelTransform * vec3(rotated, 1.0)).xy;
                vec4 col = __source__(coord);
        //        if (darken!=0.0) {
        //            vec4 hsl = RGBtoHSL(col);
        //            hsl.z *= (1.0-darken);
        //            return HSLtoRGB(hsl);
        //        } else return col;
                return mix(col, vec4(highFreqColor.rgb, col.a), darken);
            }
        }

void main() {
    fragColor = swirl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_centerTransform, u_intensity, u_power, u_dampening, u_highFreqColor);
}
