#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_modelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_intensity (U[8].x)
#define u_variability (U[9].x)
#define u_randomSeed (U[10].x)
#define u_lighting (U[11].x)
#define u_layerCount (int(U[12].x))

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

vec2 interpolatedRand2(vec2 v) {
    float fractY = fract(v.y);
    return mix(
        mix(rand2(floor(v)), rand2(vec2(floor(v.x), ceil(v.y))), fractY),
        mix(rand2(vec2(ceil(v.x), floor(v.y))), rand2(ceil(v)), fractY),
        fract(v.x) );
}

vec2 fractalValueNoiseDisplace(vec2 u, vec2 v, int count, float intensity) {
    float s = 1.0;
    float maxDisplacement = intensity; 

    vec2 totalDisp = vec2(0.);

    for(int i = 0; i<count; ++i) {
        vec2 disp = interpolatedRand2(v*s);
        totalDisp += maxDisplacement * (disp - vec2(0.5, 0.5))*2.0;

        maxDisplacement *= 0.5;
        s *= 2.1055472;
    }

    return u + totalDisp;
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

vec4 multiDistort(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity, float variability, float randomSeed, float lighting, int layerCount) {
            mat3 inverseModelTransform = inverse(modelTransform);
            vec2 u = tf(inverseModelTransform, pos);
        
            float seed = randomSeed;
            mat3 layerTransform = mat3(1., 0., 0., 0., 1., 0., 0., 0., 1.);
            vec2 displaced = u;
            
            for(int l=0; l<layerCount; ++l) {
                displaced = tf(layerTransform, displaced);
                float N = variability==0.0 ? 0.0 : 2.0;
                for(float j=-N; j<=N; ++j) {
                    for(float i=-N; i<=N; ++i) {
                        vec2 id = floor((u+1.0)/2.0) + vec2(i, j);
            
                        vec2 rnd = rand2relSeeded(id, seed);
                        vec2 rnd2 = rand2relSeeded(id+vec2(3.4, 23.3), seed);
                        vec2 rnd3 = rand2relSeeded(id-vec2(13.3, 7.2), seed);
            
                        vec2 center = id*2.0 + variability*vec2(rnd3.y, rnd2.y)*5.5;
    //                    vec2 v = u-center;
                        vec2 w = displaced-center;
            
                        float radius = abs(0.6 + rnd.x*0.8 * (1.0+2.5*abs(variability)));
                        if (id.x==0.0 && id.y==0.0 && radius<1.0) radius = 1.0;
            
    //                    float count = floor((rnd.y+0.5)*100.0+1.0);
                        float count = rnd3.x<0.0 ? floor((rnd.y+0.5)*100.0+1.0) : floor(pow(10., rnd.y*2.));
                        float ripplesIntensity = max(0.0, rnd2.x*4.0);
                        float swirlIntensity = sign(rnd2.y) * max(0.0, (abs(rnd2.y)-0.25)*8.0);
                        float flowerlIntensity = sign(rnd3.x) * max(0.0, (abs(rnd3.x)-0.25)*8.0);
                        float marbleIntensity = max(0.0, rnd3.y*2.0);
            
                        float d = length(w);
                        if (d<radius) {
                            float k = d/radius;
            
                            // marble
                            if (marbleIntensity!=0.0) {
                                w = fractalValueNoiseDisplace(w, w*5.0+rnd2*3.0, 6, marbleIntensity*intensity * smoothstep(1.0, 0.5, k));
                            }
            
                            // flower
                            if (flowerlIntensity!=0.0) {
                                float angle = atan(w.x, w.y);
                                float kk = flowerlIntensity *  (1.0 - k);
                                float scaling = 1.0 + kk*intensity * (1.0+sin((angle+PI) * count - PI/2.0));
                                w *= scaling;
                            }
            
                    //        d = length(v);
                    //        k = d/radius;
            
                            // ripples
                            if (ripplesIntensity!=0.0) {
                                float dilation = 1.0 + ripplesIntensity*intensity * sin(k * count * PI) * smoothstep(1.0, 0.5, k);
                                w = dilation*w;
                            }
            
                            // swirl
                            if (swirlIntensity!=0.0) {
                                float dampening = 0.3;
                                float power = (rnd.x+0.6)*50.0;
                                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), k) * swirlIntensity*intensity*5./pow(k, mix(0.01, 1.6, power*0.01));
                                float ca = cos(dangle);
                                float sa = sin(dangle);
                                w = vec2(ca*w.x - sa*w.y, ca*w.y + sa*w.x);
                            }
            
                            displaced = w+center;
                        }
                    }
                }
                displaced = tf(inverse(layerTransform), displaced);
//                layerTransform *= mat3(1.1, 1.5, 0.0, 1.5, -1.1, 0.0, 0.1, 0.2, 1.);
//                layerTransform *= mat3(0.7, 0.8, 0.0, 0.8, -0.7, 0.0, 0.1, 0.2, 1.);
                if (l==0) layerTransform *= mat3(0.65, 0.75, 0.0, 0.75, -0.65, 0.0, 0.1, 0.2, 1.);
                else layerTransform *= mat3(0.7, 0.9, 0.0, 0.9, -0.7, 0.0, 0.1, 0.2, 1.);
                //layerTransform *= mat3(1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.);
                seed += 0.8;
            }
            
            vec2 v = tf(modelTransform, displaced);
            vec4 outCol = __source__(v);
            if (lighting>0.0) {
//                float dilation = length(v-pos);
                float dilation = length(displaced-u);
                vec2 grad = vec2(dFdx(dilation)/dFdx(u.x), dFdy(dilation)/dFdy(u.y)) * 4.;
                float light = 1. + lighting * dot(grad, vec2(0., -1.));
                outCol.rgb *= light;
            }
            
            return outCol;
        }

void main() {
    fragColor = multiDistort((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_intensity, u_variability, u_randomSeed, u_lighting, u_layerCount);
}
