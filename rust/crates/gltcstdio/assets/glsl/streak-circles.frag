#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[20];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_pixelation (U[5].x)
#define u_count (int(U[6].x))
#define u_layerCount (int(U[7].x))
#define u_variability (U[8].x)
#define u_shadows (U[9].x)
#define u_randomSeed (U[10].x)
#define u_size (U[11].x)
#define u_sizing (int(U[12].x))
#define u_thickness (U[13].x)
#define u_borderColor (U[14])
#define u_colorShadow (U[15])
#define u_modelTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))
#define u_backgroundMode (int(U[19].x))

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

vec4 streakCircles(vec2 uv, vec2 outPos, float pixelation, int count, int layerCount, float variability, float shadows,
float randomSeed, float size, int sizing, float thickness, vec4 borderColor, vec4 colorShadow, mat3 modelTransform, int backgroundMode) {
    float ang = PI2/float(count);
    float angInv = float(count)/PI2;
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float N = shadows==0.0 ? 1.0 : 2.0;
    float height = -1.;
    vec4 color;
    
    float lc = float(layerCount);
    float scaleFactor = 1.0;
    float scale = 1.;
    if (sizing==0) scaleFactor = 1.4;
    else if (sizing==1) scaleFactor = 1.25;
    else if (sizing==2) { scaleFactor = 0.8; scale = pow(scaleFactor, -lc); }
    else if (sizing==3) { scaleFactor = 0.714; scale = pow(scaleFactor, -lc); }
    
    if (backgroundMode>=1 && backgroundMode<=2) {
        float a = atan(uv.y, uv.x);
        float ap = a * angInv;
        float a1 = floor(ap)*ang;
        float a2 = a1 + ang;
        float k = fract(ap);
        float dd = length(uv)*2.0*(1.-pixelation);
        vec2 p1 = vec2(cos(a1), sin(a1))*dd;
        vec2 p2 = vec2(cos(a2), sin(a2))*dd;
        if (backgroundMode==2) {
            p1 = tf(modelTransform, p1);
            p2 = tf(modelTransform, p2);
        }
        color = mix(
            __source__(p1),
            __source__(p2),
            k);
    }
    else if (backgroundMode==3) {
        color = borderColor;
    }
    else if (backgroundMode==4) {
        color = colorShadow;
    }
    else {
        color = __source__(uv);
    }
    float shadow = 0.0;
    for(float l = 0.; l<lc; ++l) {
        if (sizing<=3) {
            scale *= scaleFactor;
        }
        else {
            scale *= pow(2., rand2relSeeded(vec2(l), randomSeed).y);
        }
        vec2 v = u*scale;
        vec2 c = floor(v);
        for(float j=-N; j<=N; ++j) {
            for(float i=-N; i<=N; ++i) {
                vec2 id = c + vec2(i, j);
                vec2 heightAndSize = rand2relSeeded(id+1.52, randomSeed+l);
                float h = heightAndSize.x + l*0.5;
                if (h>height) {
                    float radius = (1.-(variability*(heightAndSize.y+.5))) * size;
                    vec2 delta = rand2relSeeded(id, randomSeed+l) * variability;
                    vec2 center = id + 0.5 + delta;
                    vec2 vRel = v-center;
                    float d = length(vRel);
                    if (d<radius) {
                        height = h;
                        shadow = 0.0;
                        
                        float a = atan(vRel.y, vRel.x);
                        float ap = a * angInv;
                        float a1 = floor(ap)*ang;
                        float a2 = a1 + ang;
                        float k = fract(ap);
                        float dd = d*2.0*(1.-pixelation);
                        vec2 p1 = (center + vec2(cos(a1), sin(a1))*dd)/scale;
                        vec2 p2 = (center + vec2(cos(a2), sin(a2))*dd)/scale;
                        color = mix(
                            __source__(tf(modelTransform, p1)),
                            __source__(tf(modelTransform, p2)),
                            k);
                                
                        if (d>radius-thickness*radius) {
                            color = mergeColor(color, borderColor);                                   
                        }
                    }
                    else if (shadows>0.0) {
                        shadow = max(shadow, smoothstep(radius + (shadows*0.5 * (h-height)*3.5), radius, d));
                    }
                }
            }                
        }
    }
    
    return mergeColor(color, mix(color, colorShadow, shadow));
}

void main() {
    fragColor = streakCircles((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_pixelation, u_count, u_layerCount, u_variability, u_shadows, u_randomSeed, u_size, u_sizing, u_thickness, u_borderColor, u_colorShadow, u_modelTransform, u_backgroundMode);
}
