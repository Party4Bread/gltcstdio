vec2 interpolatedRand2Seeded(vec2 v, float seed) {
    float sfractY = smoothstep(0.0, 1.0, fract(v.y));
    return mix(
        mix(rand2relSeeded(floor(v), seed), rand2relSeeded(vec2(floor(v.x), ceil(v.y)), seed), sfractY),
        mix(rand2relSeeded(vec2(ceil(v.x), floor(v.y)), seed), rand2relSeeded(ceil(v), seed), sfractY),
        smoothstep(0.0, 1.0, fract(v.x)) );
}

float circles(vec2 coord, float k, float baseRadius, float varRadius, float baseThickness, float varThickness, float seed) {
	vec2 base = floor(coord);
    float minD = 10000.0;
    int N = int(ceil(k*0.01+baseRadius*varRadius));
    for(int j = -N; j <= N; ++j) {
        for(int i = -N; i <= N; ++i) {
            vec2 center = vec2(float(i), float(j)) + base;
            vec2 delta = rand2relSeeded(center, seed);
            float radius = (varRadius*delta.x + 1.0)*baseRadius;
            float thickness = (varThickness*delta.y + 1.0)*baseThickness;
            center += vec2(0.5, 0.5) + delta*k*0.02;
            vec2 v = coord - center;
            float d = length(v);

            if (abs(d-radius) < thickness) {
            //if (d < radius) {
                return 1.0;
            }
        }
    }
    return 0.0;
}

float borderDistance(vec2 coord, float ratio, float M, float border) {
    if (border==0.0) return 0.0;
	return max(max((-ratio+border-coord.x)/border, (coord.x-(ratio-border))/border),
                  max((-1.0+border-coord.y)/border, (coord.y-(1.0-border))/border) );
}

vec4 bubbleBorder(vec2 pos, vec2 outPos, float border, vec2 sourceDim, vec2 outDim, vec4 borderColor, float variability, float randomSeed, mat3 modelTransform, mat3 borderTransform) {
    float ratio = outDim.x / outDim.y;
    vec2 v = tf(inverse(modelTransform), pos);
    
    float bRel = border*2.0; // hack to try to match size of image to border but it's approximate 
    
    float B = borderDistance(outPos, ratio, 0.1, border) + variability*100.0 * 0.08*interpolatedRand2Seeded(pos*10.0, randomSeed).x;
    if (B<=0.0) return __source__(v);

    float k = 1.0-circles((inverse(borderTransform) * vec3(pos, 1.0)).xy, 100.0, B, 2.0, 0.5*(B), 1.0, randomSeed);

    if (k==0.0) return borderColor;
    return mix(borderColor, __source__(v), k);
}
