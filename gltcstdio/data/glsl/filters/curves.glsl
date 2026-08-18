vec4 curves(vec2 pos, vec2 outPos) {
    vec4 col = __source__(pos);

    // 1. Apply R, G, B curves (direct channel mapping)
    int rIdx = clamp(int(col.r * 255.0), 0, 255);
    int gIdx = clamp(int(col.g * 255.0), 0, 255);
    int bIdx = clamp(int(col.b * 255.0), 0, 255);
    col.r = __curveLut__texelFetch__(ivec2(rIdx, 1)).r;
    col.g = __curveLut__texelFetch__(ivec2(gIdx, 2)).r;
    col.b = __curveLut__texelFetch__(ivec2(bIdx, 3)).r;

    // 2. Convert to HSLuv, apply Sat and Hue curves
    // rgbToHsluv returns vec3(H=0..360, S=0..100, L=0..100)
    vec3 hsluv = rgbToHsluv(col.rgb);
    int satIdx = clamp(int(hsluv.y * 2.55), 0, 255);
    hsluv.y = __curveLut__texelFetch__(ivec2(satIdx, 4)).r * 100.0;
    int hueIdx = clamp(int(hsluv.x * (255.0 / 360.0)), 0, 255);
    hsluv.x = __curveLut__texelFetch__(ivec2(hueIdx, 5)).r * 360.0;
    col.rgb = hsluvToRgb(hsluv);

    // 3. Apply luminosity curve (hue-preserving)
    float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    int lumIdx = clamp(int(lum * 255.0), 0, 255);
    float newLum = __curveLut__texelFetch__(ivec2(lumIdx, 0)).r;
    float t = smoothstep(0.0, 0.01, lum);
    vec3 ratioResult = col.rgb * (newLum / max(lum, 0.0001));
    vec3 flatResult = vec3(newLum);
    return vec4(clamp(mix(flatResult, ratioResult, t), 0.0, 1.0), col.a);
}
