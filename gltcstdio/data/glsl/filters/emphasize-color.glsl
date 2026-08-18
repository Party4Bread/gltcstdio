vec4 colorize(vec4 sourceColor, vec4 targetColor, float saturation) {
    vec4 hslTarget = rgbToHsl(targetColor);
    vec4 hslSource = rgbToHsl(sourceColor);

    hslSource.r = hslTarget.r; // hue
    hslSource.g = hslTarget.g==0.0 ? 0.0 : hslTarget.g*saturation + hslSource.g*(1.0-saturation);
    float gamma = pow(2.0, (0.5-hslTarget.b)*2.0);
    hslSource.b = pow(hslSource.b, gamma);

    return hslToRgb(hslSource);
}

vec4 emphasizeColor(vec2 pos, vec2 outPos, vec4 color, float intensity, float saturation, float tolerance, float hardness) {
    vec4 inc = __source__(pos);
    
    vec4 inHsl = rgbToHsl(inc);
    vec4 empHsl = rgbToHsl(color);
    vec2 delta = vec2((inHsl.x-empHsl.x)/180.0, inHsl.y-empHsl.y);
    if (delta.x>1.0) delta.x = 2.0-delta.x;
    float dist = length(delta) / 1.4;

    if (dist >= tolerance) return inc;

    vec4 rgb = colorize(inc, color, saturation);

    //float intens = intensity * (1.0-dist/tolerance);
    float intens = intensity * smoothstep(tolerance*1.001, tolerance*hardness, dist);
    return mix(inc, rgb, intens);
}
