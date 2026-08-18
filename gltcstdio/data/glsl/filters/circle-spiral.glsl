vec4 circleRippleIllusion(vec2 uv, vec2 outPos, int source_specified, float power, int mode, int count, int modCount, vec4 color1, vec4 color2, mat3 modelTransform, mat3 modelTransform2) {
    float g = 1.0;
    mat3 inverseTransform = inverse(modelTransform);
    mat3 inverseTransform2 = inverse(modelTransform2);
    
    if (mode==1) {
        uv = mod(uv+1.0, 2.0) - 1.0;
    }
    else if (mode==2) {
        uv = hexCoords(uv*0.5).xy * 2.0;
    }
    else if (mode==3) {
        vec2 origUv = uv;
        uv = mod(uv+1.0, 2.0) - 1.0;
        if (measure(uv, power)>1.0) uv = (mod(origUv, 2.0) - 1.0) / (1./pow(0.5, 1./power)-1.);
    }
    else if (mode==4) {
        vec2 origUv = uv;
        uv = hexCoords(uv*0.5).xy * 2.0;
        if (measure(uv, power)>1.0) { 
            uv = hexCoords(origUv*0.5 - vec2(0., 1.0/SQRT3)).xy * 2.0; 
            uv *= 6.4641016; 
            if (measure(uv, power)>1.0) {
                uv = hexCoords(origUv*0.5 + vec2(0., 1.0/SQRT3)).xy * 2.0; 
                uv *= 6.4641016; 
            }
        }
    }
    
    //float invPower = 1./power;
    for(float i=0.0; i<float(count); ++i) {
        float d = measure(uv, power);
        if (d>1.0) { break; }
        uv = tf(inverseTransform, uv);
        if (mod(i+1.0, float(modCount))==0.0) uv = tf(inverseTransform2, uv);
        g = 1.0 - g;
    }
    vec4 col = mix(color1, color2, g);

    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}
