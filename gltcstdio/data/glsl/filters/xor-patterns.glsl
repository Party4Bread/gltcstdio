float pr(float x, float k, int process) {
    if (process==1) return fract(x);
    else if (process==2) return 1.0 - abs(mod(x, 2.0)-1.0); // reflect
    else if (process==3) return mod(x, 2.0); 
    else if (process==4) return x/k; 
    else return x;
}

vec4 xorPatterns(vec2 uv, vec2 outPos, int source_specified, float intensity, float colorVariability, int mode, vec4 color1, vec4 color2) {

    int process = mode%5; mode /= 5;
    float mR = (float(mode%8) - 3.5)*3.0; mode /= 8;
    float mB = (float(mode%8) - 3.5)*3.0; mode /= 8;
    
    float modG = intensity;
    float modR = intensity + colorVariability * mR;
    float modB = intensity + colorVariability * mB;
    int rdx = int(round(float(mode%16) * colorVariability)); mode /= 16;
    int bdy = int(round(float(mode%16) * colorVariability)); mode /= 16;
    
    
    int x = int(uv.x);
    int y = int(uv.y);
        
    float r = pr(mod(float((x+rdx) ^ y), modR), modR, process);
    float g = pr(mod(float(x ^ y), modG), modG, process);
    float b = pr(mod(float(x ^ (y+bdy)), modB), modB, process);
    float a = pr(mod(float((x+rdx) ^ (y+bdy)), modG), modG, process);
    
    vec4 outColor = vec4(mix(color1.r, color2.r, r), mix(color1.g, color2.g, g), mix(color1.b, color2.b, b), mix(color1.a, color2.a, a));
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;     
}
