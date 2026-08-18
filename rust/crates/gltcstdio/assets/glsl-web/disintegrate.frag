#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_sourceBkg;

#define u_source sampler2D(t_source, samp)
#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_sourceBkg_specified (int(U[5].x))
#define u_mode (int(U[6].x))
#define u_colorBkg (U[7])
#define u_regularity (U[8].x)
#define u_len (U[9].x)
#define u_power (U[10].x)
#define u_translateVar (U[11].x)
#define u_scaleVar (U[12].x)
#define u_angleVar (U[13].x)
#define u_shadows (U[14].x)
#define u_minimum (U[15].x)
#define u_threshold (U[16].x)
#define u_modelTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))
#define u_randomSeed (U[20].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) textureLod(u_sourceBkg, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

float getBaseAngle(vec2 cc, float phasing, int mode) {
    int mm = mode%100;
    if (mm==20) return (cc.x+cc.y)/phasing*PI;
    else return 0.;
}

vec2 getBaseTranslate(vec2 cc, float phasing, int mode) {
    int mm = mode%100;
    if (mm==21) return vec2(0., cos((cc.x+cc.y)/phasing*PI));
    else return vec2(0.);
}

float getGlobalScaling(float progress, float phasing, int mode) {
    if (mode<10) {
        return 1. / smoothstep(phasing, 0., progress);
    }
    else {
        return 1.;
    }
}

vec2 hash22b(vec2 u) {
    return vec2(
        fract(sin(dot(u.xy, vec2(13.7545,78.224)))* 43758.5453123), 
        fract(sin(dot(u.xy, vec2(15.7545,73.224)))* 43758.5453123) );
}

vec2 rndUnit(vec2 p) {
    vec2 rnd = hash22b(p)-0.5;
    float len = length(rnd);
    if (len==0.0) return vec2(0., 1.0); else return rnd/len;
}

float dotGridGradient(vec2 g, vec2 u) {
    return dot(u-g, rndUnit(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinNoise(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float getProgress(vec2 cc, float phasing, int mode) {
    int mm = mode%10;
    if (mm==0) return cc.x;
    else if (mm==1) return length(cc);
    else if (mm==2) return -phasing+length(cc);
    else if (mm==3) return phasing-length(cc);
    else if (mm==4) return phasing-length(cc*vec2(2.0, 0.5));
    else if (mm==5) return phasing * cos(cc.x/phasing*PI);
    else if (mm==6) return 0.5*phasing * (cos(cc.x/phasing*PI)+1.);
    else if (mm==7) return 0.5*phasing * (cos(length(cc)/phasing*PI)+1.);
    else if (mm==8) return 0.25*phasing * (cos(cc.x/phasing*PI)+1.)* (cos(cc.y/phasing*PI)+1.);
    else if (mm==9) return perlinNoise(cc/phasing) * phasing;
    else return phasing;
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
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

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
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

vec4 disintegrate(vec2 uv, vec2 outPos, vec2 outDim, int mode, int sourceBkg_specified, vec4 colorBkg, float regularity, float len, float power, float translateVar, float scaleVar, float angleVar, float shadows, float minimum, float threshold, mat3 modelTransform, float randomSeed) {
            vec2 u = (inverse(modelTransform) * vec3(uv, 1.)).xy;
            float phasing = len;
            float variability = 1. - regularity;
            float pixel = 2.0/outDim.y / length(modelTransform[0].xy);
            
            // progression
            float minProgress = minimum;
            float maxProgress = threshold;
        
            vec2 cell = floor(u);
            float N = ceil(pow(10.0, scaleVar*0.5)*.75 + translateVar);
            //vec4 color = vec4(.5, .5, .5, .1);
            vec4 color = mergeColor(sourceBkg_specified==1 ? __sourceBkg__(uv) : __source__(uv), colorBkg);
            //vec4 color = vec4(0., 0., 0., .1);
            for(float i=-N; i<=N; ++i) {
                for(float j=-N; j<=N; ++j) {
                    vec2 cc = cell + vec2(i, j);
                    vec2 rnd = rand2relSeeded(cc, randomSeed);
                    vec2 rnd2 = sineSurfaceRand2Seeded(.2+cc*0.75, randomSeed*2.); //rand2relSeeded(vec2(cc.y), randomSeed*2.);
        
                    float progress = getProgress(cc, phasing, mode) + phasing*(variability*rnd2.x+variability*variability*rnd.x);
                    progress = pow(abs(progress)/phasing, 1./power) * phasing * sign(progress);
                    progress = max(progress, phasing*minProgress);
                    if (progress>phasing*maxProgress) progress = phasing;
                    float globalScaling = getGlobalScaling(progress, phasing, mode);
        
                    float intensity = smoothstep(0., phasing, progress); //pow(smoothstep(0., phasing, progress), 1./power);
                    float cScale = pow(10.0, rnd.x*0.5*intensity*scaleVar*2.) * globalScaling;
                    float cAngle = getBaseAngle(cc, phasing, mode) + rnd.y*PI*intensity * angleVar;
                    vec2 cTr = getBaseTranslate(cc, phasing, mode) + rnd*intensity * translateVar*4.;
                    mat3 locTr = mat3(cScale*cos(cAngle), -cScale*sin(cAngle), 0.,
                                      cScale*sin(cAngle), cScale*cos(cAngle), 0.,
                                      cTr.x,  cTr.y, 1.);

                    vec2 relU = (locTr*vec3((u-cc)-.5, 1.)).xy;
                    float d = sdRectangle(relU, vec2(.5));
                    float trIntens = abs(log(cScale)) + 0.5*smoothstep(0.0, 0.5, abs(cAngle)) + length(cTr);


                    float shadowLen = shadows * trIntens;
//                    if (d<0.) color = __source__(tf(modelTransform, cc+relU+.5));
//                    else if (d<shadowLen) color.rgb*=smoothstep(0., shadowLen, d);

                    if (trIntens==0.0) {
                        if (d<0.) color = __source__(tf(modelTransform, cc+relU+.5));
                        else if (d<shadowLen) color.rgb*=smoothstep(0., shadowLen, d);
                    }           
                    else color = mix(
                        (d>0. && d<shadowLen) ? color*vec4(vec3(smoothstep(0., shadowLen, d)), 1.) : color, 
                        __source__(tf(modelTransform, cc+relU+.5)), 
                        smoothstep(pixel*.75, -pixel*.75, d) );

//                    color = mix(
//                        (d>0. && d<shadowLen) ? color*vec4(vec3(smoothstep(0., shadowLen, d)), 1.) : color, 
//                        __source__(tf(modelTransform, cc+relU+.5)), 
//                        smoothstep(pixel*.75, -pixel*.75, d) );
                }
            }
        
            return color;
        }

void main() {
    fragColor = disintegrate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_outDim, u_mode, u_sourceBkg_specified, u_colorBkg, u_regularity, u_len, u_power, u_translateVar, u_scaleVar, u_angleVar, u_shadows, u_minimum, u_threshold, u_modelTransform, u_randomSeed);
}
