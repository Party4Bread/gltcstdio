vec3 patternHexDots(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec4 hex = hexCoords(u);
    float threshold = length(hex.xy)*2.0;
    return vec3(hex.zw, threshold);
}

vec3 patternDots(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = round(u);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = vec2(u.x, round(u.y));
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternWavyLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    vec2 center = vec2(u.x, round(u.y - sin(u.x*0.5)*2.0) + sin(u.x*0.5)*1.5);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec3 patternConcentricLines(mat3 transform, vec2 uv) {
    vec2 u = tf(transform, uv);
    float d = round(length(u));
    vec2 center = d * normalize(u);
    float threshold = length(u-center)*2.0;
    return vec3(center, threshold);
}

vec4 halftoneRGB(vec2 uv, vec2 outPos, float smoothen, float intensity, mat3 modelTransform, mat3 redTransform, mat3 greenTransform, mat3 blueTransform, vec4 color1, vec4 color2, int sampling, int style) {
    vec3 patternR, patternG, patternB;
    
    mat3 transformR, invTransformR, transformG, invTransformG, transformB, invTransformB;
    transformG = modelTransform;
    if (style==3) {
        transformR = modelTransform * translation3(30.*vec2(0.5, SQRT3_2));
        transformB = modelTransform * translation3(30.*vec2(-0.5, SQRT3_2));            
    }
    else if (style==1) {
        transformR = modelTransform * rotation3(0.4);
        transformB = modelTransform * rotation3(1.6);                            
    }
    else {
        transformR = modelTransform * rotation3(0.2618);
        transformB = modelTransform * rotation3(1.309);                            
    }
    
    transformR = transformR * redTransform;
    transformG = transformG * greenTransform;
    transformB = transformB * blueTransform;
    
    invTransformR = inverse(transformR);
    invTransformG = inverse(transformG);
    invTransformB = inverse(transformB);
    
    switch (style) {
        case 0: patternG = patternDots(inverse(modelTransform), uv); patternR = patternDots(invTransformR, uv); patternB = patternDots(invTransformB, uv); break;
        case 1: patternG = patternHexDots(inverse(modelTransform), uv); patternR = patternHexDots(invTransformR, uv); patternB = patternHexDots(invTransformB, uv); break;
        case 2: patternG = patternLines(inverse(modelTransform), uv); patternR = patternLines(invTransformR, uv); patternB = patternLines(invTransformB, uv); break;
        case 3: patternG = patternConcentricLines(inverse(modelTransform), uv); patternR = patternConcentricLines(invTransformR, uv); patternB = patternConcentricLines(invTransformB, uv); break;
        case 4: patternG = patternWavyLines(inverse(modelTransform), uv); patternR = patternWavyLines(invTransformR, uv); patternB = patternWavyLines(invTransformB, uv); break;
    }
    
    float thresholdR = patternR.z * intensity;
    float thresholdG = patternG.z * intensity;
    float thresholdB = patternB.z * intensity;
    
    
    vec4 color = vec4(0.0);
    float kR, kG, kB;
    
    switch (sampling) {
        case 0: {
            vec2 samplePosR = tf(transformR, patternR.xy); 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(transformR[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePosR + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePosR);
            }
            kR = color.r>thresholdR ? 1.0 : 0.0;
            color = vec4(0.0);
            
            vec2 samplePosG = tf(transformG, patternG.xy); 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(transformG[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePosG + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePosG);
            }
            kG = color.g>thresholdG ? 1.0 : 0.0;
            color = vec4(0.0);
            
            vec2 samplePosB = tf(transformB, patternB.xy); 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(transformB[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePosB + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePosB);
            }
            kB = color.b>thresholdB ? 1.0 : 0.0;                    
            
            break;
        }
        default: {
            vec2 samplePos = uv; 
            if (smoothen>0.0) {
                int N = 5;
                float r = length(modelTransform[0].xy) * smoothen * 3.0;
                float step = r/float(N);
                for(int j=-N; j<=N; ++j) {
                    for(int i=-N; i<=N; ++i) {
                        color += __source__(samplePos + vec2(float(i), float(j)) * step);
                    }
                }
                color /= float((2*N+1)*(2*N+1));
            }
            else {
                color = __source__(samplePos);
            }
            kR = color.r>thresholdR ? 1.0 : 0.0;
            kG = color.g>thresholdG ? 1.0 : 0.0;
            kB = color.b>thresholdB ? 1.0 : 0.0;
            break;
        }
    }
                
    vec4 outColor = vec4(mix(color2.r, color1.r, kR), mix(color2.g, color1.g, kG), mix(color2.b, color1.b, kB), mix(color2.a, color1.a, 0.5));
    //vec4 bkgColor = __source__(uv);
    return mergeColor(color, outColor);
}
