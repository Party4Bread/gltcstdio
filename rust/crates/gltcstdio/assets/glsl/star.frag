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
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_intensity (U[6].x)
#define u_blend (U[7].x)
#define u_center (U[8].x)
#define u_secondary (U[9].x)
#define u_thickness (U[10].x)
#define u_randomSeed (U[11].x)
#define u_color (U[12])
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

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















































































































































































































































































































































float starFlare(vec2 uv, float pixel) {
    uv = abs(uv);
    float spike = uv.y>uv.x ? (log(max((uv.x+pixel), 0.001))-log(max((uv.x-pixel), 0.001))) / uv.y
            : (log(max((uv.y+pixel), 0.001))-log(max((uv.y-pixel), 0.001))) / uv.x;
    return spike;
}

float star(vec2 uv, float pixel, float center, float flare1, float flare2) {
    mat2 rot45 = mat2(SQRT2_2, SQRT2_2, -SQRT2_2, SQRT2_2);
    return center/pow(length(uv), 2.) + flare1*starFlare(uv, pixel) + flare2*starFlare(rot45*uv, pixel);
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

vec4 star(vec2 uv, vec2 outPos, int count, float intensity, float blend, float center, float secondary, float thickness, float randomSeed, vec4 color, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float lum = intensity * star(u, thickness*0.2, center, 1., secondary);
    
    for(int i=1; i<count; ++i) {
        vec2 delta = rand2relSeeded(vec2(float(i)), randomSeed) * (30.0+float(i)*2.0);
        lum += intensity * fract(delta.x*4.0+delta.y*3.0) * star(u+delta, thickness*0.2, center, 1., secondary);
    }       
    
    
    vec4 col = vec4(lum*vec3(color), color.a);           
    vec4 bkgCol = __source__(uv);
    float k1 = blend;
    float k2 = 1.-blend;
    vec4 outCol = mix(bkgCol, bkgCol+col, k2+k1*min(lum*k2*10., 1.));
    return outCol;
}

void main() {
    fragColor = star((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_intensity, u_blend, u_center, u_secondary, u_thickness, u_randomSeed, u_color, u_modelTransform);
}
