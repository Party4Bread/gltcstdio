#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_randomSeed (U[6].x)
#define u_len (U[7].x)
#define u_thickness (U[8].x)
#define u_color (U[9])
#define u_glow (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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

float response(float d, float glow) {
    float base = (glow<0.2) ? 1.0 : 1.0+(glow-0.2)*4.;
    return base * (d<=0.0 ? 1.0 : min(1.0, glow*0.01/d)) * smoothstep(2.0, 1.2, d);
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec4 spilloverChannels(vec4 c) {
    float overflow = (max(c.r-1.0, 0.0) + max(c.g-1.0, 0.0) + max(c.b-1.0, 0.0)) / 3.0;
    c.r += overflow;
    c.g += overflow;
    c.b += overflow;
    return c;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 barcode(vec2 uv, vec2 outPos, int count, float randomSeed, float len, float thickness, vec4 color, float glow, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);

    vec2 rnd = rand2relSeeded(vec2(10.0, 10.0), randomSeed);
    vec2 rnd2 = rand2relSeeded(vec2(11.0, -5.5), randomSeed);
    float code1 = floor((rnd2.x+0.5)*256.0 + (rnd.x+0.5)*65536.0);
    float code2 = floor((rnd2.y+0.5)*256.0 + (rnd.y+0.5)*65536.0);

    float k = 0.0;
    float N = float(count);
    float unit = thickness/(3.0*N);
    float code = code1;
    for(float i=0.0; i<N; ++i) {
        float width = mod(code, 2.0)+1.0;
        code = floor(code/2.0);
        if (code==0.0) code = code2;
        float d = sdRectangle(u-vec2((i/(N-1.0)-0.5)*len, 0.0), vec2(width*unit*0.5, 0.5));
        k += response(d, glow);
    }

    vec4 bkgCol = __source__(uv);
    // k overshoots 1 in the glow bloom; the excess is a brightness multiplier, min(1,k) is coverage.
    vec4 glowCol = spilloverChannels(vec4(color.rgb*max(1.0, k), color.a));
    vec4 outCol = mergeColor(bkgCol, vec4(glowCol.rgb, glowCol.a*min(1.0, k)));

    return outCol;
}

void main() {
    fragColor = barcode((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_randomSeed, u_len, u_thickness, u_color, u_glow, u_modelTransform);
}
