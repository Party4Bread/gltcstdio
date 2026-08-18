vec4 alphaBlend(vec4 a, vec4 b) {
    float sumA = a.a + b.a;
    if (sumA==0.0) return a;
    float k1 = a.a/sumA;
    float k2 = b.a/sumA;
    vec4 outc = k1*a + k2*b;
    outc.a = 1.0 - (1.0-a.a) * (1.0-b.a);
    return outc;
}

vec4 bokehLights(vec2 uv, vec2 outPos, vec2 sourceDim, int count, float intensity, float vignetting, float radius, float radiusVariability, vec4 color, float variability, float colorVariability, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 u = tf(inverse(modelTransform), uv);

    bool inLight = false;

    vec4 col = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 baseColor = color;

    vec2 v = floor(vec2(u.x+0.5, u.y+0.5));
    float closest = 1e9;
    
    float vig = smoothstep(mix(0.2, 0.6, vignetting), mix(0.4, 1.6, vignetting), length(uv));
    intensity = intensity * mix(1.0, vig, min(1.0, vignetting * 3.));           
    
    for(int j=-2; j<=2; ++j) {
        for(int i=-2; i<=2; ++i) {
            vec2 point = vec2(v.x+float(i), v.y+float(j));
            vec2 randomness = rand2rel(point)*2.0;
            vec2 displace = randomness*variability;
            vec2 delta = point+displace - u;
            float distance = length(delta);
            float radiusModifier = randomness.x < 0.0 ? 1.0 + randomness.x * radiusVariability *0.4 : 1.0 + randomness.x * radiusVariability *2.;
            float blur = (radiusModifier < 1.0 ? 1.0/radiusModifier : radiusModifier) - 1.0;

            if (count < 15 && distance > 0.0) {
                float ang = acos(delta.x/distance);
                if (delta.y < 0.0) ang = PI2 - ang; //ang += M_PI;

                float alpha2 = PI2/float(count);
                float alpha = alpha2/2.0;
                float da = mod(ang, alpha2);

                if (da > alpha) da = alpha2-da;

                float rounding = 1.0 + 0.25*( alpha*alpha - (alpha-da)*(alpha-da) );
                //da += phase;
                radiusModifier *= blur + (1.0-blur) * cos(alpha) / cos(alpha-da) * rounding;
            }

            float rad = radius * radiusModifier;
            float rad2 = rad*rad;
            float d2 = distance*distance;

            float kk = 0.0;
            if (d2 < rad2) {
                kk = d2/(rad2*0.97);
                kk = min(1.0, kk*kk)*0.35 + 0.65;
            }
            else if (d2<2.0*rad2) {
                kk = 1.0 - (d2-rad2)/rad2;
                kk = pow(kk, 2.0)*0.5;
            }

            if (blur > 0.0 && d2<2.0*rad2) {
                blur = min(blur, 1.0);
                float xxx = d2/(2.0*rad2);
                float kkk = (1.0 + cos(xxx*PI)) * 0.5;
                kk = blur*kkk + (1.0-blur)*kk;
            }

            if (kk > 0.0) {
                inLight = true;
                vec4 newColor = baseColor;
                if (colorVariability > 0.0) {
                    vec4 hsl = rgbToHsl(color);
                    hsl.x = hsl.x + randomness.y*colorVariability*100.0;
                    newColor = hslToRgb(hsl);
                }
                newColor.a = intensity * kk;
                col = alphaBlend(col, newColor);
            }

        }
    }

    if (inLight) {
        vec4 outc = inc + col*col.a;
        outc.a = 1.0;
        return outc;
    }
    else {
        return inc;
    }
}
