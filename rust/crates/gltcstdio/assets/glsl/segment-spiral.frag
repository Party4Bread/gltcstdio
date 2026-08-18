#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_quadratic (U[7].x)
#define u_exponential (U[8].x)
#define u_count (int(U[9].x))
#define u_step (U[10].x)
#define u_thickness (U[11].x)
#define u_dampening (U[12].x)
#define u_color (U[13])
#define u_color2 (U[14])
#define u_modelTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

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

vec2 polar(float r, float angle) {
    return r * vec2(cos(angle), sin(angle));
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

vec4 segmentSpiral(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float quadratic, float exponential, int count, float step, float thickness, float dampening, vec4 color, vec4 color2, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    vec2 a = vec2(0., 0.);
    vec2 b = a;
    float k = 0.0;
    float scale = length(modelTransform[0].xy);
    float aa = 2.0/(sourceDim.y * scale);
    float th = thickness / scale;
    int maxI = 0;
    if (quadratic==0.0 && exponential==0.0) {
        for(int i=0; i<count; ++i) {
            float theta = step * float(i);
            b = polar(intensity*theta/step, theta);
            float dist = sdSegment(u, a, b);
            float kk = smoothstep(th*0.1 + aa, th*0.1, dist);
            if (kk>k) {
                k = kk;
                maxI = i;
            }
            if (k>=1.0) break;
            a = b;
        }
    }
    else {
        for(int i=0; i<count; ++i) {
            float theta = step * float(i);
            b = polar((intensity*theta + quadratic*theta*theta + exponential*pow(1.1, theta))/step, theta);
            float dist = sdSegment(u, a, b);
            k = max(k, smoothstep(th*0.1 + aa, th*0.1, dist));
            if (k>=1.0) break;
            a = b;
        }
    }
    vec4 inCol = __source__(uv);
    float ki = float(maxI)/float(count-1);
    float kCol = count>2 ? ki : 0.0;
    vec4 mixedCol = vec4(mix(color.rgb, mergeColor(color, color2).rgb, kCol), mix(color.a, color2.a, kCol));
    vec4 mergeCol = mergeColor(inCol, mixedCol);
    if (ki>=1.0-dampening && dampening>0.0) mergeCol.a *= (1.0-ki) / dampening;
    return mergeColor(inCol, vec4(mergeCol.rgb, mergeCol.a*k));
}

void main() {
    fragColor = segmentSpiral((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_quadratic, u_exponential, u_count, u_step, u_thickness, u_dampening, u_color, u_color2, u_modelTransform);
}
