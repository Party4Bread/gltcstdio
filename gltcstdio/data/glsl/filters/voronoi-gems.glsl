vec3 color(vec2 id) {
    return vec3(0.25+0.75*hash22(id), 0.5+0.05*hash22(id+123.0).x);
}

vec4 voronoiGems(vec2 pos, vec2 outPos, int mode, float colorBleed, float variability, float shadows, float specular, vec4 color1, float colorVariability) {
    vec2 uv = pos;
    
    Tile cell = getVoronoiTile(uv, variability*3.0);
    //return vec4(fract(cell.tileId.xy)*0.1, fract(cell.secondTileId.x*0.1), 1.0);
    
    float d = cell.centerDist;
    float d2 = cell.secondCenterDist;
    vec2 id = cell.tileId;
    vec2 secId = cell.secondTileId;
    float b = cell.borderDist;
    
    if (mode==3) return vec4(vec3(b*1.5), 1.);
    
    vec2 normal = cell.borderNormal;
    
    float s = dot(normal, vec2(0.0, 1.0));
    float light = pow(b, 0.35*pow(1.06, shadows*50.0-50.0));
     
    float plight = 1.0 + 1.5*smoothstep(0.6, 1.0, s);
    float nlight = (1.0-light) * (1.5 + smoothstep(0.25, 1.0, -s));
    light *= mix(1.0, mix(nlight, plight, smoothstep(-0.2, 0.2, s)), specular);
    //light *= mix(nlight, plight, smoothstep(-0.2, 0.2, s));
    
    float cb = 0.05*smoothstep(0.0, 0.9, d) + 0.25*smoothstep(2.0, 1.0, d2/d);
    vec3 faceColor = mode==1 ? color(id) : vec3(normal.x*0.5+0.5, normal.y*0.5+0.5, 0.5);
    vec3 rgb = mix(color1.rgb, faceColor, colorVariability);
    vec3 col = mix(rgb, color(secId), colorBleed*cb) * light; // gems    

    return vec4(col, 1.0);
}
