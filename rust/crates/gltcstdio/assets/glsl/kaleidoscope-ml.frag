#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_spikeCount (int(U[5].x))
#define u_regularity (U[6].x)
#define u_roundness (U[7].x)
#define u_perspective (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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

float mlRand(float x) {
    return fract(sin(x * 43758.5453));
}

float mlDisplaceAngle(float angle, float maxDisplacement) {
    return angle + maxDisplacement * (mlRand(angle) - 0.5);
}

vec2 mlGetVecAngle2(vec2 u) {
    float len = length(u);
    if (len == 0.0) return vec2(0.0, len);
    float angle;
    if (abs(u.x) < abs(u.y)) {
        angle = acos(u.x / len);
        if (u.y < 0.0) angle = -angle;
    } else {
        angle = asin(u.y / len);
        if (u.x < 0.0) angle = -angle + (u.y > 0.0 ? PI : -PI);
    }
    return vec2(angle, len);
}

vec2 mlPerspective(vec2 u, float angle) {
    if (angle != 0.0) {
        float persp = tan(PI * 0.5 - angle);
        float Z = 4.0;
        float z = Z * u.y / (-Z * persp - u.y);
        return vec2(u.x * (z + Z) / Z, z * -persp);
    }
    return u;
}

vec2 mlReflect(float d, float sourceAngle, float alpha, float halfAlpha, float halfRoundedAngle) {
    if (sourceAngle > halfAlpha) sourceAngle = alpha - sourceAngle;

    float cornerAngle = halfAlpha - halfRoundedAngle;
    if (halfRoundedAngle == 0.0 || sourceAngle <= cornerAngle) {
        return d * vec2(cos(sourceAngle), sin(sourceAngle));
    } else {
        if (cornerAngle == 0.0) cornerAngle = 0.001;

        float x = d * cos(sourceAngle);
        float y = d * sin(sourceAngle);

        float cha = cos(halfAlpha);
        float sha = sin(halfAlpha);
        float cca = cos(cornerAngle);
        float sca = sin(cornerAngle);

        float A = ((sha / sca * cca - cha) * (sha / sca * cca - cha) - 1.0);
        float B = 2.0 * (cha * x + sha * y);
        float C = -(x * x + y * y);
        float delta2 = B * B - 4.0 * A * C;
        if (delta2 < 0.0) {
            return vec2(x, y);
        }
        float l = (-B + sqrt(delta2)) / (2.0 * A);
        float cx = l * cha;
        float cy = l * sha;
        float k = l * sha / sca;

        float Xp = k * cca;
        float Yp = k * sca;
        float R = Xp - cx;

        return vec2(Xp, Yp + R * (sourceAngle - cornerAngle));
    }
}

vec4 kaleidoscopeML(vec2 uv, vec2 outPos, int spikeCount, float regularity, float roundness, float perspective, mat3 modelTransform) {
    vec2 u = mlPerspective(uv, perspective);

    float d = length(u);
    float sourceAngle = 0.0;

    float variability = 1.0 - regularity;
    float halfAlpha;
    float alpha;
    if (d > 0.0) {
        vec2 angLen = mlGetVecAngle2(u);
        float ang = angLen.x;
        if (ang < 0.0) ang += PI2;

        if (variability == 0.0) {
            halfAlpha = PI / float(spikeCount);
            alpha = halfAlpha * 2.0;
            sourceAngle = mod(ang, alpha);
        } else {
            float maxDisplacement = PI2 * 2.0 / float(spikeCount);
            float spikeAngle1 = 0.0;
            float spikeAngle2 = mlDisplaceAngle(PI2 / float(spikeCount), variability * maxDisplacement);

            for (int i = 0; i < spikeCount; ++i) {
                if ((i == spikeCount - 1) || (ang <= spikeAngle2)) {
                    alpha = spikeAngle2 - spikeAngle1;
                    halfAlpha = alpha / 2.0;
                    sourceAngle = ang - spikeAngle1;
                    break;
                } else {
                    spikeAngle1 = spikeAngle2;
                    spikeAngle2 = float(i + 2) * PI2 / float(spikeCount);
                    if (i != spikeCount - 2)
                        spikeAngle2 = mlDisplaceAngle(spikeAngle2, variability * maxDisplacement);
                }
            }
        }
    }

    float halfRoundedAngle = halfAlpha * roundness;
    vec2 coord = mlReflect(d, sourceAngle, alpha, halfAlpha, halfRoundedAngle);
    coord = (inverse(modelTransform) * vec3(coord, 1.0)).xy;
    return __source__(coord);
}

void main() {
    fragColor = kaleidoscopeML((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_spikeCount, u_regularity, u_roundness, u_perspective, u_modelTransform);
}
