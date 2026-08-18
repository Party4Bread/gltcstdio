vec4 rwdGetRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0 - abs(w)),
        max(0.0, w),
        1.0
    );
}

vec4 ripplesWithDispersionGL(vec2 pos, vec2 outPos, float intensity, float dispersion, float dampening, int count, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;

    float d = length(u);
    float rippleCount = float(count);

    if (d >= 1.0) {
        return __source__(pos);
    } else {
        // Pap: dampening>=0 ? pow(1-d, dampening*0.02) : pow(d, -dampening*0.05)
        //   with dampening in -1..1 (pap2mp) instead of -100..100 (Pap):
        float dampen = dampening >= 0.0
            ? pow(1.0 - d, dampening * 2.0)
            : pow(d, -dampening * 5.0);

        if (dispersion == 0.0) {
            // Single-sample path: matches Ripples.kt sans `spacing`.
            //   Pap: intensity*0.01 * sin(d*count*PI) * dampen
            //     with intensity in -1..1: drop the *0.01.
            float dilation = 1.0 + intensity * sin(d * rippleCount * PI) * dampen;
            vec2 coord = (modelTransform * vec3(dilation * u, 1.0)).xy;
            return __source__(coord);
        } else {
            // Dispersion: integrate intensity-perturbed samples across
            // w in -1..1 with RGB-weighted accumulation. 41-sample loop
            // hardcoded in Pap; preserved. Note Pap uses `*0.1` for the
            // dispersion spread (10× wider than Globe's `*0.01`).
            float wStep = 0.05;
            vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
            vec4 totalWeight = vec4(0.0, 0.0, 0.0, 0.0);
            float disp = dispersion * 10.0;
            for (float w = -1.0; w <= 1.0; w += wStep) {
                // Pap: intensity*(1+w*dispersion)*0.01 * sin(d*count*PI) * dampen
                //   with intensity in -1..1 (pap2mp): drop the *0.01.
                //   dispersion (Pap 0..100 * 0.1) → pap2mp (0..1 * 10.0) = disp.
                float dilation = 1.0 + intensity * (1.0 + w * disp) * sin(d * rippleCount * PI) * dampen;
                vec2 coord = (modelTransform * vec3(dilation * u, 1.0)).xy;
                vec4 weight = rwdGetRGBWeights(w);
                totalColor += weight * __source__(coord);
                totalWeight += weight;
            }
            return totalColor / totalWeight;
        }
    }
}
