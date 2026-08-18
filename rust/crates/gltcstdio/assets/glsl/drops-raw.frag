#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceBkg_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_radius (U[7].x)
#define u_radiusVariability (U[8].x)
#define u_perturbation (U[9].x)
#define u_variability (U[10].x)
#define u_randomSeed (U[11].x)
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) texture(u_sourceBkg, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 sineMix(vec2 val1, vec2 val2, float k) {
    return val1*(1.0+cos(k*PI))*0.5 + val2*(1.0+cos((1.0-k)*PI))*0.5;
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

vec4 drops(vec2 uv, vec2 outPos, int sourceBkg_specified, float intensity, float radius, float radiusVariability, float perturbation, float variability, float randomSeed, mat3 modelTransform) {
            mat3 t = inverse(modelTransform);
            vec2 u = uv;
            vec2 v = tf(t, uv);
            
            if (perturbation > 0.0) {
                v += sineSurfaceRand2Seeded(v*(1.0+perturbation*0.00), randomSeed) * 2.5*perturbation;
            }
        //    if (perturbation > 0.0) {
        //        t = perlinDisplace(t, 3, u_Perturbation*0.04);
        //    }
        
            float ci = floor(v.x);
            float cj = floor(v.y);
        
            float k = 0.0;
        
            vec2 minDelta;
            float d2min = INF;
            int minI = 0;
            int minJ = 0;
            vec2 minCenter;
            float minRadiusModifier;
            bool inBubble = false;
            float minRad = 0.0;
        
            for(int j = -2; j <= 2; ++j) {
                for(int i = -2; i <= 2; ++i) {
                    vec2 center = vec2(float(i)+ci, float(j)+cj);
                    vec2 delta = rand2relSeeded(center, randomSeed);
                    float radiusModifier = max(0.01, 1.0 + (delta.x * radiusVariability));
                    float rad = radius * radiusModifier;
                    float rad2 = rad*rad;
                    center += vec2(0.5, 0.5) + delta*variability*2.;
                    vec2 d = v - center;
                    float d2 = dot(d, d);
        
                    if (d2 < rad2) {
                        bool better = true;
                        if (inBubble) {
                            // distance between the 2 centers
                            vec2 dd = minCenter - center;
                            float cd2 = dot(dd, dd);
                            float cd = sqrt(cd2);
        
                            float minRad2 = minRad*minRad;
                            float inProj = (rad2 + cd2 - minRad2) / (2.0*cd); // position along the center's axis of the intersecting line
        
                            // distance of the projection of the current point on the center's axis to the current center (xx, yy)
                            float proj = dot(v-center, dd) / cd;
                            better = proj <= inProj;
                        }
        
                        if (better) {
                            inBubble = true;
        
                            d2min = d2;
                            minI = i;
                            minJ = j;
                            minCenter = center;
                            minDelta = delta;
                            minRadiusModifier = radiusModifier;
                            minRad = rad;
                        }
                    }
                }
            }
        
            k = sqrt(d2min);
        //    k = clamp(k, 0.0, 1.0);
        
            vec2 newPos = uv;
        
        // old mirror lab code:
//            if (inBubble && intensity > 0.0) {
//                vec2 dd = v - minCenter;
//        
//                k /= minRad;
//                float r = 1.0-k;
//                float dp = intensity*5.0 * (1.0-r)/(0.5+r);
//                newPos += dd * dp;
//        //        return vec4(0.0, 0.0, 0.0, 1.0);
//            }
            if (inBubble && intensity != 0.0) {
                vec2 dd = v - minCenter;
                float rad = radius * minRadiusModifier;
                float d = sqrt(d2min)/rad;//length(dd);
                float hh = sqrt(1.0 - d*d);
                if (hh != 0.0) {        
                    float h = 1.0 + hh;
                    float s = (- d * intensity) / hh;
                    float dilation = 1.0 + (h * s)/d;
            
                    newPos = tf(modelTransform,  minCenter + dilation*dd).xy;
                }
            }
        
            vec4 outColor = inBubble || sourceBkg_specified==0
                ? __source__(newPos)
                : __sourceBkg__(uv);
        
            return outColor;

        }

void main() {
    fragColor = drops((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceBkg_specified, u_intensity, u_radius, u_radiusVariability, u_perturbation, u_variability, u_randomSeed, u_modelTransform);
}
