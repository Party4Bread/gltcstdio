#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;
layout(binding = 4) uniform texture2D t_legacy_2;
layout(binding = 5) uniform texture2D t_legacy_3;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_Tex0 sampler2D(t_legacy_2, samp)
#define u_Tex1 sampler2D(t_legacy_3, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_locusMode (int(U[10].x))
#define u_locusTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

































































































































































































































































































































































float ciFmod(float a, float b) {
    return a - b * trunc(a / b);
}

float ciLocusGetBlock(vec2 pos) {
    float inside = 0.0;
    float i2 = floor(pos.x / 10.0) + floor(pos.y / 10.0);
    float divisor = floor(ciFmod((pos.x - 2.0 * pos.y) / 200.0, 24.0)) / 2.0;
    float threshold = ciFmod((pos.x + 2.0 * pos.y) / 200.0, 24.0) / 6.0;
    float total = 0.0;
    vec4 rdmz = vec4(ciFmod(i2 * 8877.0, 65536.0), ciFmod(55.0 + i2 * 777.0, 65536.0),
                     ciFmod(i2 * 413.0, 65536.0), ciFmod(4445.0 + i2 * 78.0, 65536.0));
    for (int i = 0; i < 5; ++i) {
        vec2 v = vec2(ciFmod(pos.x, 8.0), ciFmod(pos.y, 8.0));
        float index = v.x + v.y * 8.0;
        float idx = ciFmod(pos.y, 300.0) > 150.0 ? 3.0 : clamp(floor(index / 16.0), 0.0, 3.0);
        float ins = ciFmod(floor(rdmz[int(idx)] / pow(2.0, index - idx * 16.0)), 2.0);
        total += ins;
        pos = floor(pos / divisor);
    }
    inside = total >= threshold ? 1.0 : 0.0;
    return inside;
}

float ciLocusGetHue(vec4 c) {
    float r = c.r, g = c.g, b = c.b;
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));
    if (maxi == mini) return 0.0;
    else if (maxi == r) return ciFmod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g) return (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else return (60.0 * (r - g) / (maxi - mini)) + 240.0;
}

float ciGetLocus(vec2 pos, vec4 inCol, vec4 outCol, int locusMode, mat3 locusTransform) {
    if (locusMode == 0) return 1.0;
    mat3 m = locusTransform;
    if (locusMode <= 3) m = inverse(locusTransform);
    vec2 u = (m * vec3(pos, 1.0)).xy;
    if (locusMode == 1) {
        return max(abs(u.x), abs(u.y)) > 1.0 ? 0.0 : 1.0;
    } else if (locusMode == 2) {
        return smoothstep(0.5, 1.0, length(u));
    } else if (locusMode == 3) {
        return smoothstep(1.0, 0.5, length(u));
    } else if (locusMode == 4) {
        float hue = ciLocusGetHue(inCol);
        float targetHue = ciFmod(locusTransform[2][0] * 180.0, 360.0);
        float d = hue - targetHue;
        if (d < 0.0) d = -d;
        if (d > 180.0) d = 360.0 - d;
        float maxD = 360.0 / length(vec2(locusTransform[0][0], locusTransform[0][1]));
        d /= maxD;
        return smoothstep(1.0, 0.75, d);
    } else if (locusMode == 5) {
        vec2 v = floor(u * 40.0);
        return ciLocusGetBlock(v);
    } else if (locusMode == 6) {
        float colDist = length(inCol.rgb - outCol.rgb);
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float maxDist = scale < 1.0 ? 1.732 * scale : 1.732 / scale;
        if (scale < 1.0) colDist = 1.732 - colDist;
        colDist /= maxDist;
        return smoothstep(1.0, 0.75, colDist);
    } else if (locusMode == 7) {
        return clamp(-locusTransform[2][0] + locusTransform[2][1], 0.0, 1.0);
    } else if (locusMode == 8) {
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float angle = floor(locusTransform[2][0] * 3.0 + 0.5) / 12.0 * PI;
        float intensity = clamp(locusTransform[2][1], 0.0, 1.0);
        float ca = cos(angle), sa = sin(angle);
        float y = -sa * pos.x + ca * pos.y;
        float h = cos(y * scale * PI * 100.0);
        return intensity < 0.5 ? intensity * (h + 1.0) : 1.0 + (1.0 - intensity) * (h - 1.0);
    }
    return 1.0;
}

bool inside(vec2 pos, float X, float Y) {
    return abs(pos.y)<=Y && abs(pos.x)<=X;
}

float sampleCol(vec4 color, int count) {
    return floor((color.r + color.g + color.b)*(float(count)-1.0)/3.0 + 0.5);
}

vec4 contourInterpolateGL(vec2 pos, vec2 outPos, vec2 sourceDim, int count, mat3 modelTransform, int locusMode, mat3 locusTransform) {
    float pixel = 2.0 / sourceDim.y;
    float X = sourceDim.x / sourceDim.y;
    float Y = 1.0;

    vec2 p = vec2(pixel, 0.0);
    vec2 d = pixel * normalize(mat2(modelTransform) * p);

    vec4 bkg = __source__(pos);            // raw source — locus background (Pap u_Tex0)

    vec4 col = __source2__(pos);           // blurred source (Pap u_Tex1)
    float s = sampleCol(col, count);

    vec2 pos1 = pos;
    while (sampleCol(__source2__(pos1 + d), count) == s && inside(pos1 + d, X, Y)) {
        pos1 += d;
    }
    vec4 col1 = __source2__(pos1);

    vec2 pos2 = pos;
    while (sampleCol(__source2__(pos2 - d), count) == s && inside(pos2 - d, X, Y)) {
        pos2 -= d;
    }
    vec4 col2 = __source2__(pos2);

    vec2 dd = pos2 - pos1;
    float len = length(dd);
    // Pap quirk: isolated pixel returns the blurred colour directly, no locus.
    if (len == 0.0) return col;

    vec4 outCol = mix(col1, col2, dot((pos - pos1) / len, (pos2 - pos1) / len));

    float locus = ciGetLocus(pos, bkg, outCol, locusMode, locusTransform);
    return mix(bkg, outCol, locus);
}

void main() {
    fragColor = contourInterpolateGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_count, u_modelTransform, u_locusMode, u_locusTransform);
}
