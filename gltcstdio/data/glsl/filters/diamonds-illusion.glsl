vec4 diamondsIllusion(vec2 uv, vec2 outPos, int source_specified, int count, float power, vec4 color1, vec4 color2) {
    vec2 u = (fract(uv)-0.5)*2.0;
    
    vec2 id = floor(uv);
        
    float m = max(abs(u.x), abs(u.y));
    
    float p = pow(1.5, power);
    float strip = floor(pow(m, p) * 
    float(count));
    float tileType = mod(id.x+id.y, 2.0);
    float slope = (tileType-0.5)*2.0;
    
    vec4 outColor;
    if (mod(strip, 2.0)==0.0 ^^ tileType==0.0 ^^ (u.x*slope>u.y) ^^ mod(id.y, 2.0)==0.0) outColor = color1; else outColor =  color2;
    
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
