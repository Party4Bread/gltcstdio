#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_count (int(U[6].x))
#define u_randomSeed (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































bool inTriangle( in vec2 p, in vec2 a, in vec2 b, in vec2 c )
{
    vec2 e0 = b-a, e1 = c-b, e2 = a-c;
    vec2 v0 = p -a, v1 = p -b, v2 = p -c;
    float s = sign(e0.x*e2.y - e0.y*e2.x);
    return s*(v0.x*e0.y-v0.y*e0.x)>0.0 
        && s*(v1.x*e1.y-v1.y*e1.x)>0.0 
        && s*(v2.x*e2.y-v2.y*e2.x)>0.0; 
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

vec4 triangleFrosting(vec2 uv, vec2 outPos, float intensity, int count, float randomSeed, mat3 modelTransform) {
    vec4 col = __source__(uv);
    
    float size = 1.;
    float N = float(count);
    
    vec2 v = tf(inverse(modelTransform), uv);
    for(float i=0.; i<N; ++i) {
        vec2 offset = rand2relSeeded(vec2(i*10., i+2.221), randomSeed) - .5;
        vec2 u = (v + 200.*offset)*.5;
        vec2 id = floor(u);
        vec2 center = id + 0.5;
        vec2 rnd = rand2relSeeded(id, randomSeed);
        vec2 rnd2 = rand2relSeeded(vec2(id.x*1.15, id.y*2.55), randomSeed);
        vec2 a = center + size*(rnd);
        vec2 b = center + size*(fract(rnd*10.) - 0.5);
        vec2 c = center + size*(rnd2);

        if (inTriangle(u, a, b, c)) {
            col = mix(col, __source__(tf(modelTransform, 2.*(a+b+c)/3.-200.*offset)), intensity);
        }
    }

    return col;
}

void main() {
    fragColor = triangleFrosting((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_randomSeed, u_modelTransform);
}
