vec4 quadtone(vec2 pos, vec2 outPos, float intensity, vec4 color1, vec4 color2, vec4 color3, float normalization, float saturation) {
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
            vec3 hsluv3 = rgbToHsluv(color3.rgb);
            hsluv3.y *= saturation;
            
            float lim1 = mix(0.25, hsluv1.z*0.01, normalization);
            float lim2 = mix(0.5, hsluv2.z*0.01, normalization);
            float lim3 = mix(0.75, hsluv3.z*0.01, normalization);
            
            if (lim1>lim2) {
                float tmp = lim1;
                lim1 = lim2;
                lim2 = tmp;
                vec3 tmpc = hsluv1;
                hsluv1 = hsluv2;
                hsluv2 = tmpc;
            }
            if (lim1>lim3) {
                float tmp1 = lim1;
                float tmp2 = lim2;
                lim1 = lim3;
                lim2 = tmp1;
                lim3 = tmp2;
                vec3 tmpc1 = hsluv1;
                vec3 tmpc2 = hsluv2;
                hsluv1 = hsluv3;
                hsluv2 = tmpc1;
                hsluv3 = tmpc2;
            }
            else if (lim2>lim3) {
                float tmp = lim2;
                lim2 = lim3;
                lim3 = tmp;
                vec3 tmpc = hsluv2;
                hsluv2 = hsluv3;
                hsluv3 = tmpc;
            }
                        
            vec4 color1a = vec4(hsluvToRgb(hsluv1), color1.a);
            vec4 color2a = vec4(hsluvToRgb(hsluv2), color2.a);
            vec4 color3a = vec4(hsluvToRgb(hsluv3), color3.a);
            
            vec4 tCol;
            if (l<lim1) tCol = mix(vec4(0., 0., 0., 1.), color1a, l/lim1);
            else if (l==lim1) tCol = color1a;
            else if (l<lim2) tCol = mix(color1a, color2a, (l-lim1)/(lim2-lim1));
            else if (l==lim2) tCol = color2a;
            else if (l<lim3) tCol = mix(color2a, color3a, (l-lim2)/(lim3-lim2));
            else if (l==lim3) tCol = color3a;
            else tCol = mix(color3a, vec4(1., 1., 1., 1.), (l-lim3)/(1.-lim3));  
            
            return mix(col, tCol, intensity);
        }
