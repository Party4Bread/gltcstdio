vec4 voronoiHatch(vec2 pos, vec2 outPos, int source_specified, mat3 viewTransform, float variability, float shadows, vec4 color1, vec4 color2, float offset, float banding) {
    vec2 u = pos;
    Tile cell = getVoronoiTile(u, variability);
    float d = cell.centerDist;
    float d2 = cell.secondCenterDist;
    float d3 = cell.thirdCenterDist;
    float rounded = min(2./(1./max(d2 - d, .001) + 1./max(d3 - d, .001)), 1.);
    float lightness = smoothstep(-0.001, shadows, abs(rounded));
    vec2 id = cell.tileId;
    float even = mod(id.x+id.y, 2.0);
    vec2 dir = normalize(mix( 
        vec2(even, 1.-even),
        hash22(id) - 0.5,
        variability));
    float k = lightness * (cos(dot(u-cell.center, dir)*banding + offset*PI)*.5+.5);
    vec4 outColor = mix(color2, color1, k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;  
}
