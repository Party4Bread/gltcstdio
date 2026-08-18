vec4 tritone(vec2 pos, vec2 outPos, float intensity, vec4 color1, vec4 color2, float normalization, float saturation) {
            vec4 col = __source__(pos);
            float l = luma(col.rgb);
            
//            vec3 hsluv = rgbToHsluv(color.rgb);
//            hsluv.y *= saturation;
//            hsluv.z = mix(hsluv.z, 50.0, normalization);
//            vec4 color2 = vec4(hsluvToRgb(hsluv), color.a);
//            if (l<0.5) return mix(vec4(0., 0., 0., 1.), color2, l*2.);
//            else return mix(color2, vec4(1., 1., 1., 1.), l*2. - 1.);
            
            vec3 hsluv1 = rgbToHsluv(color1.rgb);
            hsluv1.y *= saturation;
            vec3 hsluv2 = rgbToHsluv(color2.rgb);
            hsluv2.y *= saturation;
            
            float lim1 = mix(0.333333, hsluv1.z*0.01, normalization);
            float lim2 = mix(0.666667, hsluv2.z*0.01, normalization);
            
            if (lim1>lim2) {
                float tmp = lim1;
                lim1 = lim2;
                lim2 = tmp;
                vec3 tmpc = hsluv1;
                hsluv1 = hsluv2;
                hsluv2 = tmpc;
            }
            
            vec4 color1a = vec4(hsluvToRgb(hsluv1), color1.a);
            vec4 color2a = vec4(hsluvToRgb(hsluv2), color2.a);
            
            vec4 tCol;
            if (l<lim1) tCol = mix(vec4(0., 0., 0., 1.), color1a, l/lim1);
            else if (l==lim1) tCol = color1a;
            else if (l<lim2) tCol = mix(color1a, color2a, (l-lim1)/(lim2-lim1));
            else if (l==lim2) tCol = color2a;
            else tCol = mix(color2a, vec4(1., 1., 1., 1.), (l-lim2)/(1.-lim2));  
            
            return mix(col, tCol, intensity);
        }
