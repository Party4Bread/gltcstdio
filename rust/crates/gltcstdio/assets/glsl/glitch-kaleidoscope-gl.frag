#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_legacy_1;

#define u_source sampler2D(t_source, samp)
#define u_Tex0 sampler2D(t_legacy_1, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_Tex0Transform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_spikeCount (int(U[11].x))
#define u_regularity (U[12].x)
#define u_roundedness (U[13].x)
#define u_perspective (U[14].x)
#define u_modelTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

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

float rand(float x) {
    return fract(sin(x * 43758.5453));
}

float gkglDisplaceAngle(float angle, float maxDisplacement) {
    return angle + maxDisplacement*(rand(angle)-0.5);
}

vec2 gkglPerspective(vec2 u, float perspective) {
    // Pap: u_Perspective = tan(PI/2 - perspective_radians). When perspective=0
    // → u_Perspective = INF → branch (>=10000) returns u unchanged.
    if (perspective == 0.0) return u;
    float invP = tan(PI*0.5 - perspective);
    if (invP >= 10000.0) return u;
    float Z = 4.0;
    float z = Z*u.y / (-Z*invP - u.y);
    return vec2(u.x * (z + Z) / Z, z * -invP);
}

vec2 gkglReflect(float d, float sourceAngle, float alpha, float halfAlpha, float halfRoundedAngle) {
    if (sourceAngle > halfAlpha) sourceAngle = alpha-sourceAngle;

    float cornerAngle = halfAlpha - halfRoundedAngle;
    if (halfRoundedAngle==0.0 || sourceAngle<=cornerAngle) {
        return d * vec2(cos(sourceAngle), sin(sourceAngle));
    }
    else {
        if (cornerAngle==0.0) cornerAngle = 0.001; // hack because the math is pathological here

        float x = d*cos(sourceAngle);
        float y = d*sin(sourceAngle);
        float cha = cos(halfAlpha);
        float sha = sin(halfAlpha);
        float cca = cos(cornerAngle);
        float sca = sin(cornerAngle);

        float A = ((sha/sca*cca-cha)*(sha/sca*cca-cha) - 1.0);
        float B = 2.0*(cha*x + sha*y);
        float C = -(x*x + y*y);
        float delta2 = B*B-4.0*A*C;
        if (delta2<0.0) {
            return vec2(x, y);
        }
        float l = (-B + sqrt(delta2)) / (2.0*A);
        float cx = l * cha;
        float cy = l * sha;
        float k = l*sha/sca;

        float Xp = k*cca;
        float Yp = k*sca;
        float R = Xp-cx;

        return vec2(Xp, Yp + R*(sourceAngle-cornerAngle));
    }
}

vec4 glitchKaleidoscope(vec2 uv, vec2 outPos, int spikeCount, float regularity, float roundedness, float perspective, mat3 modelTransform) {
    // TRANSFORM MAPPING (kaleidoscope-family convention; matches mirror/legacy/KaleidoscopeML
    // and docs/EFFECT_PORTING.md "Pap MODEL vs TEX <-> pap2mp viewTransform vs modelTransform"):
    //   - Pap MODEL (pre-fold pattern geometry, `u_ModelTransform * pos`) -> pap2mp
    //     `viewTransform`. The engine pre-applies it: the `uv` arg is already
    //     `inverse(viewTransform) * pos`, so we use `uv` directly for the geometry.
    //     `viewTransform` is therefore declared in the constructor but NOT a shader param.
    //   - Pap TEX (post-fold SOURCE sampling, Pap's TEX-transform applied to coord) ->
    //     pap2mp `modelTransform`, sampled as `inverse(modelTransform) * coord` (below).
    //     (Do NOT write the legacy projection-helper token here — see the NB note below.)
    // This makes the DEFAULT gesture (which drives `modelTransform`) pan/zoom the source
    // inside the fold — matching Pap's default checked mode `moveAndScaleShape` (= TEX).
    vec2 u = gkglPerspective(uv, perspective);

    float d = length(u);
    float sourceAngle = 0.0;

    float variability = 1.0 - regularity;
    float halfAlpha = 0.0;
    float alpha = 0.0;
    float sCount = float(spikeCount);
    if (d > 0.0) {
        float ang = atan(u.y, u.x);
        if (ang<0.0) ang += PI2;

        if (variability == 0.0) {
            halfAlpha = PI/sCount;
            alpha = halfAlpha * 2.0;
            sourceAngle = mod(ang, alpha);
        }
        else {
            float maxDisplacement = (4.0*PI)/sCount;
            float spikeAngle1 = 0.0;
            float spikeAngle2 = gkglDisplaceAngle(PI2/sCount, variability*maxDisplacement);

            for(int i=0; i<spikeCount; ++i) {
                if ((i==spikeCount-1) || (ang <= spikeAngle2)) {
                    alpha = spikeAngle2 - spikeAngle1;
                    halfAlpha = alpha/2.0;
                    sourceAngle = ang - spikeAngle1;
                    break;
                }
                else {
                    spikeAngle1 = spikeAngle2;
                    spikeAngle2 = float(i+2) * PI2/sCount;
                    if (i!=spikeCount-2)
                        spikeAngle2 = gkglDisplaceAngle(spikeAngle2, variability*maxDisplacement);
                }
            }
        }
    }

    float halfRoundedAngle = halfAlpha * roundedness;
    vec2 coord = gkglReflect(d, sourceAngle, alpha, halfAlpha, halfRoundedAngle);

    // Pap samples the source at the folded coord through its TEX transform
    // (proj of coord). pap2mp maps Pap TEX to `modelTransform`, applied as
    // inverse(modelTransform) so the default gesture pans/zooms the source content
    // with the fold center fixed (same as KaleidoscopeML).
    // NB: never write the legacy source-projection helper's name (proj + the digit 0)
    // immediately followed by an open-paren anywhere in this string. parseDependencies
    // scans the shader text INCLUDING COMMENTS for an identifier-then-open-paren token
    // and would pull in that helper, whose body references the undeclared u_Tex0
    // transform uniform → "u_Tex0Transform : undeclared identifier" → won't compile.
    vec2 kCoord = (inverse(modelTransform) * vec3(coord, 1.0)).xy;
    vec4 kCol = __source__(kCoord);
    return kCol;
}

void main() {
    fragColor = glitchKaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_spikeCount, u_regularity, u_roundedness, u_perspective, u_modelTransform);
}
