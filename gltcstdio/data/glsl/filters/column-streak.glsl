vec4 streak(vec2 uv, vec2 outPos, vec4 color, vec2 sourceDim, float thickness, float shadows, float randomness_variability, float randomness_seed, float subdividing, mat3 modelTransform) {
    float variability = randomness_variability;
    float randomSeed = randomness_seed;
    
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float pixel = 2.0/sourceDim.y;
    float scale = length(modelTransform[0].xy);
    float t = thickness*2.*scale;
    float var = variability*8.0;
    float index = floor(u.x+0.5);
    bool border = false;
    float light = 1.0;
    float x1, x2, i2;
    for(float k=-6.0; k<=6.0; ++k) {
        float i = k+index;
        vec2 rnd2 = rand2relSeeded(vec2(i, i), randomSeed);
        x1 = i + var * rnd2.x;
        float shadowSize = shadows*4.0 * (1.0+variability * rnd2.y);
        i2 = i+1.0;
        x2 = i2 + var * rand2relSeeded(vec2(i2, i2), randomSeed).x;
        if (abs(u.x-x1)<t || abs(x2-u.x)<t) {
            border = true;
            break;
        }
        else if (x1<=u.x && u.x<=x2) {
            light = smoothstep(mix(-shadowSize, 0.0, shadows), shadowSize, x2-u.x);
            break;
        }
    }

    vec2 rnd = rand2relSeeded(vec2(sign(u.y), i2), randomSeed);
//    float Y = abs(subdividing)*3.0*20.0 * (1.0+0.5*var*rnd.x);
//    float dy = abs(subdividing)*2.0*20.0 * (1.0+0.5*var*rnd.y);
    int maxIter = 30;
    float st = t;//*0.5;
    if (subdividing<0.0) {
        float Y = 50.0/abs(subdividing*subdividing*1.0e4) *20.0 * (1.0+0.5*var*rnd.x);
        float dy = 50.0/abs(subdividing*subdividing*1.0e4) *20.0 * (1.0+0.5*var*rnd.y);
        while (abs(u.y)>Y && abs(x2-x1)>pixel && maxIter>0) {
            float k = rnd.x+0.5;
            float x12 = mix(x1, x2, k);
            if (/*st<abs(x2-x1)/2.0 && */abs(x2-x1)<st || abs(u.x-x12)<st) {
                border = true;
                x1 = x2 = x12;
                break;
            }
            else if (u.x<x12) {
                x2 = x12;
            }
            else {
                x1 = x12;
            }
            Y += dy;
            dy *= 0.5;//subdividing*0.01;
            //st *= 0.5;
            rnd = rand2relSeeded(rnd, randomSeed);
            --maxIter;
        }
    }
    else if (subdividing>0.0) {
        border = false;
        float Y = pow(abs(subdividing*100.0), 1.5)*0.01 *20.0 * (1.0+0.01*var*rnd.x);
        float dy = 50.0/abs(subdividing*subdividing*1.0e4) *20.0 * (1.0+0.5*var*rnd.y);
        while (abs(u.y)<Y && abs(x2-x1)>pixel && maxIter>0) {
            float k = rnd.x+0.5;
            float x12 = mix(x1, x2, k);
            if (u.x<x12) {
                x2 = x12;
            }
            else {
                x1 = x12;
            }
            Y -= dy;
            dy *= 0.5;//subdividing;
            //st *= 0.5;
            rnd = rand2relSeeded(rnd, randomSeed);
            --maxIter;
        }
        if (st<abs(x2-x1)/2.0 && (abs(u.x-x1)<t || abs(x2-u.x)<t)) {
            border = true;
        }
    }

    u.x = (x1+x2)/2.0;

    vec2 v = (modelTransform * vec3(u, 1.0)).xy;
    vec4 col = __source__(v);
    vec4 outCol = border ? vec4(mix(col.rgb, color.rgb, color.a), col.a) : col;
    outCol = mix(vec4(0.0, 0.0, 0.0, 1.0), outCol, light);
    return outCol;
}
