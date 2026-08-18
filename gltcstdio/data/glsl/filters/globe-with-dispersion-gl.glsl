vec4 gwdGetRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0 - abs(w)),
        max(0.0, w),
        1.0
    );
}

vec4 globeWithDispersionGL(vec2 pos, vec2 outPos, float intensity, float dispersion, float perturbation, float randomSeed, float power, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(pos, 1.0)).xy;
    if (perturbation > 0.0) {
        // Pap: sineSurfaceRand2Seeded(u*(1+u_Perturbation*0.01), u_Seed) * 0.01*u_Perturbation
        //   with perturbation in 0..1 (pap2mp): drop both *0.01 collapses.
        u += sineSurfaceRand2Seeded(u * (1.0 + perturbation), randomSeed) * perturbation;
    }

    float p = power;
    float d = pow(pow(abs(u.x), p) + pow(abs(u.y), p), 1.0 / p);

    if (d == 0.0 || d >= 1.0) {
        return __source__(pos);
    } else {
        float hh = sqrt(1.0 - d * d);
        if (hh == 0.0) {
            return __source__(pos);
        }

        float h = 1.0 + hh;

        if (dispersion == 0.0) {
            // Single-sample path: matches Globe.kt's per-pixel math
            // (sans shadows). intensity*0.01 in Pap → intensity in pap2mp.
            float s = (-d * intensity) / hh;
            float dilation = 1.0 + (h * s) / d;
            vec2 coord = (modelTransform * vec3(dilation * u, 1.0)).xy;
            return __source__(coord);
        } else {
            // Dispersion: integrate intensity-perturbed samples across
            // w in -1..1 with RGB-weighted accumulation. 41-sample loop
            // hardcoded in Pap; preserved.
            float wStep = 0.05;
            vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
            vec4 totalWeight = vec4(0.0, 0.0, 0.0, 0.0);
            for (float w = -1.0; w <= 1.0; w += wStep) {
                // Pap: (intensity*(1+w*dispersion))*0.01  (intensity in -100..100, dispersion in 0..100 → *0.01)
                //   with intensity in -1..1 and dispersion in 0..1 (pap2mp):
                //   inner *0.01 on intensity collapses; outer *0.01 on dispersion collapses.
                float s = (-d * (intensity * (1.0 + w * dispersion))) / hh;
                float dilation = 1.0 + (h * s) / d;
                vec2 coord = (modelTransform * vec3(dilation * u, 1.0)).xy;
                vec4 weight = gwdGetRGBWeights(w);
                totalColor += weight * __source__(coord);
                totalWeight += weight;
            }
            return totalColor / totalWeight;
        }
    }
}
