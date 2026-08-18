float chan(float k, float randomSeed) {
    return triangleWave(k*randomSeed + 0.0 + fract(k*19.)) * .5 + .5;
}

vec2 overUnder1(vec2 uv) {
    return vec2(0.5, 1.);
}

vec2 overUnder2(vec2 uv, float patternShape) {
    vec2 id = floor(uv);
    int N = int(patternShape);
    float k = mod(id.x+id.y, float(N)) >= float(N/2) ? 0.0 : 1.0;
    return vec2(k, 1.);
}

vec2 overUnder2b(vec2 uv, float patternShape, float shadows) {
    vec2 id = floor(uv);
    int N = int(patternShape);
    float kk = mod(id.x+id.y, float(N));
    float k = kk >= float(N/2) ? 0.0 : 1.0;
    float light = 1.0;
    float d2 = 0.85; 
    float d1 = 0.85-shadows;
    if (k==0.0) {
        vec2 delta = fract(uv)-0.5;
        float kkk = mod(id.x+uv.y, float(N));
        if (kkk<float(N/2)+0.5 || kkk>float(N)-0.5)
            light = smoothstep(d2, d1, length(delta));
        else light = smoothstep(d2, d1, abs(fract(uv.x)-0.5));
    }
    else {
        vec2 delta = fract(uv)-0.5;
        float kkk = mod(uv.x+id.y, float(N));
        if (kkk<0.5 || kkk>float(N/2)-0.5)
            light = smoothstep(d2, d1, length(delta));
        else light = smoothstep(d2, d1, abs(fract(uv.y)-0.5));
    }
    return vec2(k, light);
}

vec2 overUnder3(vec2 uv, float patternShape) {
    uv /= max(1.0, round(patternShape));
    return vec2((fract(uv.x)+fract(uv.y))*0.707, 1.);
}

vec2 overUnder4(vec2 uv, float patternShape) {
    float scale = 1.0/max(1.0, round(patternShape)); //1. / patternShape;
    vec2 u = abs(fract(uv * scale) - 0.5);
    
    return vec2((u.x + u.y)*0.707, 1.0);
}

vec2 overUnder5(vec2 uv, float patternShape) {
    float scale = 1.0/max(1.0, round(patternShape));
    vec2 delta = fract(uv * scale)-0.5;
    float k = smoothstep(0.3, 0.35, length(delta));
    float light = 1.0;//max(abs(delta.x), abs(delta.y)) > 0.45 ? 0.0 : 1.0;
    return vec2(k, light);
}

vec2 overUnder6(vec2 uv, float patternShape, float shadows) {
    vec2 u = uv*2.;
    float waveFreq = 0.2 * pow(0.3, triangleWave(patternShape*0.0551)*5.);
    float waveStrength = (triangleWave(patternShape*0.021)+1.0)*1./waveFreq;
    float k = sin(u.x+u.y + waveStrength * sin(waveFreq *(uv.x-uv.y))) *.5 + .5;
    float light = shadows==0.0 ? 1.0 : smoothstep(-shadows*.25, shadows*.5, abs(k-0.5));
    return vec2(k, light);
}

float getBitPattern(vec2 id, int N, int mode) {
    float n = float(N);
    float index = mod(id.x, n) + mod(id.y, n)*n;
    int bit = int(pow(2., float(index)));
    float k = (mode ^ bit) == 0 ? 1.0 : 0.0;
    k = mod(float(mode) / pow(2., index), 2.) >=1. ? 1.0 : 0.;
    return k;
}

vec2 overUnder7(vec2 uv, float patternShape) {
    vec2 id = floor(uv);
    int mode = int(patternShape * 100.0);
    int N = 2;
    if (mode<16) N = 2;
    else if (mode<528) { N = 3; mode -= 16; }
    else if (mode<66064) { N = 4; mode -= 528; }
    else { N = 5; mode -= 66064; }
    float k = getBitPattern(id, N, mode);
    return vec2(k, 1.);
}

vec2 overUnder7b(vec2 uv, float patternShape, float shadows) {
    vec2 id = floor(uv);
    int mode = int(patternShape * 100.0);
    int N = 2;
    if (mode<16) N = 2;
    else if (mode<528) { N = 3; mode -= 16; }
    else if (mode<66064) { N = 4; mode -= 528; }
    else { N = 5; mode -= 66064; }
    
    float k = getBitPattern(id, N, mode);
    float light = 1.0;
    if (shadows>0.0) {
        vec2 ku = fract(uv)-.5;
        vec2 du = sign(ku);
        vec2 idx = id + vec2(du.x, 0.0);
        vec2 idy = id + vec2(0.0, du.y);
        vec2 idxy = id + du;
            
        float d1 = 0.0;
        float d2 = shadows*0.5;
        float kx = getBitPattern(idx, N, mode);
        float ky = getBitPattern(idy, N, mode);
        float kxy = getBitPattern(idxy, N, mode);
        if (k!=kx) light = min(light, smoothstep(d1, d2, abs(abs(ku.x)-0.5)));
        if (k!=ky) light = min(light, smoothstep(d1, d2, abs(abs(ku.y)-0.5)));
        if (k!=kxy) light = min(light, smoothstep(d1, d2, length(abs(ku)-0.5)));
    }
    return vec2(k, light);
}

