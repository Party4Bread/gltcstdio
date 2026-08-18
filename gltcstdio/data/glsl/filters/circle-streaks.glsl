vec4 csColorShift(vec4 color, vec2 delta, float colorVariability) {
    float deltaHue = delta.x * colorVariability * 2.0;
    vec4 hsl = rgbToHsl(color);
    hsl.x += deltaHue * 180.0;
    hsl.z *= (1.0 + 0.3 * delta.y);
    return hslToRgb(hsl);
}

vec4 circleStreaks(vec2 pos, vec2 outPos, vec4 color1, vec4 color2, float regularity, float radius, float radiusVariability, float colorVariability, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), pos);
    float variability = 1.0 - regularity;

    vec2 v = floor(vec2(u.x + 0.5, u.y + 0.5));
    int j = -2;
    int jEnd = 2;
    bool inCircle = false;
    bool shadowed = false;
    vec2 shadowingRnd = vec2(0.0);
    vec2 shadowingDisplacedPoint = vec2(0.0, 1e20);
    float minDistance = 1e5;
    while (j <= jEnd) {
        for (int i = -2; i <= 2; ++i) {
            vec2 point = vec2(v.x + float(i), v.y + float(j));
            vec2 rnd = rand2rel(point);
            vec2 displace = rnd * variability * 2.0;
            vec2 displacedPoint = point + displace;
            if (shadowingDisplacedPoint.y > displacedPoint.y) {
                float distance = length(displacedPoint - u);
                float r = radius * (1.0 + displace.x * radiusVariability);
                bool inRadius = distance < r;
                if (abs(displacedPoint.x - u.x) < r && (inRadius || displacedPoint.y > u.y)) {
                    minDistance = min(minDistance, distance);
                    shadowingDisplacedPoint = displacedPoint;
                    shadowingRnd = rnd;
                    shadowed = true;
                    inCircle = inRadius;
                }
            }
        }
        if (!shadowed && jEnd < 100) ++jEnd;
        ++j;
    }

    if (shadowed) {
        vec4 baseColor = csColorShift(color1, shadowingRnd, colorVariability);
        return inCircle
            ? baseColor
            : vec4(mix((baseColor.rgb + 0.2) * 1.15, color2.rgb, min(1.0, 0.5 * minDistance)), baseColor.a);
    }
    return color2;
}
