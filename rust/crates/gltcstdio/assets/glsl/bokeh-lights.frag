#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_intensity (U[7].x)
#define u_vignetting (U[8].x)
#define u_radius (U[9].x)
#define u_radiusVariability (U[10].x)
#define u_color (U[11])
#define u_variability (U[12].x)
#define u_colorVariability (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

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

vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
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

vec4 bokehLights(vec2 uv, vec2 outPos, vec2 sourceDim, int count, float intensity, float vignetting, float radius, float radiusVariability, vec4 color, float variability, float colorVariability, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 u = tf(inverse(modelTransform), uv);

    bool inLight = false;

    vec4 col = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 baseColor = color;

    vec2 v = floor(vec2(u.x+0.5, u.y+0.5));
    float closest = 1e9;
    
    float vig = smoothstep(mix(0.2, 0.6, vignetting), mix(0.4, 1.6, vignetting), length(uv));
    intensity = intensity * mix(1.0, vig, min(1.0, vignetting * 3.));           
    
    for(int j=-2; j<=2; ++j) {
        for(int i=-2; i<=2; ++i) {
            vec2 point = vec2(v.x+float(i), v.y+float(j));
            vec2 randomness = rand2rel(point)*2.0;
            vec2 displace = randomness*variability;
            vec2 delta = point+displace - u;
            float distance = length(delta);
            float radiusModifier = randomness.x < 0.0 ? 1.0 + randomness.x * radiusVariability *0.4 : 1.0 + randomness.x * radiusVariability *2.;
            float blur = (radiusModifier < 1.0 ? 1.0/radiusModifier : radiusModifier) - 1.0;

            if (count < 15 && distance > 0.0) {
                float ang = acos(delta.x/distance);
                if (delta.y < 0.0) ang = PI2 - ang; //ang += M_PI;

                float alpha2 = PI2/float(count);
                float alpha = alpha2/2.0;
                float da = mod(ang, alpha2);

                if (da > alpha) da = alpha2-da;

                float rounding = 1.0 + 0.25*( alpha*alpha - (alpha-da)*(alpha-da) );
                //da += phase;
                radiusModifier *= blur + (1.0-blur) * cos(alpha) / cos(alpha-da) * rounding;
            }

            float rad = radius * radiusModifier;
            float rad2 = rad*rad;
            float d2 = distance*distance;

            float kk = 0.0;
            if (d2 < rad2) {
                kk = d2/(rad2*0.97);
                kk = min(1.0, kk*kk)*0.35 + 0.65;
            }
            else if (d2<2.0*rad2) {
                kk = 1.0 - (d2-rad2)/rad2;
                kk = pow(kk, 2.0)*0.5;
            }

            if (blur > 0.0 && d2<2.0*rad2) {
                blur = min(blur, 1.0);
                float xxx = d2/(2.0*rad2);
                float kkk = (1.0 + cos(xxx*PI)) * 0.5;
                kk = blur*kkk + (1.0-blur)*kk;
            }

            if (kk > 0.0) {
                inLight = true;
                vec4 newColor = baseColor;
                if (colorVariability > 0.0) {
                    vec4 hsl = rgbToHsl(color);
                    hsl.x = hsl.x + randomness.y*colorVariability*100.0;
                    newColor = hslToRgb(hsl);
                }
                newColor.a = intensity * kk;
                col = alphaBlend(col, newColor);
            }

        }
    }

    if (inLight) {
        vec4 outc = inc + col*col.a;
        outc.a = 1.0;
        return outc;
    }
    else {
        return inc;
    }
}

void main() {
    fragColor = bokehLights((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_count, u_intensity, u_vignetting, u_radius, u_radiusVariability, u_color, u_variability, u_colorVariability, u_modelTransform);
}
