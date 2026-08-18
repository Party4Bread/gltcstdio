vec2 f1(vec2 u, vec2 split, int N, float intensity, float balance, float variability, float randomSeed) {
    float r = 0.0;
    for(int i=0; i<N; ++i) {
        
        vec2 scale;
        vec2 center;
        if (u.x>split.x && u.y>split.y) {
            scale = 2.0/vec2(1.0-split.x, 1.0-split.y);
            center = vec2(1.0+split.x, 1.0+split.y)/2.0;
            r += 0.25 * pow(0.5, float(i));
        }
        else if (u.x<=split.x && u.y>split.y) {
            scale = 2.0/vec2(1.0+split.x, 1.0-split.y);
            center = vec2(-1.0+split.x, 1.0+split.y)/2.0;
            r += 0.5 * pow(0.5, float(i));
        }
        else if (u.x>split.x) {
            scale = 2.0/vec2(1.0-split.x, 1.0+split.y);
            center = vec2(1.0+split.x, -1.0+split.y)/2.0;
            r += 0.75 * pow(0.5, float(i));
        }
        else {
            scale = 2.0/vec2(1.0+split.x, 1.0+split.y);
            center = vec2(-1.0+split.x, -1.0+split.y)/2.0;
            r += 1.0 * pow(0.5, float(i));
        }
        
        vec2 rnd = rand2relSeeded(vec2(r ,r), randomSeed);
        float rndx = (rnd.x + 0.5)*variability;
        if (rndx<0.25) u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        else if (rndx<0.5) u = -(mix(vec2(0.), center, intensity) + (u-center)*scale);
        else if (rndx<0.75) { 
            u = u = -u;
        }
        else {
            if (i<2) u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        
//        u = u*scale - center*scale;
        //u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        split = mix(split, center, balance);
    }
    return u;
}

vec2 f2(vec2 u, vec2 split, int N, float intensity, float balance, float variability, float randomSeed) {
    float r = 0.0;
    vec2 origU = u;
    for(int i=0; i<N; ++i) {
        
        vec2 scale;
        vec2 center;
        if (u.x>split.x && u.y>split.y) {
            scale = 2.0/vec2(1.0-split.x, 1.0-split.y);
            center = vec2(1.0+split.x, 1.0+split.y)/2.0;
            r += 0.25 * pow(0.5, float(i));
        }
        else if (u.x<=split.x && u.y>split.y) {
            scale = 2.0/vec2(1.0+split.x, 1.0-split.y);
            center = vec2(-1.0+split.x, 1.0+split.y)/2.0;
            r += 0.5 * pow(0.5, float(i));
        }
        else if (u.x>split.x) {
            scale = 2.0/vec2(1.0-split.x, 1.0+split.y);
            center = vec2(1.0+split.x, -1.0+split.y)/2.0;
            r += 0.75 * pow(0.5, float(i));
        }
        else {
            scale = 2.0/vec2(1.0+split.x, 1.0+split.y);
            center = vec2(-1.0+split.x, -1.0+split.y)/2.0;
            r += 1.0 * pow(0.5, float(i));
        }
        
        vec2 rnd = rand2relSeeded(vec2(r ,r), randomSeed);
        float rndx = (rnd.x + 0.5)*variability;
        if (rndx<0.1) u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        else if (rndx<0.2) {
            center = vec2(0.);
            u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        else if (rndx<0.3) u = -(mix(vec2(0.), center, intensity) + (u-center)*scale);
        else if (rndx<0.4) { 
            u = mix(vec2(0.), center, intensity) + (u-center)*scale;
            u = rotation2(0.3) * u;
        }
        else if (rndx<0.5) u = origU;
        else if (rndx<0.6) { 
            u = u = -u;
        }
        else if (rndx<0.7) {
            scale *= 0.5;
            u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        else if (rndx<0.8) {
            u.x = 0.0;
        }
        else if (rndx<0.9) {
            u.y = 0.0;
        }
        else {
            if (i<2) u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        }
        
//        u = u*scale - center*scale;
        //u = mix(vec2(0.), center, intensity) + (u-center)*scale;
        split = mix(split, center, balance);
    }
    return u;
}

float getPlacement(vec2 u, float style, float randomSeed) {
    if (style==0.0) return 1.;
    float s = abs(style);
    float d;
    if (s<0.1) {
        d = length(u) * s / 0.1;
    }
    else if (s<0.5) {
        float p = mix(2., 50., (s-0.1)/0.4);
        d = pow(pow(abs(u.x), p) + pow(abs(u.y), p), 1./p);
    }
    else {
        float k = (s-0.5)*2.;
//        u += k * rand2relSeeded(floor(u*(1.+k*5.)), randomSeed);
        u += k * rand2relSeeded(floor(u*2.), randomSeed);
        if (k>0.33) u += k*.5 * rand2relSeeded(floor(u*4.), randomSeed);
        if (k>0.66) u += k*.25 * rand2relSeeded(floor(u*8.), randomSeed);
        d = max(abs(u.x), abs(u.y));
    }
    return (1.0-d) * sign(style);
}

vec4 division(vec2 pos, vec2 outPos, int count, float intensity, float balance, float border, vec4 borderColor, vec2 sourceDim, mat3 modelTransform, float variability, float randomSeed, mat3 placementTransform, float placementStyle, float placementFeather) {
            vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
//            vec2 u = (inverse(modelTransform) * vec3(0.0, 0.0, 1.0)).xy;
//            vec2 u = mix((inverse(modelTransform) * vec3(pos, 1.0)).xy, (inverse(modelTransform) * vec3(0.0, 0.0, 1.0)).xy, intensity);
            vec2 split = fract(u)*2.0-1.0;
            float ratio = sourceDim.x/sourceDim.y;
            vec2 vRatio = vec2(ratio, 1.0);
            
            vec2 v = f2(pos/vRatio, split, count, intensity, balance, variability, randomSeed)*vRatio;
            
            float p = getPlacement(tf(inverse(placementTransform), pos), placementStyle, randomSeed);
            v = mix(pos, v, smoothstep(-0.001, placementFeather, p));
            
            vec4 outColor = __source__(v);
            
            float edgeDist = abs(min(1.0-abs(v.y), ratio-abs(v.x)));
            if (edgeDist<border) outColor = mergeColor(outColor, borderColor);
                      
            return outColor;
        }
