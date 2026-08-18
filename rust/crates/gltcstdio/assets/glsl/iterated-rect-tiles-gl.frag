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
#define u_outDim (U[4].xy)
#define u_InverseModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_ModelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_intensity (U[11].x)
#define u_iterations (int(U[12].x))
#define u_shapeAspectRatio (U[13].x)
#define u_distortion (U[14].x)
#define u_pixelation (U[15].x)
#define u_modelTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

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















































































































































































































































































































































vec4 iteratedRectTilesGL(vec2 pos, vec2 outPos, float intensity, int iterations, float shapeAspectRatio, float distortion, float pixelation, mat3 modelTransform) {
    // Pap's RectTiles shader (unlike IteratedRipples) applies the
    // forward `u_ModelTransform` to enter tile space and uses the
    // inverse only as the back-transform for sampling. pap2mp's
    // `modelTransform` parameter is the user-visible forward matrix
    // (Pap MODEL_SCALE=5 → pap2mp scale(5.0)); the shader inverts
    // internally for the sampling step.
    mat3 invM = inverse(modelTransform);

    // Pap: u = u_ModelTransform * pos  (forward).
    vec2 u = (modelTransform * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;
    float tileHeight = 2.0 * shapeAspectRatio;

    // Pap: tileSize = length(u_InverseModelTransform[0/1][0]) * tile*.
    //   → in pap2mp our invM is exactly Pap's u_InverseModelTransform.
    vec2 tileSize = vec2(length(vec2(invM[0][0], invM[1][0])) * tileWidth,
                         length(vec2(invM[0][1], invM[1][1])) * tileHeight);

    // Pap: intensity_local = u_Intensity * 0.1   (u_Intensity in -100..100)
    //   then s = 1 + intensity_local*0.01 * locusStrength * (max(...) - 1)
    // pap2mp intensity in -1..1 (= u_Intensity/100), so the combined
    // factor becomes `intensity * 0.1` (= u_Intensity * 0.001).
    // locusStrength = 1.0 here — external `.withLocusHandling()` wrap
    // applies the mask blend after this shader returns.
    float locusStrength = 1.0;
    float intEff = intensity * 0.1;
    float s = 1.0 + intEff * locusStrength * (max(2.0 / tileSize.x, 2.0 / tileSize.y) - 1.0);

    vec2 tileCenter = vec2(0.0, 0.0);
    vec2 p = vec2(0.0, 0.0);

    for (int i = 0; i < iterations; ++i) {
        float row = floor(u.y / tileHeight);
        float column = floor(u.x / tileWidth);

        tileCenter = vec2((column + 0.5) * tileWidth, (row + 0.5) * tileHeight);

        vec2 v = u - tileCenter;

        // Pap: p = u_InverseModelTransform * vec3(v*s + tileCenter, 1.0).
        p = (invM * vec3(v * s + tileCenter, 1.0)).xy;

        vec2 r;
        bool borderX = false;
        bool borderY = false;
        if (distortion > 0.0) {
            // Pap: d = u_Distortion * 0.01 (u_Distortion 0..100)
            //   → with distortion in 0..1: d = distortion.
            float d = distortion;
            r = v / vec2(tileWidth, tileHeight) + vec2(0.5, 0.5);

            if (r.x < d / 2.0) {
                r.x = 2.0 * r.x / d;
                borderX = true;
                p.x -= tileSize.x * (1.0 - r.x) / (0.5 + r.x);
            } else if (r.x > 1.0 - d / 2.0) {
                r.x = 2.0 * (1.0 - r.x) / d;
                borderX = true;
                p.x += tileSize.x * (1.0 - r.x) / (0.5 + r.x);
            }

            if (r.y < d / 2.0) {
                r.y = 2.0 * r.y / d;
                borderY = true;
                p.y -= tileSize.y * (1.0 - r.y) / (0.5 + r.y);
            } else if (r.y > 1.0 - d / 2.0) {
                r.y = 2.0 * (1.0 - r.y) / d;
                borderY = true;
                p.y += tileSize.y * (1.0 - r.y) / (0.5 + r.y);
            }
        }
        // Pap: u = u_ModelTransform * vec3(p, 1.0) — forward, for next iteration.
        u = (modelTransform * vec3(p, 1.0)).xy;
    }

    vec4 outColor = __source__(p);

    // Pap: `if (u_LowResColorBleed != 0.0) outColor = mix(..., u_LowResColorBleed*0.01)`.
    //   pap2mp pixelation in 0..1: drop the *0.01.
    if (pixelation != 0.0) {
        // Pap: tileCenterTexSpace = u_InverseModelTransform * vec3(tileCenter, 1.0).
        vec2 tileCenterTexSpace = (invM * vec3(tileCenter, 1.0)).xy;
        vec4 pixelColor = __source__(tileCenterTexSpace);
        outColor = mix(outColor, pixelColor, pixelation);
    }

    return outColor;
}

void main() {
    fragColor = iteratedRectTilesGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_iterations, u_shapeAspectRatio, u_distortion, u_pixelation, u_modelTransform);
}
