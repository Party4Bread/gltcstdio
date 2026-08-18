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
#define u_layers (U[6].x)
#define u_radiusVariability (U[7].x)
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_balance (U[10].x)
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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
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

vec2 turb3Layer(vec2 u, float intensity, float radiusVariability, float variability, float randomSeed, float balance) {
    float ci = floor(u.x);
    float cj = floor(u.y);

    float k = 0.0;

    vec2 displacement = vec2(0.0, 0.0);

    for(int j = -2; j <= 2; ++j) {
        for(int i = -2; i <= 2; ++i) {
            vec2 center = vec2(float(i)+ci, float(j)+cj);
            vec2 delta = rand2relSeeded(center, randomSeed);
            float radiusModifier = max(0.01, 1.0 + (delta.x * radiusVariability ));
            center += vec2(0.5, 0.5) + delta*variability;
            vec2 d = u - center;
            k = length(d);

            float threshold = radiusModifier*0.75;
            if (k < threshold) {
                k /= threshold;

                float bal = (-balance+1.0)*0.5;
                if (bal != 0.5) {
                    if (bal==1.0 || k < bal) {
                        float ratio2 = k/bal;
                        k = 0.5 * ratio2;
                    }
                    else {
                        float ratio2 = (k-bal)/(1.0-bal);
                        k = 0.5 * (1.0-ratio2);
                    }
                }

                float dangle = intensity * delta.x * 10. * (1.0-cos(k*2.0*PI));
                float ca = cos(dangle);
                float sa = sin(dangle);
                vec2 rotated = vec2(ca*d.x - sa*d.y, ca*d.y + sa*d.x);
                displacement += (rotated - d);
            }
        }
        
    }

    return displacement;
}

vec4 turbulence3(vec2 uv, vec2 outPos, float intensity, float layers, float radiusVariability, float variability, float randomSeed, float balance, mat3 modelTransform) {
            vec2 u = tf(inverse(modelTransform), uv);
            
            u += turb3Layer(u, intensity, radiusVariability, variability, randomSeed, balance);

            if (layers>0.0) {
                u += min(1., layers*4.) *2. * turb3Layer(u*.5, intensity, radiusVariability, variability, randomSeed+1.1, balance);
            }
            if (layers>0.25) {
                u += min(1., layers*4.-1.) *4. * turb3Layer(u*.25, intensity, radiusVariability, variability, randomSeed-1.2, balance);
            }
            if (layers>0.5) {
                u += min(1., layers*4.-2.) *8. * turb3Layer(u*.125, intensity, radiusVariability, variability, randomSeed-2.22, balance);
            }
            if (layers>0.75) {
                u += min(1., layers*4.-3.) *16. * turb3Layer(u*.0625, intensity, radiusVariability, variability, randomSeed+2.72, balance);
            }
            
//            if (layers>0.75) {
//                u += min(1., layers*4.-3.) *16. * turb3Layer(u*.0625, intensity, radiusVariability, variability, randomSeed+2.72, balance);
//            }
//            if (layers>0.5) {
//                u += min(1., layers*4.-2.) *8. * turb3Layer(u*.125, intensity, radiusVariability, variability, randomSeed-2.22, balance);
//            }
//            if (layers>0.25) {
//                u += min(1., layers*4.-1.) *4. * turb3Layer(u*.25, intensity, radiusVariability, variability, randomSeed-1.2, balance);
//            }
//            if (layers>0.0) {
//                u += min(1., layers*4.) *2. * turb3Layer(u*.5, intensity, radiusVariability, variability, randomSeed+1.1, balance);
//            }
//            u += turb3Layer(u, intensity, radiusVariability, variability, randomSeed, balance);
            
   
            u = tf(modelTransform, u);
            
            return __source__(u);
        }

void main() {
    fragColor = turbulence3((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_layers, u_radiusVariability, u_variability, u_randomSeed, u_balance, u_modelTransform);
}
