#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_chroma (U[6].x)
#define u_ringing (U[7].x)
#define u_balance (U[8].x)
#define u_variability (U[9].x)
#define u_randomSeed (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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











































































































































































































































































































































// centred YCbCr (no constant offset) — a pure linear map, so it can be
// applied to DCT coefficients as well as pixels (DCT and a linear colour
// transform commute), which lets us quantize chroma separately.
















vec3 jpegBlockHash3(vec2 b) {
    return fract(sin(vec3(dot(b, vec2(127.1, 311.7)), dot(b, vec2(269.5, 183.3)), dot(b, vec2(419.2, 371.9)))) * 43758.5453);
}

vec4 jpegHash4(vec2 b) {
    return fract(sin(vec4(dot(b, vec2(127.1, 311.7)), dot(b, vec2(269.5, 183.3)), dot(b, vec2(419.2, 371.9)), dot(b, vec2(523.7, 283.3)))) * 43758.5453);
}

vec3 jpegRgb2ycc(vec3 c) {
    return vec3(
        dot(c, vec3( 0.299,     0.587,     0.114)),
        dot(c, vec3(-0.168736, -0.331264,  0.5)),
        dot(c, vec3( 0.5,      -0.418688, -0.081312)));
}

vec3 jpegYcc2rgb(vec3 y) {
    return vec3(
        y.x                  + 1.402   * y.z,
        y.x - 0.344136 * y.y - 0.714136 * y.z,
        y.x + 1.772   * y.y);
}

