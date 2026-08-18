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
#define u_time (U[5].x)
#define u_mode (int(U[6].x))
#define u_dampening (U[7].x)
#define u_roundness (U[8].x)
#define u_color1 (U[9])
#define u_color2 (U[10])
#define u_border (U[11].x)
#define u_color3 (U[12])
#define u_color4 (U[13])





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















































































































































































































































































































































vec4 checkerboardLooper(vec2 uv, vec2 outPos, float time, int mode, float dampening,
        float roundness, vec4 color1, vec4 color2,
        float border, vec4 color3, vec4 color4) {
    float t = fract(time * 0.5);
    float phase = step(0.5, t);
    float progress = fract(t * 2.0);

    // phase 0: color1 tiles rotate over color2 background
    // phase 1: color2 tiles rotate over color1 background
    vec4 bgInner = mix(color2, color1, phase);
    vec4 fgInner = mix(color1, color2, phase);
    vec4 bgBorder = mix(color4, color3, phase);
    vec4 fgBorder = mix(color3, color4, phase);

    // find nearest foreground tile center
    vec2 cell = floor(uv);
    float parity = mod(cell.x + cell.y, 2.0);
    if (abs(parity - phase) > 0.5) {
        vec2 f = fract(uv);
        if (min(f.x, 1.0 - f.x) < min(f.y, 1.0 - f.y))
            cell.x += f.x < 0.5 ? -1.0 : 1.0;
        else
            cell.y += f.y < 0.5 ? -1.0 : 1.0;
    }

    // direction bitmask
    int ci = int(cell.x);
    int cj = int(cell.y);
    int flip = 0;
    if ((mode & 1) != 0) flip ^= int(phase);
    if ((mode & 2) != 0) flip ^= ci & 1;
    if ((mode & 4) != 0) flip ^= cj & 1;
    if ((mode & 8) != 0) flip ^= int(mod(floor(cell.x * 0.5) + floor(cell.y * 0.5), 2.0));

    // easing
    float e = 1.0 + dampening * 4.0;
    progress = 1.0 - pow(1.0 - progress, e);

    // corner radius: fully rounded ~80% of cycle
    float rAnim = smoothstep(0.0, 0.1, progress) * (1.0 - smoothstep(0.9, 1.0, progress));
    float r = roundness * rAnim;

    // flat rotation
    float dir = (flip != 0) ? -1.0 : 1.0;
    float angle = progress * 1.5707963 * dir;
    vec2 d = uv - (cell + 0.5);
    float ca = cos(angle), sa = sin(angle);
    vec2 rd = vec2(ca * d.x + sa * d.y, -sa * d.x + ca * d.y);

    // rounded rect SDF for outer edge
    vec2 q = abs(rd) - vec2(0.5) + vec2(r);
    float sdf = min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;

    if (sdf < 0.0) {
        // inside the foreground tile -- check border vs inner
        if (border > 0.0) {
            float ri = r * max(1.0 - border / 0.5, 0.0);
            vec2 qi = abs(rd) - vec2(0.5 - border) + vec2(ri);
            float sdfInner = min(max(qi.x, qi.y), 0.0) + length(max(qi, 0.0)) - ri;
            if (sdfInner < 0.0)
                return fgInner;
            return fgBorder;
        }
        return fgInner;
    }

    // background: draw non-rotating tiles with border
    vec2 bgCell = floor(uv);
    float bgPar = mod(bgCell.x + bgCell.y, 2.0);
    if (abs(bgPar - phase) > 0.5) {
        vec2 bd = fract(uv) - 0.5;
        if (border > 0.0 && (abs(bd.x) > 0.5 - border || abs(bd.y) > 0.5 - border))
            return bgBorder;
        return bgInner;
    }
    return bgInner;
}

void main() {
    fragColor = checkerboardLooper((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_time, u_mode, u_dampening, u_roundness, u_color1, u_color2, u_border, u_color3, u_color4);
}
