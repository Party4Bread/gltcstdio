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
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_colorVariability (U[7].x)
#define u_mode (int(U[8].x))
#define u_color1 (U[9])
#define u_color2 (U[10])

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


















































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float pr(float x, float k, int process) {
    if (process==1) return fract(x);
    else if (process==2) return 1.0 - abs(mod(x, 2.0)-1.0); // reflect
    else if (process==3) return mod(x, 2.0); 
    else if (process==4) return x/k; 
    else return x;
}

vec4 xorPatterns(vec2 uv, vec2 outPos, int source_specified, float intensity, float colorVariability, int mode, vec4 color1, vec4 color2) {

    int process = mode%5; mode /= 5;
    float mR = (float(mode%8) - 3.5)*3.0; mode /= 8;
    float mB = (float(mode%8) - 3.5)*3.0; mode /= 8;
    
    float modG = intensity;
    float modR = intensity + colorVariability * mR;
    float modB = intensity + colorVariability * mB;
    int rdx = int(round(float(mode%16) * colorVariability)); mode /= 16;
    int bdy = int(round(float(mode%16) * colorVariability)); mode /= 16;
    
    
    int x = int(uv.x);
    int y = int(uv.y);
        
    float r = pr(mod(float((x+rdx) ^ y), modR), modR, process);
    float g = pr(mod(float(x ^ y), modG), modG, process);
    float b = pr(mod(float(x ^ (y+bdy)), modB), modB, process);
    float a = pr(mod(float((x+rdx) ^ (y+bdy)), modG), modG, process);
    
    vec4 outColor = vec4(mix(color1.r, color2.r, r), mix(color1.g, color2.g, g), mix(color1.b, color2.b, b), mix(color1.a, color2.a, a));
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;     
}

void main() {
    fragColor = xorPatterns((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_intensity, u_colorVariability, u_mode, u_color1, u_color2);
}
