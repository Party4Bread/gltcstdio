vec4 grain(vec2 pos, vec2 outPos, int layerCount, float intensity, float balance, float stratification, int octaves, float power, vec4 color, vec4 color2, float vignetting, mat3 vignetteTransform, mat3 layerTransform, mat3 modelTransform) {
            vec4 col = __source__(pos);

            vec2 u = tf(inverse(modelTransform), pos);

            float totalHum = 0.0;
            float k = 1.0;
            float totalK = 0.0;
            //mat3 transform = mat3(0.9, 0.7, 0.0, -0.7, 0.9, 0.0, 10.3, 4.4, 1.0);
            mat3 inverseLayerTransform = inverse(layerTransform);
            
            for(int i=0; i<layerCount; ++i) {
                float hum = 2.0 * (perlinOctaveNoise(u, octaves) - 0.5);
                
                hum = mod(hum*stratification, 2.) * 0.5;
                if (hum<balance) hum = hum/balance; else hum = 1.-(hum-balance)/(1.-balance);
                hum = pow(hum, power);
                totalHum += hum*k;
                totalK += k;
                k *= 0.6; 
                u = tf(inverseLayerTransform, u);
            }
            
            totalHum /= mix(1.0, totalK, pow(0.5, power));           
            
            vec4 hueShiftedCol = col; //hue==0.0 ? col : adjustColorHSLuv(col, 0.0, 1.0, 0.0, 0.0, 0.0, mix(0.0, hue, totalHum), vec4(0.)); // not convincing
            vec4 targetCol = totalHum<0.5 
                ? mix(hueShiftedCol, mergeColor(hueShiftedCol, color2), totalHum/0.5)  
//                : mergeColor(col, mix(color2, color, (totalHum-0.5)/0.5));                        
                : mix(mergeColor(hueShiftedCol, color2), mergeColor(hueShiftedCol, color), (totalHum-0.5)/0.5);                        
            col = mix(col, targetCol, intensity*simpleVignette(vignetting, pos, inverse(vignetteTransform)));
                        
//            totalHum *= simpleVignette(vignetting, pos, inverse(vignetteTransform));
//            col = mix(col, color, totalHum*intensity);
                         
            return col;
        }
