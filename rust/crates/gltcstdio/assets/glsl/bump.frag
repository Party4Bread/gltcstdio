#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_power (U[7].x)
#define u_dampening (U[8].x)
#define u_lighting (U[9].x)
#define u_highFreqColor (U[10])
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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

float measure(vec2 v, float power) {
    float low = min(abs(v.x), abs(v.y));
    float high = max(abs(v.x), abs(v.y));
    return high==0.0 ? 0.0 : high * pow(1.0 + pow(low/high, power), 1.0/power);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 bump(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float power, float dampening, float lighting, vec4 highFreqColor, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    float ratio = sourceDim.x / sourceDim.y;
    vec2 u = ratio<1.0 ? uv / ratio : uv;
    vec2 v = tf(t, u);
    
    float d = measure(v, power); //pow(pow(abs(v.x), power) + pow(abs(v.y), power), 1.0/power);
    float kCol = 0.0;
    float light = 1.0;
    float dilation = 1.0;
    
    if (d>0.0 && d<1.0) {
        float k = d*d;
        if (intensity <= 0.0) {
            dilation = pow(k, intensity*2.5);
        }
        else {
            float b = 1.0 - intensity * 2.;
            dilation = b + k * (1.0-b);
        }

        if (dampening>0.0 && d>1.0 - dampening) {
            //dilation = mix(1.0, dilation, (1.0-d)/dampening);
            dilation = mix(1.0, dilation, smoothstep(1.0, 1.0-dampening, d));
        }
        else if (dampening<0.0) {
            dilation *= 1.0-dampening*dampening*0.25*pow(d*2.0, -4.0*dampening);
        }
        
        //kCol = smoothstep(1.0, 15.0, dilation*highFreqColor.a);
        kCol = smoothstep(0.0, 3.0, log(dilation)*highFreqColor.a);

        u = tf(modelTransform,  dilation*v).xy;
    }                     
    
    if (lighting>0.0) {
        float pixel = 2.0/sourceDim.y;
        vec2 grad = vec2(dFdx(dilation)/dFdx(u.x), dFdy(dilation)/dFdy(u.y)) * 4.;
        light = 1. + lighting * dot(grad, vec2(0., -1.));
    }
    
    u = ratio<1.0 ? u * ratio : u;
    vec4 outCol = __source__(u);
    outCol.rgb *= light;
    
    return mix(outCol, vec4(highFreqColor.rgb, 1.0), kCol);
}

void main() {
    fragColor = bump((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_power, u_dampening, u_lighting, u_highFreqColor, u_modelTransform);
}
