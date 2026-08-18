vec2 distort(vec2 pos, vec2 a, vec2 b, vec2 splits, vec4 rect, float intensity, float seed, int mode) {
    vec2 rnd = rand2relSeeded(splits, seed+122.1);
    float dx = rect.z-rect.x;
    float dy = rect.w-rect.y;
    if (dx>dy) {
        return pos + vec2(sign(rnd.x)*dx/dy*intensity*0.0005, 0.0);
    }
    else {
        return pos + vec2(0.0, sign(rnd.y)*dy/dx*intensity*0.0005);
    }
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

float roundedRectField(vec2 uv, float shapeAspectRatio) {
    // rounded-rectangle-gradient viewTransform: scale 1.1036 (translation ignored).
    // Generators sample world = inverse(viewTransform)*coord, so divide by the scale.
    uv /= 1.1036;
    vec2 rectSize = vec2(1.0, shapeAspectRatio);
    rectSize /= length(rectSize);
    float d = sdRectangle(uv*2.0, rectSize);
    return step(d*0.25, 0.0);
}

vec4 schema1(vec2 uv, vec2 outPos, vec2 sourceDim, float shapeAspectRatio, int iterations, float intensity, float variability, float randomSeed, vec4 color1, vec4 color2, float thickness, mat3 modelTransform) {
    vec4 bg = __source__(uv);

    // (1) overlay placement: map screen uv into the pattern's local frame.
    vec2 p = (inverse(modelTransform) * vec3(uv, 1.0)).xy;

    // Internal dichotomic-break subdivision depth + bias (from the snuggly-caterpillar
    // dichotomic-break modelTransform: scale 0.057275485, translation 0).
    float scale = 1.0/0.057275485;
    vec2 bias = vec2(0.0, 0.0);

    int mode = 9;
    float ratio = 1.0;              // square pattern field
    float pixel = 2.0/sourceDim.y;

    bool border = false;
    vec4 rect;
    float rndStep = 0.0;            // mode 9 -> rndStep 0
    float regularity = 1.0-variability;

    for(int j=0; j<iterations; ++j) {
        rect = vec4(-ratio, -1.0, ratio, 1.0);
        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0);
        float sPos = 0.0;
        float sscale = 0.5;
        float inverter = 0.0;

        for (float i=0.0; i+sPos<scale; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed+122.1+rndStep*float(j));
            vec2 size = rect.zw-rect.xy;
            if (size.x<pixel || size.y<pixel) break;

            if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
            float variability = 1.0-max(0.0, (regularity*2.0-1.0));

            if (horSplit) {
                float Y = mix(rect.y, rect.w, variability*withBias(rnd.y, bias.y)+0.5);
                if (abs(Y-p.y)<thickness*0.1) { border = true; break; }
                if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            else {
                float X = mix(rect.x, rect.z, variability*withBias(rnd.x, bias.x)+0.5);
                if (abs(X-p.x)<thickness*0.1) { border = true; break; }
                if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            horSplit = !horSplit;
            inverter = 1.0-inverter;
            sscale *= 0.5;
            bias *= 0.5;
        }
        if (border) break;
        p = distort(p, rect.xy, rect.zw, splits, rect, intensity, randomSeed, mode);
    }

    // (2) per-cell color: rounded-rectangle field at the distorted point, mapped to the two
    // hatch colors (color2 outside the shape / transparent, color1 inside).
    float k = roundedRectField(p, shapeAspectRatio);
    vec4 fg = border ? color2 : mix(color2, color1, k);

    // (3) overlay composite over the background (intensity was 1.0 -> full).
    return mergeColor(bg, fg);
}
