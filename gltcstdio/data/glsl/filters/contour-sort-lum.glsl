bool inside(vec2 pos, float X, float Y) {
    return abs(pos.y)<=Y && abs(pos.x)<=X;
}

vec4 contourInterpolate(vec2 pos, vec2 outPos, vec2 sourceDim, int count, float contrast, mat3 modelTransform) {
    float pixel = 2.0 / sourceDim.y;
    float X = sourceDim.x / sourceDim.y;
    float Y = 1.0;
    float sC = float(count)/3.0;
    
    vec2 p = vec2(pixel, 0.0);
    //vec2 d = pixel*normalize(mat2(modelTransform) * p);
    vec2 d = mat2(modelTransform) * p;

    vec4 col = __source__(pos);
    float grey = clamp(col.r + col.g + col.b, 0., 3.);
    int s = min(int(grey*sC), count-1);
    
    const int N = 256;
    float sN = float(N)/3.0;
    int[N] buckets;
    for(int i=0; i<N; ++i) buckets[i] = 0;
    int g = min(int(grey*sN), N-1);
    ++buckets[g];

    bool advance = false;   

    vec2 pos1 = pos;
    int preCount = 0;
    do {
        vec2 next = pos1+d;
        vec4 cNext = __source__(next);
        float gNext = clamp(cNext.r + cNext.g + cNext.b, 0., 3.);
        int scNext = min(int(gNext*sC), count-1);
        advance = scNext==s && inside(next, X, Y);
        if (advance) {
            ++buckets[min(int(gNext*sN), N-1)];
            ++preCount;
            pos1 = next;
        }
    } while (advance);

    vec2 pos2 = pos;
    int postCount = 0;
    do {
        vec2 next = pos2-d;
        vec4 cNext = __source__(next);
        float gNext = clamp(cNext.r + cNext.g + cNext.b, 0., 3.);
        int scNext = min(int(gNext*sC), count-1);
        advance = scNext==s && inside(next, X, Y);
        if (advance) {
            ++buckets[min(int(gNext*sN), N-1)];
            ++postCount;
            pos2 = next;
        }
    } while (advance);

    int bucketIndex = 0;
    int total = 0;
    while (bucketIndex<N && total+buckets[bucketIndex]<preCount+1) {
        total += buckets[bucketIndex];
        ++bucketIndex;
    }
    float lum = 1.0;
    if (bucketIndex<N) {
        float fractLum = float(preCount+1-total)/float((N-1)*buckets[bucketIndex]);
        lum = 3.0 * (fractLum + float(bucketIndex)/float(N-1));
        float avgLum = 3.0 * ((float(s)+.5)/float(count));
        float deltaLum = lum-avgLum;
        lum = avgLum + contrast * deltaLum; 
    }
    
    vec4 outCol = vec4(col.rgb / clamp(col.r + col.g + col.b, 0., 3.) * lum, col.a);
    return outCol;
}
