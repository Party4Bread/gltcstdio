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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_border (U[6].x)
#define u_borderColor (U[7])
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_borderTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

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

float borderDistance(vec2 coord, float ratio, float M, float border) {
    if (border==0.0) return 0.0;
	return max(max((-ratio+border-coord.x)/border, (coord.x-(ratio-border))/border),
                  max((-1.0+border-coord.y)/border, (coord.y-(1.0-border))/border) );
}

vec2 hash22(vec2 u) {
    return vec2(
        fract(sin(u.x*776.45+u.y*453.24)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24)*88.77) );
}

float hatch(vec2 u, float intensity, float freq, float size) {
    vec2 b = floor(u+0.5);
    float N = floor(size+abs(intensity));
    float l = 0.0;
    for(float j=b.y-N; j<=b.y+N; ++j) {
        for(float i=b.x-N; i<=b.x+N; ++i) {
            vec2 id = vec2(i, j);
            vec2 dd = (hash22(id)-0.5);
            vec2 c = id + intensity * dd;
            float d = length(u-c);
            if (d<size) {
                vec2 dir = normalize(dd);
                float falloff = smoothstep(2.0, 1.0, d);
                l = max(l, falloff * (sin(dot(dir, u-c)*freq)*.5+.5));
            }
        }        
    }
    return l;
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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 crossHatchBorder(vec2 pos, vec2 outPos, float border, vec2 sourceDim, vec2 outDim, vec4 borderColor, float variability, float randomSeed, mat3 modelTransform, mat3 borderTransform) {
    float ratio = outDim.x / outDim.y;
    vec2 v = tf(inverse(modelTransform), pos);
    
    float bRel = border*2.0; // hack to try to match size of image to border but it's approximate 
    
    float B = borderDistance(outPos, ratio, 0.1, border) + variability*100.0 * 0.08*interpolatedRand2Seeded(pos*2.0, randomSeed).x;
    if (B<=0.0) return __source__(v);

    float freq = 100.0;
    vec2 u = (inverse(borderTransform) * vec3(pos, 1.0)).xy;
    float k = smoothstep(B-0.01, B, 1.0-hatch(u, 0.2, freq, 2.0));

    if (k==0.0) return borderColor;
    return mix(borderColor, __source__(v), k);
}

void main() {
    fragColor = crossHatchBorder((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_border, u_sourceDim, u_outDim, u_borderColor, u_variability, u_randomSeed, u_modelTransform, u_borderTransform);
}
