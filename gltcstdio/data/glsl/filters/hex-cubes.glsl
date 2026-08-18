float reflectFloat(float x) {
    return 1.0-abs(mod(x, 2.)-1.0);
}

vec4 reflectVec4(vec4 u) {           
    return vec4(reflectFloat(u.x), reflectFloat(u.y), reflectFloat(u.z), reflectFloat(u.a)); 
}

vec4 hexCubes(vec2 uv, vec2 outPos, int source_specified, float thickness, vec4 borderColor, vec4 colorShadow, vec4 colorOffset, vec4 color1, vec4 color2, vec4 color3) {
    vec2 u = uv;
    
    vec4 col; 

    vec4 hex = hexPolarBorderCoords(u);
    float borderSize = thickness*0.5;
    if (hex.y<borderSize) return borderColor;
    float angle = mod(hex.x + PI2 + PI/6.0, PI2);
    vec2 id = hex.zw;
    float topIndex = id.y;
    float rightIndex = id.x-id.y*0.5;
    float leftIndex = id.x+id.y*0.5;
    
    float gradientStrength = colorOffset.a*colorOffset.a;

    if (angle<PI2_3) col = reflectVec4(color2 + vec4(colorOffset.r*rightIndex-0.5, 0.0, 0.0, 0.0) * gradientStrength);
    else if (angle<2.*PI2_3) col = reflectVec4(color1 + vec4(0.0, colorOffset.g*leftIndex-0.5, 0.0, 0.0) * gradientStrength);
    else col = reflectVec4(color3 + vec4(0.0, 0.0, colorOffset.b*topIndex-0.5, 0.0) * gradientStrength);
    
    float shadowK = (0.5-hex.y)/(0.5-borderSize);
    vec4 sCol = vec4(colorShadow.rgb, colorShadow.a*shadowK);
    col = mergeColor(col, sCol);
    
    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}
