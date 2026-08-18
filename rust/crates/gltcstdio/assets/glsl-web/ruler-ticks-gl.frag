#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_glow (U[5].x)
#define u_color1 (U[6])
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

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


















































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float rt_response(float d, float glow) {
    // Scale `d` so the per-distance units match BarCode's tuning
    // (where `d` was in O(1) units). Our ticks are O(0.001..0.05)
    // wide; multiply `d` by 100 so the smoothstep cutoff `[2, 1.2]`
    // works at a sensible pos-space distance, and `glow*0.01` becomes
    // a sensible halo radius. This rescaling is the only freedom in
    // matching Pap's Gaussian blur — see header note.
    float dn = d * 100.0;
    float base = (glow < 0.2) ? 1.0 : 1.0 + (glow - 0.2) * 4.0;
    return base * (dn <= 0.0 ? 1.0 : min(1.0, glow * 0.01 / dn)) * smoothstep(2.0, 1.2, dn);
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec4 spilloverChannels(vec4 c) {
    float overflow = (max(c.r-1.0, 0.0) + max(c.g-1.0, 0.0) + max(c.b-1.0, 0.0)) / 3.0;
    c.r += overflow;
    c.g += overflow;
    c.b += overflow;
    return c;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 rulerTicksGL(vec2 pos, vec2 outPos,
                  float glow, vec4 color1,
                  mat3 modelTransform) {
    // Standard pap2mp inverse-on-shader convention (mirrors
    // BarCode.kt: `u = tf(inverse(modelTransform), uv)`).
    vec2 p = (inverse(modelTransform) * vec3(pos, 1.0)).xy;

    // Pap loop: `y = -H/2 .. H/2 step H/100` → in pos-y space
    // (1 unit = H/2 pixels) that's `y = -1 .. 1 step 0.02`. So
    // `step = 0.02` and `n = round(p.y / step)` is the tick index.
    float step = 0.02;
    float n = floor(p.y / step + 0.5);

    // Out-of-range: no tick → return source untouched.
    if (abs(n) > 50.0) return __source__(pos);

    // Big tick every 5 indices (Pap `N % 5 == 0`).
    float bigTick = (mod(abs(n) + 0.5, 5.0) < 1.0) ? 1.5 : 1.0;

    // Tick rectangle half-extents in pos-space:
    //   hTick      = H/40  * bigTick → 0.05  * bigTick (pos-x)
    //   strokeHalf = H*0.0015*bigTick → 0.0015*bigTick (pos-y)
    //   (Pap's stroke is drawn around the line; half-width = stroke/2;
    //    we use the BarCode pattern where the rectangle dim is the
    //    full half-extent.)
    float hTick = 0.05 * bigTick;
    float strokeHalf = 0.0015 * bigTick;

    // SDF to the nearest tick (centered at (0, n*step)).
    vec2 q = vec2(p.x, p.y - n * step);
    float d = sdRectangle(q, vec2(hTick, strokeHalf));

    float k = rt_response(d, glow);

    vec4 bkgCol = __source__(pos);
    // k overshoots 1 in the glow bloom; the excess is a brightness multiplier, min(1,k) is coverage.
    vec4 glowCol = spilloverChannels(vec4(color1.rgb * max(1.0, k), color1.a));
    vec4 outCol = mergeColor(bkgCol, vec4(glowCol.rgb, glowCol.a * min(1.0, k)));

    return outCol;
}

void main() {
    fragColor = rulerTicksGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_glow, u_color1, u_modelTransform);
}
