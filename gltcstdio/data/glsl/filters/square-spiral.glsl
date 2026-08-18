float getSpiralIndex(vec2 uv) {
    vec2 v = fract(uv);
    vec2 u = floor(uv);
    
    vec2 m = abs(u + .5);
    float level = max(m.x, m.y) + .5;
    
    if (u.y==-level) {
        return 4.*level*level - 1. - (level-1.-u.x);
    }
    else if (u.x==-level) {
        return 4.*level*level - 1. - (2.*level-1.) + (-level-u.y);
    }
    else if (u.y==level-1.) {
        return 4.*(level-1.)*(level-1.) - 1. + (2.*level - 1.) + (level-1.-u.x);
    }
    else {
        return 4.*(level-1.)*(level-1.) - 1. + (u.y + level);
    }
}

vec2 remap(vec2 uv, int scale) {
    float s = float(scale);
    return uv*s - float(scale/2);    
}

vec4 squareSpiral(vec2 uv, vec2 outPos, vec2 outDim, int source_specified, int scale, int innerScale, vec4 color1, vec4 color2, vec4 color3, vec4 color4, vec4 borderColor, int mode, float thickness, float border, float balance, float offset) {
    vec2 orig2Uv = uv;
    if (mode>=1) uv = mod(uv+vec2(1., 1.), 2.) - vec2(1., 1.);
//    if (mode==2) return vec4(uv.x, uv.y, .5, 1.);
    
    vec2 origUv = uv;
//    uv = remap((uv + vec2(outDim.x/outDim.y, 1.))*.5, scale);
    uv = remap((uv + vec2(1., 1.))*.5, scale);
    float index = getSpiralIndex(uv);
    float intensity = 1./float(scale*scale);
    float k = intensity * index;
    if (balance!=0.0) k = k * pow(1000., balance);
    if (offset!=0.0) k += offset;
    if (mode!=0) {
        k = mir(k, 1.0);
    }
    vec4 outColor = mix(color1, color2, k);
       
    vec2 uv2 = fract(uv);
    float t = thickness * 0.5;
    if (uv2.x>t && uv2.x<1.-t && uv2.y>t && uv2.y<1.-t) {
        uv2 = remap((uv2-t) / (1.-thickness), innerScale);
        float index = getSpiralIndex(uv2);
        float intensity = 1./float(innerScale*innerScale);
        float k = intensity * index;
        vec4 innerColor = mix(color3, color4, k);
        outColor = mergeColor(outColor, innerColor);
    }
    
    if (border>0.) {
        vec2 fuv = fract(uv);
        if (fuv.x<border && abs(index - getSpiralIndex(uv-vec2(1.0, 0.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.y<border && abs(index - getSpiralIndex(uv-vec2(0.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x>1.-border && abs(index - getSpiralIndex(uv+vec2(1.0, 0.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.y>1.-border && abs(index - getSpiralIndex(uv+vec2(0.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x<border && fuv.y<border && abs(index - getSpiralIndex(uv-vec2(1.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x>1.-border && fuv.y<border && abs(index - getSpiralIndex(uv+vec2(1.0, -1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x<border && fuv.y>1.-border && abs(index - getSpiralIndex(uv+vec2(-1.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x>1.-border && fuv.y>1.-border && abs(index - getSpiralIndex(uv+vec2(1.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (mode==1) {
            if (origUv.x<-1.0+2.*border/float(scale) || origUv.x>1.0-2.*border/float(scale)) {
                outColor = mergeColor(outColor, borderColor);
            }
        }
    }
    if (mode==2) {
        if (origUv.x<-1.0+2.*border/float(scale) || origUv.x>1.0-2.*border/float(scale)) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (orig2Uv.y<-1.0+2.*border/float(scale) || orig2Uv.y>1.0-2.*border/float(scale)) {
            outColor = mergeColor(outColor, borderColor);
        }
    }
    
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}
