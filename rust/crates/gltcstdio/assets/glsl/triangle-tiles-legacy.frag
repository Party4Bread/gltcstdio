#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_distortion (U[6].x)
#define u_pixelation (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

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

vec4 triangleTilesLegacy(vec2 pos, vec2 outPos, float intensity, float distortion, float pixelation, mat3 modelTransform) {
    mat3 invMT = inverse(modelTransform);
    vec2 u = (invMT * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;
    float halfTileWidth = 1.0;
    float tileHeight = 2.0 * SQRT3_2;
    float centerHeight = tileWidth / (2.0 * SQRT3);

    vec2 tileSize = vec2(
        length(vec2(modelTransform[0][0], modelTransform[1][0])) * tileWidth,
        length(vec2(modelTransform[0][1], modelTransform[1][1])) * tileHeight
    );

    float s = 1.0 + intensity * 0.01 * (max(2.0 / tileSize.x, 2.0 / tileSize.y) - 1.0);

    float row = floor(u.y / tileHeight);
    float column = floor(u.x / halfTileWidth);
    float dx0 = u.x - column * halfTileWidth;
    float dy0 = u.y - row * tileHeight;

    bool rectDown = mod(row + column, 2.0) == 0.0;
    float cx, cy;
    bool down;
    if (rectDown) {
        if (dy0 > tileHeight - dx0 * SQRT3) {
            cy = (row + 1.0) * tileHeight - centerHeight;
            cx = (column + 1.0) * halfTileWidth;
            down = true;
        } else {
            cy = row * tileHeight + centerHeight;
            cx = column * halfTileWidth;
            down = false;
        }
    } else {
        if (dy0 > dx0 * SQRT3) {
            cy = (row + 1.0) * tileHeight - centerHeight;
            cx = column * halfTileWidth;
            down = true;
        } else {
            cy = row * tileHeight + centerHeight;
            cx = (column + 1.0) * halfTileWidth;
            down = false;
        }
    }

    vec2 tileCenter = vec2(cx, cy);
    vec2 v = u - tileCenter;
    vec2 p = (modelTransform * vec3(v * s + tileCenter, 1.0)).xy;

    if (distortion > 0.0) {
        float ori = down ? -1.0 : 1.0;
        float d = distortion * 0.01;
        float dx = -v.x / centerHeight;
        float dy = -v.y / centerHeight;
        float scaleK = 2.0 / sqrt(invMT[0][0] * invMT[0][0] + invMT[0][1] * invMT[0][1]);
        float r0 = ori * dy;
        if (1.0 - r0 < d) {
            r0 = (1.0 - r0) / d;
            p.y += ori * tileWidth * (1.0 - r0) / (0.5 + r0) * scaleK;
        }
        float r1 = -dx * SQRT3_2 - ori * dy * 0.5;
        if (1.0 - r1 < d) {
            r1 = (1.0 - r1) / d;
            float dp = tileWidth * (1.0 - r1) / (0.5 + r1) * scaleK;
            p.x += -SQRT3_2 * dp;
            p.y += -ori * 0.5 * dp;
        }
        float r2 = dx * SQRT3_2 - ori * dy * 0.5;
        if (1.0 - r2 < d) {
            r2 = (1.0 - r2) / d;
            float dp = tileWidth * (1.0 - r2) / (0.5 + r2) * scaleK;
            p.x += SQRT3_2 * dp;
            p.y += -ori * 0.5 * dp;
        }
    }

    vec4 outColor = __source__(p);
    if (pixelation != 0.0) {
        vec2 tileCenterTex = (modelTransform * vec3(tileCenter, 1.0)).xy;
        vec4 pixelColor = __source__(tileCenterTex);
        outColor = mix(outColor, pixelColor, pixelation);
    }
    return outColor;
}

void main() {
    fragColor = triangleTilesLegacy((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_distortion, u_pixelation, u_modelTransform);
}
