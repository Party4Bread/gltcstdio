vec2 getOffsetPos(mat3 transform, vec2 pos, float vignetting) {
    vec2 tPos = (inverse(transform)*vec3(pos, 1.0)).xy;
    float dist = length(pos);
    if (dist<1.0) {
        tPos = mix(pos, tPos, 1.0 - vignetting*(1.0 - dist*dist));
    }
    return tPos;
}

vec4 colorOffsetGL(vec2 pos, vec2 outPos,
                   float vignetting, float blur,
                   vec4 color1, vec4 color2,
                   mat3 modelTransform, mat3 modelTransform2) {
    if (blur != 0.0) {
        vec2 p1 = getOffsetPos(modelTransform,  pos, vignetting);
        vec2 p2 = getOffsetPos(modelTransform2, pos, vignetting);
        vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
        float totalWeight = 0.0;
        float N = 100.0;
        float blurExp = pow(blur*2.0, -4.0);
        for (float i = 0.0; i <= N; i += 1.0) {
            float k = i / N;
            vec4 c1tone = mix(vec4(1.0, 1.0, 1.0, 1.0), color1, k);
            vec4 c2tone = mix(vec4(1.0, 1.0, 1.0, 1.0), color2, k);
            vec2 q1 = mix(pos, p1, k);
            vec2 q2 = mix(pos, p2, k);
            float weight = pow(k, blurExp);
            totalWeight += weight;

            vec4 s1 = __source__(q1);
            total.rgb += c1tone.rgb * s1.rgb * weight;
            total.a   += s1.a * weight;

            vec4 s2 = __source__(q2);
            total.rgb += c2tone.rgb * s2.rgb * weight;
            total.a   += s2.a * weight;
        }
        return total / (totalWeight * mix(1.0, 1.5, blur));
    } else {
        vec4 c1 = __source__(getOffsetPos(modelTransform,  pos, vignetting));
        vec4 c2 = __source__(getOffsetPos(modelTransform2, pos, vignetting));
        return vec4((c1*color1 + c2*color2).rgb, (c1.a + c2.a) * 0.5);
    }
}
