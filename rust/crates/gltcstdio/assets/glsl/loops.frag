#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_layerCount (int(U[7].x))
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_color (U[11])
#define u_colorVariability (U[12].x)
#define u_glow (U[13].x)
#define u_neon (U[14].x)
#define u_thickness (U[15].x)
#define u_offset (U[16].x)
#define u_randomSeed (U[17].x)
#define u_variability (U[18].x)

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


















































































































































































































































































































































vec4 hexCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    vec2 id = v-hv;
    return vec4(hv, id);
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

vec4 layer(vec2 uv, vec4 col, int count, float offset, float thickness, float glow, float neon, float randomSeed, float variability, float colorVariability, vec4 color) {
    //vec4 col = vec4(0., 0., 0., 1.);
    
    float D = offset;
    float T = thickness*0.1;
    float MAXR = 1.5;
    vec4 hex = hexCoords(uv);
    vec2 id = floor(hex.zw*100.+.5);
    uv = hex.xy * 15.;
    vec2 relCenter = (rand2relSeeded(id, randomSeed)) * 6.;
    float radius = (MAXR-D) - 0.5*fract((relCenter.x+relCenter.y)*11.);
    for(int i=0; i<count; ++i) {
        float k = float(i);
        vec2 rnd = rand2relSeeded(id+k, randomSeed);
        vec2 c = relCenter + D * rnd;
        float d = abs(length(uv-c)-radius);
        float alpha = 0.;
        if (d<T) alpha = 1.;
        else if (glow>0.0) alpha = smoothstep(T*(10.*glow), T*(5.*glow), d) *  T/d * .75;
        
//        vec3 colLoop = mix(color, vec3(rnd+.5, fract(rnd.x*4.434+rnd.y*7.565)), colorVariability);
        vec3 colLoop = color.rgb + vec3(rnd, fract(rnd.x*4.434+rnd.y*7.565)-.5)*colorVariability;
        if (alpha>0.) col = mergeColor(col, vec4(colLoop+neon, alpha));
    }
    return col;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 loops(vec2 uv, vec2 outPos, int count, int layerCount, mat3 modelTransform, vec4 color, float colorVariability, float glow, float neon, float thickness, float offset, float randomSeed, float variability, int source_specified) {
    mat3 inverseModelTransform = inverse(modelTransform);
        
    vec4 bkg = vec4(0., 0., 0., 1.);
    if (source_specified==1) {
        bkg = __source__(outPos);
    }
    vec4 col = bkg;
    
    for(int i=0; i<layerCount; ++i) {        
        col = layer(uv, col, count, offset, thickness, glow, neon, randomSeed, variability, colorVariability, color);
        uv = tf(inverseModelTransform, uv);
    }
    
    return col;
}

void main() {
    fragColor = loops((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_layerCount, u_modelTransform, u_color, u_colorVariability, u_glow, u_neon, u_thickness, u_offset, u_randomSeed, u_variability, u_source_specified);
}
