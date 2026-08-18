vec2 turb3Layer(vec2 u, float intensity, float radiusVariability, float variability, float randomSeed, float balance) {
    float ci = floor(u.x);
    float cj = floor(u.y);

    float k = 0.0;

    vec2 displacement = vec2(0.0, 0.0);

    for(int j = -2; j <= 2; ++j) {
        for(int i = -2; i <= 2; ++i) {
            vec2 center = vec2(float(i)+ci, float(j)+cj);
            vec2 delta = rand2relSeeded(center, randomSeed);
            float radiusModifier = max(0.01, 1.0 + (delta.x * radiusVariability ));
            center += vec2(0.5, 0.5) + delta*variability;
            vec2 d = u - center;
            k = length(d);

            float threshold = radiusModifier*0.75;
            if (k < threshold) {
                k /= threshold;

                float bal = (-balance+1.0)*0.5;
                if (bal != 0.5) {
                    if (bal==1.0 || k < bal) {
                        float ratio2 = k/bal;
                        k = 0.5 * ratio2;
                    }
                    else {
                        float ratio2 = (k-bal)/(1.0-bal);
                        k = 0.5 * (1.0-ratio2);
                    }
                }

                float dangle = intensity * delta.x * 10. * (1.0-cos(k*2.0*PI));
                float ca = cos(dangle);
                float sa = sin(dangle);
                vec2 rotated = vec2(ca*d.x - sa*d.y, ca*d.y + sa*d.x);
                displacement += (rotated - d);
            }
        }
        
    }

    return displacement;
}

vec4 turbulence3(vec2 uv, vec2 outPos, float intensity, float layers, float radiusVariability, float variability, float randomSeed, float balance, mat3 modelTransform) {
            vec2 u = tf(inverse(modelTransform), uv);
            
            u += turb3Layer(u, intensity, radiusVariability, variability, randomSeed, balance);

            if (layers>0.0) {
                u += min(1., layers*4.) *2. * turb3Layer(u*.5, intensity, radiusVariability, variability, randomSeed+1.1, balance);
            }
            if (layers>0.25) {
                u += min(1., layers*4.-1.) *4. * turb3Layer(u*.25, intensity, radiusVariability, variability, randomSeed-1.2, balance);
            }
            if (layers>0.5) {
                u += min(1., layers*4.-2.) *8. * turb3Layer(u*.125, intensity, radiusVariability, variability, randomSeed-2.22, balance);
            }
            if (layers>0.75) {
                u += min(1., layers*4.-3.) *16. * turb3Layer(u*.0625, intensity, radiusVariability, variability, randomSeed+2.72, balance);
            }
            
//            if (layers>0.75) {
//                u += min(1., layers*4.-3.) *16. * turb3Layer(u*.0625, intensity, radiusVariability, variability, randomSeed+2.72, balance);
//            }
//            if (layers>0.5) {
//                u += min(1., layers*4.-2.) *8. * turb3Layer(u*.125, intensity, radiusVariability, variability, randomSeed-2.22, balance);
//            }
//            if (layers>0.25) {
//                u += min(1., layers*4.-1.) *4. * turb3Layer(u*.25, intensity, radiusVariability, variability, randomSeed-1.2, balance);
//            }
//            if (layers>0.0) {
//                u += min(1., layers*4.) *2. * turb3Layer(u*.5, intensity, radiusVariability, variability, randomSeed+1.1, balance);
//            }
//            u += turb3Layer(u, intensity, radiusVariability, variability, randomSeed, balance);
            
   
            u = tf(modelTransform, u);
            
            return __source__(u);
        }
