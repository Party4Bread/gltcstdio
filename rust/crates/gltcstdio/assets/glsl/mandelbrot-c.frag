#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_offsetTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_texTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_iterations (int(U[15].x))
#define u_julianess (U[16].x)
#define u_power (U[17].x)
#define u_offset (U[18].x)
#define u_colorIn (U[19])
#define u_colorOut (U[20])

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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 mandelbrotC(vec2 pos, vec2 outPos, int source_specified, mat3 modelTransform, mat3 offsetTransform, mat3 texTransform, int iterations, float julianess, float power, float offset, vec4 colorIn, vec4 colorOut) {
    float cj = cos(julianess * PI*0.5);
    float sj = sin(julianess * PI*0.5);

    mat3 invModelTransform = inverse(modelTransform*mat3(vec3(offsetTransform[0].xy, 0.0), vec3(offsetTransform[1].xy, 0.0), vec3(0.0, 0.0, 1.0)));

    vec2 uv = tf(invModelTransform, pos);
    vec2 t = cj*uv + sj*offsetTransform[2].xy;
    vec2 z0 = sj*uv + cj*offsetTransform[2].xy;
    vec2 z = z0;

    vec2 prev = t;
    int iter = 0;
    float d2 = 0.0;
    bool outside = true;

    if (power == 2.0) {
        while (iter < iterations) {
            ++iter;
            prev = z;
            z.x = prev.x*prev.x - prev.y*prev.y + t.x;
            z.y = 2.0*prev.x*prev.y + t.y;
            d2 = dot(z, z);
            if (d2 > 400000000.0) { outside = false; break; }
        }
    }
    else if (power == 3.0) {
        while (iter < iterations) {
            ++iter;
            prev = z;
            z.x = prev.x*prev.x*prev.x - 3.0*prev.y*prev.y*prev.x + t.x;
            z.y = -prev.y*prev.y*prev.y + 3.0*prev.x*prev.x*prev.y + t.y;
            d2 = dot(z, z);
            if (d2 > 400000000.0) { outside = false; break; }
        }
    }
    else {
        float d = length(z);
        while (iter < iterations) {
            ++iter;
            prev = z;
            float angle = atan(prev.y, prev.x);
            float dp = pow(d, power);
            z.x = dp*cos(power*angle) + t.x;
            z.y = dp*sin(power*angle) + t.y;
            d = length(z);
            if (d > 20000.0) { outside = false; break; }
        }
        d2 = d*d;
    }

    float d = sqrt(d2);
    // Branch-cut-free angle via acos(x/|v|). atan2 has a seam on the -x axis that
    // survives through the source sampler when sourceTransform scales the UV,
    // breaking the period-2 mirror wrap that would otherwise hide it.
    float angleT = acos(t.x / max(length(t), 1e-6));
    float angleZ0 = acos(z0.x / max(length(z0), 1e-6));
    float angle = cj*angleT + sj*angleZ0;

    float tx = angle/PI * 2.0 - 1.0;
    float ty = 1.0 + float(iter) - log(log(max(d, 2.718281828)))/log(max(power, 1.0001));
    if (offset != 0.0) ty = pow(max(ty, 0.0001), pow(1.05, -offset));
    vec2 s = vec2(tx, ty);

    vec4 texCol = __source__(tf(inverse(texTransform), s));
    vec4 inoutCol = outside ? colorIn : colorOut;
    return vec4(mix(texCol.rgb, inoutCol.rgb, inoutCol.a), texCol.a);
}

void main() {
    fragColor = mandelbrotC((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_modelTransform, u_offsetTransform, u_texTransform, u_iterations, u_julianess, u_power, u_offset, u_colorIn, u_colorOut);
}
