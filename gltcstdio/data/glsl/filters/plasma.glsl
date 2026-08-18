vec4 plasma(vec2 uv, vec2 outPos, int source_specified, float intensity, float balance, float hardness, float dampening, vec4 color1, vec4 color2, float colorVariability, float randomSeed, float variability, mat3 modelTransform) {
    vec2 u = uv;
    vec2 u2 = u*0.3;

    vec2 p = floor(u+0.5);
    vec2 p2 = floor(u2+0.5);

    float N = 4.0;
    float t = 0.0;
    float tk2 = 0.0;
    vec3 tc = vec3(0.0, 0.0, 0.0);
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {
            vec2 q = p+vec2(i, j);
            vec2 q2 = p2+vec2(i, j);
			vec2 rnd = rand2relSeeded(q, randomSeed);
			vec2 rnd2 = rand2relSeeded(q2, randomSeed);

            vec3 col = color2.rgb + vec3(rnd2.x, rnd2.y, fract((rnd2.x+rnd2.y)*50.0)-0.5)*colorVariability*2.0;

            vec2 c = q+rnd*variability*2.;
            vec2 c2 = q2+rnd2*2.0;

            vec2 d = u-c;
            vec2 d2 = u2-c2;

            float k2 = 1.0/(0.001+dot(d2, d2));
            float k = 1.0/(dampening + smoothstep(0.0, 3.0, length(d)));

            t += k;
            tk2 += k2;
            tc += col*k2;
        }
    }

    // good simple:
    //float k = smoothstep(-0.50, -0.455, sin(t*0.05));//t*0.0055 > 1.0 ? 1.0 : 0.0;
    float a = mix(-2.0, balance, hardness);
    float b = mix(2.0, balance, hardness);
    float k = smoothstep(a, b, sin(t*intensity*2.));//t*0.0055 > 1.0 ? 1.0 : 0.0;
    tc /= tk2;

    vec4 outColor = mix(color1, vec4(tc, color2.a), k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
