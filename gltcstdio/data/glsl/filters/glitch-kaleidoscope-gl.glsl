float gkglDisplaceAngle(float angle, float maxDisplacement) {
    return angle + maxDisplacement*(rand(angle)-0.5);
}

vec2 gkglReflect(float d, float sourceAngle, float alpha, float halfAlpha, float halfRoundedAngle) {
    if (sourceAngle > halfAlpha) sourceAngle = alpha-sourceAngle;

    float cornerAngle = halfAlpha - halfRoundedAngle;
    if (halfRoundedAngle==0.0 || sourceAngle<=cornerAngle) {
        return d * vec2(cos(sourceAngle), sin(sourceAngle));
    }
    else {
        if (cornerAngle==0.0) cornerAngle = 0.001; // hack because the math is pathological here

        float x = d*cos(sourceAngle);
        float y = d*sin(sourceAngle);
        float cha = cos(halfAlpha);
        float sha = sin(halfAlpha);
        float cca = cos(cornerAngle);
        float sca = sin(cornerAngle);

        float A = ((sha/sca*cca-cha)*(sha/sca*cca-cha) - 1.0);
        float B = 2.0*(cha*x + sha*y);
        float C = -(x*x + y*y);
        float delta2 = B*B-4.0*A*C;
        if (delta2<0.0) {
            return vec2(x, y);
        }
        float l = (-B + sqrt(delta2)) / (2.0*A);
        float cx = l * cha;
        float cy = l * sha;
        float k = l*sha/sca;

        float Xp = k*cca;
        float Yp = k*sca;
        float R = Xp-cx;

        return vec2(Xp, Yp + R*(sourceAngle-cornerAngle));
    }
}

vec2 gkglPerspective(vec2 u, float perspective) {
    // Pap: u_Perspective = tan(PI/2 - perspective_radians). When perspective=0
    // → u_Perspective = INF → branch (>=10000) returns u unchanged.
    if (perspective == 0.0) return u;
    float invP = tan(PI*0.5 - perspective);
    if (invP >= 10000.0) return u;
    float Z = 4.0;
    float z = Z*u.y / (-Z*invP - u.y);
    return vec2(u.x * (z + Z) / Z, z * -invP);
}

vec4 glitchKaleidoscope(vec2 uv, vec2 outPos, int spikeCount, float regularity, float roundedness, float perspective, mat3 modelTransform) {
    // TRANSFORM MAPPING (kaleidoscope-family convention; matches mirror/legacy/KaleidoscopeML
    // and docs/EFFECT_PORTING.md "Pap MODEL vs TEX <-> pap2mp viewTransform vs modelTransform"):
    //   - Pap MODEL (pre-fold pattern geometry, `u_ModelTransform * pos`) -> pap2mp
    //     `viewTransform`. The engine pre-applies it: the `uv` arg is already
    //     `inverse(viewTransform) * pos`, so we use `uv` directly for the geometry.
    //     `viewTransform` is therefore declared in the constructor but NOT a shader param.
    //   - Pap TEX (post-fold SOURCE sampling, Pap's TEX-transform applied to coord) ->
    //     pap2mp `modelTransform`, sampled as `inverse(modelTransform) * coord` (below).
    //     (Do NOT write the legacy projection-helper token here — see the NB note below.)
    // This makes the DEFAULT gesture (which drives `modelTransform`) pan/zoom the source
    // inside the fold — matching Pap's default checked mode `moveAndScaleShape` (= TEX).
    vec2 u = gkglPerspective(uv, perspective);

    float d = length(u);
    float sourceAngle = 0.0;

    float variability = 1.0 - regularity;
    float halfAlpha = 0.0;
    float alpha = 0.0;
    float sCount = float(spikeCount);
    if (d > 0.0) {
        float ang = atan(u.y, u.x);
        if (ang<0.0) ang += PI2;

        if (variability == 0.0) {
            halfAlpha = PI/sCount;
            alpha = halfAlpha * 2.0;
            sourceAngle = mod(ang, alpha);
        }
        else {
            float maxDisplacement = (4.0*PI)/sCount;
            float spikeAngle1 = 0.0;
            float spikeAngle2 = gkglDisplaceAngle(PI2/sCount, variability*maxDisplacement);

            for(int i=0; i<spikeCount; ++i) {
                if ((i==spikeCount-1) || (ang <= spikeAngle2)) {
                    alpha = spikeAngle2 - spikeAngle1;
                    halfAlpha = alpha/2.0;
                    sourceAngle = ang - spikeAngle1;
                    break;
                }
                else {
                    spikeAngle1 = spikeAngle2;
                    spikeAngle2 = float(i+2) * PI2/sCount;
                    if (i!=spikeCount-2)
                        spikeAngle2 = gkglDisplaceAngle(spikeAngle2, variability*maxDisplacement);
                }
            }
        }
    }

    float halfRoundedAngle = halfAlpha * roundedness;
    vec2 coord = gkglReflect(d, sourceAngle, alpha, halfAlpha, halfRoundedAngle);

    // Pap samples the source at the folded coord through its TEX transform
    // (proj of coord). pap2mp maps Pap TEX to `modelTransform`, applied as
    // inverse(modelTransform) so the default gesture pans/zooms the source content
    // with the fold center fixed (same as KaleidoscopeML).
    // NB: never write the legacy source-projection helper's name (proj + the digit 0)
    // immediately followed by an open-paren anywhere in this string. parseDependencies
    // scans the shader text INCLUDING COMMENTS for an identifier-then-open-paren token
    // and would pull in that helper, whose body references the undeclared u_Tex0
    // transform uniform → "u_Tex0Transform : undeclared identifier" → won't compile.
    vec2 kCoord = (inverse(modelTransform) * vec3(coord, 1.0)).xy;
    vec4 kCol = __source__(kCoord);
    return kCol;
}
