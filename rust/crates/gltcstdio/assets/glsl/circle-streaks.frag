#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_color1 (U[5])
#define u_color2 (U[6])
#define u_regularity (U[7].x)
#define u_radius (U[8].x)
#define u_radiusVariability (U[9].x)
#define u_colorVariability (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))





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

vec4 csColorShift(vec4 color, vec2 delta, float colorVariability) {
    float deltaHue = delta.x * colorVariability * 2.0;
    vec4 hsl = rgbToHsl(color);
    hsl.x += deltaHue * 180.0;
    hsl.z *= (1.0 + 0.3 * delta.y);
    return hslToRgb(hsl);
}

vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 circleStreaks(vec2 pos, vec2 outPos, vec4 color1, vec4 color2, float regularity, float radius, float radiusVariability, float colorVariability, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), pos);
    float variability = 1.0 - regularity;

    vec2 v = floor(vec2(u.x + 0.5, u.y + 0.5));
    int j = -2;
    int jEnd = 2;
    bool inCircle = false;
    bool shadowed = false;
    vec2 shadowingRnd = vec2(0.0);
    vec2 shadowingDisplacedPoint = vec2(0.0, 1e20);
    float minDistance = 1e5;
    while (j <= jEnd) {
        for (int i = -2; i <= 2; ++i) {
            vec2 point = vec2(v.x + float(i), v.y + float(j));
            vec2 rnd = rand2rel(point);
            vec2 displace = rnd * variability * 2.0;
            vec2 displacedPoint = point + displace;
            if (shadowingDisplacedPoint.y > displacedPoint.y) {
                float distance = length(displacedPoint - u);
                float r = radius * (1.0 + displace.x * radiusVariability);
                bool inRadius = distance < r;
                if (abs(displacedPoint.x - u.x) < r && (inRadius || displacedPoint.y > u.y)) {
                    minDistance = min(minDistance, distance);
                    shadowingDisplacedPoint = displacedPoint;
                    shadowingRnd = rnd;
                    shadowed = true;
                    inCircle = inRadius;
                }
            }
        }
        if (!shadowed && jEnd < 100) ++jEnd;
        ++j;
    }

    if (shadowed) {
        vec4 baseColor = csColorShift(color1, shadowingRnd, colorVariability);
        return inCircle
            ? baseColor
            : vec4(mix((baseColor.rgb + 0.2) * 1.15, color2.rgb, min(1.0, 0.5 * minDistance)), baseColor.a);
    }
    return color2;
}

void main() {
    fragColor = circleStreaks((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color1, u_color2, u_regularity, u_radius, u_radiusVariability, u_colorVariability, u_modelTransform);
}
