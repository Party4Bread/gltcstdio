#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_thickness (U[7].x)
#define u_angle (U[8].x)
#define u_color1 (U[9])
#define u_color2 (U[10])

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec2 osc_getStart(vec2 p, vec2 dir, vec2 dim) {
    float kx1 = dir.x==0.0 ? -1.0 : (-dim.x-p.x)/dir.x;
    float kx2 = dir.x==0.0 ? -1.0 : (dim.x-p.x)/dir.x;
    float ky1 = dir.y==0.0 ? -1.0 : (-dim.y-p.y)/dir.y;
    float ky2 = dir.y==0.0 ? -1.0 : (dim.y-p.y)/dir.y;
    float k = kx1;
    if (k<0.0 || (kx2>=0.0 && kx2<k)) k = kx2;
    if (k<0.0 || (ky2>=0.0 && ky2<k)) k = ky2;
    if (k<0.0 || (ky1>=0.0 && ky1<k)) k = ky1;
    return p + k*dir;
}

vec4 oscilloscope(vec2 pos, vec2 outPos, float intensity, float thickness, float angle, vec4 color1, vec4 color2, vec2 sourceDim) {
    float ratio = sourceDim.x / sourceDim.y;
    // Pap: dir = vec2(cos(u_Phase), sin(u_Phase)).
    vec2 dir = vec2(cos(angle), sin(angle));

    float pixel = 2.0 / sourceDim.y;
    // Pap: step = pixel * 1.0 * u_Step; u_Step hardcoded to 1.0 in
    // the Pap surface (length param hidden, default 1).
    float step = pixel;

    vec2 dim = vec2(ratio, 1.0);
    vec2 p = osc_getStart(pos, -dir, dim);
    float acc = 0.0;

    // Pap: radius = u_Thickness*0.0002. Here Thickness is 0..1, so
    // multiply by 0.02 (= 0.0002 * 100).
    float radius = thickness * 0.02;
    // Pap: weight = step*333.33*intensity (intensity already 0..1).
    float weight = step * 333.33 * intensity;
    // Pap: N = int(min((dim.x+dim.y)*2.01/pixel,
    //                  ceil((length(p-pos)+radius)/step)))
    // Overshoot cap preserved — guards against runaway loops on
    // near-zero step.
    int N = int(min((dim.x + dim.y) * 2.01 / pixel,
                    ceil((length(p - pos) + radius) / step)));
    float bestL = 1e10;

    // Single fast branch — the slow branch (smoothing/contrast/
    // vignetting/brightness/scanlines) is unreachable in the Pap
    // Glitch Lab surface because none of those parameters are
    // exposed; their `create()` defaults are all 0.
    for (int i = 0; i < N; ++i) {
        vec4 c = __source__(p);
        float val = (c.r + c.g + c.b);
        acc += weight * val;
        if (acc >= 1.0) {
            vec2 dd = p - pos;
            bestL = min(bestL, dot(dd, dd)); // squared distance
            acc = 0.0;
        }
        p += step * dir;
    }
    float k = smoothstep(radius, 0.0, sqrt(bestL));

    vec4 bkgCol = __source__(pos);
    vec4 lineColor = vec4(mix(bkgCol.rgb, color2.rgb, color2.a), bkgCol.a);
    vec4 backColor = vec4(mix(bkgCol.rgb, color1.rgb, color1.a), bkgCol.a);
    // Pap-faithful: the original shader writes `clamp(k, 0.0, 1.0)`
    // (swapped arg order — looks like a bug, clamps the value `0.0`
    // between `1.0` and `k`). Preserved verbatim per bug-port
    // fidelity (rule #3) — `smoothstep` already returns 0..1 so the
    // net effect is a slight tonal shift vs the "correct"
    // `clamp(k, 0.0, 1.0)`.
    return mix(backColor, lineColor, clamp(k, 0.0, 1.0));
}

void main() {
    fragColor = oscilloscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_thickness, u_angle, u_color1, u_color2, u_sourceDim);
}
