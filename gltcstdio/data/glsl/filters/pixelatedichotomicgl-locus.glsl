// Non-monotonic bias curve. b in roughly [-1, 1]; for b=0 returns x.
// Pap-original form preserved verbatim (modulo s/ab decomposition).
float pdg_withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x + 0.5, pow(2.0, -s * ab)) - 0.5;
}

vec4 pixelateDichotomic(vec2 pos, vec2 outPos, vec2 sourceDim, mat3 modelTransform,
                         float randomSeed, float regularity, float thickness, vec4 color1,
                         vec2 paletteDim) {
    // Pap: `ratio = round(u_Tex0Dim.x/u_Tex0Dim.y, 0.01)` -- preview-coherence
    // rounding (so splits stay stable as resolution changes).
    float ratio = floor((sourceDim.x / sourceDim.y) * 100.0 + 0.5) * 0.01;
    float pixel = 2.0 / sourceDim.y;
    vec4 rect = vec4(-ratio, -1.0, ratio, 1.0);

    bool horSplit = true;
    bool border = false;
    // Pap init: `splits = vec2(0.0, 0.0)` -- intentionally a constant seed
    // vector; mutates as branches are taken below.
    vec2 splits = vec2(0.0, 0.0);
    // Pap: bias from modelTransform's translation column.
    vec2 bias = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;

    // Pap: max split depth = 1/length(modelTransform[0].xy).
    float maxSplits = 1.0 / length(vec2(modelTransform[0][0], modelTransform[0][1]));

    // Pap rescale: regularity (0..100) * 0.02 -> (0..1) * 2.0
    float regularityScaled = regularity * 2.0;
    float variability = 1.0 - max(0.0, regularityScaled - 1.0);

    // Pap: u_Thickness was the CPU-pre-squared `thickness*thickness*0.01`
    // (range 0..100 input). pap2mp passes the raw 0..1 thickness; fold
    // the pre-square + 0.001 shader factor + 100x range rescale:
    //   Pap final: (thickness_pap*thickness_pap*0.01) * 0.001
    //   pap2mp:    thickness_2mp = thickness_pap / 100
    //   -> thickness_pap*thickness_pap = thickness_2mp*thickness_2mp*10000
    //   -> shader uses: thickness_2mp*thickness_2mp*0.1
    float thicknessShader = thickness * thickness * 0.1;

    // GLSL ES requires a constant loop bound; cap at 100 splits and
    // break on `i >= maxSplits` inside the loop. Pap's shader uses
    // `i+sPos<scale` (early termination) - we use a simpler hard cap
    // since the rect-size check below already handles degenerate cases.
    for (int i = 0; i < 100; ++i) {
        if (float(i) >= maxSplits) break;
        vec2 rnd = rand2relSeeded(splits, randomSeed + 122.1);
        vec2 size = rect.zw - rect.xy;
        if (size.x < pixel || size.y < pixel) break;

        if (rnd.x + 0.5 < regularityScaled) horSplit = size.y > size.x;

        if (horSplit) {
            float Y = mix(rect.y, rect.w, variability * pdg_withBias(rnd.y, bias.y) + 0.5);
            if (abs(Y - pos.y) < thicknessShader) { border = true; break; }
            if (pos.y < Y) { rect.w = Y; splits.y += 1.0; }
            else            { rect.y = Y; splits.y += 100.0; }
        } else {
            float X = mix(rect.x, rect.z, variability * pdg_withBias(rnd.x, bias.x) + 0.5);
            if (abs(X - pos.x) < thicknessShader) { border = true; break; }
            if (pos.x < X) { rect.z = X; splits.x += 1.0; }
            else            { rect.x = X; splits.x += 100.0; }
        }
        horSplit = !horSplit;
        bias *= 0.5;
    }

    vec4 col = __source__(pos);
    vec4 outCol;
    if (border) {
        outCol = vec4(mix(col.rgb, color1.rgb, color1.a), col.a);
    } else {
        // sampleRect: Pap's body samples the rect center.
        outCol = __source__((rect.xy + rect.zw) * 0.5);
        // Palette quantization. A multi-colour palette always quantizes. A SINGLE-colour
        // palette is ambiguous: the "All colors" sentinel is a single **alpha-0** colour
        // (skip quantization, keep all source colours — Pap's `intArrayOf(0)` default),
        // whereas a single **opaque** colour is a genuine quantize-everything-to-one
        // palette. Distinguish by the entry's alpha.
        int n = int(paletteDim.x);
        bool doQuantize = n > 1;
        if (n == 1) doQuantize = __palette__texelFetch__(ivec2(0, 0)).a > 0.5;
        if (doQuantize) {
            float minDist = 1e9;
            vec4 bestColor = outCol;
            for (int i = 0; i < n; ++i) {
                vec4 target = __palette__texelFetch__(ivec2(i, 0));
                float dist = length(outCol - target);
                if (dist < minDist) {
                    minDist = dist;
                    bestColor = target;
                }
            }
            outCol = bestColor;
        }
    }
    return outCol;
}
