#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_intensity (U[7].x)
#define u_balance (U[8].x)
#define u_border (U[9].x)
#define u_borderColor (U[10])
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_variability (U[14].x)
#define u_randomSeed (U[15].x)
#define u_placementTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))
#define u_placementStyle (U[19].x)
#define u_placementFeather (U[20].x)

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

mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}

vec2 f2(vec2 u, vec2 split, int N, float intensity, float balance, float variability, float randomSeed) {
    float r = 0.0;
    vec2 origU = u;
    for(int i=0; i<N; ++i) {
        
        vec2 scale;
        vec2 center;
        if (u.x>split.x && u.y>split.y) {
            scale = 2.0/vec2(1.0-split.x, 1.0-split.y);
            center = vec2(1.0+split.x, 1.0+split.y)/2.0;
            r += 0.25 * pow(0.5, float(i));
        }
        else if (u.x<=split.x && u.y>split.y) {
            scale = 2.0/vec2(1.0+split.x, 1.0-split.y);
            center = vec2(-1.0+split.x, 1.0+split.y)/2.0;
            r += 0.5 * pow(0.5, float(i));
        }
        else if (u.x>split.x) {
            scale = 2.0/vec2(1.0-split.x, 1.0+split.y);
            center = vec2(1.0+split.x, -1.0+split.y)/2.0;
            r += 0.75 * pow(0.5, float(i));
        }
        else {
            scale = 2.0/vec2(1.0+split.x, 1.0+split.y);
            center = vec2(-1.0+split.x, -1.0+split.y)/2.0;
            r += 1.0 * pow(0.5, float(i));
        }
        
        vec2 rnd = rand2relSeeded(vec2(r ,r), randomSeed);
        float rndx = (rnd.x + 0.5)*variability;
        if (rndx<0.1) u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        else if (rndx<0.2) {
            center = vec2(0.);
            u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        else if (rndx<0.3) u = -(mix(vec2(0.), center, intensity) + (u-center)*scale);
        else if (rndx<0.4) { 
            u = mix(vec2(0.), center, intensity) + (u-center)*scale;
            u = rotation2(0.3) * u;
        }
        else if (rndx<0.5) u = origU;
        else if (rndx<0.6) { 
            u = u = -u;
        }
        else if (rndx<0.7) {
            scale *= 0.5;
            u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        else if (rndx<0.8) {
            u.x = 0.0;
        }
        else if (rndx<0.9) {
            u.y = 0.0;
        }
        else {
            if (i<2) u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        
//        u = u*scale - center*scale;
        //u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        split = mix(split, center, balance);
    }
    return u;
}

float getPlacement(vec2 u, float style, float randomSeed) {
    if (style==0.0) return 1.;
    float s = abs(style);
    float d;
    if (s<0.1) {
        d = length(u) * s / 0.1;
    }
    else if (s<0.5) {
        float p = mix(2., 50., (s-0.1)/0.4);
        d = pow(pow(abs(u.x), p) + pow(abs(u.y), p), 1./p);
    }
    else {
        float k = (s-0.5)*2.;
//        u += k * rand2relSeeded(floor(u*(1.+k*5.)), randomSeed);
        u += k * rand2relSeeded(floor(u*2.), randomSeed);
        if (k>0.33) u += k*.5 * rand2relSeeded(floor(u*4.), randomSeed);
        if (k>0.66) u += k*.25 * rand2relSeeded(floor(u*8.), randomSeed);
        d = max(abs(u.x), abs(u.y));
    }
    return (1.0-d) * sign(style);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 division(vec2 pos, vec2 outPos, int count, float intensity, float balance, float border, vec4 borderColor, vec2 sourceDim, mat3 modelTransform, float variability, float randomSeed, mat3 placementTransform, float placementStyle, float placementFeather) {
            vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
//            vec2 u = (inverse(modelTransform) * vec3(0.0, 0.0, 1.0)).xy;
//            vec2 u = mix((inverse(modelTransform) * vec3(pos, 1.0)).xy, (inverse(modelTransform) * vec3(0.0, 0.0, 1.0)).xy, intensity);
            vec2 split = fract(u)*2.0-1.0;
            float ratio = sourceDim.x/sourceDim.y;
            vec2 vRatio = vec2(ratio, 1.0);
            
            vec2 v = f2(pos/vRatio, split, count, intensity, balance, variability, randomSeed)*vRatio;
            
            float p = getPlacement(tf(inverse(placementTransform), pos), placementStyle, randomSeed);
            v = mix(pos, v, smoothstep(-0.001, placementFeather, p));
            
            vec4 outColor = __source__(v);
            
            float edgeDist = abs(min(1.0-abs(v.y), ratio-abs(v.x)));
            if (edgeDist<border) outColor = mergeColor(outColor, borderColor);
                      
            return outColor;
        }

void main() {
    fragColor = division((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_intensity, u_balance, u_border, u_borderColor, u_sourceDim, u_modelTransform, u_variability, u_randomSeed, u_placementTransform, u_placementStyle, u_placementFeather);
}
