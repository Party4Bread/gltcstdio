vec4 colorize(vec4 sourceColor, vec4 targetColor, float saturation) {
    vec4 hslTarget = rgbToHsl(targetColor);
    vec4 hslSource = rgbToHsl(sourceColor);

    hslSource.r = hslTarget.r; // hue
    hslSource.g = hslTarget.g==0.0 ? 0.0 : hslTarget.g*saturation + hslSource.g*(1.0-saturation);
    float gamma = pow(2.0, (0.5-hslTarget.b)*2.0);
    hslSource.b = pow(hslSource.b, gamma);

    return hslToRgb(hslSource);
}

vec4 emphasizePalette(vec2 pos, vec2 outPos, vec2 paletteDim, float intensity, float saturation, float tolerance, float hardness) {
    vec4 inc = __source__(pos);
    vec4 total = vec4(0.0, 0.0, 0.0, 1.0);
    float totalWeight = 0.0;
    float separation = 0.0 + hardness*10.0;

    float k0 = 1.0;

    int n = int(paletteDim.x);
    float tol = tolerance*2.5;//1.74;

    for(int i=0; i<n; ++i) {
        vec4 target = __palette__texelFetch__(ivec2(i, 0));

        vec4 contribColor = vec4(0.0, 0.0, 0.0, 1.0);
        float k = 0.0;
        float dist = length((inc-target).rgb);
        if (dist < tol) {
            contribColor = vec4(colorize(inc, target, saturation).rgb, inc.a);
            k = 1.0-dist/tol;
        }

        k0 = max(0.0, k0-k);
        k = pow(k, separation+0.5);
        total += k*contribColor;
        totalWeight += k;
    }

    vec4 rgb = k0==1.0 ? inc : mix(total / totalWeight, inc, k0); // weird alpha issue if k0==1.0 not handled separately
    return vec4(mix(inc.rgb, rgb.rgb, intensity), inc.a);
}
