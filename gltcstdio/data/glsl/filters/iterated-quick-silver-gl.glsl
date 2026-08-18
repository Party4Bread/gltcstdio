vec4 iteratedQuickSilverGL(vec2 pos, vec2 outPos, float intensity, int iterations, float phase, mat3 modelTransform, int displacement_specified) {
    mat3 invM = inverse(modelTransform);
    vec2 origPos = pos;
    vec2 originalPos = pos;

    // Pap: u_Intensity = pap_intensity² * 0.01 (uploaded). With pap2mp
    // intensity in 0..1 instead of 0..100, the equivalent in-shader is
    // intensity*intensity*100. The 0.004 multiplier on each step
    // remains: intensity*intensity*100 * 0.004 = intensity*intensity*0.4.
    float intEff = intensity * intensity * 100.0;

    if (intEff != 0.0) {
        for (int i = 0; i < iterations; ++i) {
            vec2 t = (invM * vec3(pos, 1.0)).xy;
            vec4 val = displacement_specified == 1
                ? __displacement__(t)
                : __source1__(t);
            val.xy -= vec2(0.5, 0.5);
            vec2 tt = phase == 0.0
                ? val.xy
                : vec2(cos(phase) * val.x - sin(phase) * val.y,
                       cos(phase) * val.y + sin(phase) * val.x);
            vec2 displacement = intEff * 0.004 * tt;
            pos += displacement;
        }
    }

    // displacementLen / maxDisplacement computed but unused (Pap had a
    // disabled HSL block here). Omitted for brevity.

    return __source1__(pos);
}
