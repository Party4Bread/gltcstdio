vec4 kaleidoscope(vec2 uv, vec2 outPos, int spikeCount, mat3 modelTransform, float stretch, float variability, float randomSeed) {
    vec2 u = uv;//(inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float a = (atan(u.x, u.y));
    float period = PI2 / float(spikeCount);
    float halfPeriod = period * 0.5;
    float index = floor(a/period);
    
    if (spikeCount!=1 && (variability==0.0 || spikeCount>100)) {
        a = mod(a, period);
        if (a>halfPeriod) {
            a = period - a;
        }
        else {
        }
    }
    else {
        //float debugA = a;
        float maxDisplacement = halfPeriod;
        float spikeAngle1 = -PI;
        float spikeAngle2 = spikeAngle1 + period + variability*maxDisplacement * 2.0*rand2relSeeded(vec2(0.0, 0.0), randomSeed).x;
        for(int i=0; i<spikeCount; ++i) {
            if ((i==spikeCount-1) || (a <= spikeAngle2)) {
                float deltaAng = spikeAngle2 - spikeAngle1;
                //float halfAlpha = deltaAng/2.0;
                a = a - spikeAngle1;
                if (a>deltaAng*0.5) {
                    a = deltaAng - a;
                }
                break;
            }
            else {
                spikeAngle1 = spikeAngle2;
                spikeAngle2 = -PI + float(i+2) * period;
                if (i!=spikeCount-2) spikeAngle2 = spikeAngle2 + variability*maxDisplacement * 2.0*rand2relSeeded(vec2(float(i), 0.0), randomSeed).x;
            }
        }
        //float da = debugA/PI*0.5+0.5;
        //return vec4(a*2., a, a*3., 1.);
    }
    float d = length(u);
    u = d*vec2(cos(a), sin(a));
    u = (inverse(modelTransform) * vec3(u, 1.0)).xy  * pow(2., -stretch*max(0., d));
    return __source__(u);
}
