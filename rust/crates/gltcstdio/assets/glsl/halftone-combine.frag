#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_pattern;
layout(binding = 3) uniform texture2D t_source;

#define u_pattern sampler2D(t_pattern, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_smoothen (U[5].x)
#define u_intensity (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_color1 (U[10])
#define u_color2 (U[11])

#define __pattern__texelFetch__(c) texelFetch(u_pattern, (c), 0)
#define __pattern__(p) texture(u_pattern, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
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















































































































































































































































































































































float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 halftoneCombine(vec2 uv, vec2 outPos, float smoothen, float intensity, mat3 modelTransform, vec4 color1, vec4 color2) {
    float threshold = luma(__pattern__(tf(inverse(modelTransform), uv)).rgb);
    
    vec2 samplePos = uv;
    
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
    
    return mix(color2, color1, k);
}

void main() {
    fragColor = halftoneCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_smoothen, u_intensity, u_modelTransform, u_color1, u_color2);
}