vec4 jpegCrushGL(vec2 pos, vec2 outPos, float intensity, float chroma, float ringing, float balance, float variability, float randomSeed, mat3 modelTransform) {
    vec4 inCol = __source__(pos);

    const int N = 8;
    // Standard inverse-transform lattice — the block grid lives in im-space
    // (im = inverse(modelTransform)), so the decompose-based touch client drives
    // all gestures naturally. Default modelTransform = scale(1/24) → im = scale(24)
    // → 24 blocks across. Pinch-OUT raises modelTransform's scale → im's scale drops
    // → fewer, BIGGER blocks (the natural direction; reading modelTransform DIRECTLY
    // inverted it). Pan comes from im's translation.
    mat3 im = inverse(modelTransform);
    float res = max(1.0, length(im[0].xy));                      // blocks across
    float blockUV = 1.0 / res;
    vec2 L = (im * vec3(pos, 1.0)).xy;
    vec2 cbidx = floor(L);
    vec2 lc = clamp(floor(fract(L) * float(N)), 0.0, float(N) - 1.0);

    // crush amount -> retained low frequencies (keep) + quantization step
    int keep = int(clamp(6.0 - intensity * 5.0, 1.0, 6.0));
    float quant = 0.02 + intensity * 0.6;
    // chroma subsampling: keep fewer chroma frequencies (keepC <= keep) and quantize coarser
    int keepC = int(clamp(float(keep) - chroma * 4.0, 1.0, 6.0));
    float quantC = quant * (1.0 + chroma * 8.0);
    float chromaMix = clamp(chroma, 0.0, 1.0);

    float aN0 = sqrt(1.0 / float(N));
    float aNk = sqrt(2.0 / float(N));
    float PI2N = PI / (2.0 * float(N));

    vec3 result = vec3(0.0);
    for (int u = 0; u < 8; ++u) {
        if (u >= keep) break;
        float au = (u == 0) ? aN0 : aNk;
        for (int v = 0; v < 8; ++v) {
            if (v >= keep) break;
            float av = (v == 0) ? aN0 : aNk;

            // forward coefficient over the N x N block
            vec3 F = vec3(0.0);
            for (int x = 0; x < 8; ++x) {
                float bx = cos((2.0 * float(x) + 1.0) * float(u) * PI2N);
                for (int y = 0; y < 8; ++y) {
                    // forward-map the lattice point back to pos space to sample
                    vec2 s = (modelTransform * vec3(cbidx + (vec2(float(x), float(y)) + 0.5) / float(N), 1.0)).xy;
                    vec3 f = __source__(s).rgb;
                    F += f * bx * cos((2.0 * float(y) + 1.0) * float(v) * PI2N);
                }
            }
            F *= au * av;

            // quantize. luma at `quant`; chroma subsampling routes the coeff through
            // centred YCbCr (coarser quant + dropped high chroma freqs), crossfaded back.
            vec3 Frgb = floor(F / quant + 0.5) * quant;
            if (chroma > 0.0) {
                vec3 ycc = jpegRgb2ycc(F);
                ycc.x  = floor(ycc.x  / quant  + 0.5) * quant;
                ycc.yz = floor(ycc.yz / quantC + 0.5) * quantC;
                if (u >= keepC || v >= keepC) ycc.yz = vec2(0.0);
                F = mix(Frgb, jpegYcc2rgb(ycc), chromaMix);
            } else {
                F = Frgb;
            }

            // ringing: boost AC (more for higher freqs) so edge overshoot grows into halos
            float acw = float(u + v);
            if (ringing > 0.0 && acw > 0.0) F *= 1.0 + ringing * 0.3 * acw;

            result += au * av * F
                    * cos((2.0 * lc.x + 1.0) * float(u) * PI2N)
                    * cos((2.0 * lc.y + 1.0) * float(v) * PI2N);
        }
    }

    // Clustered corruption distributed by five unaligned anisotropic grids whose
    // per-type votes MULTIPLY -> organic blobs/streaks. variability sign flips streak axis.
    if (abs(variability) > 0.0) {
        vec2 gc = cbidx + 0.5;
        float s = randomSeed;

        vec4 w = vec4(1.0);
        w *= jpegHash4(floor(gc * vec2(0.043, 0.052) + vec2(11.3) + s));
        w *= jpegHash4(floor(gc * vec2(0.075, 0.091) + vec2(53.1) + s * 2.1));
        w *= jpegHash4(floor(gc * vec2(0.244, 0.270) + vec2(17.5) + s * 2.9));
        vec2 kA = (variability >= 0.0) ? vec2(0.037, 0.213) : vec2(0.213, 0.037);
        vec2 kB = (variability >= 0.0) ? vec2(0.024, 0.131) : vec2(0.131, 0.024);
        w *= pow(jpegHash4(floor(gc * kA + vec2(31.7) + s * 1.3)), vec4(2.5));
        w *= pow(jpegHash4(floor(gc * kB + vec2( 7.9) + s * 1.7)), vec4(1.6));

        int type = 0; float best = w.x;
        if (w.y > best) { best = w.y; type = 1; }
        if (w.z > best) { best = w.z; type = 2; }
        if (w.w > best) { best = w.w; type = 3; }

        float density = clamp(abs(variability), 0.0, 1.0);
        float g = pow(best, 0.14);
        if (g > mix(1.02, 0.25, pow(density, 1.3))) {
            if (type == 0) {
                vec3 tint = jpegBlockHash3(floor(cbidx * vec2(0.10, 0.35)) + vec2(s, 5.0));
                vec2 disp = (jpegBlockHash3(cbidx + vec2(s, 91.0)).xy - 0.5) * blockUV * 6.0;
                vec3 src = __source__(pos + disp).rgb;
                result = mix(src, tint, 0.5);
            } else if (type == 1) {
                vec3 U = floor(jpegBlockHash3(cbidx + vec2(s, 17.0)) * 6.0) + 1.0;
                vec3 V = floor(jpegBlockHash3(cbidx + vec2(s, 41.0)) * 6.0) + 1.0;
                vec3 dc = jpegBlockHash3(cbidx + vec2(s, 5.0));
                vec3 amp = jpegBlockHash3(cbidx + vec2(s, 71.0));
                result = dc + amp * cos((2.0 * lc.x + 1.0) * U * PI2N) * cos((2.0 * lc.y + 1.0) * V * PI2N);
            } else if (type == 2) {
                vec2 disp = (jpegBlockHash3(cbidx + vec2(s, 23.0)).xy - 0.5) * blockUV * 5.0;
                result = vec3(
                    __source__(pos + disp).r,
                    __source__(pos - disp).g,
                    __source__(pos + disp.yx).b);
            } else {
                result = jpegBlockHash3(floor(L * float(N)) + vec2(s, 3.0));
            }
        }
    }

    vec4 outCol = vec4(clamp(result, 0.0, 1.0), inCol.a);
    // balance: positive blends toward source; negative fades toward the difference image
    float bal = balance;
    if (bal >= 0.0) {
        outCol.rgb = mix(outCol.rgb, inCol.rgb, bal);
    } else {
        outCol.rgb = mix(outCol.rgb, abs(outCol.rgb - inCol.rgb), -bal);
    }
    return outCol;
}

void main() {
    fragColor = jpegCrushGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_chroma, u_ringing, u_balance, u_variability, u_randomSeed, u_modelTransform);
}
