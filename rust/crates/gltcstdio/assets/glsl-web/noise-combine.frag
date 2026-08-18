#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
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
#define u_octaves (int(U[9].x))
#define u_randomSeed (U[10].x)
#define u_shapeAspectRatio (U[11].x)
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_viewTransform1 (mat3(U[15].xyz, U[16].xyz, U[17].xyz))
#define u_viewTransform2 (mat3(U[18].xyz, U[19].xyz, U[20].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) textureLod(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































vec2 aRatio(float a) {
	return vec2(a, 1.0)/(1.0+a)*2.0;
}

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

vec4 noiseCombine(vec2 pos, vec2 outPos, float coverage, float aspectRatio, int octaves, float randomSeed, float shapeAspectRatio, mat3 modelTransform, vec2 source1Dim, vec2 source2Dim, mat3 viewTransform1, mat3 viewTransform2) {
    vec2 u = tf(inverse(modelTransform), pos);
    vec2 uv = u / aRatio(shapeAspectRatio);

    // Octave sum over the shared 3D Perlin field, sliced at z = randomSeed so each seed
    // is an independent field (same approach as PerlinNoise2). Weights and the per-octave
    // transform match perlinOctaveNoise, so octaveStd below stays valid.
    mat2 octaveTransform = 2.1111 * mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
    float k = 1.0;
    float xacc = 0.0;
    float total = 0.0;
    for (int i = 0; i < octaves; ++i) {
        xacc += k * perlinNoise3(vec3(uv, randomSeed));
        total += k;
        k *= 0.5;
        uv = octaveTransform * uv;
    }
    float x = xacc / total;

    // Perceptually-linear coverage: map coverage through the noise's quantile so that the
    // source2 fraction ~= coverage (at coverage 0.3, ~30% of the frame is source2). The
    // octave noise is ~Gaussian about 0.5 with std `sigma`; its quantile is
    // 0.5 - sigma*probit(t), and the logistic logit approximates the Gaussian probit closely
    // (Phi(x) ~= 1/(1+exp(-1.702 x))). octaveStd is the relative std of the weighted octave
    // sum (1.0 at 1 octave, ->~0.577 as octaves grow) so the calibration tracks the octave
    // count; 0.16 is the single-octave absolute std. Because logit -> +/-inf at the ends,
    // clamping coverage drives the threshold past the [0,1] noise bounds — guaranteeing
    // pure source1 at 0 and pure source2 at 1 for any octave count. logit has finite
    // nonzero slope at the center, so there is no zero-slope plateau (the earlier power
    // curve's flat center read as a pause mid-animation).
    float octaveStd = sqrt((1.0 - pow(0.25, float(octaves))) / (3.0 * pow(1.0 - pow(0.5, float(octaves)), 2.0)));
    float sigma = 0.16 * octaveStd; // tune up if the source2 fraction outruns coverage, down if it lags
    float p = clamp(coverage, 1e-5, 1.0 - 1e-5);
    float threshold = 0.5 - sigma * log(p / (1.0 - p)) / 1.702;

    // Output aspect ratio: explicit value if given, else source1's (the negative sentinel
    // from FitAspectRatioOrUnspecified means "unspecified"). Cover-fit both sources into
    // that view so no out-of-bounds areas show; per-source viewTransform pans/zooms on top.
    float outAr = aspectRatio > 0.0 ? aspectRatio : source1Dim.x / source1Dim.y;
    mat3 fit1 = getCoverFitTransform(outAr, source1Dim);
    mat3 fit2 = getCoverFitTransform(outAr, source2Dim);

    if (x < threshold) return __source1__(tf(fit1 * inverse(viewTransform1), pos));
    else return __source2__(tf(fit2 * inverse(viewTransform2), pos));
}

void main() {
    fragColor = noiseCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_coverage, u_aspectRatio, u_octaves, u_randomSeed, u_shapeAspectRatio, u_modelTransform, u_source1Dim, u_source2Dim, u_viewTransform1, u_viewTransform2);
}
