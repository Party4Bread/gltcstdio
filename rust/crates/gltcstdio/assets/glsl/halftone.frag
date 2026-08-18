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
#define u_smoothen (U[5].x)
#define u_intensity (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_color1 (U[10])
#define u_color2 (U[11])
#define u_sampling (int(U[12].x))
#define u_style (int(U[13].x))

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

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec3 patternConcentricLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    float d = round(length(u));
    vec2 center = d * normalize(u);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternDots(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = round(u);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec4 hexCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    vec2 id = v-hv;
    return vec4(hv, id);
}

vec3 patternHexDots(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec4 hex = hexCoords(u);
    float threshold = length(hex.xy)*2.0;
    return vec3(hex.zw, threshold);
}

vec3 patternLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = vec2(u.x, round(u.y));
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternWavyLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = vec2(u.x, round(u.y - sin(u.x*0.5)*2.0) + sin(u.x*0.5)*1.5);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec4 halftone(vec2 uv, vec2 outPos, float smoothen, float intensity, mat3 modelTransform, vec4 color1, vec4 color2, int sampling, int style) {
    vec3 pattern;
    { int _sw_sel = int(style);
if (_sw_sel == int(0)) { pattern = patternDots(inverse(modelTransform), uv); }
else if (_sw_sel == int(1)) { pattern = patternHexDots(inverse(modelTransform), uv); }
else if (_sw_sel == int(2)) { pattern = patternLines(inverse(modelTransform), uv); }
else if (_sw_sel == int(3)) { pattern = patternConcentricLines(inverse(modelTransform), uv); }
else if (_sw_sel == int(4)) { pattern = patternWavyLines(inverse(modelTransform), uv); }
}
    
    float threshold = pattern.z * intensity;
    
    vec2 samplePos;
    
    { int _sw_sel = int(sampling);
if (_sw_sel == int(0)) { samplePos = tf(modelTransform, pattern.xy); }
else { samplePos = uv; }
}
    
    vec4 color = vec4(0.0);
    if (smoothen>0.0) {
        int N = 5;
        float r = length(modelTransform[0].xy) * smoothen * 3.0;
        float step = r/float(N);
        for(int j=-N; j<=N; ++j) {
            for(int i=-N; i<=N; ++i) {
                color += __source__(samplePos + vec2(float(i), float(j)) * step);
            }
        }
        color /= float((2*N+1)*(2*N+1));
    }
    else {
        color = __source__(samplePos);
    }
    
    float k = luma(color.rgb)>threshold ? 1.0 : 0.0;
    
    vec4 outColor = mix(color2, color1, k);
    //vec4 bkgColor = __source__(uv);
    return mergeColor(color, outColor);
}

void main() {
    fragColor = halftone((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_smoothen, u_intensity, u_modelTransform, u_color1, u_color2, u_sampling, u_style);
}
