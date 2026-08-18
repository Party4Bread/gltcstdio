#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_ditheringPattern;
layout(binding = 3) uniform texture2D t_palette;
layout(binding = 4) uniform texture2D t_source;

#define u_ditheringPattern sampler2D(t_ditheringPattern, samp)
#define u_palette sampler2D(t_palette, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_paletteDim (U[4].xy)
#define u_ditheringPatternDim (U[5].xy)
#define u_pixelAspectRatio (U[6].x)
#define u_outDim (U[7].xy)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_dithering (U[11].x)

#define __ditheringPattern__texelFetch__(c) texelFetch(u_ditheringPattern, (c), 0)
#define __ditheringPattern__(p) texture(u_ditheringPattern, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __palette__texelFetch__(c) texelFetch(u_palette, (c), 0)
#define __palette__(p) texture(u_palette, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
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

vec4 pixelate(vec2 uv, vec2 outPos, mat3 modelTransform, float dithering, vec2 paletteDim, vec2 ditheringPatternDim, float pixelAspectRatio) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    vec2 pixDim = pixelAspectRatio>=1.0 ? vec2(pixelAspectRatio, 1.0) : vec2(1.0, 1.0/pixelAspectRatio);
    vec2 iPos = round(u/pixDim);
    vec2 pix = iPos * pixDim; //floor(u+0.5);
    vec2 v = (modelTransform * vec3(pix.xy, 1.0)).xy;
    vec4 col = __source__(v);
    
    // dithering
    if (dithering!=0.0) {
        ivec2 dPos = ivec2(int(mod(iPos.x, ditheringPatternDim.x)), int(mod(iPos.y, ditheringPatternDim.y)));
        vec4 patternCol = __ditheringPattern__texelFetch__(dPos);
        col.rgb += dithering * (patternCol.rgb - .5);
    }
    
    int n = int(paletteDim.x);
    float minDist = 1e9;
    vec4 bestColor = col;

    for(int i=0; i<n; ++i) {
        vec4 target = __palette__texelFetch__(ivec2(i, 0));

        float dist = length((col-target).rgb);
        if (dist < minDist) {
            minDist = dist;
            bestColor = target;
        }
    }
    
    return bestColor;

}

void main() {
    fragColor = pixelate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_dithering, u_paletteDim, u_ditheringPatternDim, u_pixelAspectRatio);
}
