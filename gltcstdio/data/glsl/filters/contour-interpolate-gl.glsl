float sampleCol(vec4 color, int count) {
    return floor((color.r + color.g + color.b)*(float(count)-1.0)/3.0 + 0.5);
}

bool inside(vec2 pos, float X, float Y) {
    return abs(pos.y)<=Y && abs(pos.x)<=X;
}

float ciFmod(float a, float b) {
    return a - b * trunc(a / b);
}

float ciLocusGetHue(vec4 c) {
    float r = c.r, g = c.g, b = c.b;
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));
    if (maxi == mini) return 0.0;
    else if (maxi == r) return ciFmod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g) return (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else return (60.0 * (r - g) / (maxi - mini)) + 240.0;
}

float ciLocusGetBlock(vec2 pos) {
    float inside = 0.0;
    float i2 = floor(pos.x / 10.0) + floor(pos.y / 10.0);
    float divisor = floor(ciFmod((pos.x - 2.0 * pos.y) / 200.0, 24.0)) / 2.0;
    float threshold = ciFmod((pos.x + 2.0 * pos.y) / 200.0, 24.0) / 6.0;
    float total = 0.0;
    vec4 rdmz = vec4(ciFmod(i2 * 8877.0, 65536.0), ciFmod(55.0 + i2 * 777.0, 65536.0),
                     ciFmod(i2 * 413.0, 65536.0), ciFmod(4445.0 + i2 * 78.0, 65536.0));
    for (int i = 0; i < 5; ++i) {
        vec2 v = vec2(ciFmod(pos.x, 8.0), ciFmod(pos.y, 8.0));
        float index = v.x + v.y * 8.0;
        float idx = ciFmod(pos.y, 300.0) > 150.0 ? 3.0 : clamp(0.0, 3.0, floor(index / 16.0));
        float ins = ciFmod(floor(rdmz[int(idx)] / pow(2.0, index - idx * 16.0)), 2.0);
        total += ins;
        pos = floor(pos / divisor);
    }
    inside = total >= threshold ? 1.0 : 0.0;
    return inside;
}

float ciGetLocus(vec2 pos, vec4 inCol, vec4 outCol, int locusMode, mat3 locusTransform) {
    if (locusMode == 0) return 1.0;
    mat3 m = locusTransform;
    if (locusMode <= 3) m = inverse(locusTransform);
    vec2 u = (m * vec3(pos, 1.0)).xy;
    if (locusMode == 1) {
        return max(abs(u.x), abs(u.y)) > 1.0 ? 0.0 : 1.0;
    } else if (locusMode == 2) {
        return smoothstep(0.5, 1.0, length(u));
    } else if (locusMode == 3) {
        return smoothstep(1.0, 0.5, length(u));
    } else if (locusMode == 4) {
        float hue = ciLocusGetHue(inCol);
        float targetHue = ciFmod(locusTransform[2][0] * 180.0, 360.0);
        float d = hue - targetHue;
        if (d < 0.0) d = -d;
        if (d > 180.0) d = 360.0 - d;
        float maxD = 360.0 / length(vec2(locusTransform[0][0], locusTransform[0][1]));
        d /= maxD;
        return smoothstep(1.0, 0.75, d);
    } else if (locusMode == 5) {
        vec2 v = floor(u * 40.0);
        return ciLocusGetBlock(v);
    } else if (locusMode == 6) {
        float colDist = length(inCol.rgb - outCol.rgb);
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float maxDist = scale < 1.0 ? 1.732 * scale : 1.732 / scale;
        if (scale < 1.0) colDist = 1.732 - colDist;
        colDist /= maxDist;
        return smoothstep(1.0, 0.75, colDist);
    } else if (locusMode == 7) {
        return clamp(-locusTransform[2][0] + locusTransform[2][1], 0.0, 1.0);
    } else if (locusMode == 8) {
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float angle = floor(locusTransform[2][0] * 3.0 + 0.5) / 12.0 * PI;
        float intensity = clamp(locusTransform[2][1], 0.0, 1.0);
        float ca = cos(angle), sa = sin(angle);
        float y = -sa * pos.x + ca * pos.y;
        float h = cos(y * scale * PI * 100.0);
        return intensity < 0.5 ? intensity * (h + 1.0) : 1.0 + (1.0 - intensity) * (h - 1.0);
    }
    return 1.0;
}

vec4 contourInterpolateGL(vec2 pos, vec2 outPos, vec2 sourceDim, int count, mat3 modelTransform, int locusMode, mat3 locusTransform) {
    float pixel = 2.0 / sourceDim.y;
    float X = sourceDim.x / sourceDim.y;
    float Y = 1.0;

    vec2 p = vec2(pixel, 0.0);
    vec2 d = pixel * normalize(mat2(modelTransform) * p);

    vec4 bkg = __source__(pos);            // raw source — locus background (Pap u_Tex0)

    vec4 col = __source2__(pos);           // blurred source (Pap u_Tex1)
    float s = sampleCol(col, count);

    vec2 pos1 = pos;
    while (sampleCol(__source2__(pos1 + d), count) == s && inside(pos1 + d, X, Y)) {
        pos1 += d;
    }
    vec4 col1 = __source2__(pos1);

    vec2 pos2 = pos;
    while (sampleCol(__source2__(pos2 - d), count) == s && inside(pos2 - d, X, Y)) {
        pos2 -= d;
    }
    vec4 col2 = __source2__(pos2);

    vec2 dd = pos2 - pos1;
    float len = length(dd);
    // Pap quirk: isolated pixel returns the blurred colour directly, no locus.
    if (len == 0.0) return col;

    vec4 outCol = mix(col1, col2, dot((pos - pos1) / len, (pos2 - pos1) / len));

    float locus = ciGetLocus(pos, bkg, outCol, locusMode, locusTransform);
    return mix(bkg, outCol, locus);
}
