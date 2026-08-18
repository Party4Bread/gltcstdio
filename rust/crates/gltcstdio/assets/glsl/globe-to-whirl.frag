#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[20];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_time (U[6].x)
#define u_globeIntensity (U[7].x)
#define u_power (U[8].x)
#define u_shadows (U[9].x)
#define u_colorShadow (U[10])
#define u_whirlIntensity (U[11].x)
#define u_unwind (U[12].x)
#define u_highFreqColor (U[13])
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_shadowTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))

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

float measure(vec2 v, float power) {
    float low = min(abs(v.x), abs(v.y));
    float high = max(abs(v.x), abs(v.y));
    return high==0.0 ? 0.0 : high * pow(1.0 + pow(low/high, power), 1.0/power);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 globe_to_whirl(vec2 uv, vec2 outPos, float time,
    float globeIntensity, vec2 sourceDim, float power, float shadows, vec4 colorShadow,
    float whirlIntensity, float unwind, vec4 highFreqColor,
    mat3 modelTransform, mat3 shadowTransform) {

    mat3 t = inverse(modelTransform);

    // Fade out Globe's aspect-ratio correction
    float ratio = sourceDim.x / sourceDim.y;
    float ratioScale = ratio < 1.0 ? mix(1.0 / ratio, 1.0, time) : 1.0;
    vec2 u = uv * ratioScale;
    vec2 v = tf(t, u);

    // Blend distance metric: Minkowski (Globe) → Euclidean (Whirl)
    float dCircle = length(v);
    float dShape = measure(v, power);
    float d = mix(dShape, dCircle, time);

    float kShadow = 0.0;
    float darken = 0.0;

    if (d < 1.0) {
        // --- Globe radial dilation ---
        float hh = sqrt(1.0 - d * d);
        float globeDilation = 1.0;
        if (hh != 0.0) {
            float h = 1.0 + hh;
            float s = (-d * globeIntensity) / hh;
            globeDilation = 1.0 + (h * s) / d;
        }
        vec2 globeUV = globeDilation * v;

        // --- Whirl angular rotation ---
        float dWhirl = dCircle;
        float bal = unwind;
        if (bal != 0.5) {
            if (bal == 1.0 || dWhirl < bal) {
                dWhirl = 0.5 * dWhirl / bal;
            } else {
                dWhirl = 0.5 * (1.0 - (dWhirl - bal) / (1.0 - bal));
            }
        }
        float dangle = whirlIntensity * 10.0 * (1.0 - cos(dWhirl * 2.0 * PI));
        float ca = cos(dangle);
        float sa = sin(dangle);
        vec2 whirlUV = vec2(ca * v.x - sa * v.y, ca * v.y + sa * v.x);

        // Morph between Globe's dilation and Whirl's rotation
        vec2 blended = mix(globeUV, whirlUV, time);
        u = tf(modelTransform, blended);

        // Fade out Globe's inner shadows
        if (shadows < 0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = measure(vs, power);
            kShadow = (1.0 - time) * smoothstep(shadows, 0.0, ds - 1.0);
        }

        // Fade in Whirl's darkening
        if (highFreqColor.a != 0.0) {
            float dRot = length(whirlUV * vec2(min(1.5, 1.0 + abs(whirlIntensity * 3.0)), 1.0));
            float sHeight = highFreqColor.a * 4.0;
            float sSlope = 1.0 + highFreqColor.a * 3.0;
            darken = clamp(sHeight - dRot * sSlope, 0.0, 1.0) * time;
        }
    } else {
        // Outside the effect region — fade out Globe's outer shadows
        if (shadows > 0.0) {
            vec2 vs = tf(inverse(shadowTransform), v);
            float ds = measure(vs, power);
            kShadow = (1.0 - time) * smoothstep(shadows, 0.0, ds - 1.0);
        }
    }

    // Undo aspect-ratio correction
    u = u / ratioScale;

    vec4 col = __source__(u);
    // Globe shadow (fading out)
    col = mix(col, vec4(colorShadow.rgb, col.a), kShadow * colorShadow.a);
    // Whirl darkening (fading in)
    col = mix(col, vec4(highFreqColor.rgb, col.a), darken);
    return col;
}

void main() {
    fragColor = globe_to_whirl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_time, u_globeIntensity, u_sourceDim, u_power, u_shadows, u_colorShadow, u_whirlIntensity, u_unwind, u_highFreqColor, u_modelTransform, u_shadowTransform);
}
