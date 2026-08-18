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
#define u_intensity (U[6].x)
#define u_lightAngle (U[7].x)
#define u_blur (U[8].x)
#define u_color (U[9])
#define u_variability (U[10].x)
#define u_colorVariability (U[11].x)
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


















































































































































































































































































































































vec4 alphaBlend(vec4 a, vec4 b) {
    float sumA = a.a + b.a;
    if (sumA==0.0) return a;
    float k1 = a.a/sumA;
    float k2 = b.a/sumA;
    vec4 outc = k1*a + k2*b;
    outc.a = 1.0 - (1.0-a.a) * (1.0-b.a);
    return outc;
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

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
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

vec4 directionalLight(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float lightAngle, float blur, vec4 color, float variability, float colorVariability, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 t = tf(inverse(modelTransform), uv);

    float lightDistance = 1.0 + sourceDim.x/sourceDim.y; // XXX parameterize
    float angleSize = lightAngle;

    vec4 baseColor = color;


    float lightX = -lightDistance;
    float lightY = 0.0;
    vec2 light = vec2(lightX, lightY);
    float d = length(light);

    float dx = t.x-lightX;
    float dy = t.y-lightY;
    vec2 delta = vec2(dx, dy);

    vec4 col = vec4(0.);
    bool inLight = false;

    float angle = atan(delta.y, delta.x);

    int N = 1 + int(ceil(variability*5.));
    for(int i = 0; i < N; ++i) {
        float subAngleSize = angleSize/float(N);
        float subPhase = - angleSize/2.0 + subAngleSize/2.0 + subAngleSize*float(i);

        // perturbate
        vec2 var = rand2(vec2(float(N), float(i)));
        subPhase += subAngleSize * var.y*variability;
        float sizeVar = var.x<0.0 ? 1.0 + var.x*variability*0.5 : 1.0 + var.x*variability;
        subAngleSize *= sizeVar;
        float subIntensity = intensity*100.;

        float deltaAngle = angle-subPhase;
        if (deltaAngle < -PI) deltaAngle += 2.0*PI;
        else if (deltaAngle > PI) deltaAngle -= 2.0*PI;

        if (deltaAngle > -subAngleSize/2.0 && deltaAngle <= subAngleSize/2.0) {
            inLight = true;
            vec4 newColor = baseColor;
            float kk = 1.0;
            if (blur > 0.0) {
                float distFromBorder = (subAngleSize/2.0 - abs(deltaAngle)) / subAngleSize * 2.0;
                float blurDist = blur;
                if (distFromBorder < blurDist) {
                    kk = distFromBorder/blurDist;
                }
            }
            if (colorVariability > 0.0) {
                vec4 hsl = rgbToHsl(color);
                hsl[0] = hsl[0] + var.y*colorVariability;
                newColor = hslToRgb(hsl);
            }
            newColor.a = subIntensity*0.01 * kk;
            color = alphaBlend(col, newColor);
        }
    }


    if (inLight) {
        vec4 outc = inc + color*color.a;
        outc.a = 1.0;
        return outc;
    }
    else {
        return inc;
    }
}

void main() {
    fragColor = directionalLight((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_lightAngle, u_blur, u_color, u_variability, u_colorVariability, u_modelTransform);
}
