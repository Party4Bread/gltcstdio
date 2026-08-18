vec4 multiDistort(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity, float variability, float randomSeed, float lighting, int layerCount) {
            mat3 inverseModelTransform = inverse(modelTransform);
            vec2 u = tf(inverseModelTransform, pos);
        
            float seed = randomSeed;
            mat3 layerTransform = mat3(1., 0., 0., 0., 1., 0., 0., 0., 1.);
            vec2 displaced = u;
            
            for(int l=0; l<layerCount; ++l) {
                displaced = tf(layerTransform, displaced);
                float N = variability==0.0 ? 0.0 : 2.0;
                for(float j=-N; j<=N; ++j) {
                    for(float i=-N; i<=N; ++i) {
                        vec2 id = floor((u+1.0)/2.0) + vec2(i, j);
            
                        vec2 rnd = rand2relSeeded(id, seed);
                        vec2 rnd2 = rand2relSeeded(id+vec2(3.4, 23.3), seed);
                        vec2 rnd3 = rand2relSeeded(id-vec2(13.3, 7.2), seed);
            
                        vec2 center = id*2.0 + variability*vec2(rnd3.y, rnd2.y)*5.5;
    //                    vec2 v = u-center;
                        vec2 w = displaced-center;
            
                        float radius = abs(0.6 + rnd.x*0.8 * (1.0+2.5*abs(variability)));
                        if (id.x==0.0 && id.y==0.0 && radius<1.0) radius = 1.0;
            
    //                    float count = floor((rnd.y+0.5)*100.0+1.0);
                        float count = rnd3.x<0.0 ? floor((rnd.y+0.5)*100.0+1.0) : floor(pow(10., rnd.y*2.));
                        float ripplesIntensity = max(0.0, rnd2.x*4.0);
                        float swirlIntensity = sign(rnd2.y) * max(0.0, (abs(rnd2.y)-0.25)*8.0);
                        float flowerlIntensity = sign(rnd3.x) * max(0.0, (abs(rnd3.x)-0.25)*8.0);
                        float marbleIntensity = max(0.0, rnd3.y*2.0);
            
                        float d = length(w);
                        if (d<radius) {
                            float k = d/radius;
            
                            // marble
                            if (marbleIntensity!=0.0) {
                                w = fractalValueNoiseDisplace(w, w*5.0+rnd2*3.0, 6, marbleIntensity*intensity * smoothstep(1.0, 0.5, k));
                            }
            
                            // flower
                            if (flowerlIntensity!=0.0) {
                                float angle = atan(w.x, w.y);
                                float kk = flowerlIntensity *  (1.0 - k);
                                float scaling = 1.0 + kk*intensity * (1.0+sin((angle+PI) * count - PI/2.0));
                                w *= scaling;
                            }
            
                    //        d = length(v);
                    //        k = d/radius;
            
                            // ripples
                            if (ripplesIntensity!=0.0) {
                                float dilation = 1.0 + ripplesIntensity*intensity * sin(k * count * PI) * smoothstep(1.0, 0.5, k);
                                w = dilation*w;
                            }
            
                            // swirl
                            if (swirlIntensity!=0.0) {
                                float dampening = 0.3;
                                float power = (rnd.x+0.6)*50.0;
                                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), k) * swirlIntensity*intensity*5./pow(k, mix(0.01, 1.6, power*0.01));
                                float ca = cos(dangle);
                                float sa = sin(dangle);
                                w = vec2(ca*w.x - sa*w.y, ca*w.y + sa*w.x);
                            }
            
                            displaced = w+center;
                        }
                    }
                }
                displaced = tf(inverse(layerTransform), displaced);
//                layerTransform *= mat3(1.1, 1.5, 0.0, 1.5, -1.1, 0.0, 0.1, 0.2, 1.);
//                layerTransform *= mat3(0.7, 0.8, 0.0, 0.8, -0.7, 0.0, 0.1, 0.2, 1.);
                if (l==0) layerTransform *= mat3(0.65, 0.75, 0.0, 0.75, -0.65, 0.0, 0.1, 0.2, 1.);
                else layerTransform *= mat3(0.7, 0.9, 0.0, 0.9, -0.7, 0.0, 0.1, 0.2, 1.);
                //layerTransform *= mat3(1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.);
                seed += 0.8;
            }
            
            vec2 v = tf(modelTransform, displaced);
            vec4 outCol = __source__(v);
            if (lighting>0.0) {
//                float dilation = length(v-pos);
                float dilation = length(displaced-u);
                vec2 grad = vec2(dFdx(dilation)/dFdx(u.x), dFdy(dilation)/dFdy(u.y)) * 4.;
                float light = 1. + lighting * dot(grad, vec2(0., -1.));
                outCol.rgb *= light;
            }
            
            return outCol;
        }
