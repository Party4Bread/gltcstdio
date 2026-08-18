vec4 streakCircles(vec2 uv, vec2 outPos, float pixelation, int count, int layerCount, float variability, float shadows,
float randomSeed, float size, int sizing, float thickness, vec4 borderColor, vec4 colorShadow, mat3 modelTransform, int backgroundMode) {
    float ang = PI2/float(count);
    float angInv = float(count)/PI2;
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float N = shadows==0.0 ? 1.0 : 2.0;
    float height = -1.;
    vec4 color;
    
    float lc = float(layerCount);
    float scaleFactor = 1.0;
    float scale = 1.;
    if (sizing==0) scaleFactor = 1.4;
    else if (sizing==1) scaleFactor = 1.25;
    else if (sizing==2) { scaleFactor = 0.8; scale = pow(scaleFactor, -lc); }
    else if (sizing==3) { scaleFactor = 0.714; scale = pow(scaleFactor, -lc); }
    
    if (backgroundMode>=1 && backgroundMode<=2) {
        float a = atan(uv.y, uv.x);
        float ap = a * angInv;
        float a1 = floor(ap)*ang;
        float a2 = a1 + ang;
        float k = fract(ap);
        float dd = length(uv)*2.0*(1.-pixelation);
        vec2 p1 = vec2(cos(a1), sin(a1))*dd;
        vec2 p2 = vec2(cos(a2), sin(a2))*dd;
        if (backgroundMode==2) {
            p1 = tf(modelTransform, p1);
            p2 = tf(modelTransform, p2);
        }
        color = mix(
            __source__(p1),
            __source__(p2),
            k);
    }
    else if (backgroundMode==3) {
        color = borderColor;
    }
    else if (backgroundMode==4) {
        color = colorShadow;
    }
    else {
        color = __source__(uv);
    }
    float shadow = 0.0;
    for(float l = 0.; l<lc; ++l) {
        if (sizing<=3) {
            scale *= scaleFactor;
        }
        else {
            scale *= pow(2., rand2relSeeded(vec2(l), randomSeed).y);
        }
        vec2 v = u*scale;
        vec2 c = floor(v);
        for(float j=-N; j<=N; ++j) {
            for(float i=-N; i<=N; ++i) {
                vec2 id = c + vec2(i, j);
                vec2 heightAndSize = rand2relSeeded(id+1.52, randomSeed+l);
                float h = heightAndSize.x + l*0.5;
                if (h>height) {
                    float radius = (1.-(variability*(heightAndSize.y+.5))) * size;
                    vec2 delta = rand2relSeeded(id, randomSeed+l) * variability;
                    vec2 center = id + 0.5 + delta;
                    vec2 vRel = v-center;
                    float d = length(vRel);
                    if (d<radius) {
                        height = h;
                        shadow = 0.0;
                        
                        float a = atan(vRel.y, vRel.x);
                        float ap = a * angInv;
                        float a1 = floor(ap)*ang;
                        float a2 = a1 + ang;
                        float k = fract(ap);
                        float dd = d*2.0*(1.-pixelation);
                        vec2 p1 = (center + vec2(cos(a1), sin(a1))*dd)/scale;
                        vec2 p2 = (center + vec2(cos(a2), sin(a2))*dd)/scale;
                        color = mix(
                            __source__(tf(modelTransform, p1)),
                            __source__(tf(modelTransform, p2)),
                            k);
                                
                        if (d>radius-thickness*radius) {
                            color = mergeColor(color, borderColor);                                   
                        }
                    }
                    else if (shadows>0.0) {
                        shadow = max(shadow, smoothstep(radius + (shadows*0.5 * (h-height)*3.5), radius, d));
                    }
                }
            }                
        }
    }
    
    return mergeColor(color, mix(color, colorShadow, shadow));
}
