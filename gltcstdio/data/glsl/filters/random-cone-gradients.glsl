float changeIn01(float x, float range, float k) {
    float r2 = range*0.5;
    float a = x-r2;
    float b = x+r2;
    if (a<0.0) {
        b -= a;
        a = 0.;
    }
    if (b>1.0) {
        a += 1.-b;
        b = 1.;
    }
    return a + (b-a)*k;
}

vec4 randomConeGradients(vec2 u, vec2 outPos, vec4 color1, vec4 color2, vec4 color3, vec4 color4, vec4 colorBkg, float hardness, float variability, float colorVariability, float randomSeed,
    float acuteness, float radiality
) {
    float intensity = variability * 4.;
    
    vec2 b = floor(u+0.5); 
    float N = floor(2.0+0.5*abs(intensity));
    float totalW = colorBkg.a*colorBkg.a*2.;
    vec3 col = totalW*colorBkg.rgb;
    for(float j=b.y-N; j<=b.y+N; ++j) {
        for(float i=b.x-N; i<=b.x+N; ++i) {
            vec2 id = vec2(i, j);
            vec2 rnd1 = rand2relSeeded(id, randomSeed);
            vec2 rnd2 = rand2relSeeded(id+1., randomSeed);
            vec2 c = id + intensity * rnd1;
            vec2 dir = normalize(mix(rnd2, normalize(c), radiality));
            //vec2 dir = normalize(-id);
            float d = length(u-c);
//            float w = pow(smoothstep(1.64, 0., d), 2.25) * pow(smoothstep(-1.0, 1.0, dot(normalize(u-c), dir)), 0.5);
            float w = pow(0.001+0.999*smoothstep(1.64, 0., d), 2.2+1.6*hardness) * (acuteness==1.0 ? 1.0 : pow(smoothstep(-1.0, 1.0, dot(normalize(u-c), dir)), (2.0-acuteness*2.)));
            //float w = pow(max(0., 1.-d), 1.25) * pow(smoothstep(-0.5, 1.0, dot(normalize(u-c), dir)), 0.25);
            //w *=w*w; // optional
            float selector = mod(rnd1.x*40., 4.0);
            float rndR = fract(rnd1.y*10.);
            float rndB = fract(rnd2.x*10.);
            float rndG = fract(rnd2.y*10.);
            vec4 baseCol = selector<1.0 ? color1 : selector<2.0 ? color2 : selector<3.0 ? color3 : color4;
            baseCol.r = changeIn01(baseCol.r, colorVariability, rndR);
            baseCol.g = changeIn01(baseCol.g, colorVariability, rndG);
            baseCol.b = changeIn01(baseCol.b, colorVariability, rndB);
            col += w * baseCol.rgb;//hash23(id);
            totalW += w;
        }
    }

    return vec4(col/totalW, 1.0);
}
