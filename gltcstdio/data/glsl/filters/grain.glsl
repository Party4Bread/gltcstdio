vec4 grain(vec2 pos, vec2 outPos, float intensity, float type, int octaves, mat3 modelTransform) {
    vec4 col = __source__(pos);
    
    vec2 u = tf(inverse(modelTransform), pos) * 300.0;
    float pn = 2.0 * (perlinOctaveNoise(u, octaves) - 0.5);
    
    float additive = type * intensity * 4.0;
    float multiplicative = (1. - type) * intensity * 4.0;            
    
    col.rgb += additive * pn;
    col.rgb *= 1.0 + multiplicative * pn;
    
    return col;
}
