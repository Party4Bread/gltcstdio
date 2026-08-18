#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_style (int(U[6].x))
#define u_channels_red (U[7].x)
#define u_channels_green (U[8].x)
#define u_channels_blue (U[9].x)
#define u_channels_hue (U[10].x)
#define u_channels_saturation (U[11].x)
#define u_channels_luminance (U[12].x)

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

vec4 channelMultiplier(vec2 pos, vec2 outPos, float intensity, int style, float channels_red, float channels_green, float channels_blue, float channels_hue, float channels_saturation, float channels_luminance) {
    int mode = style;
    vec4 col = __source__(pos);
    vec4 inCol = col;
    
    col.rgb *= vec3(channels_red, channels_green, channels_blue);
    
    if (mode==0) {
        col.rgb = fract(col.rgb);          
    }
    else if (mode==1) {
        col.rgb = 1.0 - abs(fract(col.rgb*0.5)*2.0-1.0);
    } 
    else {
        col.rgb = clamp(col.rgb, 0.0, 1.0);
    }

    vec4 hsl = rgbToHsl(col);
    hsl.xyz *= vec3(channels_hue, channels_saturation, channels_luminance);
    if (mode==0) {
        hsl.x = mod(hsl.x, 360.0); 
        hsl.yz = fract(hsl.yz);          
    }
    else if (mode==1) {
        hsl.x = mod(hsl.x, 360.0); 
        hsl.yz = 1.0 - abs(fract(hsl.yz*0.5)*2.0-1.0);
    } 
    else {
        hsl.x = mod(hsl.x, 360.0); 
        hsl.yz = clamp(hsl.yz, 0.0, 1.0);
    }
    
    vec4 rgb = hslToRgb(hsl);
    return mix(inCol, rgb, intensity);
}

void main() {
    fragColor = channelMultiplier((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_style, u_channels_red, u_channels_green, u_channels_blue, u_channels_hue, u_channels_saturation, u_channels_luminance);
}
