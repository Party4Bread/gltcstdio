vec4 bump(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float power, float dampening, float lighting, vec4 highFreqColor, mat3 modelTransform) {
    mat3 t = inverse(modelTransform);
    float ratio = sourceDim.x / sourceDim.y;
    vec2 u = ratio<1.0 ? uv / ratio : uv;
    vec2 v = tf(t, u);
    
    float d = measure(v, power); //pow(pow(abs(v.x), power) + pow(abs(v.y), power), 1.0/power);
    float kCol = 0.0;
    float light = 1.0;
    float dilation = 1.0;
    
    if (d>0.0 && d<1.0) {
        float k = d*d;
        if (intensity <= 0.0) {
            dilation = pow(k, intensity*2.5);
        }
        else {
            float b = 1.0 - intensity * 2.;
            dilation = b + k * (1.0-b);
        }

        if (dampening>0.0 && d>1.0 - dampening) {
            //dilation = mix(1.0, dilation, (1.0-d)/dampening);
            dilation = mix(1.0, dilation, smoothstep(1.0, 1.0-dampening, d));
        }
        else if (dampening<0.0) {
            dilation *= 1.0-dampening*dampening*0.25*pow(d*2.0, -4.0*dampening);
        }
        
        //kCol = smoothstep(1.0, 15.0, dilation*highFreqColor.a);
        kCol = smoothstep(0.0, 3.0, log(dilation)*highFreqColor.a);

        u = tf(modelTransform,  dilation*v).xy;
    }                     
    
    if (lighting>0.0) {
        float pixel = 2.0/sourceDim.y;
        vec2 grad = vec2(dFdx(dilation)/dFdx(u.x), dFdy(dilation)/dFdy(u.y)) * 4.;
        light = 1. + lighting * dot(grad, vec2(0., -1.));
    }
    
    u = ratio<1.0 ? u * ratio : u;
    vec4 outCol = __source__(u);
    outCol.rgb *= light;
    
    return mix(outCol, vec4(highFreqColor.rgb, 1.0), kCol);
}
