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
#define u_modelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_regularity (U[8].x)
#define u_balance (U[9].x)

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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 pixelateVariable(vec2 pos, vec2 outPos, mat3 modelTransform, float regularity, float balance) {
    mat3 invModelTransform = inverse(modelTransform);
    vec4 sampledColor;
    vec2 uu;
    float scale = 1.0;
    for(int i=0; i<5; ++i) {
        mat3 sM = mat3(scale, 0.0, 0.0, 0.0, scale, 0.0, 0.0, 0.0, 1.0);
        mat3 isM = mat3(1./scale, 0.0, 0.0, 0.0, 1./scale, 0.0, 0.0, 0.0, 1.0);
        vec2 v = tf(isM*invModelTransform, pos);
        vec2 pix = round(v);
        vec2 u = tf(modelTransform*sM, pix);
        
        
        sampledColor = __source__(u);
        float scale2 = regularity==0.0 ? 0.0000001 : regularity*2.*scale;
        
        mat3 sM2 = mat3(scale2, 0.0, 0.0, 0.0, scale2, 0.0, 0.0, 0.0, 1.0);
        mat3 isM2 = mat3(1./scale2, 0.0, 0.0, 0.0, 1./scale2, 0.0, 0.0, 0.0, 1.0);
        v = tf(isM2*invModelTransform, pos);
        pix = round(v);
        u = tf(modelTransform*sM2, pix);
        
        float total = 0.0;
        for(int j=-1; j<=1; ++j) {
            for(int i=-1; i<=1; ++i) {
                vec4 other = __source__(u + scale*0.5*vec2(float(i), float(j)));
                total += length(sampledColor.rgb - other.rgb);
            }
        }
        float dist = total/8.0;
        if (dist >= (0.5 + balance*0.5) * 1.717) break;
        
        scale *= 2.;
    }

    return sampledColor;

}

void main() {
    fragColor = pixelateVariable((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_regularity, u_balance);
}
