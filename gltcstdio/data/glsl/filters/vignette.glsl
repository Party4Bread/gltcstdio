vec4 vignette(vec2 pos, vec2 outPos, float vignette_intensity, float vignette_hardness, vec4 vignette_color, mat3 vignette_transform) {
    vec4 col = __source__(pos);
    
    if (vignette_intensity != 0.) {
        float d = length(tf(inverse(vignette_transform), pos));
        float k = vignette_intensity * smoothstep(min(vignette_hardness, 0.9999), 1.0, d);
        col = mix(col, vignette_color, k);
    }
    
    return col;
}
