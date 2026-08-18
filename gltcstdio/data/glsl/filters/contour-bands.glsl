float sampleCol(vec4 color, float count) {
    return floor((color.r + color.g + color.b)*(count-1.0)/3.0 + 0.5);
}

vec4 contour(vec2 uv, vec2 outPos, int count, vec4 color1, vec4 color2, int source2_specified) {
    float s = sampleCol(source2_specified==1 ? __source2__(uv) : __source__(uv), float(count));
    float k = mod(s, 2.0);        

    vec4 color;
    color = mix(color1, color2, k);
    vec4 bkgColor = __source__(uv);

    return mergeColor(bkgColor, color);
}
