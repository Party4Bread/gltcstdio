#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
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
#define u_intensity (U[6].x)
#define u_saturation (U[7].x)
#define u_tolerance (U[8].x)
#define u_hardness (U[9].x)

#define __palette__texelFetch__(c) texelFetch(u_palette, (c), 0)
#define __palette__(p) texture(u_palette, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
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

vec4 colorize(vec4 sourceColor, vec4 targetColor, float saturation) {
    vec4 hslTarget = rgbToHsl(targetColor);
    vec4 hslSource = rgbToHsl(sourceColor);

    hslSource.r = hslTarget.r; // hue
    hslSource.g = hslTarget.g==0.0 ? 0.0 : hslTarget.g*saturation + hslSource.g*(1.0-saturation);
    float gamma = pow(2.0, (0.5-hslTarget.b)*2.0);
    hslSource.b = pow(hslSource.b, gamma);

    return hslToRgb(hslSource);
}

vec4 emphasizePalette(vec2 pos, vec2 outPos, vec2 paletteDim, float intensity, float saturation, float tolerance, float hardness) {
    vec4 inc = __source__(pos);
    vec4 total = vec4(0.0, 0.0, 0.0, 1.0);
    float totalWeight = 0.0;
    float separation = 0.0 + hardness*10.0;

    float k0 = 1.0;

    int n = int(paletteDim.x);
    float tol = tolerance*2.5;//1.74;

    for(int i=0; i<n; ++i) {
        vec4 target = __palette__texelFetch__(ivec2(i, 0));

        vec4 contribColor = vec4(0.0, 0.0, 0.0, 1.0);
        float k = 0.0;
        float dist = length((inc-target).rgb);
        if (dist < tol) {
            contribColor = vec4(colorize(inc, target, saturation).rgb, inc.a);
            k = 1.0-dist/tol;
        }

        k0 = max(0.0, k0-k);
        k = pow(k, separation+0.5);
        total += k*contribColor;
        totalWeight += k;
    }

    vec4 rgb = k0==1.0 ? inc : mix(total / totalWeight, inc, k0); // weird alpha issue if k0==1.0 not handled separately
    return vec4(mix(inc.rgb, rgb.rgb, intensity), inc.a);
}

void main() {
    fragColor = emphasizePalette((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_paletteDim, u_intensity, u_saturation, u_tolerance, u_hardness);
}
