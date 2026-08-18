vec4 iteratedWaveGL(vec2 pos, vec2 outPos, float intensity, int count, float regularity, float balance, float randomSeed, mat3 modelTransform) {
    vec2 u = pos;

    // Pap shader computes `Variability = 100 - regularity` on CPU,
    // then uses `Variability * 0.1` in the shader (giving 0..10).
    // pap2mp regularity is 0..1 → variability is 0..1; multiply by 10.0
    // in the magnitude expression to keep the same coefficient.
    float variability = 1.0 - regularity;

    // Second (odd-iteration) matrix. Pap's `u_ModelTransform2 =
    // getTransform(modelX, modelY, modelScale, PHASE2 = PI/4)`: same translation and
    // scale as modelTransform, rotation PINNED at 45° (independent of MODEL_ANGLE).
    // Build it as scale·R(45°) with the translation column copied VERBATIM from
    // modelTransform — identical to the reference `WaveFlow`. This preserves
    // the pan (Tx/Ty): a previous form `rotation3(PI/4) * modelTransform` rotated the
    // WHOLE matrix incl. its translation column, so pan landed in the wave-invariant
    // y-axis and cancelled on odd iterations ("y touch translation does nothing"); it
    // also wrongly added 45° on top of the user rotation. This form fixes both.
    float mtScale = length(modelTransform[0].xy);
    float mt2k = mtScale * SQRT2_2;   // cos(45°) == sin(45°) == SQRT2_2
    mat3 modelTransform2 = mat3(vec3(mt2k, mt2k, 0.0), vec3(-mt2k, mt2k, 0.0), modelTransform[2]);
    mat3 invM1 = inverse(modelTransform);
    mat3 invM2 = inverse(modelTransform2);

    // Pap: bTranslate = (balance>0 ? balance*0.01 : 0.0) * vec2(cos(balance*0.1), sin(-balance*0.1))
    //   Pap balance range -100..100; with pap2mp balance in -1..1,
    //   `balance*0.01` -> `balance`; `balance*0.1` -> `balance*10.0`.
    vec2 bTranslate = (balance > 0.0 ? balance : 0.0) * vec2(cos(balance * 10.0), sin(-balance * 10.0));

    // GLSL ES requires a constant loop bound; cap at Pap's COUNT_1_1000 max
    // and break on `j >= count` inside the loop.
    for (int j = 0; j < 1000; ++j) {
        if (j >= count) break;
        float jf = float(j);

        vec2 translate = bTranslate * jf;
        // Pap balance<0 branch: pow(0.999, abs(balance)*100.0*jf) — at pap2mp
        // balance=-0.5, that's pow(0.999, 50*jf) — matches Pap's pow(0.999, 50*jf).
        float scl = balance < 0.0 ? pow(0.999, abs(balance) * 100.0 * jf) : 1.0;
        mat3 ts = mat3(scl, 0.0, 0.0, 0.0, scl, 0.0, 0.0, 0.0, 1.0);
        mat3 invts = mat3(1.0 / scl, 0.0, 0.0, 0.0, 1.0 / scl, 0.0, 0.0, 0.0, 1.0);
        mat3 tt = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, translate.x, translate.y, 1.0);
        mat3 invtt = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, -translate.x, -translate.y, 1.0);

        bool even = mod(jf, 2.0) == 0.0;
        mat3 t1 = ts * (even ? modelTransform : modelTransform2) * tt;
        mat3 invt1 = invtt * (even ? invM1 : invM2) * invts;

        u = (invt1 * vec3(u, 1.0)).xy;

        float N = 4.0;
        float xx = u.x / N;
        float i = floor(xx);
        float di = xx - i;

        vec2 rnd = rand2relSeeded(vec2(i, i), randomSeed);
        vec2 rnd2;
        float vary = rnd.x;
        if (di < 0.5) {
            rnd2 = rand2relSeeded(vec2(i - 1.0, i - 1.0), randomSeed);
            di = 0.5 - di;
        } else {
            rnd2 = rand2relSeeded(vec2(i + 1.0, i + 1.0), randomSeed);
            di = di - 0.5;
        }
        vary = mix(vary, rnd2.x, di * di * 2.0);

        // Pap: intensity * (1 + variability*0.1 * vary * 2.0)
        //   pap2mp: variability is 0..1, multiply by 10.0 (== Pap *0.1 on 0..100).
        float magnitude = intensity * (1.0 + variability * 10.0 * vary * 2.0);
        float dy = sin(xx * PI) * magnitude;

        u = (t1 * vec3(u.x, u.y + dy, 1.0)).xy;
        // Pap shader's `invTransf = invTransf * 0.9;` and
        // `transf = rotMat / 0.9;` at loop end are inner-scope shadowed
        // assignments — dead code. Preserved as no-ops (i.e. omitted).
    }

    return __source__(u);
}
