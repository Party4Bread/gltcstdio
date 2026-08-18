vec4 outrunSun(vec2 uv, vec2 outPos, float thickness, vec4 color1, vec4 color2, float glow, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);

    vec4 bkgCol = __source__(uv);
    float l = length(u);
    vec4 color = bkgCol;
    bool inside = false;
    
    if (l<1.0) {
        if (u.y>0.0) {
            float i = 1.0+u.y*(thickness*4.);
            if (fract(i*i)>0.5) {
                color = mix(color1, color2, 0.5+u.y*0.5);
                inside = true;
            }
        }
        else if (u.y<=0.0) {
            color = mix(color1, color2, 0.5+u.y*0.5);
            inside = true;
        }
    }
    
    if (!inside && glow>0.0) {
        float d = max(0.0, l-1.0)+1.1;
        vec4 glowColor = mix(color1, color2, 0.5+u.y*0.5);
        float alpha = pow(d, -2.5) * glow;
        color.rgb = mix(color.rgb, glowColor.rgb, alpha);                
    }

    return mergeColor(bkgCol, color);
}