vec2 overUnder8(vec2 uv, float patternShape) {
    vec2 id = floor(uv);
    float mode = patternShape * 100.0;
    int N = 2;
    if (mode<16.) N = 2;
    else if (mode<528.) { N = 3; mode -= 16.; }
    else if (mode<66064.) { N = 4; mode -= 528.; }
    else { N = 5; mode -= 66064.; }
    int index = int(id.x)%N + (int(id.y)%N)*N;
    float k = mod(float(mode) / pow(2., float(index)), 2.);// >=1. ? 1.0 : 0.;
    return vec2(k, 1.);
}

vec2 overUnder9(vec2 uv, float patternShape, float shadows) {
    float kk = sin(length(uv / patternShape * 10.));
    float k = smoothstep(-0.02, 0.02, kk);
    float light = shadows==0.0 ? 1.0 : smoothstep(-0.01, shadows, abs(kk));
    return vec2(k, light);
}

vec2 overUnder10(vec2 uv, float patternShape) {
    vec2 id = floor(uv);
    float mode = patternShape;
    float div = 2./patternShape;
    float k = mod(float(int(id.x) ^ int(id.y)), mode) * div >=1. ? 1.0 : 0.;
    //float k = mod(float(int(id.x) ^ int(id.y)), mode) * div;
    return vec2(k, 1.);
}

vec2 overUnder11(vec2 uv, float patternShape) {
    vec2 id = floor(uv);
    float mode = patternShape;
    float div = 2./patternShape;
    float k = mod(float(int(id.x) ^ int(id.y)), mode) * div;
    return vec2(k, 1.);
}

vec2 overUnder(vec2 uv, int ouMode, float shadows, float patternShape) {
    if (ouMode<6) {
        if (ouMode<3) {
            if (ouMode==0) return overUnder1(uv);
            else if (ouMode==1) return overUnder2(uv, patternShape);
            else return overUnder2b(uv, patternShape, shadows);
        }
        else {
            if (ouMode==3) return overUnder3(uv, patternShape);
            else if (ouMode==4) return overUnder4(uv, patternShape);
            else return overUnder5(uv, patternShape);
        }
    }
    else {
        if (ouMode<9) {
            if (ouMode==6) return overUnder6(uv, patternShape, shadows);
            else if (ouMode==7) return overUnder7(uv, patternShape);
            else return overUnder7b(uv, patternShape, shadows);
        }
        else {
            if (ouMode==9) return overUnder8(uv, patternShape);
            else if (ouMode==10) return overUnder9(uv, patternShape, shadows);
            else if (ouMode==11) return overUnder10(uv, patternShape);
            else return overUnder11(uv, patternShape);
        }
    
    }
}

vec4 getLinCol(float i, float size, float randomSeed, vec4 c1, vec4 c2, vec4 c3, vec4 c4, vec4 c5) {
    float y1 = chan(0.4, randomSeed);
    float y2 = y1+chan(0.8, randomSeed);
    float y3 = y2+chan(1.232, randomSeed);
    float y4 = y3+chan(2.323, randomSeed);
    float y5 = y4+chan(2.44, randomSeed);
    //float x = SYM ? abs(mod(i/float(P), 2.)-1.) * y5 : fract(i/float(P)) * y5;
    float x = abs(mod(i/round(size), 2.)-1.) * y5;
    if (x<y1) return c1;
    else if (x<y2) return c2;
    else if (x<y3) return c3;
    else if (x<y4) return c4;
    else return c5;
}

vec4 plaid(vec2 uv, vec2 outPos, 
    int mode, int source_specified, float shadows, float size,
    float patternShape, float randomSeed, float colorVariability,
    vec4 color1, vec4 color2, vec4 color3, vec4 color4, vec4 color5
    ) {

    vec2 id = floor(uv);
    vec2 ou = overUnder(uv, mode, shadows, patternShape);
    float k = ou.x;
    float light = ou.y;
    
    color1 = mergeColor(vec4(chan(1.23, randomSeed), chan(0.553, randomSeed), chan(1.83, randomSeed), 1.0), color1);
    color2 = mergeColor(vec4(chan(1.73, randomSeed), chan(0.3153, randomSeed), chan(1.03, randomSeed), 1.0), color2);
    color3 = mergeColor(vec4(chan(1.673, randomSeed), chan(1.013, randomSeed), chan(2.593, randomSeed), 1.0), color3);
    color4 = mergeColor(vec4(chan(0.53, randomSeed), chan(2.253, randomSeed), chan(0.823, randomSeed), 1.0), color4);
    color5 = mergeColor(vec4(chan(3.213, randomSeed), chan(1.953, randomSeed), chan(1.0863, randomSeed), 1.0), color5);
    
    float X = floor(id.x);
    float Y = floor(id.y);
    vec4 vCol = getLinCol(X, size, randomSeed, color1, color2, color3, color4, color5) + colorVariability*vec4(vec3(hash11(X)-0.5), 1.0);
    vec4 hCol = getLinCol(Y, size, randomSeed, color1, color2, color3, color4, color5) + colorVariability*vec4(vec3(hash11(Y)-0.5), 1.0); 
    vec4 col = vec4(vec3(light), 1.) * mix(vCol, hCol, k);
    
    if (source_specified==1 && col.a<1.0) {
    return mergeColor(__source__(uv), col);
}
else {
    return col;
}
}
