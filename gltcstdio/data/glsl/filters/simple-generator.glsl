vec4 simpleGen(vec2 uv, vec2 outPos) {
    float k = mod(floor(uv.x)+floor(uv.y), 2.0); 
    vec2 id = mod(floor(uv), 4.0);
    float index = id.x+id.y*4.0;
    float bit = mod(floor(float(42405.0)/pow(2.0, index)), 2.0);
        
    vec4 outColor = mix(vec4(0., 0., 0., 1.), vec4(1.), bit);
    
    return outColor;
    
}
