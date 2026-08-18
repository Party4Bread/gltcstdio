float inCircle(vec2 c, float r, vec2 p) {
    return length(c-p)<r ? 1.0 : 0.0;
}

float inCircle2(float a, float d, float r, vec2 p) {
    return inCircle(d*vec2(-sin(a), cos(a)), r, p);

}

float inRosace(float r1, float r2, int N, vec2 p) {
    float di = length(p);
    if (di<r1 || di>r2) return 0.0;

    float r = (r2-r1)/2.0;
    float d = r2-r;
    float inside = 0.0;
    for(int i=0; i<N; ++i) {
        float a = PI2*float(i)/float(N);
        inside += inCircle2(a, d, r, p);
    }
    return inside;
}

float makeDivisible(float a, float b) {
    if (a>b) {
        return b*floor(a/b+0.5);
    }
    else {
        return a*floor(b/a+0.5);
    }
}

float getInsideRosace(vec2 u, vec2 id, float radius, float randomSeed) {
    vec2 pos = u / radius;
    if (length(pos)>0.75) return 0.0;
    
    float inside = 0.0;

    vec2 rnd = rand2relSeeded(id, randomSeed)+vec2(0.5, 0.5);

    int levels = int(1.0 + floor(rnd.x*3.0));

    float N = 1.0;
    float r1 = 0.75;
    float r2;

    if (id.x==0.0 && id.y==0.0 && randomSeed==0.0) {
        inside += inRosace(0.0, 0.25, 24, pos);
        inside += inRosace(0.25, 0.35, 12, pos);
        inside += inRosace(0.35, 0.75, 60, pos);
    }
    else for(int j=0; j<levels; ++j) {
        rnd = rand2relSeeded(rnd, randomSeed)+vec2(0.5, 0.5);
        r2 = r1;
        r1 = r1 * rnd.x;
        if (r1/r2>0.9) r1 = r2*0.9;
        if (r1<0.05) r1 = 0.0;
        N = makeDivisible(N, floor(rnd.y*rnd.y*60.0)+2.0);
        inside += inRosace(r1, r2, int(N), pos);
    }
    
    return inside;
}

vec4 rosaces(vec2 pos, vec2 outPos, vec4 color1, vec4 color2, float radius, float randomSeed, int mode) {

    vec4 hexCoord = hexCoords(pos);
    vec2 gridPos = hexCoord.xy;
    vec2 gridIndex = floor(hexCoord.zw * vec2(2.0, 2.0*SQRT3) + 0.5);

//    vec4 hexCoord = hexPolarCoords(pos);
//    vec2 gridPos = hexCoord.y*vec2(cos(hexCoord.x), sin(hexCoord.x));
//    vec2 gridIndex = floor(hexCoord.zw*1000.+0.5)*0.001;

    pos = gridPos / radius;
    float inside = 0.0;
    
    inside += getInsideRosace(gridPos, gridIndex, radius, randomSeed);
    if (radius>0.66) {
        inside += getInsideRosace(gridPos-vec2(1., 0.), gridIndex+vec2(2., 0.), radius, randomSeed);
        inside += getInsideRosace(gridPos+vec2(1., 0.), gridIndex-vec2(2., 0.), radius, randomSeed);
        inside += getInsideRosace(gridPos-vec2(0.5, SQRT3_2), gridIndex+vec2(1., 3.), radius, randomSeed);
        inside += getInsideRosace(gridPos-vec2(-0.5, SQRT3_2), gridIndex+vec2(-1., 3.), radius, randomSeed);
        inside += getInsideRosace(gridPos-vec2(0.5, -SQRT3_2), gridIndex+vec2(1., -3.), radius, randomSeed);
        inside += getInsideRosace(gridPos-vec2(-0.5, -SQRT3_2), gridIndex+vec2(-1., -3.), radius, randomSeed);
    }

    /*vec2 rnd = rand2relSeeded(gridIndex, randomSeed)+vec2(0.5, 0.5);

    int levels = int(1.0 + floor(rnd.x*3.0));

    float N = 1.0;
    float r1 = 0.75;
    float r2;

    if (gridIndex.x==0.0 && gridIndex.y==0.0 && randomSeed==0.0) {
        inside += inRosace(0.0, 0.25, 24, pos);
        inside += inRosace(0.25, 0.35, 12, pos);
        inside += inRosace(0.35, 0.75, 60, pos);
    }
    else for(int j=0; j<levels; ++j) {
        rnd = rand2relSeeded(rnd, randomSeed)+vec2(0.5, 0.5);
        r2 = r1;
        r1 = r1 * rnd.x;
        if (r1/r2>0.9) r1 = r2*0.9;
        if (r1<0.05) r1 = 0.0;
        N = makeDivisible(N, floor(rnd.y*rnd.y*60.0)+2.0);
        inside += inRosace(r1, r2, int(N), pos);
    }*/
    
    float k;
     if (mode==0) k = mod(inside, 2.0)<1.0 ? 1.0 : 0.0;
     else if (mode==1) k = pow(0.8, inside);
     else if (mode==2) k = mod(inside, 2.0)<1.0 ? pow(0.8, inside) : 1.0-pow(0.8, inside);
     else k = 0.5;
    
//    float coordK = 1.0;
//    float y = (gridPos.y*20.0 + 0.0);
//    if (gridPos.x>-0.1 && gridPos.x<-0.05) {
//        if (y>0.0 && gridIndex.x>floor(y) && fract(y)>0.1 && fract(y)<0.9) coordK = 0.0;
//    }
//    else if (gridPos.x>0.05 && gridPos.x<0.1) {
//        if (y>0.0 && gridIndex.y>floor(y) && fract(y)>0.1 && fract(y)<0.9) coordK = 0.5;
//    }
//    return vec4(coordK * fract(gridIndex*0.1), 0.0, 1.0);

    return mix(color2, color1, k);
}
