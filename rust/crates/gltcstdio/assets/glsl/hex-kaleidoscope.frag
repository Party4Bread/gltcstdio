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
#define u_mode (int(U[5].x))
#define u_spikeCount (int(U[6].x))
#define u_offset (U[7].x)
#define u_shadows (U[8].x)
#define u_colorShadow (U[9])
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_shadowTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

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

vec4 hexPolarCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    float x = atan(hv.y, hv.x);
    float y = length(hv);
    vec2 id = v-hv;
    return vec4(x, y, id);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 hexKaleidoscope(vec2 uv, vec2 outPos, int mode, int spikeCount, float offset, float shadows, vec4 colorShadow, mat3 modelTransform, mat3 viewTransform, mat3 shadowTransform) {
    vec2 u = uv;
    vec4 hex = hexPolarCoords(u);
    float a = hex.x;
    float anglePeriod = PI2 / float(spikeCount);
    a = mod(a, anglePeriod);
    if (mode==0) a = a>anglePeriod/2.0 ? anglePeriod - a : a;
    vec2 dv = offset * u;
    //vec2 dv = (offsetTransform * vec3(u, 1.0)).xy;
    vec2 w = hex.y*vec2(cos(a), sin(a));
    vec2 v = (inverse(modelTransform) * vec3(w + dv, 1.0)).xy;
    
    vec4 col = __source__(v);
    if (shadows>0.0) {
        vec2 hex2 = tf(inverse(shadowTransform), hex.y*vec2(cos(hex.x), sin(hex.x)));
        float kShadow = smoothstep(-0.15+shadows, -0.15, (0.5-length(hex2))*2.0) * colorShadow.a;
        col.rgb = mix(col.rgb, colorShadow.rgb, kShadow);
    }
    
    return col;
}

void main() {
    fragColor = hexKaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_spikeCount, u_offset, u_shadows, u_colorShadow, u_modelTransform, u_viewTransform, u_shadowTransform);
}
