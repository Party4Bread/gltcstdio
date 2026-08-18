vec4 bloomCombine(vec2 uv, vec2 outPos, float intensity, float balance, float normalization) {
    vec4 bkgColor = __source1__(uv);
    vec4 bloomColor = __source2__(uv);
                    
    vec3 added = bkgColor.rgb + bloomColor.rgb * intensity*bloomColor.a;
    vec3 blended = mix(bkgColor.rgb, bloomColor.rgb, min(intensity*bloomColor.a, 1.0));
    float maxValue = mix(1.0+intensity, 1.0, balance);
    
    return vec4(mix(added, blended, balance) * mix(1.0, 1.0/maxValue, normalization), bkgColor.a);
      
}
