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
#define u_outDim (U[4].xy)
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_intensity (U[8].x)
#define u_balance (U[9].x)
#define u_randomSeed (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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

vec2 hueOffsetDistortedDistort(vec2 p, float k, float randomSeed) {
    vec3 pp = vec3(p, randomSeed);
    vec3 m = vec3(sin(randomSeed), sin(randomSeed + 10.0), sin(-randomSeed + 20.0));
    pp.xyz += k * 1.0  * sin((2.0 + m.x) * pp.yzx);
    pp.xyz += k * 0.75 * sin((2.0 + m.y) * pp.yzx);
    pp.xyz += k * 0.5  * sin((2.0 + m.z) * pp.yzx);
    return pp.xy;
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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 hueOffsetDistortedGl(vec2 pos, vec2 outPos, float intensity, float balance, float randomSeed, mat3 modelTransform) {
    // pap2mp's modelTransform is the model->screen (forward) transform; the
    // Pap shader used `u_ModelTransform * vec3(pos, 1.0)` where Pap
    // pre-inverted it (`doInverseModelTransform() = true`). Mirror this by
    // inverting in-shader.
    vec2 u = tf(inverse(modelTransform), pos);

    vec4 col = __source__(pos);
    vec4 hsl = rgbToHsl(col);
    // Hue shift driven by distortion x-component * 2000 * saturation.
    hsl[0] += hueOffsetDistortedDistort(u, 1.1, randomSeed).x * 2000.0 * hsl[1];
    // Saturation inversion balance: Pap used balance(-100..100) * 0.005 + 0.5;
    // with balance now in -1..1, the equivalent factor is balance * 0.5 + 0.5.
    hsl[1] = mix(hsl[1], 1.0 - hsl[1], balance * 0.5 + 0.5);
    vec4 outCol = hslToRgb(hsl);

    // Original Pap formula:
    //   k = intensity(0..100)*0.01 * locus
    //   return clamp(mix(col, outCol, k*2.0), 0.0, 1.0);
    // After 0..100 → 0..1 rescale: k = intensity * locus, mix factor = k*2.0.
    // The `*2.0` boost is intentional over-mixing — at intensity=1 it produces
    // `2*outCol - col` (clamped). Reproduce faithfully; locus is layered on by
    // `.withLocusHandling()` wiring at the Model.kt level.
    return clamp(mix(col, outCol, intensity * 2.0), 0.0, 1.0);
}

void main() {
    fragColor = hueOffsetDistortedGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_balance, u_randomSeed, u_modelTransform);
}
