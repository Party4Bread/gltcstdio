vec4 duotone(vec2 pos, vec2 outPos, float intensity, vec4 color, float normalization, float saturation) {
            vec4 col = __source__(pos);
            float l = luma(col.rgb);
            
//            vec3 hsluv = rgbToHsluv(color.rgb);
//            hsluv.y *= saturation;
//            hsluv.z = mix(hsluv.z, 50.0, normalization);
//            vec4 color2 = vec4(hsluvToRgb(hsluv), color.a);
//            if (l<0.5) return mix(vec4(0., 0., 0., 1.), color2, l*2.);
//            else return mix(color2, vec4(1., 1., 1., 1.), l*2. - 1.);
            
            vec3 hsluv = rgbToHsluv(color.rgb);
            hsluv.y *= saturation;
            float lim = mix(0.5, hsluv.z*0.01, normalization);
            vec4 color2 = vec4(hsluvToRgb(hsluv), color.a);
            
            vec4 tCol;
            if (l<lim) tCol = mix(vec4(0., 0., 0., 1.), color2, l/lim);
            else if (l>lim) tCol = mix(color2, vec4(1., 1., 1., 1.), (l-lim)/(1.0-lim));
            else tCol = color2;
            
            return mix(col, tCol, intensity);
            
        }
