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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_border (U[6].x)
#define u_borderColor (U[7])
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

float borderDistanceRounded(vec2 coord, float ratio, float radius, float thickness) {
    float D = radius+thickness;
    float x1 = (-ratio+D-coord.x)/D;
    float x2 = (coord.x-(ratio-D))/D;
    float y1 = (-1.0+D-coord.y)/D;
    float y2 = (coord.y-(1.0-D))/D;
    float X = max(x1, x2);
    float Y = max(y1, y2);
    if (X>0.0 && Y>0.0) {
        return length(vec2(X, Y)) - radius/(radius+thickness);
    }
    else {
        return max(X, Y) - radius/(radius+thickness);
    }
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

vec2 interpolatedRand2Seeded(vec2 v, float seed) {
    float sfractY = smoothstep(0.0, 1.0, fract(v.y));
    return mix(
        mix(rand2relSeeded(floor(v), seed), rand2relSeeded(vec2(floor(v.x), ceil(v.y)), seed), sfractY),
        mix(rand2relSeeded(vec2(ceil(v.x), floor(v.y)), seed), rand2relSeeded(ceil(v), seed), sfractY),
        smoothstep(0.0, 1.0, fract(v.x)) );
}

float sinewaves(vec2 coord, float angle, float r, float baseAmp, float varAmp, float baseThickness, float varThickness, float size, float variability, float randomSeed) {
    float scale = size + 15.0;
    vec2 base = floor(vec2(r*scale, r*scale));
    float seed = randomSeed;
    //int N = 8;
    //int(ceil(k*0.01+baseRadius*varRadius));
    //for(int j = -N; j <= N; ++j) {
    //    vec2 center = vec2(0.0, float(j)) + base;
    float value = 0.0;
    for(int j = -2; j <= int(scale)+2; ++j) {
        vec2 center = vec2(0.0, float(j));
        vec2 delta = rand2relSeeded(center, seed);
        center += variability*100.0 * vec2(6.0, 2.0)/scale*delta;
        float amp = (varAmp*delta.x + 1.0)*baseAmp;
        float thickness = (varThickness*delta.y + 1.0)*baseThickness;
        float rr = center.y + amp*sin(center.x + angle*10.0);
        float d = abs(r*scale-rr)/(30.0*thickness);
        if (d<1.0) {
            float k = 0.8;
            if (d<k) {
                return 1.0;
            }
            else {
                value = max(value, (1.0-d)/(1.0-k));//smoothstep(k, 1.0, d);
            }
        }
    }
    return value;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 weaveBorder(vec2 pos, vec2 outPos, float border, vec2 sourceDim, vec2 outDim, vec4 borderColor, float variability, float randomSeed, mat3 modelTransform) {
    float ratio = outDim.x / outDim.y;
    vec2 v = tf(inverse(modelTransform), pos);
    
    float bRel = border*2.0; // hack to try to match size of image to border but it's approximate 
    
    float B = borderDistanceRounded(outPos, ratio, bRel, bRel) + variability * 0.08*interpolatedRand2Seeded(pos*10.0, randomSeed).x;
    if (B<=0.0) return __source__(v);

    float angle = atan(outPos.y, outPos.x);
    float k = 1.0 - sinewaves(pos, angle, B, 2.0, 1.0, 0.1*(B<0.0?0.0:pow(B, 0.7)), 0.5, 20.0, variability, randomSeed);
//    float k = 1.0 - sinewaves(pos, angle, pos.x, 2.0, 1.0, 0.5, 0.5);

    if (k==0.0) return borderColor;
    return mix(borderColor, __source__(v), k);
}

void main() {
    fragColor = weaveBorder((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_border, u_sourceDim, u_outDim, u_borderColor, u_variability, u_randomSeed, u_modelTransform);
}
