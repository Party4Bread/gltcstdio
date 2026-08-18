#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_InverseModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_iterations (int(U[8].x))
#define u_intensity (U[9].x)
#define u_balance (U[10].x)
#define u_variability (U[11].x)
#define u_randomSeed (U[12].x)
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

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

vec4 waveFlow(vec2 uv, vec2 outPos, int iterations, float intensity, float balance, float variability, float randomSeed, mat3 modelTransform) {
            float mtScale = length(modelTransform[0].xy);
            float mt2k = mtScale*SQRT2_2; // (cos(pi/4)==sin(pi/4))
            mat3 modelTransform2 = mat3(vec3(mt2k, mt2k, 0.), vec3(-mt2k, mt2k, 0.), modelTransform[2]);
            
            vec2 u = uv;
                
            //mat3 rotMat = mat3(cos(angle), sin(angle), 0.0, -sin(angle), cos(angle), 0.0, 0.0, 0.0, 1.0);
        
            mat3 inverseTransform = inverse(modelTransform);
            mat3 inverseTransform2 = inverse(modelTransform2);
            mat3 invTransf = inverseTransform;
            mat3 transf = modelTransform;
            vec2 bTranslate = (balance > 0.0 ? balance : 0.0) * vec2(cos(balance*10.), sin(-balance*10.));
        
            for(int j=0; j<iterations; ++j) {
                vec2 translate = bTranslate*float(j); //u_Balance > 0.0 ? u_Balance*0.005*float(j) : 0.0;
                float scale = balance < 0.0 ? pow(0.999, abs(balance)*100.*float(j)) : 1.0;
                mat3 ts = mat3(scale, 0.0, 0.0, 0.0, scale, 0.0, 0.0, 0.0, 1.0);
                mat3 invts = mat3(1.0/scale, 0.0, 0.0, 0.0, 1.0/scale, 0.0, 0.0, 0.0, 1.0);
                mat3 tt = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, translate.x, translate.y, 1.0);
                mat3 invtt = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, -translate.x, -translate.y, 1.0);
                mat3 t1 = ts* modelTransform * tt;
                mat3 invt1 = invtt * inverseTransform * invts;
                mat3 t2 = ts * modelTransform2 * tt;
                mat3 invt2 = invtt * inverseTransform2 * invts;
        
                mat3 invTransf = (j==(j/2)*2) ? invt1 : invt2;
                //        mat3 invTransf = u_InverseModelTransform;
                u = (invTransf * vec3(u, 1.0)).xy;
        
                float d = u.x;
        
                float N = 4.0;
                float xx = u.x/N;
                float i = floor(xx);
                float di = xx - i;
        
                vec2 rnd = rand2relSeeded(vec2(i, i), randomSeed);
                vec2 rnd2;
                float var = rnd.x;
                if (di<0.5) {
                    rnd2 = rand2relSeeded(vec2(i-1.0, i-1.0), randomSeed);
                    di = 0.5-di;
                }
                else {
                    rnd2 = rand2relSeeded(vec2(i+1.0, i+1.0), randomSeed);
                    di = di-0.5;
                }
                var = mix(var, rnd2.x, di*di*2.0);
        
                float magnitude = intensity * (1.0 + ((variability*10.) * (var)*2.0));
                float dy =  sin(xx*PI) * magnitude;
        
                mat3 transf = (j==(j/2)*2) ? t1 : t2;
                u = (transf * vec3(u.x, u.y+dy, 1.0)).xy;
        
//                invTransf = invTransf * 0.9; // weird code that did nothing
//                transf = rotMat / 0.9;
            }
        
            return __source__(u);
        }

void main() {
    fragColor = waveFlow((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_iterations, u_intensity, u_balance, u_variability, u_randomSeed, u_modelTransform);
}
