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
#define u_outDim (U[4].xy)
#define u_depth (U[5].x)
#define u_count (int(U[6].x))
#define u_coverage (U[7].x)
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_colorScheme (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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















































































































































































































































































































































vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

vec4 squareNoise(vec2 uv, vec2 outPos, float depth, int count, float coverage, float variability, float randomSeed, float colorScheme, mat3 modelTransform) {
    vec4 col = __source__(uv);
                
    float baseScale = 10.0;
    int N = count;
    float noiseSize = coverage*0.5;
    
    mat3 invModelTransform = inverse(modelTransform);
    
    for(int i=0; i<N; ++i) {
        float s = N<=1 ? 1.0 : pow(depth, 1.0-2.0*float(i)/float(N-1));
        vec2 u = (invModelTransform * (mat3(s, 0.0, 0.0, 0.0, s, 0.0, 0.0, 0.0, 1.0)) * vec3(uv, 1.0)).xy;
        vec2 id = round(u);
        vec2 v = u-id;
        vec2 rnd = rand2relSeeded(id+float(i)*vec2(4.43, -5.434), randomSeed);
        if (abs(rnd.x-rnd.y)>1.0 - 0.75*variability) rnd = rand2relSeeded(floor(id*0.25)+float(i)*vec2(4.43, -5.434), randomSeed);
        if (abs(rnd.x-rnd.y)>1.0 - 0.75*variability) rnd = rand2relSeeded(floor(id*0.0625)+float(i)*vec2(4.43, -5.434), randomSeed);
        
        bool hide = fract(rnd.x*10.0)>1.0 - 0.5*variability;
        
        if (fract(rnd.x*20.)>1.0 - 0.25*variability) v = abs(v-.12);
        
        vec2 center = variability < 0.01 ? v : v + sign(rnd) * vec2(pow(rnd.x, 1./variability), pow(rnd.y, 1./variability));
        float nSize = noiseSize * pow(4.0, variability * (fract(rnd.y*10.)-.5));
        if (!hide && abs(center.x)<nSize && abs(center.y)<nSize) {
            float k = colorScheme*5.;
            vec4 col1, col2;         
            float rc = fract(rnd.y*10.0+.33);
            if (colorScheme<0.2) {
                col = rc>=k ? vec4(0., 0., 0., 1.) : vec4(1., 1., 1., 1.);
            }
            else if (colorScheme<0.4) {
                k -= 1.;
                col = rc>=k ? vec4(1., 1., 1., 1.) : __source__(u);
            }
            else if (colorScheme<0.6) {
                k -= 2.;
                col = rc>=k ? __source__(u) : __source__(id * 0.731344);
            }
            else if (colorScheme<0.8) {
                k -= 3.;
                col = rc>=k ? __source__(id * 0.731344) : vec4(0., 0., 0., 1.);
            }
            else {
                k -= 4.;
                col = rc>=k ? vec4(0., 0., 0., 1.) : vec4(1., 1., 1., 1.);
            }
        }      
    }
    
    return col;
}

void main() {
    fragColor = squareNoise((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_depth, u_count, u_coverage, u_variability, u_randomSeed, u_colorScheme, u_modelTransform);
}
