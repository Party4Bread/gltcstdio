#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_aspectRatio (U[4].x)
#define u_source1Dim (U[5].xy)
#define u_source2Dim (U[6].xy)
#define u_outDim (U[7].xy)
#define u_coverage (U[8].x)
#define u_mode (int(U[9].x))
#define u_style (int(U[10].x))
#define u_thickness (U[11].x)
#define u_patternDensity (U[12].x)
#define u_viewTransform1 (mat3(U[13].xyz, U[14].xyz, U[15].xyz))
#define u_viewTransform2 (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) texture(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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















































































































































































































































































































































mat3 getCoverFitTransform(float aspectRatio, vec2 imageDims) {
    float srcAr = imageDims.x / imageDims.y;
    float h = min(1.0, srcAr / aspectRatio);
    return mat3(h, 0.0, 0.0, 0.0, h, 0.0, 0.0, 0.0, 1.0);
}

vec3 rndUnit3(vec3 p) {
    vec3 u = fract(p * vec3(.1031, .1030, .0973));
    u += dot(u, u.yxz+33.33);
    vec3 h = fract((u.xxy + u.yxx)*u.zyx);
    return normalize(h-0.5);
}

float dotGridGradient3(vec3 g, vec3 u) {
    return dot(u-g, rndUnit3(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinRelNoise3(vec3 p) {
    vec3 s = vec3(1.0, 0.0, 0.0);
    vec3 f = floor(p);
    vec3 d = p-f;
    float ix00 = smix(dotGridGradient3(f, p), dotGridGradient3(f+s, p), d.x);
    float ix10 = smix(dotGridGradient3(f+s.yxz, p), dotGridGradient3(f+s.xxz, p), d.x);
    float ix01 = smix(dotGridGradient3(f+s.yyx, p), dotGridGradient3(f+s.xyx, p), d.x);
    float ix11 = smix(dotGridGradient3(f+s.yxx, p), dotGridGradient3(f+s.xxx, p), d.x);
    float iy0 = smix(ix00, ix10, d.y);
    float iy1 = smix(ix01, ix11, d.y);
    return smix(iy0, iy1, d.z);
}

float perlinNoise3(vec3 p) {
    return 0.5+perlinRelNoise3(p)*0.5;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 sweepCombine(vec2 pos, vec2 outPos, float coverage, int mode, int style, float thickness, float patternDensity, float aspectRatio, vec2 source1Dim, vec2 source2Dim, mat3 viewTransform1, mat3 viewTransform2) {
    float outAr = aspectRatio > 0.0 ? aspectRatio : source1Dim.x / source1Dim.y;

    float y = -pos.y; // flip to visual orientation (+y = top)

    // `s` (~0..1) drives the reveal band; source2 appears where `s` is largest first, so
    // the "from" edge has s~1. `pAlong` is the sweep-aligned 1D coordinate the `lines`
    // style runs along (isotropic screen units so stripe spacing is aspect-stable).
    // `halftone` ignores it and uses a fixed screen-space grid (see the style block).
    float s; float pAlong;
    if (mode == 0) {            // top to bottom
        s = y * 0.5 + 0.5;
        pAlong = y;
    } else if (mode == 1) {     // bottom to top
        s = 0.5 - y * 0.5;
        pAlong = y;
    } else if (mode == 2) {     // left to right
        s = 0.5 - (pos.x / outAr) * 0.5;
        pAlong = pos.x;
    } else if (mode == 3) {     // right to left
        s = (pos.x / outAr) * 0.5 + 0.5;
        pAlong = pos.x;
    } else if (mode == 4) {     // diagonal
        s = ((pos.x / outAr) + y) * 0.25 + 0.5;
        pAlong = (pos.x + y) * 0.70710678;
    } else if (mode == 5) {     // clock: growing pie from 12 o'clock, clockwise
        // pos.x and y are already isotropic screen units, so the screen-space angle uses
        // raw pos.x (dividing by outAr would distort it -> anisotropic sweep).
        float a = atan(pos.x, y);   // 0 at 12 o'clock, increasing clockwise
        if (a < 0.0) a += PI2;
        s = 1.0 - a / PI2;
        pAlong = a;                          // angular (lines -> radial spokes)
    } else if (mode == 6) {     // 180: half-pie about a fixed pivot at the bottom middle
        vec2 d = vec2(pos.x, y + 1.0);          // pivot at bottom-middle (y = -1), screen units
        float a = atan(d.y, d.x);               // (0, PI) across the upper half-plane
        s = 1.0 - a / PI;                        // grows from the right (a = 0)
        pAlong = a;
    } else if (mode == 7) {     // anti-diagonal
        s = ((pos.x / outAr) - y) * 0.25 + 0.5;
        pAlong = (pos.x - y) * 0.70710678;
    } else if (mode == 8) {     // radial: circle growing from the centre (iris)
        float r = length(vec2(pos.x, y));
        s = 1.0 - r / length(vec2(outAr, 1.0));
        pAlong = r;                          // lines -> concentric rings
    } else if (mode == 9) {     // diamond: L1 box growing from the centre
        float r = abs(pos.x) + abs(y);
        s = 1.0 - r / (outAr + 1.0);
        pAlong = r;
    } else {                    // box: rectangle of the image's aspect, growing from the centre
        // normalize each axis by its own half-extent so all four edges are reached together
        float r = max(abs(pos.x) / outAr, abs(y));
        s = 1.0 - r;
        pAlong = r;
    }

    // Transition band of width `thickness`, slid by coverage so coverage 0 -> all source1
    // and coverage 1 -> all source2 (endpoints pure). local: 0 on source1 side, 1 on source2.
    float lo = 1.0 - coverage * (1.0 + thickness);
    float local = clamp((s - lo) / max(thickness, 1e-4), 0.0, 1.0);

    // Style resolves `local` (the gradient fraction) into a blend. `lines` runs a 1D
    // pattern along the sweep so stripes stay parallel to the boundary; `halftone` uses a
    // *fixed* screen-space dot grid (independent of the sweep) so its dots don't polar-
    // distort under the rotational sweeps — the sweep only contributes the threshold.
    // Both threshold styles stay bounded: where local clamps to 0/1 the test is constant.
    float blend;
    if (style == 1) {           // lines
        float freq = 1.0 + patternDensity * 20.0;
        float pat = 0.5 + 0.5 * cos(pAlong * freq);
        blend = step(pat, local);
    } else if (style == 2) {    // halftone (fixed screen-space grid)
        float freq = 1.0 + patternDensity * 20.0;
        float pat = 0.5 + 0.5 * cos(pos.x * freq) * cos(pos.y * freq);
        blend = step(pat, local);
    } else if (style == 3) {    // noise: Perlin field (NoiseCombine's default look)
        // The field's seed rides coverage 0 -> 4, so the noise churns/evolves as the
        // sweep progresses rather than being a static dissolve mask.
        float freq = 1.0 + patternDensity * 20.0;
        vec2 uv = pos * freq;
        float seed = coverage * 4.0;
        mat2 oct = 2.1111 * mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
        float k = 1.0; float acc = 0.0; float tot = 0.0;
        for (int i = 0; i < 4; ++i) {        // 4 octaves, matching NoiseCombine's default
            acc += k * perlinNoise3(vec3(uv, seed));
            tot += k;
            k *= 0.5;
            uv = oct * uv;
        }
        float n = acc / tot;
        // Flatten the bell-shaped Perlin distribution to ~uniform so coverage is
        // perceptually linear (the NoiseCombine fix, applied to the pattern): the field is
        // ~Gaussian about 0.5 with std `sigma`, and the logistic approximates its CDF, so
        // logistic(n) is ~uniform on [0,1] and step(.,local) reveals a fraction ~= local
        // instead of bunching the change near the middle of the noise range.
        float sigma = 0.098;   // 4-octave noise std (0.16 * octaveStd(4))
        float pat = 1.0 / (1.0 + exp(-1.702 * (n - 0.5) / sigma));
        blend = step(pat, local);
    } else {                    // gradient
        blend = local;
    }

    vec4 c1 = __source1__(tf(getCoverFitTransform(outAr, source1Dim) * inverse(viewTransform1), pos));
    vec4 c2 = __source2__(tf(getCoverFitTransform(outAr, source2Dim) * inverse(viewTransform2), pos));
    return mix(c1, c2, blend);
}

void main() {
    fragColor = sweepCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_coverage, u_mode, u_style, u_thickness, u_patternDensity, u_aspectRatio, u_source1Dim, u_source2Dim, u_viewTransform1, u_viewTransform2);
}
