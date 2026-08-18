float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

vec4 dichotomicTiles(vec2 uv, vec2 outPos,
        vec2 source1Dim, vec2 source2Dim, vec2 source3Dim,
        float variability, float randomSeed,
        vec4 colorBkg, vec4 color, float thickness, mat3 modelTransform) {

    float ratio = source1Dim.x / source1Dim.y;   // canonical frame aspect (from source 1)
    float pixel = 2.0 / source1Dim.y;             // one texel, in canonical Y units

    // ModelTransform drives the subdivision (as in DichotomicBreak/Streak):
    //   scale       => recursion depth (loop runs while i + sPos < scale)
    //   translation => directional bias of every bisection (decays x0.5 per level)
    vec2 biasBase = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0 / length(vec2(modelTransform[0][0], modelTransform[0][1]));

    vec2 p = uv;
    float regularity = 1.0 - variability;

    // --- dichotomic subdivision: descend to the cell containing p ---
    // rect = current cell bounds; splits = unique-ish path id (also the per-cell RNG seed).
    vec4 rect = vec4(-ratio, -1.0, ratio, 1.0);
    vec2 splits = vec2(0.0, 0.0);
    bool horSplit = true;
    vec2 bias = biasBase;
    float sPos = 0.0;       // sub-cell position in 1D split space (preview coherence)
    float sscale = 0.5;
    float inverter = 0.0;

    for (float i = 0.0; i + sPos < scale; ++i) {
        vec2 rnd = rand2relSeeded(splits, randomSeed + 122.1);   // in [-0.5, 0.5]
        vec2 size = rect.zw - rect.xy;
        if (size.x < pixel || size.y < pixel) break;

        // low variability => split the longer side (clean grid); high => alternate h/v.
        if (rnd.x + 0.5 < regularity * 2.0) horSplit = size.y > size.x;
        // posVar: 0 => split at the centre, 1 => split anywhere in the middle half (biased).
        float posVar = 1.0 - max(0.0, regularity * 2.0 - 1.0);

        if (horSplit) {
            float Y = mix(rect.y, rect.w, posVar * withBias(rnd.y, bias.y) + 0.5);
            if (p.y < Y) { rect.w = Y; splits.y += 1.0;   sPos += inverter * sscale; }
            else         { rect.y = Y; splits.y += 100.0; sPos += (1.0 - inverter) * sscale; }
        } else {
            float X = mix(rect.x, rect.z, posVar * withBias(rnd.x, bias.x) + 0.5);
            if (p.x < X) { rect.z = X; splits.x += 1.0;   sPos += inverter * sscale; }
            else         { rect.x = X; splits.x += 100.0; sPos += (1.0 - inverter) * sscale; }
        }
        horSplit = !horSplit;
        inverter = 1.0 - inverter;
        sscale *= 0.5;
        bias *= 0.5;        // bias decays with depth, like DichotomicBreak
    }

    float cw = rect.z - rect.x;
    float ch = rect.w - rect.y;

    // --- pick one of the 3 images for this cell (coherent per cell path) ---
    float r = rand2relSeeded(splits, randomSeed + 55.5).x + 0.5;   // [0, 1]
    int k = int(min(2.0, floor(r * 3.0)));
    vec2 dimK = (k == 0) ? source1Dim : (k == 1) ? source2Dim : source3Dim;
    float a = dimK.x / dimK.y;   // image aspect (w/h) — never squished

    // --- fit as many copies as possible in one row OR one column ---
    // nH = how many full-cell-height copies span the width; its reciprocal is the vertical count.
    float nH = cw / (ch * a);
    bool horizontal = nH >= 1.0;
    int n = horizontal ? int(floor(nH)) : int(floor(1.0 / nH));
    n = max(n, 1);

    float u = 0.0, v = 0.0;
    bool inside;
    if (horizontal) {
        float tileW = ch * a;                         // each copy: full cell height, image-aspect width
        float rowW = tileW * float(n);
        float startX = rect.x + (cw - rowW) * 0.5;    // centre the row in the cell
        float lx = p.x - startX;
        float idx = floor(lx / tileW);
        inside = (lx >= 0.0 && lx <= rowW);
        u = (lx - idx * tileW) / tileW;
        v = (p.y - rect.y) / ch;
    } else {
        float tileH = cw / a;                         // each copy: full cell width, image-aspect height
        float colH = tileH * float(n);
        float startY = rect.y + (ch - colH) * 0.5;    // centre the column in the cell
        float ly = p.y - startY;
        float idx = floor(ly / tileH);
        inside = (ly >= 0.0 && ly <= colH);
        u = (p.x - rect.x) / cw;
        v = (ly - idx * tileH) / tileH;
    }

    // --- optional per-cell border ---
    bool border = false;
    if (thickness > 0.0) {
        float t = thickness * 0.1;
        if (p.x - rect.x < t || rect.z - p.x < t || p.y - rect.y < t || rect.w - p.y < t) border = true;
    }

    if (border) return color;
    if (!inside) return colorBkg;

    // sample image k at normalized (u,v) via the centered-V2 __source__ contract
    vec2 X = vec2((u - 0.5) * 2.0 * a, (v - 0.5) * 2.0);
    return (k == 0) ? __source1__(X) : (k == 1) ? __source2__(X) : __source3__(X);
}
