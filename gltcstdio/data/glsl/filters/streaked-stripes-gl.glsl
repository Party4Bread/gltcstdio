vec4 streakedStripesGL(vec2 uv, vec2 outPos, vec4 color, float thickness, float balance, float variability, float shadows, float randomSeed, vec2 sourceDim, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(uv, 1.0)).xy;
    float pixel = 2.0 / sourceDim.y;
    // Pap: scale = length(vec2(u_ModelTransform[0][0], u_ModelTransform[0][1]))
    // Pap's u_ModelTransform is the forward (zoom-in) matrix that maps pos→u — here that
    // role is played by invM (modelTransform is the analog of Pap's u_InverseModelTransform).
    // Reading modelTransform here gave scale=0.05 instead of 20 → t (border half-width) and
    // st (dichotomy threshold) came out 400× too small → almost no white borders, most
    // visible as missing white when dezoom pushes balance negative (subdivision branch).
    float scale = length(invM[0].xy);
    // Pap: t = u_Thickness*0.0002*scale  (u_Thickness in 0..100)
    //     → with thickness in 0..1:  thickness * 0.02 * scale
    float t = thickness * 0.02 * scale;
    // Pap: var = u_Variability*0.08  (u_Variability in 0..100)
    //     → variability * 8.0
    float varAmt = variability * 8.0;
    float index = floor(u.x + 0.5);
    bool border = false;
    float light = 1.0;
    float x1 = 0.0;
    float x2 = 0.0;
    float i2 = 0.0;
    for (float i = index - 6.0; i <= index + 6.0; i += 1.0) {
        vec2 rnd2 = rand2relSeeded(vec2(i, i), randomSeed);
        x1 = i + varAmt * rnd2.x;
        // Pap: shadowSize = u_Shadows*0.04 * (1.0 + u_Variability*0.01 * rnd2.y)
        //   shadows 0..1, variability 0..1 (was 0..100): inner *0.01 collapses to *1.0
        float shadowSize = shadows * 4.0 * (1.0 + variability * rnd2.y);
        i2 = i + 1.0;
        x2 = i2 + varAmt * rand2relSeeded(vec2(i2, i2), randomSeed).x;
        if (abs(u.x - x1) < t || abs(x2 - u.x) < t) {
            border = true;
            break;
        } else if (x1 <= u.x && u.x <= x2) {
            // Pap: smoothstep(mix(-shadowSize, 0.0, u_Shadows*0.01), shadowSize, x2-u.x)
            light = smoothstep(mix(-shadowSize, 0.0, shadows), shadowSize, x2 - u.x);
            break;
        }
    }

    vec2 rnd = rand2relSeeded(vec2(sign(u.y), i2), randomSeed);
    int maxIter = 30;
    float st = t;
    if (balance < 0.0) {
        // Pap: 50.0/abs(u_Balance*u_Balance) *20.0  (u_Balance in -100..100)
        //   → with balance in -1..1: 50.0/abs(balance*balance*1.0e4) *20.0
        float Y = 50.0 / abs(balance * balance * 1.0e4) * 20.0 * (1.0 + 0.5 * varAmt * rnd.x);
        float dy = 50.0 / abs(balance * balance * 1.0e4) * 20.0 * (1.0 + 0.5 * varAmt * rnd.y);
        while (abs(u.y) > Y && abs(x2 - x1) > pixel && maxIter > 0) {
            float k = rnd.x + 0.5;
            float x12 = mix(x1, x2, k);
            if (abs(x2 - x1) < st || abs(u.x - x12) < st) {
                border = true;
                x1 = x2 = x12;
                break;
            } else if (u.x < x12) {
                x2 = x12;
            } else {
                x1 = x12;
            }
            Y += dy;
            dy *= 0.5;
            rnd = rand2relSeeded(rnd, randomSeed);
            --maxIter;
        }
    } else if (balance > 0.0) {
        border = false;
        // Pap: pow(abs(u_Balance), 1.5)*0.01 *20.0  (u_Balance in -100..100)
        //   → pow(abs(balance*100.0), 1.5)*0.01 *20.0
        float Y = pow(abs(balance * 100.0), 1.5) * 0.01 * 20.0 * (1.0 + 0.01 * varAmt * rnd.x);
        float dy = 50.0 / abs(balance * balance * 1.0e4) * 20.0 * (1.0 + 0.5 * varAmt * rnd.y);
        while (abs(u.y) < Y && abs(x2 - x1) > pixel && maxIter > 0) {
            float k = rnd.x + 0.5;
            float x12 = mix(x1, x2, k);
            if (u.x < x12) {
                x2 = x12;
            } else {
                x1 = x12;
            }
            Y -= dy;
            dy *= 0.5;
            rnd = rand2relSeeded(rnd, randomSeed);
            --maxIter;
        }
        if (st < abs(x2 - x1) / 2.0 && (abs(u.x - x1) < t || abs(x2 - u.x) < t)) {
            border = true;
        }
    }

    // Snap to stripe centre then sample source.
    u.x = (x1 + x2) / 2.0;
    vec2 v = (modelTransform * vec3(u, 1.0)).xy;
    vec4 col = __source__(v);
    vec4 outCol = border ? vec4(mix(col.rgb, color.rgb, color.a), col.a) : col;
    outCol = mix(vec4(0.0, 0.0, 0.0, 1.0), outCol, light);
    return outCol;
}
