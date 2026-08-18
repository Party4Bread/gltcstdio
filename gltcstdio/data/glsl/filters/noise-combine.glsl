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
