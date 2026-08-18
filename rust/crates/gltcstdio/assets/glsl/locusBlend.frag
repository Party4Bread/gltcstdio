#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_effect;
layout(binding = 3) uniform texture2D t_source;

#define u_effect sampler2D(t_effect, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_locusMode (int(U[5].x))
#define u_locusTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))

#define __effect__texelFetch__(c) texelFetch(u_effect, (c), 0)
#define __effect__(p) texture(u_effect, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
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



























































































































































































































































































































































vec4 blend(int mode, vec4 a, vec4 b) {
    vec3 aa = a.rgb;
    vec3 bb = b.rgb;
    vec3 cc;
    { int _sw_sel = int(mode);
if (_sw_sel == int(1)) { cc = aa + bb; }
else if (_sw_sel == int(2)) { cc = aa * bb; }
else if (_sw_sel == int(3)) { cc = aa - bb; }
else if (_sw_sel == int(4)) { cc = abs(aa - bb); }
else if (_sw_sel == int(5)) { cc = aa / bb; }
else if (_sw_sel == int(10)) { return max(a, b); }
else if (_sw_sel == int(11)) { return min(a, b); }
else { return b; }
}
    return vec4(cc, mix(a.a, b.a, 0.5));
}

float locusFmod(float a, float b) {
    return a - b * trunc(a / b);
}

float locusGetBlock(vec2 pos) {
    float inside = 0.0;
    float i2 = floor(pos.x/10.0) + floor(pos.y/10.0);
    float divisor = floor(locusFmod((pos.x-2.0*pos.y)/200.0, 24.0))/2.0;
    float threshold = locusFmod((pos.x+2.0*pos.y)/200.0, 24.0)/6.0;
    float total = 0.0;
    vec4 rdmz = vec4(locusFmod(i2*8877.0, 65536.0), locusFmod(55.0+i2*777.0, 65536.0),
                     locusFmod(i2*413.0, 65536.0), locusFmod(4445.0+i2*78.0, 65536.0));
    for (int i = 0; i < 5; ++i) {
        vec2 v = vec2(locusFmod(pos.x, 8.0), locusFmod(pos.y, 8.0));
        float index = v.x + v.y*8.0;
        float idx = locusFmod(pos.y, 300.0) > 150.0 ? 3.0 : clamp(floor(index/16.0), 0.0, 3.0);
        float ins = locusFmod(floor(rdmz[int(idx)]/pow(2.0, index-idx*16.0)), 2.0);
        total += ins;
        pos = floor(pos/divisor);
    }
    inside = total >= threshold ? 1.0 : 0.0;
    return inside;
}

float locusGetHue(vec4 c) {
    float r = c.r, g = c.g, b = c.b;
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));
    if (maxi == mini) return 0.0;
    else if (maxi == r) return locusFmod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g) return (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else return (60.0 * (r - g) / (maxi - mini)) + 240.0;
}

float getLocus(vec2 pos, vec4 inCol, vec4 outCol, int locusMode, mat3 locusTransform) {
    if (locusMode == 0) return 1.0;

    // legacy host inverts the transform for the geometric modes (1-3) only
    mat3 m = locusTransform;
    if (locusMode <= 3) m = inverse(locusTransform);
    vec2 u = (m * vec3(pos, 1.0)).xy;

    if (locusMode == 1) {                 // square
        return max(abs(u.x), abs(u.y)) > 1.0 ? 0.0 : 1.0;
    } else if (locusMode == 2) {          // outside circle
        return smoothstep(0.5, 1.0, length(u));
    } else if (locusMode == 3) {          // inside circle
        return smoothstep(1.0, 0.5, length(u));
    } else if (locusMode == 4) {          // hue select
        float hue = locusGetHue(inCol);
        float targetHue = locusFmod(locusTransform[2][0] * 180.0, 360.0);
        float d = hue - targetHue;
        if (d < 0.0) d = -d;
        if (d > 180.0) d = 360.0 - d;
        float maxD = 360.0 / length(vec2(locusTransform[0][0], locusTransform[0][1]));
        d /= maxD;
        return smoothstep(1.0, 0.75, d);
    } else if (locusMode == 5) {          // block glitch
        vec2 v = floor(u * 40.0);
        return locusGetBlock(v);
    } else if (locusMode == 6) {          // color change
        float colDist = length(inCol.rgb - outCol.rgb);
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float maxDist = scale < 1.0 ? 1.732 * scale : 1.732 / scale;
        if (scale < 1.0) colDist = 1.732 - colDist;
        colDist /= maxDist;
        return smoothstep(1.0, 0.75, colDist);
    } else if (locusMode == 7) {          // blend (uniform opacity)
        return clamp(-locusTransform[2][0] + locusTransform[2][1], 0.0, 1.0);
    } else if (locusMode == 8) {          // scanlines
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

vec4 locusBlend(vec2 pos, vec2 outPos, int locusMode, mat3 locusTransform) {
    vec4 inc = __source__(pos);
    vec4 outc = __effect__(pos);
    return mix(inc, outc, getLocus(pos, inc, outc, locusMode, locusTransform));
}

void main() {
    fragColor = locusBlend((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_locusMode, u_locusTransform);
}
