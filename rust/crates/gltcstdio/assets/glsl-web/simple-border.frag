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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_border (U[6].x)
#define u_shadows (U[7].x)
#define u_colorOut (U[8])
#define u_colorShadow (U[9])
#define u_shadowTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 simpleBorder(vec2 uv, vec2 outPos, float border, vec2 sourceDim, float shadows, vec2 outDim, vec4 colorOut, vec4 colorShadow, mat3 viewTransform, mat3 shadowTransform, mat3 modelTransform) {
    float ratio = sourceDim.x/sourceDim.y;
    float borderSize = border * 2. * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 threshold = vec2(outDim.x/outDim.y * ratio/newBounds.x, 1./newBounds.y);
    vec2 u = uv;
    float d = sdRectangle(u, threshold);
    bool inside = d<0.0; //abs(u.x)<=threshold.x && abs(u.y)<=threshold.y;
    float shadow = 0.0;
    
    vec2 v = tf(inverse(modelTransform), uv);
    if (inside) {
        if (shadows<0.0) {
            vec2 v = tf(inverse(shadowTransform), u);
            d = sdRectangle(v, threshold);
            shadow = smoothstep(shadows, 0., d); // d is shadow d here
        }
    }
    else {
        if (shadows>0.0) {
            vec2 v = tf(inverse(shadowTransform), u);
            d = sdRectangle(v, threshold);
            shadow = smoothstep(shadows, 0., d); // d is shadow d here
        }
    }
    
    vec4 outCol = inside ? __source__(v) : mergeColor(__source__(v), colorOut);
    return mix(outCol, mergeColor(outCol, colorShadow), shadow);
}

void main() {
    fragColor = simpleBorder((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_border, u_sourceDim, u_shadows, u_outDim, u_colorOut, u_colorShadow, u_viewTransform, u_shadowTransform, u_modelTransform);
}
