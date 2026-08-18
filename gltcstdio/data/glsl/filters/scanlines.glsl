vec2 pincushion(vec2 p, float k) {
	return p*(1.0+k*dot(p, p)*dot(p, p));
	//return p*(1.0+k*dot(p, p));
}

vec4 scanlines(vec2 uv, vec2 outPos, float intensity, float distortion, float hueShift, float brightness, mat3 modelTransform, mat3 hueTransform) {
            mat3 invModelTransform = inverse(modelTransform);
            mat3 invHueTransform = inverse(hueTransform);
        
            vec4 col = __source__(uv);
            vec4 hsl = rgbToHsl(col);
            vec4 origHsl = hsl;
        
            float scale = length(vec2(invModelTransform[0][0], invModelTransform[0][1]));
            mat2 rot = mat2(invModelTransform)/scale;
            vec2 pinc = pincushion(uv, distortion*0.15);
            vec2 pin = (invModelTransform * vec3(pinc, 1.0)).xy;
            vec2 v = tf(invModelTransform, pinc);
            vec2 huePin = tf(invHueTransform, v);
            
            hsl[0]+=huePin.y*2000.0;
            float b = pow(1.04, -brightness*100.);
            //hsl[2] *= pow((1.0+sin((rot*pinc).y*200.))*(brightness*0.1+0.5), b);
            hsl[2] *= pow((1.0+sin(v.y*300.))*(brightness*0.1+0.5), b);
        //    hsl[2] *= (1.0+sin(pincushion(u, u_Distortion*0.05).y*200.0))*(u_Brightness*0.005+0.5);
            if (hueShift<0.0) {
                hsl[1] = max(hsl[1], -hueShift); // force minimum saturation
            }
            
            vec4 hslD = origHsl;
            hslD[2] = hsl[2];
            vec4 rgbD = hslToRgb(hslD);
            vec4 rgb = hslToRgb(hsl);
            rgb = mix(rgbD, rgb, abs(hueShift));
        
            return mix(col, rgb, intensity);        
}
