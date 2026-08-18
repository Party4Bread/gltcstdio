vec4 adjust(vec2 pos, vec2 outPos, float brightness, float contrast, float luminosity, float gamma, float saturation, float hue, 
            vec4 tint,
            float vignette_intensity, float vignette_hardness, vec4 vignette_color, mat3 vignette_transform) {
            vec4 col = __source__(pos);

            col = adjustColor(col, brightness, contrast, luminosity, gamma, saturation, hue, tint);
            
            if (vignette_intensity != 0.) {
                float d = length(tf(inverse(vignette_transform), pos));
                float k = vignette_intensity * smoothstep(min(vignette_hardness, 0.9999), 1.0, d);
                col = mix(col, vignette_color, k);
//                col = vec4(1., 0., 0., 1.);
            }

            
            return col;
        }
