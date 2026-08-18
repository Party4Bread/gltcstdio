vec4 voronoiNoise(vec2 pos, vec2 outPos, int source_specified, mat3 viewTransform, int octaves, float variability, float randomSeed, vec4 color1, vec4 color2, float threshold, vec4 thresholdColor) {
    vec2 u = pos;
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
        
    float total = 0.;
    float noise = 0.0;
    float amplitude = 1.0;

    for(int k=0; k<octaves; ++k) {
        vec2 v = floor(vec2(u.x+0.5, u.y+0.5));
        float closest = 1e9;
        for(int j=-2; j<=2; ++j) {
            for(int i=-2; i<=2; ++i) {
                vec2 point = vec2(v.x+float(i), v.y+float(j));
                vec2 displace = (rand2relSeeded(point, randomSeed) * variability)* 2.0;
                float distance = length(point+displace - u);
                if (distance < closest) {
                    closest = distance;
                }
            }
        }
        total += amplitude;
        noise += amplitude * closest;
        amplitude *= 0.5;
        u = u*2.0 + vec2(1.34, 2.55);
    }
    
    noise /= total;
    
    vec4 outColor;
    if (threshold==0.0) outColor = mix(color1, color2, noise);
    else if (threshold<0.0) {
        if (noise >= 1.0 + threshold) {
            outColor = thresholdColor;
        }
        else {
            outColor = mix(color1, color2, (noise)/(1.0+threshold));
        }
    }
    else {
        if (noise <= threshold) {
            outColor = thresholdColor;
        }
        else {
            outColor = mix(color1, color2, (noise-threshold)/(1.0-threshold));
        }
    }
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor; 
}
