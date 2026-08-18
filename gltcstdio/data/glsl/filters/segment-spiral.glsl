vec4 segmentSpiral(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float quadratic, float exponential, int count, float step, float thickness, float dampening, vec4 color, vec4 color2, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    vec2 a = vec2(0., 0.);
    vec2 b = a;
    float k = 0.0;
    float scale = length(modelTransform[0].xy);
    float aa = 2.0/(sourceDim.y * scale);
    float th = thickness / scale;
    int maxI = 0;
    if (quadratic==0.0 && exponential==0.0) {
        for(int i=0; i<count; ++i) {
            float theta = step * float(i);
            b = polar(intensity*theta/step, theta);
            float dist = sdSegment(u, a, b);
            float kk = smoothstep(th*0.1 + aa, th*0.1, dist);
            if (kk>k) {
                k = kk;
                maxI = i;
            }
            if (k>=1.0) break;
            a = b;
        }
    }
    else {
        for(int i=0; i<count; ++i) {
            float theta = step * float(i);
            b = polar((intensity*theta + quadratic*theta*theta + exponential*pow(1.1, theta))/step, theta);
            float dist = sdSegment(u, a, b);
            k = max(k, smoothstep(th*0.1 + aa, th*0.1, dist));
            if (k>=1.0) break;
            a = b;
        }
    }
    vec4 inCol = __source__(uv);
    float ki = float(maxI)/float(count-1);
    float kCol = count>2 ? ki : 0.0;
    vec4 mixedCol = vec4(mix(color.rgb, mergeColor(color, color2).rgb, kCol), mix(color.a, color2.a, kCol));
    vec4 mergeCol = mergeColor(inCol, mixedCol);
    if (ki>=1.0-dampening && dampening>0.0) mergeCol.a *= (1.0-ki) / dampening;
    return mergeColor(inCol, vec4(mergeCol.rgb, mergeCol.a*k));
}
