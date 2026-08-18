vec2 bdDistort(vec2 pos, vec2 a, vec2 b, vec2 splits, vec4 rect, float intensity, int mode, float seed) {
    vec2 c = (a + b) / 2.0;
    if (mode <= 1) {
        return c + (pos - c) * pow(1.05, intensity);
    }
    else if (mode == 2) {
        vec2 rnd = rand2relSeeded(splits, seed + 122.1);
        return pos + vec2(rnd.x * intensity * 0.02, 0.0);
    }
    else if (mode == 3) {
        vec2 rnd = rand2relSeeded(splits, seed + 122.1);
        return pos + vec2(0.0, rnd.y * intensity * 0.02);
    }
    else if (mode == 4) {
        vec2 rnd = rand2relSeeded(splits, seed + 122.1);
        if (abs(rnd.x) > abs(rnd.y)) {
            return pos + vec2(rnd.x * intensity * 0.02, 0.0);
        } else {
            return pos + vec2(0.0, rnd.y * intensity * 0.02);
        }
    }
    else if (mode == 5) {
        vec2 rnd = rand2relSeeded(splits, seed + 122.1);
        if (rect.z - rect.x > rect.w - rect.y) {
            return pos + vec2(rnd.x * intensity * 0.02, 0.0);
        } else {
            return pos + vec2(0.0, rnd.y * intensity * 0.02);
        }
    }
    else if (mode == 6) {
        vec2 delta = (pos - c);
        return c - delta * pow(1.05, intensity);
    }
    else if (mode <= 8) {
        vec2 rnd = rand2relSeeded(splits, seed + 122.1);
        float dx = rect.z - rect.x;
        float dy = rect.w - rect.y;
        if (dx > dy) {
            return pos + vec2(sign(rnd.x) * dx * intensity * 0.02, 0.0);
        } else {
            return pos + vec2(0.0, sign(rnd.y) * dy * intensity * 0.02);
        }
    }
    else if (mode == 9) {
        vec2 rnd = rand2relSeeded(splits, seed + 122.1);
        float dx = rect.z - rect.x;
        float dy = rect.w - rect.y;
        if (dx > dy) {
            return pos + vec2(sign(rnd.x) * dx / dy * intensity * 0.0005, 0.0);
        } else {
            return pos + vec2(0.0, sign(rnd.y) * dy / dx * intensity * 0.0005);
        }
    }
    else {
        // mode >= 10: rotation around centre by `intensity * 0.1` radians.
        float ca = cos(intensity * 0.1);
        float sa = sin(intensity * 0.1);
        return c + mat2(ca, sa, -sa, ca) * (pos - c);
    }
}

float bdRound(float x, float prec) {
    return floor(x / prec + 0.5) * prec;
}

float bdWithBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    // Original commented-out version: pow(2.0, -s*min(ab, sqrt(ab))).
    return pow(x + 0.5, pow(2.0, -s * ab)) - 0.5;
}

vec4 breakDichotomic(vec2 pos, vec2 outPos, int mode, int count, float intensity, float randomSeed, float regularity, float thickness, vec4 color, vec2 sourceDim, mat3 modelTransform) {
    // Pap CPU pre-compute folded in:
    //   Pap intensity raw 0..100 → uniform raw → shader maps sign*I*I*0.01.
    //   pap2mp intensity is normalised to -1..1; equivalent is sign*I*I*100.
    float intensityFolded = sign(intensity) * intensity * intensity * 100.0;

    // Pap thickness raw 0..100; CPU multiplies u_Thickness = T*T*0.01.
    // Shader then * 0.001. Combined factor in pap2mp (T in 0..1):
    //   T_pap = T * 100; uniform = T_pap*T_pap*0.01 = T*T*100.
    //   At call site: *0.001 → final coefficient T*T*0.1.
    float thicknessThreshold = thickness * thickness * 0.1;

    // Pap u_Regularity*0.02 with raw 0..100 → with pap2mp 0..1: regularity*2.
    float regularityScaled = regularity * 2.0;

    // Pap: bias = (u_ModelTransform * vec3(0,0,1)).xy → forward
    // translation column. No inverse needed.
    vec2 bias = modelTransform[2].xy;
    float scaleInv = 1.0 / length(vec2(modelTransform[0][0], modelTransform[0][1]));

    float ratio = bdRound(sourceDim.x / sourceDim.y, 0.01); // preview coherence
    float pixel = 2.0 / sourceDim.y;
    vec2 p = pos;

    bool border = false;
    vec4 rect;
    float rndStep = 1.0;
    if (mode == 1 || mode == 8 || mode == 9) rndStep = 0.0;

    for (int j = 0; j < count; ++j) {
        rect = vec4(-ratio, -1.0, ratio, 1.0);

        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0); // preview coherence

        float sPos = 0.0; // 1D split-space position
        float sscale = 0.5;
        float inverter = 0.0;
        // bias keeps halving across BOTH the inner i-loop AND the
        // outer j-loop in the Pap original (not re-seeded each j);
        // preserved verbatim per Rule #3 (bug-port fidelity).

        for (float i = 0.0; i + sPos < scaleInv; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed + 122.1 + rndStep * float(j));
            vec2 size = rect.zw - rect.xy;
            if (size.x < pixel || size.y < pixel) break;

            if (rnd.x + 0.5 < regularityScaled) horSplit = size.y > size.x;
            float variability = 1.0 - max(0.0, regularityScaled - 1.0);

            if (horSplit) {
                float Y = mix(rect.y, rect.w, variability * bdWithBias(rnd.y, bias.y) + 0.5);
                if (abs(Y - p.y) < thicknessThreshold) { border = true; break; }
                if (p.y < Y) {
                    rect.w = Y;
                    splits.y += 1.0;
                    sPos += inverter * sscale;
                } else {
                    rect.y = Y;
                    splits.y += 100.0;
                    sPos += (1.0 - inverter) * sscale;
                }
            } else {
                float X = mix(rect.x, rect.z, variability * bdWithBias(rnd.x, bias.x) + 0.5);
                if (abs(X - p.x) < thicknessThreshold) { border = true; break; }
                if (p.x < X) {
                    rect.z = X;
                    splits.x += 1.0;
                    sPos += inverter * sscale;
                } else {
                    rect.x = X;
                    splits.x += 100.0;
                    sPos += (1.0 - inverter) * sscale;
                }
            }
            horSplit = !horSplit;
            inverter = 1.0 - inverter;
            sscale *= 0.5;
            bias *= 0.5;
        }
        if (border) break;
        p = bdDistort(p, rect.xy, rect.zw, splits, rect, intensityFolded, mode, randomSeed);
    }

    vec4 col = __source__(pos);
    vec4 outCol;
    if (border) {
        outCol = vec4(mix(col.rgb, color.rgb, color.a), col.a);
    } else {
        outCol = __source__(p);
    }

    // Locus stripped: Pap's shader branched on u_LocusMode to either
    // modulate `intensity` by getLocus() (modes 1-5) or apply a final
    // mix(col, outCol, getLocus(...)) (modes 6+). Here the external
    // `.withLocusHandling()` wrapper supplies the locus blend.
    return outCol;
}
