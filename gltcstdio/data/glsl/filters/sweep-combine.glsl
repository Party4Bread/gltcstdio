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
