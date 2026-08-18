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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_dampening (U[7].x)
#define u_blend (U[8].x)
#define u_mirrorMode (int(U[9].x))
#define u_texTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 polarPlanet(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float dampening, float blend, int mirrorMode, mat3 texTransform) {
    vec2 u = uv;
    mat3 inverseTexTransform = inverse(texTransform);

    float d = length(u);

    float angle = atan(u.y, u.x);

    float phase = 0.0;

    if (mirrorMode==1) {
        angle = 2.0*(angle + phase);
        angle = mod(angle, PI4);
        if (angle > PI2) { angle = PI4-angle; }
    }
    else {
        angle = angle + phase;
        angle = mod(angle, PI2);
    }

    float blendedWidth = sourceDim.x * (1.0-blend*0.5);
    float fullRatio = sourceDim.x / sourceDim.y;
    float blendedRatio = blendedWidth / sourceDim.y;
    float xp = angle/PI - 1.0;
    float sx = blendedRatio * xp;

    float I = intensity;
    float sy = d <= I
        ? 1.0 - d*2.0
        : I < 1.0
            ? 1.0 - (2.0*I + ((2.0-2.0*I)/log(2.0-I)) * log(1.0+d-I))
            : 1.0 - (2.0 + 2.0*log(d));

    float xpp = xp/fullRatio*blendedRatio;
    float blendStart = 1.0-blend;
    if (abs(xpp) <= blendStart) {
        vec2 pos = vec2(sx, sy);
        return __source__(tf(inverseTexTransform, pos));
    }
    else {
        float k = (abs(xpp)-blendStart) / blend;
        vec2 pos1 = vec2(sx, sy);
        float sx2 = xp>=0.0 ? sx - blendedRatio*2.0 : sx + blendedRatio*2.0;
        vec2 pos2 = vec2(sx2, sy);
        return mix(__source__(tf(inverseTexTransform, pos1)), __source__(tf(inverseTexTransform, pos2)), k);
    }
}

void main() {
    fragColor = polarPlanet((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_dampening, u_blend, u_mirrorMode, u_texTransform);
}
