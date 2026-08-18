#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_palette;
layout(binding = 3) uniform texture2D t_source;

#define u_palette sampler2D(t_palette, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_paletteDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_balance (U[9].x)
#define u_regularity (U[10].x)
#define u_dithering (U[11].x)

#define __palette__texelFetch__(c) texelFetch(u_palette, (c), 0)
#define __palette__(p) textureLod(u_palette, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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











































































































































































































































































































































// 4x4 ordered-dither lookup. Pap filter's `pattern4x4` array, inlined.







float pvg_dither4x4(int x, int y) {
    int i = x + y * 4;
    if (i == 0)  return -7.0/17.0;
    if (i == 1)  return  2.0/17.0;
    if (i == 2)  return -5.0/17.0;
    if (i == 3)  return  3.0/17.0;
    if (i == 4)  return  5.0/17.0;
    if (i == 5)  return -3.0/17.0;
    if (i == 6)  return  7.0/17.0;
    if (i == 7)  return -1.0/17.0;
    if (i == 8)  return -4.0/17.0;
    if (i == 9)  return  4.0/17.0;
    if (i == 10) return -6.0/17.0;
    if (i == 11) return  2.0/17.0;
    if (i == 12) return  8.0/17.0;
    if (i == 13) return  0.0;
    if (i == 14) return  6.0/17.0;
    return -2.0/17.0; // i == 15
}

vec4 pixelateVariable(vec2 pos, vec2 outPos, mat3 modelTransform,
                       float balance, float regularity, float dithering,
                       vec2 paletteDim) {
    float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
    vec4 sampledColor;
    vec2 uu = vec2(0.0);
    float scale = 1.0 / resolution;

    // Pap: `(0.5 + u_Balance*0.005) * 1.717` for u_Balance in -100..100
    //   -> 0.5 + balance*0.5 for balance in -1..1.
    float threshold = (0.5 + balance * 0.5) * 1.717;

    // Pap rescale: u_Regularity * 0.02 -> regularity * 2.0
    float regularityScaled = regularity * 2.0;

    // 5 iterations, fixed. Probes pixel-scale doublings.
    for (int i = 0; i < 5; ++i) {
        scale *= 2.0;
        uu = floor(pos / scale + 0.5);
        vec2 u = uu * scale;
        sampledColor = __source__(u);

        // Pap guards against division by zero when regularity == 0.
        float scale2 = (regularityScaled == 0.0) ? 1e-7 : (regularityScaled * scale);

        // 3x3 / 8-sample avg distance. Center contributes 0 (length(c-c)).
        float total = 0.0;
        vec2 base = floor(pos / scale2 + 0.5) * scale2;
        for (int j = -1; j <= 1; ++j) {
            for (int k = -1; k <= 1; ++k) {
                vec4 other = __source__(base + scale * 0.5 * vec2(float(k), float(j)));
                total += length(sampledColor.rgb - other.rgb);
            }
        }
        float dist = total / 8.0;

        if (dist >= threshold) break;
    }

    int colorCount = max(int(paletteDim.x), 1);

    if (dithering != 0.0) {
        // GLSL ES: mod() in place of Pap's fmod()
        vec2 offset = vec2(mod(uu.x, 4.0), mod(uu.y, 4.0));
        // ensure offsets are in [0, 4) for negative uu (mod can return
        // negatives in some drivers); add and re-mod defensively.
        offset = mod(offset + 4.0, 4.0);
        float k = pvg_dither4x4(int(offset.x), int(offset.y))
                  * dithering * 3.0 * 1.4 / pow(float(colorCount), 0.5);
        sampledColor.rgb *= 1.0 + k;
    }

    // Palette quantization. Skip when palette has 0 or 1 entries
    // (matches Pap's `u_ColorCount <= 1` guard).
    vec4 outCol = sampledColor;
    int n = int(paletteDim.x);
    if (n > 1) {
        float minDist = 1e9;
        for (int i = 0; i < n; ++i) {
            vec4 target = __palette__texelFetch__(ivec2(i, 0));
            float dist = length(sampledColor - target);
            if (dist < minDist) {
                minDist = dist;
                outCol = target;
            }
        }
    }
    return outCol;
}

void main() {
    fragColor = pixelateVariable((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_balance, u_regularity, u_dithering, u_paletteDim);
}
