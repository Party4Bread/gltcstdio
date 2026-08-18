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
#define u_intensity (U[5].x)
#define u_perturbation (U[6].x)
#define u_distortion (U[7].x)
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_pixelation (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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


















































































































































































































































































































































vec2 hash12(float x) {
    return vec2(
        fract(sin(x*776.4577)*45.77), 
        fract(sin(x*376.4517+1.2524)*88.77) );
}

vec2 getCenter(float i, float variability, float randomSeed) {
    float x = i*0.2;
    vec2 p = x*vec2(cos(x), sin(x));
    if (variability!=0.0) {
        p += x * variability * 2. * (hash12(i*10. + randomSeed) - .5);
    }
    return p;
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

vec2 sineMix(vec2 val1, vec2 val2, float k) {
    return val1*(1.0+cos(k*PI))*0.5 + val2*(1.0+cos((1.0-k)*PI))*0.5;
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 sineSurfaceRand2Seeded(vec2 v, float seed) {
    vec2 u00 = floor(v);
    vec2 u01 = vec2(floor(v.x), ceil(v.y));
    vec2 u10 = vec2(ceil(v.x), floor(v.y));
    vec2 u11 = ceil(v);

    vec2 r00 = varyVec2NoiseSmoothly(rand2(u00), seed)-vec2(0.5, 0.5);
    vec2 r01 = varyVec2NoiseSmoothly(rand2(u01), seed)-vec2(0.5, 0.5);
    vec2 r10 = varyVec2NoiseSmoothly(rand2(u10), seed)-vec2(0.5, 0.5);
    vec2 r11 = varyVec2NoiseSmoothly(rand2(u11), seed)-vec2(0.5, 0.5);

    return sineMix(
            sineMix(r00, r01, fract(v.y)),
            sineMix(r10, r11, fract(v.y)),
            fract(v.x));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

        vec4 spiralBreaks(vec2 uv, vec2 outPos, float intensity, float perturbation, float distortion, float variability, float randomSeed, float pixelation, mat3 modelTransform) {
            mat3 inverseModelTransform = inverse(modelTransform);
            vec2 u = uv;
            vec2 t = tf(inverseModelTransform, uv);
            
//            if (perturbation > 0.0) {
//                t = perlinDisplace(t, 3, perturbation*4.0);
//            }
            if (perturbation > 0.0) {
                t += sineSurfaceRand2Seeded(t*(1.0+perturbation*0.00), randomSeed) * 2.5*perturbation;
            }        
        
            float d2min = INF;
            float d2min2 = INF;
            vec2 minCenter;
            float minIndex = 0.0;
        
        //    float N = 60.0;
            float N = 100.0;
            for(float i=0.0; i<N; ++i) {
                float angle = i*6.0*PI2/N;
                vec2 center = getCenter(i, variability, randomSeed);
        
                vec2 d = t - center;
                float d2 = dot(d, d);
        
                if (d2 < d2min) {
                    d2min2 = d2min;
                    d2min = d2;
                    minIndex = i;
                    minCenter = center;
                }
                else if (d2 < d2min2) {
                    d2min2 = d2;
                }
            }
        
            vec2 delta = (rand2(vec2(minIndex+1.0, minIndex))-vec2(0.5, 0.5)) * intensity*2.0;
            vec2 newPos = uv + delta;
        
            bool distorted = false;
            if (d2min > 0.0 && distortion > 0.0 && pixelation!=1.0) {
                    vec2 dd = t - minCenter;
                    distorted = true;
                    float k = clamp(sqrt(d2min), 0.0, 1.0) / sqrt(d2min2);
        //            float k = sqrt(d2min / d2min2);
                    float r = 1.0-k;
                    float dp = distortion*2.0 * (1.0-r)/(0.5+r);
                    newPos += dd * dp;
            }
        
            vec4 outColor = __source__(newPos);
        
            if (pixelation!= 0.0) {
                vec2 pixelPos = tf(modelTransform, minCenter) + delta;
                outColor = mix(outColor, __source__(pixelPos), pixelation);
            }
        
            return outColor;
        }

void main() {
    fragColor = spiralBreaks((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_perturbation, u_distortion, u_variability, u_randomSeed, u_pixelation, u_modelTransform);
}
