vec4 findMaxXYGL(vec2 pos, vec2 outPos, float intensity, float phase) {
    vec4 inCol = __source__(pos);
    int N = 25;
    // Pap: u_Intensity*0.0002 (intensity 0..100). pap2mp intensity is -1..1;
    //   multiply by 0.02 to keep the same absolute step size at Pap=10 → pap2mp=0.1.
    float delta = intensity * 0.02;
    vec4 col = inCol;
    vec2 step = mat2(cos(phase), sin(phase), sin(phase), -cos(phase)) * vec2(delta, 0.0);
    for (int i = -N; i < N; ++i) {
        vec4 a = __source__(pos + float(i) * step);
        if (rgbToHsl(a).y > rgbToHsl(col).y) col = a;
        vec4 b = __source__(pos + float(i) * vec2(step.y, -step.x));
        if (rgbToHsl(b).y > rgbToHsl(col).y) col = b;
    }
    // Pap returns the max-saturation cross result at FULL strength; `intensity`
    // only sets the search step size (`delta` above). `isIntensityBlendable` is
    // the Area-of-Effect mask hook (Model.java:1847), NOT a global fade — so no
    // outer mix here. (locus blend comes from the external .withLocusHandling().)
    return col;
}
