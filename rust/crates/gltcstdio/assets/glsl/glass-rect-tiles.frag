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
#define u_outAspectRatio (U[4].x)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_distortion (U[7].x)
#define u_pixelation (U[8].x)
#define u_highFreqColor (U[9])
#define u_shapeAspectRatio (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 glassRectTiles(vec2 uv, vec2 outPos, float intensity, float distortion, float outAspectRatio, float pixelation, vec4 highFreqColor, float shapeAspectRatio, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    vec2 u = uv;
    vec2 v = tf(t, uv);
    
    vec2 tileDim = vec2(2.*shapeAspectRatio/(1.+shapeAspectRatio), 2./(1.+shapeAspectRatio));
    
    float tileSize = length(modelTransform[0].xy) * max(tileDim.x, tileDim.y);
    float maxTileViewSize = min(outAspectRatio, 1.0);
    float viewSize = mix(tileSize, maxTileViewSize, intensity);
    
    vec2 c = round(v/tileDim) * tileDim;
    vec2 pos = v - c;
    float borderDist = min(tileDim.x*.5-abs(pos.x), tileDim.y*.5-abs(pos.y));
    float distort = max(1.0, distortion/borderDist);

    vec2 center = tf(modelTransform, c) * (tileSize>=maxTileViewSize ? vec2(1.) : (vec2(outAspectRatio, 1.)-viewSize*.5)/(vec2(outAspectRatio, 1.)-tileSize*.5));
    float scale = viewSize/tileSize;
    
    vec4 pixColor = __source__(center);
    vec2 w = center + mat2(modelTransform)*pos*distort*scale;
    vec4 col = __source__(w);
    
    float hf = 0.;
    if (highFreqColor.a>0.) {
        float hfThreshold = 2./highFreqColor.a;
        hf = smoothstep(hfThreshold, hfThreshold*10.0, distort);
    }
    
    return mergeColor(mix(col, pixColor, pixelation), vec4(highFreqColor.rgb, hf));
}

void main() {
    fragColor = glassRectTiles((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_distortion, u_outAspectRatio, u_pixelation, u_highFreqColor, u_shapeAspectRatio, u_modelTransform);
}
