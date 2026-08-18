vec4 waveFlow(vec2 uv, vec2 outPos, int iterations, float intensity, float balance, float variability, float randomSeed, mat3 modelTransform) {
            float mtScale = length(modelTransform[0].xy);
            float mt2k = mtScale*SQRT2_2; // (cos(pi/4)==sin(pi/4))
            mat3 modelTransform2 = mat3(vec3(mt2k, mt2k, 0.), vec3(-mt2k, mt2k, 0.), modelTransform[2]);
            
            vec2 u = uv;
                
            //mat3 rotMat = mat3(cos(angle), sin(angle), 0.0, -sin(angle), cos(angle), 0.0, 0.0, 0.0, 1.0);
        
            mat3 inverseTransform = inverse(modelTransform);
            mat3 inverseTransform2 = inverse(modelTransform2);
            mat3 invTransf = inverseTransform;
            mat3 transf = modelTransform;
            vec2 bTranslate = (balance > 0.0 ? balance : 0.0) * vec2(cos(balance*10.), sin(-balance*10.));
        
            for(int j=0; j<iterations; ++j) {
                vec2 translate = bTranslate*float(j); //u_Balance > 0.0 ? u_Balance*0.005*float(j) : 0.0;
                float scale = balance < 0.0 ? pow(0.999, abs(balance)*100.*float(j)) : 1.0;
                mat3 ts = mat3(scale, 0.0, 0.0, 0.0, scale, 0.0, 0.0, 0.0, 1.0);
                mat3 invts = mat3(1.0/scale, 0.0, 0.0, 0.0, 1.0/scale, 0.0, 0.0, 0.0, 1.0);
                mat3 tt = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, translate.x, translate.y, 1.0);
                mat3 invtt = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, -translate.x, -translate.y, 1.0);
                mat3 t1 = ts* modelTransform * tt;
                mat3 invt1 = invtt * inverseTransform * invts;
                mat3 t2 = ts * modelTransform2 * tt;
                mat3 invt2 = invtt * inverseTransform2 * invts;
        
                mat3 invTransf = (j==(j/2)*2) ? invt1 : invt2;
                //        mat3 invTransf = u_InverseModelTransform;
                u = (invTransf * vec3(u, 1.0)).xy;
        
                float d = u.x;
        
                float N = 4.0;
                float xx = u.x/N;
                float i = floor(xx);
                float di = xx - i;
        
                vec2 rnd = rand2relSeeded(vec2(i, i), randomSeed);
                vec2 rnd2;
                float var = rnd.x;
                if (di<0.5) {
                    rnd2 = rand2relSeeded(vec2(i-1.0, i-1.0), randomSeed);
                    di = 0.5-di;
                }
                else {
                    rnd2 = rand2relSeeded(vec2(i+1.0, i+1.0), randomSeed);
                    di = di-0.5;
                }
                var = mix(var, rnd2.x, di*di*2.0);
        
                float magnitude = intensity * (1.0 + ((variability*10.) * (var)*2.0));
                float dy =  sin(xx*PI) * magnitude;
        
                mat3 transf = (j==(j/2)*2) ? t1 : t2;
                u = (transf * vec3(u.x, u.y+dy, 1.0)).xy;
        
//                invTransf = invTransf * 0.9; // weird code that did nothing
//                transf = rotMat / 0.9;
            }
        
            return __source__(u);
        }
