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
#define u_outDim (U[4].xy)
#define u_InverseModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_ModelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_color (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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

vec4 breakRectColorize(vec4 base, vec4 tint) {
    vec4 hslBase = rgbToHsl(base);
    vec4 hslTint = rgbToHsl(tint);
    float kCol = clamp(tint.a * 2.0, 0.0, 1.0);
    hslTint.z = hslBase.z;
    vec4 tintLum = hslToRgb(hslTint);
    vec3 colorized = mix(base.rgb, tintLum.rgb, kCol);
    float kMate = clamp((tint.a - 0.5) * 2.0, 0.0, 1.0);
    return vec4(mix(colorized, tint.rgb, kMate), base.a);
}

vec4 breakRect(vec2 pos, vec2 outPos, vec4 color, mat3 modelTransform) {
    // Pap's filter: doInverseModelTransform=true AND supplyInverseModelTransform=true.
    //   - u_ModelTransform   = inverse(forwardModel)   (the "forward" uniform IS the inverse)
    //   - u_InverseModelTransform = forwardModel       (the "inverse" uniform IS the forward)
    // In pap2mp we receive the forward matrix; reproduce both sides:
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;

    vec4 inCol = __source__(pos);
    if (abs(u.y) < 1.0) {
        // Pap: u.x += u_ModelTransform[2][0]  — note u_ModelTransform
        //   here is the inverse matrix's third column (translation of
        //   the inverse), not the forward translation.
        u.x += invM[2][0];
        // Pap: p = u_InverseModelTransform * vec3(u, 1.0)
        //   — u_InverseModelTransform IS the forward matrix.
        vec2 p = (modelTransform * vec3(u, 1.0)).xy;
        vec4 outCol = breakRectColorize(__source__(p), color);
        // Locus stripped: Pap returns mix(inCol, outCol, getLocus(...));
        // here the external `.withLocusHandling()` wrapper supplies the
        // locus blend on top of our `outCol` return.
        return outCol;
    }
    else {
        return inCol;
    }
}

void main() {
    fragColor = breakRect((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color, u_modelTransform);
}
