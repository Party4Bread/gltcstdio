vec4 cherckerboard(vec2 uv, vec2 outPos, int mode, int source_specified, vec4 color1, vec4 color2) {
    float k = mod(floor(uv.x)+floor(uv.y), 2.0); 
    vec2 id = mod(floor(uv), 4.0);
    float index = id.x+id.y*4.0;
    float bit = mod(floor(float(mode)/pow(2.0, index)), 2.0);
        
    vec4 outColor = mix(color1, color2, bit);
    
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
    
    //return vec4(vec3(outPos.y), 1.);
}
