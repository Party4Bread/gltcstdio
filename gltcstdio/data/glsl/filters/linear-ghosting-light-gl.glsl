float colorWeight(vec4 color, vec4 refColor, float tolerance) {
    float d = length(color.rgb-refColor.rgb);
    float maxDistance = tolerance*1.7320508075688772;
    return smoothstep(maxDistance, maxDistance*0.5, d);
}

vec4 ghosting(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, int iterations, float tolerance, float vignetting, float dampening, vec4 color, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, uv);
 
    vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
    float totalWeight = 0.0;
    vec2 delta = (u-uv) / float(iterations);
    float radius = min(1.0, sourceDim.x/sourceDim.y)*1.1;
    vec4 outColor;
    
    vec2 p = uv;
    if (mode==0) {
        for(int i=0; i<iterations; ++i) {
            vec4 color = __source__(p);
            float centrality = vignetting==0.0 ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            float weight = i==0 ? 1.0 : pow(1.0-dampening, float(i)/float(iterations-1)) * centrality;
            //float weight = 1.;
            totalColor += weight * color;
            totalWeight += weight;
            p += delta;
        }

        outColor = totalColor / totalWeight;
    }
    else if (mode==1) {
         for(int i=0; i<iterations; ++i) {
            vec4 color = __source__(p);
            if (i==0) totalColor = color;
            else {
                if ((color.r+color.g+color.b) >= pow(1.0-dampening, float(i)/float(iterations-1))*(totalColor.r+totalColor.g+totalColor.b)) totalColor = color;
            }
            float centrality = (vignetting==0.0) ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            outColor = i==0 ? totalColor : mix(outColor, totalColor, centrality);
            p += delta;
        }
    }
   else if (mode==2) {
         for(int i=0; i<iterations; ++i) {
            vec4 color = __source__(p);
            if (i==0) totalColor = color;
            else {
                if ((color.r+color.g+color.b) <= pow(1.0-dampening, float(i)/float(iterations-1))*(totalColor.r+totalColor.g+totalColor.b)) totalColor = color;
            }
            float centrality = (vignetting==0.0) ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            outColor = i==0 ? totalColor : mix(outColor, totalColor, centrality);
            p += delta;
        }           
    }
   else {
       for(int i=0; i<iterations; ++i) {
            vec4 col = __source__(p);
            float centrality = vignetting==0.0 ? 1. : smoothstep(radius/vignetting, radius*0.6, length(p));
            float weight = i==0 ? 1.0 : pow(1.0-dampening, float(i)/float(iterations-1)) * centrality * colorWeight(col, color, tolerance);
            //float weight = 1.;
            totalColor += weight * col;
            totalWeight += weight;
            p += delta;
        }

        outColor = totalColor / totalWeight;
    }
    
    return outColor;
}
