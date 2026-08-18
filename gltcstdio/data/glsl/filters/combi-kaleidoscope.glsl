float shapeSdf(vec2 u, int spikeCount, float shape) {
    spikeCount = max(3, spikeCount);
    
    float k = fract(shape);
    float radius = 0.66666;
    float starMul = 0.9/radius;
    if (shape<1.0) {
        float d1 = length(u) - radius;
        float d2 = sdStar(vec2(u.x, -u.y)*starMul, spikeCount, 1.0, 2.0);
        return mix(d1, d2, k);
    } 
    else if (shape<2.0) {
        float kk = k*0.75;
        float m = 2.0 + kk*kk*(float(spikeCount)-2.0);
        return sdStar(vec2(u.x, -u.y)*starMul, spikeCount, 1.0, m);
    }
    else if (shape<3.0) {
        float m = 2.0 + 0.75*0.75* (float(spikeCount)-2.0);
        float d1 = sdStar(vec2(u.x, -u.y)*starMul, spikeCount, 1.0, m);
        float d2 = sdVesica(u*0.75, radius, radius*0.5);
        return mix(d1, d2, k);
    }
    else {
        k = shape - 3.;
        float d1 = sdVesica(u*0.75, radius, radius*0.5);;
        float d2 = length(u) - radius;
        return mix(d1, d2, k);
    
    }
}

vec4 combiKaleidoscope(vec2 uv, vec2 outPos, int source2_specified, int spikeCount,
    float border, float shadows, vec4 borderColor, vec4 colorShadow, float blend,
    int transformPairing,
    float shape, mat3 modelTransform, mat3 modelTransform2, mat3 borderTransform, float offset, float stretch) {
    
    vec2 u = uv;
    float a = abs(atan(u.x, u.y));
    float period = PI2 / float(spikeCount);
    float halfPeriod = period * 0.5;
    float index = floor(a/period);
    a = mod(a, period);
    if (a>halfPeriod) {
        a = period - a;
        a = mix(offset*(index+1.0), halfPeriod+offset*(index+1.0), a/halfPeriod);
    }
    else {
        a = mix(offset*index, halfPeriod+offset*(index+1.0), a/halfPeriod);
    }
    
    vec2 bu = tf(inverse(borderTransform), u);
    float dist = shapeSdf(bu, spikeCount, shape);
    bool inside = dist<0.0;
   
    vec4 outColor;            
    float d = length(u);
    u = d*vec2(cos(a), sin(a));
    
    vec2 u1 = (inverse(modelTransform) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
    mat3 transform2 = transformPairing==0 ? modelTransform2 : modelTransform*modelTransform2;
    vec2 u2 = (inverse(transform2) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
        
    if (blend==0.0) {
        outColor = inside ? __source1__(u1) : (source2_specified!=1) ? __source1__(u2) : __source2__(u2);
    }
    else {
        vec4 c1 = __source1__(u1);
        vec4 c2 = (source2_specified!=1) ? __source1__(u2) : __source2__(u2);
        float bk = smoothstep(-blend, blend, dist);
        outColor = mix(c1, c2, bk);
    }

    float adist = abs(dist);
    if (adist < border*0.1) outColor = mergeColor(outColor, borderColor);
    else if (adist<abs(shadows)) {
        float ds = (shadows<0.0 && inside && dist>shadows) || (shadows>0.0 && !inside && dist<shadows) ? abs(dist)/abs(shadows) : 1.0;
        
        outColor = mergeColor(outColor, vec4(colorShadow.rgb, colorShadow.a * 0.8f * smoothstep(1.0, 0.0, ds)));
    }

    return outColor;
}
