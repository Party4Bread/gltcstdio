#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_color (U[5])
#define u_regularity (U[6].x)
#define u_colorVariability (U[7].x)
#define u_randomSeed (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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











































































































































































































































































































































// Per-stripe hue/luminance tweak — mirrors Pap's getColor().
// colorVariability is normalised (0..1); original used (u_ColorVariability * 0.02)
// where u_ColorVariability was 0..100, so the compensated constant is 2.0.



// Pap's colorize(): split the tint's alpha into a colorize-region (kCol)
// and a flat-mate-region (kMate). Equivalent to the original byte-for-byte.







float hueToRgb(float p, float q, float h) {
    if (h < 0.0) h += 1.0;

    if (h > 1.0 ) h -= 1.0;

    if (6.0 * h < 1.0) {
        return p + ((q - p) * 6.0 * h);
    }

    if (2.0 * h < 1.0 ) {
        return  q;
    }

    if (3.0 * h < 2.0) {
        return p + ( (q - p) * 6.0 * ((2.0 / 3.0) - h) );
    }

    return p;
}

vec4 hslToRgb(vec4 inc) {
    //  Formula needs all values between 0 - 1.
    float h = mod(inc.r, 360.0);
    h /= 360.0;
    float s = inc.g;
    float l = inc.b;

    float q = 0.0;

    if (l < 0.5)
        q = l * (1.0 + s);
    else
        q = (l + s) - (s * l);

    float p = 2.0 * l - q;

    float r = max(0.0, hueToRgb(p, q, h + (1.0 / 3.0)));
    float g = max(0.0, hueToRgb(p, q, h));
    float b = max(0.0, hueToRgb(p, q, h - (1.0 / 3.0)));

    vec4 outc;
    outc.r = min(r, 1.0);
    outc.g = min(g, 1.0);
    outc.b = min(b, 1.0);
    outc.a = inc.a;

    return outc;
}

vec4 rgbToHcv(in vec4 RGB) {
    vec4 P = (RGB.g < RGB.b) ? vec4(RGB.bg, -1.0, 2.0/3.0) : vec4(RGB.gb, 0.0, -1.0/3.0);
    vec4 Q = (RGB.r < P.x) ? vec4(P.xyw, RGB.r) : vec4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6. * C + 1e-10) + Q.z);
    return vec4(H, C, Q.x, RGB.a);
}

vec4 rgbToHsl(in vec4 RGB) {
    vec4 HCV = rgbToHcv(RGB);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1. - abs(L * 2. - 1.) + 1e-6);  // careful with the 1e-6 - used to be 1e-10 which caused errors because of low precision and we god NaNs. A test would be more clean but potentially slower.
    return vec4(HCV.x*360., S, L, RGB.a);
}

vec4 coloredStripesColorize(vec4 base, vec4 tint) {
    vec4 hslBase = rgbToHsl(base);
    vec4 hslTint = rgbToHsl(tint);
    float kCol = clamp(tint.a * 2.0, 0.0, 1.0);
    hslTint.z = hslBase.z;
    vec4 tintLum = hslToRgb(hslTint);
    vec3 colorized = mix(base.rgb, tintLum.rgb, kCol);
    float kMate = clamp((tint.a - 0.5) * 2.0, 0.0, 1.0);
    return vec4(mix(colorized, tint.rgb, kMate), base.a);
}

vec4 coloredStripesGetColor(vec4 baseColor, vec2 delta, float colorVariability) {
    float deltaHue = delta.x * colorVariability * 2.0;
    vec4 hsl = rgbToHsl(baseColor);
    hsl.x += deltaHue * 180.0;
    hsl.z *= (1.0 + 0.3 * delta.y);
    return hslToRgb(hsl);
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 coloredStripesGL(vec2 pos, vec2 outPos, vec4 color, float regularity, float colorVariability, float randomSeed, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = tf(invM, pos);

    vec4 inCol = __source__(pos);
    float index = floor(u.y / 2.0);
    vec2 delta = rand2relSeeded(vec2(index, index), randomSeed);

    // Pap: u_Variability = 100 - regularity (0..100), shader: u_Variability * 0.01
    //   → with regularity normalised to 0..1, this becomes (1.0 - regularity).
    float variability = 1.0 - regularity;
    float var_ = variability * delta.x * 2.0;
    float inside = (mod(u.y, 2.0) < 1.0 + var_) ? 1.0 : 0.0;

    if (inside > 0.0) {
        vec4 stripeColor = coloredStripesGetColor(color, delta, colorVariability);
        vec4 outCol = coloredStripesColorize(inCol, stripeColor);
        return outCol;
    } else {
        return inCol;
    }
}

void main() {
    fragColor = coloredStripesGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color, u_regularity, u_colorVariability, u_randomSeed, u_modelTransform);
}
