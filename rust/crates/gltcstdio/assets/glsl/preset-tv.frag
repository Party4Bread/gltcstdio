#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_ModelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_intensity (U[9].x)
#define u_balance (U[10].x)
#define u_brightness (U[11].x)
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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

vec4 presetTv(vec2 pos, vec2 outPos, float intensity, float balance, float brightness, vec2 sourceDim, mat3 modelTransform) {
    // ---- crtContrast(pos, 0.8, 0.025) ----------------------------------
    float radius = 0.025;
    float k0 = 0.8;
    vec4 color = __source__(pos);

    // blurH(pos + vec2(radius/2, 0), radius), inlined from Pap's blurH().
    vec2 bpos = pos + vec2(radius / 2.0, 0.0);
    float pixel = 2.0 / sourceDim.y;
    int n = int(ceil(radius / pixel)) + 1;
    vec4 total = vec4(0.0);
    vec2 bp = bpos - vec2(float(n) * pixel, 0.0);
    float div = 0.0;
    for (int i = -64; i <= 64; ++i) {
        if (i < -n || i > n) continue;
        float d = length(vec2(float(i), 0.0)) * pixel / radius;
        if (d <= 1.0) {
            float kk = (d > 0.5) ? (1.0 - d) * (1.0 - d) * 2.0 : 1.0 - d * d * 2.0;
            total += kk * __source__(bp);
            div += kk;
            bp.x += pixel;
        }
    }
    vec4 blur = total / div;
    color = (1.0 + k0) * color - k0 * blur;

    // ---- chromaOffset(color, pos) --------------------------------------
    // Pap: u = vec2(pos.x + 0.05, pos.y);  (u_ModelTransform line commented out)
    vec2 cu = vec2(pos.x + 0.05, pos.y);
    vec4 chsl = rgbToHsl(color);
    vec4 cOffHsl = rgbToHsl(__source__(cu));
    chsl[0] = cOffHsl[0];
    chsl[1] = cOffHsl[1];
    color = hslToRgb(chsl);

    // ---- scanlines(color, pos) -----------------------------------------
    vec4 shsl = rgbToHsl(color);
    vec4 sOrigHsl = shsl;
    // pincushion(pos, 0.15): p*(1 + k*dot(p,p)*dot(p,p))  (4th-power barrel)
    float pk = 0.15;
    float dd = dot(pos, pos);
    vec2 pinc = pos * (1.0 + pk * dd * dd);
    shsl[0] += pinc.y * 1000.0;
    float brightnessRaw = -brightness * 100.0;   // Pap: brightness = -u_Brightness
    float b = pow(1.04, brightnessRaw);
    shsl[2] *= pow((1.0 + sin(pinc.y * 600.0)) * (brightnessRaw * 0.001 + 0.5), b);

    vec4 shslD = sOrigHsl;
    shslD[2] = shsl[2];
    vec4 srgbD = hslToRgb(shslD);
    vec4 srgb = hslToRgb(shsl);
    srgb = mix(srgb, srgbD, 0.0);     // Pap no-op (factor 0.0): yields srgb
    color = mix(color, srgb, 0.4);

    // ---- ray darkening -------------------------------------------------
    // Pap filter doInverseModelTransform()=true → u_ModelTransform is the
    // inverse of the forward matrix. pap2mp passes forward → apply inverse.
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;

    // fmod(u.y+2, 2) → mod(u.y+2, 2) (non-negative base; GLSL ES has no fmod)
    float k = mod(u.y + 2.0, 2.0) * 0.5;

    // intensity: Pap getMaskedParameter(u_Intensity*0.01, outPos) → bare intensity.
    float base = pow(10.0, intensity * 20.0);
    k = balance + 0.5 * pow(base, k) / (base / 10.0);  // Pap u_Balance*0.01 → balance

    vec4 outCol = color * vec4(k, k, k, 1.0);
    // Pap literal arg order: clamp(intensity*3.0, 0.0, 1.0) = min(1.0, intensity*3.0).
    return mix(color, outCol, clamp(intensity * 3.0, 0.0, 1.0));
}

void main() {
    fragColor = presetTv((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_balance, u_brightness, u_sourceDim, u_modelTransform);
}
