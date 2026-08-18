#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_modelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_shapeAspectRatio (U[8].x)

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















































































































































































































































































































































vec4 pixelateGradient(vec2 pos, vec2 outPos, mat3 modelTransform,
                       float shapeAspectRatio) {
    float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    float scale = 1.0 / resolution;
    float scaleY = sqrt(1.0 / shapeAspectRatio);
    float scaleX = 1.0 / scaleY;
    vec2 scaleV = vec2(scaleX, scaleY) * scale;

    vec2 uu = floor(pos / scaleV + 0.5);
    vec2 du = (pos / scaleV - uu) + 0.5;
    vec2 u = uu * scaleV;

    vec2 delta = vec2(0.4, 0.0);
    vec4 cx1 = __source__(u - delta * scaleV);
    vec4 cx2 = __source__(u + delta * scaleV);
    vec4 cy1 = __source__(u - delta.yx * scaleV);
    vec4 cy2 = __source__(u + delta.yx * scaleV);

    vec4 outCol;
    if (length(cx1 - cx2) > length(cy1 - cy2)) {
        outCol = mix(cx1, cx2, du.x);
    } else {
        outCol = mix(cy1, cy2, du.y);
    }
    return outCol;
}

void main() {
    fragColor = pixelateGradient((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_shapeAspectRatio);
}
