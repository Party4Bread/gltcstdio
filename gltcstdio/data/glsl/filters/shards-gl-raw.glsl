float round2(float x, float prec) {
    return floor(x/prec+0.5)*prec;
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    //return pow(x+0.5, pow(2.0, -s * min(ab, sqrt(ab)))) - 0.5;
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

float segDist(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b-a;
    float abLen = length(ab);
    if (abLen==0.0) return length(p-a);
    vec2 abNorm = ab/abLen;
    vec2 ap = p-a;
    float abProj = dot(ap, abNorm);
    if (abProj>=0.0 && abProj<=abLen) {
        return abs(dot(ap, vec2(abNorm.y, -abNorm.x)));
    }
    else {
        return min(length(ap), length(p-b));
    }
}

bool inQuad(vec2 p, vec2 E, vec2 F, vec2 A, vec2 B) {
    vec2 EA = A-E;
    float lea = length(EA);
    if (lea==0.0) {
        vec2 FB = B-F;
        float lfb = length(FB);
        if (lfb==0.0) return false;
        FB /= lfb;
        vec2 Fp = p-F;
        float lfp = length(Fp);
        if (lfp==0.0) return true;
        Fp = Fp/lfp;
        vec2 FE = normalize(E-F);
        return dot(FE, FB)<dot(Fp, FB);
    }
    else {
        EA = EA/lea;
        vec2 Ep = p-E;
        float lep = length(Ep);
        if (lep==0.0) return true;
        Ep = Ep/lep;
        vec2 EF = normalize(F-E);
        return dot(EF, EA)<dot(Ep, EA);
    }
}

float center(float c, float delta) {
    return delta<0.0
        ? mix(0.0, c, delta*2.0+1.0)
        : mix(c, 1.0, delta*2.0);
}

vec4 shards(vec2 pos, vec2 outPos, int mode, vec4 borderColor, float thickness, float regularity, float randomSeed, float balance, vec2 sourceDim, mat3 modelTransform, vec2 paletteDim) {
    float ratio = round2(sourceDim.x/sourceDim.y, 0.01); // preview coherence
    float pixel = 2.0/sourceDim.y;
    vec2 quad0 = vec2(-ratio, -1.0); //a
    vec2 quad1 = vec2(ratio, -1.0); //b
    vec2 quad2 = vec2(-ratio, 1.0); //c
    vec2 quad3 = vec2(ratio, 1.0); //d

    bool abSplit = true; // split ab and cd if true otherwise ac and bd
    float border = 0.0;
//    vec2 splits = vec2(0.0, 0.0); // preview coherence
    float splitsX = 0.0;
    float splitsY = 0.0;
    vec2 bias = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;

    float scale = 1.0/length(modelTransform[0].xy);

    float sPos = 0.0; // position in 1D split space
    float sscale = 0.5;
    float inverter = 0.0;
    float count = 0.0;

    float borderThick = thickness*0.05;
    float borderTransition = min(pixel, borderThick*0.3) *0.5;
    float borderAA = borderThick-smoothstep(pixel*0.5, pixel, borderThick)*0.5*pixel;
    float borderBB = borderThick + pixel*0.5;

    for(float i=0.0; i+sPos<scale; ++i) {
        vec2 rnd = rand2relSeeded(vec2(-4.0, 3.0)+vec2(splitsX, splitsY), randomSeed+122.1);
        vec2 size = max(abs(quad0-quad3), abs(quad1-quad2)).xy;
        if (size.x<pixel || size.y<pixel) break;

        float lenAB = length(quad0.xy-quad1.xy) + length(quad2.xy-quad3.xy);
        float lenAC = length(quad0.xy-quad2.xy) + length(quad1.xy-quad3.xy);

        if (rnd.x+0.5<regularity*2.) abSplit = lenAB>lenAC;
        float variability = 1.0-max(0.0, (regularity*2.-1.0));
//if (rnd.x==rnd.y) return vec4(1.0, 0.0, 0.0, 1.0);

        float deviate = balance;
        float devEx = clamp(rnd.x+deviate, -1.0, 1.0);
        float devFx = clamp(rnd.y+deviate, -1.0, 1.0);
        float devEy = devEx;
        float devFy = devFx;
        float cEx = 0.5, cEy = 0.5, cFx = 0.5, cFy = 0.5;

        if (mode==1) {
            devEx = -devEx;
            devFy = -devFy;
        }
        else if (mode==3) {
            devEy = -devEy;
        }
        else if (mode==4) {
            cEx = 0.1;
        }
        else if (mode==5) {
            cEx = 0.7;
            cEy = 0.7;
        }
        else if (mode==6) {
            cEx = 0.2;
            cFx = 1.0-cEx;
            cEy = 0.8;
            cFy = 1.0-cEy;
       }
        else if (mode==7) {
            cEx = 0.2;
            cFx = 1.0-cEx;
            cEy = 0.2;
            cFy = 1.0-cEy;
        }

        if (abSplit) {
            vec2 E = mix(quad0, quad1, center(cEx, variability*withBias(devEx, bias.x)));
            vec2 F = mix(quad2, quad3, center(cFx, variability*withBias(devFx, bias.x)));
            float bDist = segDist(pos, E.xy, F.xy);
            if (bDist<borderBB) { float x=bDist-borderThick; border = clamp(0.0, min(1.0, borderThick/pixel), (pixel*0.5-x)/pixel); if (border>=1.0) break; }
            vec2 EA = quad0.xy-E.xy;
            vec2 EF = F.xy-E.xy;
            if (inQuad(pos, E.xy, F.xy, quad0.xy, quad2.xy)) { quad1 = E; quad3 = F; ++splitsX; sPos += inverter*sscale; } else { quad0 = E; quad2 = F; splitsX += 100.0; sPos += (1.0-inverter)*sscale; }
//            if (true) { splitsY = splitsY + 1.0;  } else { splitsY = splitsY + 100.0; }
        }
        else {
            vec2 E = mix(quad0, quad2, center(cEy, variability*withBias(devEy, bias.y)));
            vec2 F = mix(quad1, quad3, center(cFy, variability*withBias(devFy, bias.y)));
            float bDist = segDist(pos, E.xy, F.xy);
            if (bDist<borderBB) { float x=bDist-borderThick; border = clamp(0.0, min(1.0, borderThick/pixel), (pixel*0.5-x)/pixel); if (border>=1.0) break; }
            vec2 EA = quad0.xy-E.xy;
            vec2 EF = F.xy-E.xy;
            if (inQuad(pos, E.xy, F.xy, quad0.xy, quad1.xy)) { quad2 = E; quad3 = F; ++splitsY; sPos += inverter*sscale; } else { quad0 = E; quad1 = F; splitsY += 100.0; sPos += (1.0-inverter)*sscale; }
//            if (true) { splitsY = splitsY + 1.0;  } else { splitsY = splitsY + 100.0; }
        }

        if (mode==2) {
            abSplit = fract(count*0.1)<0.5;
        }
        else {
            abSplit = !abSplit;
        }

        inverter = 1.0-inverter;
        sscale *= 0.5;
        bias *= 0.5;
        ++count;
    }

    vec2 samplePos = mix(mix(quad0, quad1, 0.5), mix(quad2, quad3, 0.5), 0.5).xy;
    vec4 col = __source__(samplePos);

    vec4 outCol = mix(col, vec4(mix(col.rgb, borderColor.rgb, borderColor.a), col.a), border);

    // Palette quantization (Pap `getFromPalette` + `if (u_ColorCount>1)` guard,
    // applied to the FINAL outCol post border-mix, exactly as Pap does). A
    // multi-colour palette always quantizes. A SINGLE-colour palette is ambiguous:
    // the "All colors" sentinel is a single **alpha-0** colour (skip quantization,
    // keep all source colours — Pap's `intArrayOf(0)` default → `u_ColorCount==1`),
    // whereas a single **opaque** colour is a genuine quantize-everything-to-one
    // palette. Distinguish by the entry's alpha (the codebase-correct idiom; avoids
    // the opaque-1-colour all-black false-skip).
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

    return outCol;
}
