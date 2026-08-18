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
#define u_type (U[6].x)
#define u_octaves (int(U[7].x))
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

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

float perlinOctaveNoise(vec2 uv, int n) {
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
    
    float k = 1.;
    float x = 0.;
    float total = 0.;
    
    for(int i=0; i<n; ++i) {
        x += k * perlinNoise(uv);
        total += k;
        k *= 0.5;
        uv = transform * uv;
    }
    
    x /= total;  
    return x;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 grain(vec2 pos, vec2 outPos, float intensity, float type, int octaves, mat3 modelTransform) {
    vec4 col = __source__(pos);
    
    vec2 u = tf(inverse(modelTransform), pos) * 300.0;
    float pn = 2.0 * (perlinOctaveNoise(u, octaves) - 0.5);
    
    float additive = type * intensity * 4.0;
    float multiplicative = (1. - type) * intensity * 4.0;            
    
    col.rgb += additive * pn;
    col.rgb *= 1.0 + multiplicative * pn;
    
    return col;
}

void main() {
    fragColor = grain((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_type, u_octaves, u_modelTransform);
}
