#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source2_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_balance (U[7].x)
#define u_mode (U[8].x)
#define u_mode2 (U[9].x)
#define u_backgroundOnly (U[10].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

float iridizeGetChannel(int select, vec4 rgb, vec4 hsl) {
    if (select==0) return rgb.r;
    else if (select==1) return rgb.g;
    else if (select==2) return rgb.b;
    else if (select==3) return hsl.r;
    else if (select==4) return hsl.g;
    else if (select==5) return hsl.b;
    else if (select==6) return 1.0-rgb.r;
    else if (select==7) return 1.0-rgb.g;
    else if (select==8) return 1.0-rgb.b;
    else if (select==9) return 1.0-hsl.r;
    else if (select==10) return 1.0-hsl.g;
    else return 1.0-hsl.b;
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

vec4 iridizeSwap(vec4 rgb, float mode) {
    float coding = floor(mode);
    bool toHsl = coding >= 1728.0;
    if (toHsl) coding = mod(coding, 1728.0);
    vec4 hsl = rgbToHsl(rgb);
    hsl.r /= 360.0;
    int rChannel = int(mod(coding, 12.0));
    int gChannel = int(mod(coding/12.0, 12.0));
    int bChannel = int(mod(coding/144.0, 12.0));
    vec4 color = vec4(
        iridizeGetChannel(rChannel, rgb, hsl) * (toHsl ? 360.0 : 1.0),
        iridizeGetChannel(gChannel, rgb, hsl),
        iridizeGetChannel(bChannel, rgb, hsl),
        rgb.a );
    return toHsl ? hslToRgb(color) : color;
}

vec4 iridizeModesGL(vec2 pos, vec2 outPos, int source2_specified, float intensity, float balance, float mode, float mode2, float backgroundOnly) {
    vec4 rgb = __source__(pos);
    vec4 mapRgb = source2_specified==0 ? rgb : __source2__(pos);
    if (mode >= 0.0) { rgb = iridizeSwap(rgb, mode); mapRgb = iridizeSwap(mapRgb, mode); }

    // Pap's locus background = the mode-swapped source (mix(rgb, outCol, locus)).
    // When used as LocusBlend's `source`, emit exactly that and skip the rest.
    if (backgroundOnly >= 0.5) return rgb;

    vec4 hsl = rgbToHsl(rgb);
    vec4 mapHsl = rgbToHsl(mapRgb);

    float saturation = mapHsl.g;
    float satBal = 0.5-balance*0.5;
    hsl.g = saturation * smoothstep(0.0, 1.0, (saturation-satBal)*4.0+0.5);

    hsl.r = mapHsl.r * (1.0 + saturation*intensity*40.);

    vec4 outCol = hslToRgb(hsl);
    if (mode2 >= 0.0) { outCol = iridizeSwap(outCol, mode2); }
    return outCol;
}

void main() {
    fragColor = iridizeModesGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source2_specified, u_intensity, u_balance, u_mode, u_mode2, u_backgroundOnly);
}
