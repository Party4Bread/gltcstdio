vec2 mashHash2(vec2 c) {
    return fract(sin(vec2(dot(c, vec2(127.1, 311.7)), dot(c, vec2(269.5, 183.3)))) * 43758.5453);
}

vec4 mashGL(vec2 pos, vec2 outPos, float intensity, float balance, mat3 modelTransform, mat3 objectTransform) {
    vec2 frag = pos;
    vec2 center = modelTransform[2].xy;          // (u_ModelTransform * vec3(0,0,1)).xy
    vec4 inCol = __source__(frag);

    float STEP = intensity * 2.0;                // Pap u_Power
    float scaleM = length(modelTransform[0].xy); // Pap `scale` (MODEL_SCALE, default 0.1)
    float cellLen = length(objectTransform[0].xy);
    float marchCell = max(0.0, cellLen - 1.0) * 0.02;  // identity = 0 (no shuffle)
    vec2 marchBias = objectTransform[2].xy;
    float stepLen = 0.001 * STEP;

    // mode 21 = INVERT + CIRCULAR + DIR 5
    vec2 dir = -normalize(frag - center);        // INVERT
    vec2 origdir = dir;
    float dist = length(center - frag);          // CIRCULAR
    vec2 p = frag;                               // INVERT: start at the fragment
    vec2 q = p;

    vec3 maxC = vec3(0.0);
    vec3 minC = vec3(1.0);
    float sumV = 0.0;
    float maxV = 0.0;
    float k = 0.0;

    float d = 0.0;
    for (int i = 0; i < 400; ++i) {              // count = 400
        if (d >= dist) break;
        q += (dir + marchBias) * stepLen;
        if (marchCell > 1e-6) {
            // datamosh shuffle: each cell samples a coherent hash-displaced spot
            vec2 cell = floor(q / marchCell);
            p = (cell + 0.5) * marchCell + (mashHash2(cell) - 0.5) * marchCell * 6.0;
        } else {
            p = q;
        }
        vec3 col = __source__(p).rgb;
        float vv = (col.r + col.g + col.b) / 3.0;
        sumV += vv;
        maxC = max(maxC, col);
        minC = min(minC, col);
        k += 0.001 * vv;
        if (vv > maxV) maxV = vv;
        // DIR 5: snap direction to the dominant axis, toggled by accumulated brightness
        dir = (mod(maxV * 50.0, 2.0) < 1.0) ? normalize(vec2(origdir.x, 0.0)) : normalize(vec2(0.0, origdir.y));
        d += stepLen;
    }

    float insidness = k * STEP / scaleM;
    vec4 outCol;
    if (insidness < 1.0) {
        vec4 iCol = vec4(mix(minC, maxC, 1.0 - 3.0 * k), 1.0);   // style 10: light -> dark
        if (balance >= 0.0) {
            outCol = mix(iCol, inCol, balance);                  // Pap u_Balance*0.01 -> balance
        } else {
            outCol = vec4((iCol * inCol * min(1.0, -balance * 2.0) + iCol * (1.0 + balance * 0.6)).rgb, inCol.a);
        }
    } else {
        outCol = __source__(frag);
    }

    outCol.a = inCol.a;
    outCol.rgb = clamp(outCol.rgb, 0.0, 1.0);
    return outCol;
}
