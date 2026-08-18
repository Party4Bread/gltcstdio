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
#define u_variability (U[5].x)
#define u_randomSeed (U[6].x)
#define u_count (int(U[7].x))
#define u_step (U[8].x)
#define u_thickness (U[9].x)
#define u_color (U[10])
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))
#define u_outerTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_innerTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))

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

vec2 getPoint(float x, float y, float variability, float seed) {
    vec2 u = vec2(x, y);
    return u + variability * 4.0 * rand2relSeeded(u, seed);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 squareSegments(vec2 uv, vec2 outPos, float variability, float randomSeed, int count, float step, float thickness, vec4 color, mat3 modelTransform, mat3 outerTransform, mat3 innerTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    vec2 a = vec2(0., 0.);
    vec2 b = a;
    float k = 0.0;
    float th = thickness / length(modelTransform[0].xy);
    
    vec2 o11 = tf(outerTransform, getPoint(-1.0, -1.0, variability, randomSeed));
    vec2 o21 = tf(outerTransform, getPoint(1.0, -1.0, variability, randomSeed));
    vec2 o12 = tf(outerTransform, getPoint(-1.0, 1.0, variability, randomSeed));
    vec2 o22 = tf(outerTransform, getPoint(1.0, 1.0, variability, randomSeed));
    
    vec2 i11 = tf(innerTransform, getPoint(-1.0, -1.0, variability, randomSeed));
    vec2 i21 = tf(innerTransform, getPoint(1.0, -1.0, variability, randomSeed));
    vec2 i12 = tf(innerTransform, getPoint(-1.0, 1.0, variability, randomSeed));
    vec2 i22 = tf(innerTransform, getPoint(1.0, 1.0, variability, randomSeed));
    
    for(int i=0; i<count; ++i) {
        float l = float(i)/float(count);
        
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o11, o21, l), mix(i11, i21, l))));
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o21, o22, l), mix(i21, i22, l))));
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o22, o12, l), mix(i22, i12, l))));
        k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, mix(o12, o11, l), mix(i12, i11, l))));
        if (k>=1.0) break;
        a = b;
    }
    vec4 inCol = __source__(uv);
    vec4 mergeCol = mergeColor(inCol, color);
    return mix(inCol, mergeCol, k);
}

void main() {
    fragColor = squareSegments((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_variability, u_randomSeed, u_count, u_step, u_thickness, u_color, u_modelTransform, u_outerTransform, u_innerTransform);
}
