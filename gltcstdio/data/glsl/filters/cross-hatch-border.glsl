vec2 interpolatedRand2Seeded(vec2 v, float seed) {
    float sfractY = smoothstep(0.0, 1.0, fract(v.y));
    return mix(
        mix(rand2relSeeded(floor(v), seed), rand2relSeeded(vec2(floor(v.x), ceil(v.y)), seed), sfractY),
        mix(rand2relSeeded(vec2(ceil(v.x), floor(v.y)), seed), rand2relSeeded(ceil(v), seed), sfractY),
        smoothstep(0.0, 1.0, fract(v.x)) );
}

float hatch(vec2 u, float intensity, float freq, float size) {
    vec2 b = floor(u+0.5);
    float N = floor(size+abs(intensity));
    float l = 0.0;
    for(float j=b.y-N; j<=b.y+N; ++j) {
        for(float i=b.x-N; i<=b.x+N; ++i) {
            vec2 id = vec2(i, j);
            vec2 dd = (hash22(id)-0.5);
            vec2 c = id + intensity * dd;
            float d = length(u-c);
            if (d<size) {
                vec2 dir = normalize(dd);
                float falloff = smoothstep(2.0, 1.0, d);
                l = max(l, falloff * (sin(dot(dir, u-c)*freq)*.5+.5));
            }
        }        
    }
    return l;
}

float borderDistance(vec2 coord, float ratio, float M, float border) {
    if (border==0.0) return 0.0;
	return max(max((-ratio+border-coord.x)/border, (coord.x-(ratio-border))/border),
                  max((-1.0+border-coord.y)/border, (coord.y-(1.0-border))/border) );
}

vec4 crossHatchBorder(vec2 pos, vec2 outPos, float border, vec2 sourceDim, vec2 outDim, vec4 borderColor, float variability, float randomSeed, mat3 modelTransform, mat3 borderTransform) {
    float ratio = outDim.x / outDim.y;
    vec2 v = tf(inverse(modelTransform), pos);
    
    float bRel = border*2.0; // hack to try to match size of image to border but it's approximate 
    
    float B = borderDistance(outPos, ratio, 0.1, border) + variability*100.0 * 0.08*interpolatedRand2Seeded(pos*2.0, randomSeed).x;
    if (B<=0.0) return __source__(v);

    float freq = 100.0;
    vec2 u = (inverse(borderTransform) * vec3(pos, 1.0)).xy;
    float k = smoothstep(B-0.01, B, 1.0-hatch(u, 0.2, freq, 2.0));

    if (k==0.0) return borderColor;
    return mix(borderColor, __source__(v), k);
}
