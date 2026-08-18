vec2 reflct(float d, float sourceAngle, float alpha, float halfAlpha) {
    if (sourceAngle > halfAlpha) sourceAngle = alpha-sourceAngle;
    return d * vec2(cos(sourceAngle), sin(sourceAngle));
}

vec4 kaleidoscope(vec2 pos, vec2 outPos, int mode, int spikeCount, mat3 texTransform, float blend, float randomSeed, float variability) {
            float totalWeight = 0.0;
            vec4 totalCol = vec4(0.0);
            vec2 totalCoord = vec2(0.0);
            vec4 lightestCol = vec4(0.0, 0.0, 0.0, 1.0);
            float lightestVal = 0.0;
            float lighting = 1.0;
            
            if (mode==0) {
            
                float N = 1.0;
                for(float j=-N; j<=N; ++j) {
                    for(float i=-N; i<=N; ++i) {
                        vec2 u, id, center;
                        
                        u = pos;
//                        if (mode==0) {
                            id = floor((u+1.0)/2.0) + vec2(i, j);
                            center = id*2.0;// + variability*vec2(rnd3.y, rnd2.y)*3.5;
                            u = u-center;
//                        }
//                        else {
//                            HexTile tile = hexTile(u*.5);
//                            id = round(tile.center*10.);
//                            center = tile.center;
//                            u = (u*.5-center)*2.;
//                        }
    
                        float d = length(u);
                        float weight;
                        if (blend<=0.0) {
                            weight = (i==0. && j==0.) ? 1.0 : 0.0; //max(abs(u.x), abs(u.y))<=1.0 ? 1.0 : 0.0;
                            vec2 borderDist = u - vec2(-1.);
                            vec2 lightFactor = smoothstep(0.0, 1.4, borderDist);
                            float lightStrength = lightFactor.x * lightFactor.y;
                            if (i==0. && j==0.) lighting = mix(1.0, lightStrength, -blend);// + blend * (1.0-lightStrength);
                            /*if (i==0. && j==0.) {
                                if (mod(id.x+id.y, 2.)==0.) return vec4(lightStrength, lightStrength, lightStrength, 1.0);
                                return vec4(lighting, lighting, lighting, 1.0);
                            }*/
                        }
                        else if (blend<0.15) {
                            weight = smoothstep(1.0+blend, 1.0-blend, max(abs(u.x), abs(u.y)));
                        }
                        else if (blend<0.3) {
            //                float squareWeight = smoothstep(1.0+u_Blend*0.01, 1.0-u_Blend*0.01, max(abs(u.x), abs(u.y)));
            //                float circleWeight = smoothstep(1.4+u_Blend*0.01, 1.4-u_Blend*0.01, d);
                            float squareWeight = smoothstep(1.0+0.15, 1.0-0.15, max(abs(u.x), abs(u.y)));
                            float circleWeight = smoothstep(1.4+0.15, 1.4-0.15, d);
                            weight = mix(squareWeight, circleWeight, (blend-0.15)/0.15);
                        }
                        else {
                            float b = mix(0.15, 1.0, (blend-0.3)/0.7);
                            weight = smoothstep(1.4+b, 1.4-b, d);
                        }
            
                        if (weight>0.0) {
                            float sourceAngle = 0.0;
            
                            float halfAlpha = 0.0;
                            float alpha = 0.0;
                            if (d > 0.0) {
                                float ang = atan(u.y, u.x);
                                if (ang<0.0) ang += PI2;
            
                                halfAlpha = PI/float(spikeCount);
                                alpha = halfAlpha * 2.0;
                                sourceAngle = mod(ang, alpha);
                            }
            
                            vec2 coord = reflct(d, sourceAngle, alpha, halfAlpha);
                            float angle = 0.0;
                            float scale = 1.0;
                            vec2 t = vec2(0.0, 0.0);
            
                            if (id.x!=0.0 || id.y!=0.0) {
                                vec2 rnd = rand2relSeeded(id, randomSeed);
                                angle = variability*rnd.x*PI*2.0;
                                scale = variability*rnd.y*0.2+1.0;
                                t = variability*rnd*2.0;
                                //tr = mat3(scale*cos(angle), scale*sin(angle), 0.0, -scale*sin(angle), scale*cos(angle), 0.0, t.x, t.y, 1.0); // this approach crashes on some devices such as Nexus 7
                            }
                            vec2 tc = tf(inverse(texTransform), coord);
                            vec2 tcc = vec2(scale*(cos(angle)*tc.x+sin(angle)*tc.y)+t.x, scale*(-sin(angle)*tc.x+cos(angle)*tc.y)+t.y);
                            vec4 col = __source__(tcc);
                            
            
                            totalCol += weight*col;
                            totalWeight += weight;
                        }
                    }
                }
            }
            else {
                vec2 u, id, center;
                u = pos;
                HexTile tile = hexTile(u*.5);
                id = round(tile.center*10.);
                center = tile.center;
                u = (pos*.5-center)*2.;
                
                if (blend<=0.0) {
                    vec2 borderDist = u - vec2(-1.);
                    vec2 lightFactor = smoothstep(0.0, 1.4, borderDist);
                    float lightStrength = lightFactor.x * lightFactor.y;
                    lighting = mix(1.0, lightStrength, -blend);// + blend * (1.0-lightStrength);
                }
        
                for(int i=0; i<7; ++i) {
                    float weight = 1.;

                    if (blend>0.) {
                        if (i==0) {
                        
                        }
                        else {
                            float angle = float(i-1) * PI_3;
                            center = tile.center + vec2(cos(angle), sin(angle));
                            id = round(center*10.);
                            u = (pos*.5-center)*2.;
                        }
                        
                        if (blend<0.5) {
                            weight = smoothstep(1.0/SQRT3_2, 1.0/SQRT3_2 * (1.0-blend*2.0), length(u));
                        }
                        else {
                            weight = smoothstep(mix(1.0/SQRT3_2, 2.0, (blend-0.5)*2.), 0.0, length(u));
                        }
                        
                        if (blend<0.2 && i==0) weight += pow(1.0-blend*5., 15.) * 250.;
//                        if (i==0) {
//                            if (blend<0.025) weight += 3.;
//                            else if (blend<0.05) weight += 2.;
//                            else if (blend<0.075) weight += 1.;
//                            else if (blend<0.1) weight += 0.5;
//                        } 
//                        weight = smoothstep(SQRT3, 0., length(u));
//                        weight = smoothstep(SQRT3_2, SQRT3_2-0.19, length(u));
                    }
                    else {
                        weight = i==0 ? 1.0 : 0.0;
                    }
                    float d = length(u);
                    
                    if (weight>0.0) {
                        float sourceAngle = 0.0;
        
                        float halfAlpha = 0.0;
                        float alpha = 0.0;
                        if (d > 0.0) {
                            float ang = atan(u.y, u.x);
                            if (ang<0.0) ang += PI2;
        
                            halfAlpha = PI/float(spikeCount);
                            alpha = halfAlpha * 2.0;
                            sourceAngle = mod(ang, alpha);
                        }
        
                        vec2 coord = reflct(d, sourceAngle, alpha, halfAlpha);
                        float angle = 0.0;
                        float scale = 1.0;
                        vec2 t = vec2(0.0, 0.0);
        
                        if (id.x!=0.0 || id.y!=0.0) {
                            vec2 rnd = rand2relSeeded(id, randomSeed);
                            angle = variability*rnd.x*PI*2.0;
                            scale = variability*rnd.y*0.2+1.0;
                            t = variability*rnd*2.0;
                            //tr = mat3(scale*cos(angle), scale*sin(angle), 0.0, -scale*sin(angle), scale*cos(angle), 0.0, t.x, t.y, 1.0); // this approach crashes on some devices such as Nexus 7
                        }
                        vec2 tc = tf(inverse(texTransform), coord);
                        vec2 tcc = vec2(scale*(cos(angle)*tc.x+sin(angle)*tc.y)+t.x, scale*(-sin(angle)*tc.x+cos(angle)*tc.y)+t.y);
                        vec4 col = __source__(tcc);
                        
                        totalCol += weight*col;
                        totalWeight += weight;
                    }
                }
        
            }
            return (totalCol/totalWeight) * vec4(vec3(lighting), 1.);
        }
