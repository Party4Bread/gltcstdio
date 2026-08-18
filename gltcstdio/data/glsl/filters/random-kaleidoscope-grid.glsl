vec2 reflct(float d, float sourceAngle, float alpha, float halfAlpha) {
    if (sourceAngle > halfAlpha) sourceAngle = alpha-sourceAngle;
    return d * vec2(cos(sourceAngle), sin(sourceAngle));
}

vec4 kaleidoscope(vec2 pos, vec2 outPos, int spikeCount, mat3 texTransform, float blend, float randomSeed, float variability) {
    float totalWeight = 0.0;
    vec4 totalCol = vec4(0.0);
    vec2 totalCoord = vec2(0.0);
    vec4 lightestCol = vec4(0.0, 0.0, 0.0, 1.0);
    float lightestVal = 0.0;
    float lighting = 1.0;
    
    float N = 1.0;
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {

            vec2 u = pos;
            vec2 id = floor((u+1.0)/2.0) + vec2(i, j);
            vec2 center = id*2.0;// + variability*vec2(rnd3.y, rnd2.y)*3.5;
            u = u-center;

            float d = length(u);
            float weight;
            if (blend<=0.0) {
                weight = max(abs(u.x), abs(u.y))<=1.0 ? 1.0 : 0.0;
                vec2 borderDist = u - vec2(-1.);
                vec2 lightFactor = smoothstep(0.0, 1.4, borderDist);
                float lightStrength = lightFactor.x * lightFactor.y;
                if (i==0. && j==0.) lighting = mix(1.0, lightStrength, -blend);// + blend * (1.0-lightStrength);
                /*if (i==0. && j==0.) {
                    if (mod(id.x+id.y, 2.)==0.) return vec4(lightStrength, lightStrength, lightStrength, 1.0);
                    return vec4(lighting, lighting, lighting, 1.0);
                }*/
            }
            else if (blend<0.15) {
                weight = smoothstep(1.0+blend, 1.0-blend, max(abs(u.x), abs(u.y)));
            }
            else if (blend<0.3) {
//                float squareWeight = smoothstep(1.0+u_Blend*0.01, 1.0-u_Blend*0.01, max(abs(u.x), abs(u.y)));
//                float circleWeight = smoothstep(1.4+u_Blend*0.01, 1.4-u_Blend*0.01, d);
                float squareWeight = smoothstep(1.0+0.15, 1.0-0.15, max(abs(u.x), abs(u.y)));
                float circleWeight = smoothstep(1.4+0.15, 1.4-0.15, d);
                weight = mix(squareWeight, circleWeight, (blend-0.15)/0.15);
            }
            else {
                float b = mix(0.15, 1.0, (blend-0.3)/0.7);
                weight = smoothstep(1.4+b, 1.4-b, d);
            }

            if (weight>0.0) {
                float sourceAngle = 0.0;

                float halfAlpha = 0.0;
                float alpha = 0.0;
                if (d > 0.0) {
                    float ang = atan(u.y, u.x);
                    if (ang<0.0) ang += PI2;

                    halfAlpha = PI/float(spikeCount);
                    alpha = halfAlpha * 2.0;
                    sourceAngle = mod(ang, alpha);
                }

                vec2 coord = reflct(d, sourceAngle, alpha, halfAlpha);
                float angle = 0.0;
                float scale = 1.0;
                vec2 t = vec2(0.0, 0.0);

                if (id.x!=0.0 || id.y!=0.0) {
                    vec2 rnd = rand2relSeeded(id, randomSeed);
                    angle = variability*rnd.x*PI*2.0;
                    scale = variability*rnd.y*0.2+1.0;
                    t = variability*rnd*2.0;
                    //tr = mat3(scale*cos(angle), scale*sin(angle), 0.0, -scale*sin(angle), scale*cos(angle), 0.0, t.x, t.y, 1.0); // this approach crashes on some devices such as Nexus 7
                }
                vec2 tc = tf(inverse(texTransform), coord);
                vec2 tcc = vec2(scale*(cos(angle)*tc.x+sin(angle)*tc.y)+t.x, scale*(-sin(angle)*tc.x+cos(angle)*tc.y)+t.y);
                vec4 col = __source__(tcc);
                

                totalCol += weight*col;
                totalWeight += weight;
            }
        }
    }

    return (totalCol/totalWeight) * vec4(vec3(lighting), 1.);
}
