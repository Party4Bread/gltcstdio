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

vec4 halftone(vec2 uv, vec2 outPos, float smoothen, float intensity, mat3 modelTransform, vec4 color1, vec4 color2, int sampling, int style) {
    vec3 pattern;
    switch (style) {
        case 0: pattern = patternDots(inverse(modelTransform), uv); break;
        case 1: pattern = patternHexDots(inverse(modelTransform), uv); break;
        case 2: pattern = patternLines(inverse(modelTransform), uv); break;
        case 3: pattern = patternConcentricLines(inverse(modelTransform), uv); break;
        case 4: pattern = patternWavyLines(inverse(modelTransform), uv); break;
    }
    
    float threshold = pattern.z * intensity;
    
    vec2 samplePos;
    
    switch (sampling) {
        case 0: samplePos = tf(modelTransform, pattern.xy); break;
        default: samplePos = uv; break;
    }
    
    vec4 color = vec4(0.0);
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
    
    float k = luma(color.rgb)>threshold ? 1.0 : 0.0;
    
    vec4 outColor = mix(color2, color1, k);
    //vec4 bkgColor = __source__(uv);
    return mergeColor(color, outColor);
}
