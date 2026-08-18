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
#define u_spikeCount (int(U[5].x))
#define u_intensity (U[6].x)
#define u_dampening (U[7].x)
#define u_shape (U[8].x)
#define u_variability (U[9].x)
#define u_randomSeed (U[10].x)
#define u_lighting (U[11].x)
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float triangleToSquareWave(float x, float k) {
    x = mod(x, 4.);
    float s = 1.0;
    if (x>2.0) { x = x - 2.0; s = -1.; }
    float m = k>0.0 ? 1.0 : pow(mix(5., 40., -k), -k);
    return m * s * (1. - pow(abs(x-1.), pow(100.0, k)));
}

vec4 flower(vec2 uv, vec2 outPos, int spikeCount, float intensity, float dampening, float shape, float variability, float randomSeed, float lighting, mat3 modelTransform) {
         
            float N = float(spikeCount);
            vec2 u = tf(inverse(modelTransform), uv);
            
            float d = length(u);
        
            if (d>=1.0) {
                return __source__(uv);
            }
            else {
                float angle = atan(u.y, u.x);
                float k = intensity;
        
                float variab = 1.0;
                if (variability != 0.0) {
                    float w = (angle+PI)/PI2*N;
                    float index = ceil(w);
                    float dw = index-w;
                    float rnd = rand2relSeeded(vec2(index, index), randomSeed).x + 0.5;
                    variab = 1.0 - variability * rnd;
                }
                if (d>=variab) {
                    return __source__(uv);
                }
        
                float limit = 0.9 * variab;
        
                if (dampening >= 0.0) {
                    float threshold = limit * (1.0 - dampening);
                    if (d > threshold) {
                        k *= 1.0 - (d - threshold) / (variab-threshold);
                    }
                }
                else {
                    if (d > limit) {
                        k *= 1.0 - (d - limit) / (variab-limit);
                    }
                    float threshold = limit * (-dampening);
                    if (d < threshold) {
                        k *= max(0.0, 1.0 - 2.0 * ((threshold - d) / threshold));
                    }
                }
        
        
//                float scaling = 1.0 + k * (1.0+sin((angle+PI) * N - PI/2.0));
                //float scaling = 1.0 + k * (1.0+triangleToSquareWave(angle/PI_2*N, shape));
                float scaling = 1.0 + k * (1.0+triangleToSquareWave((angle+PI)/PI2*4. * N - 1., shape));
                vec2 coord = tf(modelTransform, scaling*u);
                vec4 outCol = __source__(coord);
                
                if (lighting>0.0) {
                    float dilation = length(coord-u);
                    vec2 grad = vec2(dFdx(dilation)/dFdx(u.x), dFdy(dilation)/dFdy(u.y)) * 4.;
                    float light = 1. + lighting * dot(grad, vec2(0., -1.));
                    outCol.rgb *= light;
                }
            
                 return outCol;
            }
        }

void main() {
    fragColor = flower((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_spikeCount, u_intensity, u_dampening, u_shape, u_variability, u_randomSeed, u_lighting, u_modelTransform);
}
