vec2 interpolatedRand2Seeded(vec2 v, float seed) {
    float sfractY = smoothstep(0.0, 1.0, fract(v.y));
    return mix(
        mix(rand2relSeeded(floor(v), seed), rand2relSeeded(vec2(floor(v.x), ceil(v.y)), seed), sfractY),
        mix(rand2relSeeded(vec2(ceil(v.x), floor(v.y)), seed), rand2relSeeded(ceil(v), seed), sfractY),
        smoothstep(0.0, 1.0, fract(v.x)) );
}

float lenP(vec2 u, float k) {
    return pow(pow(u.x, k) + pow(u.y, k), 1.0/k);
}

float sinewaves(vec2 coord, float angle, float r, float baseAmp, float varAmp, float baseThickness, float varThickness, float size, float variability, float randomSeed) {
    float scale = size + 15.0;
    vec2 base = floor(vec2(r*scale, r*scale));
    float seed = randomSeed;
    //int N = 8;
    //int(ceil(k*0.01+baseRadius*varRadius));
    //for(int j = -N; j <= N; ++j) {
    //    vec2 center = vec2(0.0, float(j)) + base;
    float value = 0.0;
    for(int j = -2; j <= int(scale)+2; ++j) {
        vec2 center = vec2(0.0, float(j));
        vec2 delta = rand2relSeeded(center, seed);
        center += variability*100.0 * vec2(6.0, 2.0)/scale*delta;
        float amp = (varAmp*delta.x + 1.0)*baseAmp;
        float thickness = (varThickness*delta.y + 1.0)*baseThickness;
        float rr = center.y + amp*sin(center.x + angle*10.0);
        float d = abs(r*scale-rr)/(30.0*thickness);
        if (d<1.0) {
            float k = 0.8;
            if (d<k) {
                return 1.0;
            }
            else {
                value = max(value, (1.0-d)/(1.0-k));//smoothstep(k, 1.0, d);
            }
        }
    }
    return value;
}

float borderDistanceRounded(vec2 coord, float ratio, float radius, float thickness) {
    float D = radius+thickness;
    float x1 = (-ratio+D-coord.x)/D;
    float x2 = (coord.x-(ratio-D))/D;
    float y1 = (-1.0+D-coord.y)/D;
    float y2 = (coord.y-(1.0-D))/D;
    float X = max(x1, x2);
    float Y = max(y1, y2);
    if (X>0.0 && Y>0.0) {
        return length(vec2(X, Y)) - radius/(radius+thickness);
    }
    else {
        return max(X, Y) - radius/(radius+thickness);
    }
}

vec4 weaveBorder(vec2 pos, vec2 outPos, float border, vec2 sourceDim, vec2 outDim, vec4 borderColor, float variability, float randomSeed, mat3 modelTransform) {
    float ratio = outDim.x / outDim.y;
    vec2 v = tf(inverse(modelTransform), pos);
    
    float bRel = border*2.0; // hack to try to match size of image to border but it's approximate 
    
    float B = borderDistanceRounded(outPos, ratio, bRel, bRel) + variability * 0.08*interpolatedRand2Seeded(pos*10.0, randomSeed).x;
    if (B<=0.0) return __source__(v);

    float angle = atan(outPos.y, outPos.x);
    float k = 1.0 - sinewaves(pos, angle, B, 2.0, 1.0, 0.1*(B<0.0?0.0:pow(B, 0.7)), 0.5, 20.0, variability, randomSeed);
//    float k = 1.0 - sinewaves(pos, angle, pos.x, 2.0, 1.0, 0.5, 0.5);

    if (k==0.0) return borderColor;
    return mix(borderColor, __source__(v), k);
}
