float locusFmod(float a, float b) {
    return a - b * trunc(a / b);
}

float locusGetHue(vec4 c) {
    float r = c.r, g = c.g, b = c.b;
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));
    if (maxi == mini) return 0.0;
    else if (maxi == r) return locusFmod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g) return (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else return (60.0 * (r - g) / (maxi - mini)) + 240.0;
}

float locusGetBlock(vec2 pos) {
    float inside = 0.0;
    float i2 = floor(pos.x/10.0) + floor(pos.y/10.0);
    float divisor = floor(locusFmod((pos.x-2.0*pos.y)/200.0, 24.0))/2.0;
    float threshold = locusFmod((pos.x+2.0*pos.y)/200.0, 24.0)/6.0;
    float total = 0.0;
    vec4 rdmz = vec4(locusFmod(i2*8877.0, 65536.0), locusFmod(55.0+i2*777.0, 65536.0),
                     locusFmod(i2*413.0, 65536.0), locusFmod(4445.0+i2*78.0, 65536.0));
    for (int i = 0; i < 5; ++i) {
        vec2 v = vec2(locusFmod(pos.x, 8.0), locusFmod(pos.y, 8.0));
        float index = v.x + v.y*8.0;
        float idx = locusFmod(pos.y, 300.0) > 150.0 ? 3.0 : clamp(0.0, 3.0, floor(index/16.0));
        float ins = locusFmod(floor(rdmz[int(idx)]/pow(2.0, index-idx*16.0)), 2.0);
        total += ins;
        pos = floor(pos/divisor);
    }
    inside = total >= threshold ? 1.0 : 0.0;
    return inside;
}

float getLocus(vec2 pos, vec4 inCol, vec4 outCol, int locusMode, mat3 locusTransform) {
    if (locusMode == 0) return 1.0;

    // legacy host inverts the transform for the geometric modes (1-3) only
    mat3 m = locusTransform;
    if (locusMode <= 3) m = inverse(locusTransform);
    vec2 u = (m * vec3(pos, 1.0)).xy;

    if (locusMode == 1) {                 // square
        return max(abs(u.x), abs(u.y)) > 1.0 ? 0.0 : 1.0;
    } else if (locusMode == 2) {          // outside circle
        return smoothstep(0.5, 1.0, length(u));
    } else if (locusMode == 3) {          // inside circle
        return smoothstep(1.0, 0.5, length(u));
    } else if (locusMode == 4) {          // hue select
        float hue = locusGetHue(inCol);
        float targetHue = locusFmod(locusTransform[2][0] * 180.0, 360.0);
        float d = hue - targetHue;
        if (d < 0.0) d = -d;
        if (d > 180.0) d = 360.0 - d;
        float maxD = 360.0 / length(vec2(locusTransform[0][0], locusTransform[0][1]));
        d /= maxD;
        return smoothstep(1.0, 0.75, d);
    } else if (locusMode == 5) {          // block glitch
        vec2 v = floor(u * 40.0);
        return locusGetBlock(v);
    } else if (locusMode == 6) {          // color change
        float colDist = length(inCol.rgb - outCol.rgb);
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float maxDist = scale < 1.0 ? 1.732 * scale : 1.732 / scale;
        if (scale < 1.0) colDist = 1.732 - colDist;
        colDist /= maxDist;
        return smoothstep(1.0, 0.75, colDist);
    } else if (locusMode == 7) {          // blend (uniform opacity)
        return clamp(-locusTransform[2][0] + locusTransform[2][1], 0.0, 1.0);
    } else if (locusMode == 8) {          // scanlines
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

vec4 locusBlend(vec2 pos, vec2 outPos, int locusMode, mat3 locusTransform) {
    vec4 inc = __source__(pos);
    vec4 outc = __effect__(pos);
    return mix(inc, outc, getLocus(pos, inc, outc, locusMode, locusTransform));
}
