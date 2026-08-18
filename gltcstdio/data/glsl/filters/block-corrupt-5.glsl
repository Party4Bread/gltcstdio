float bc5GetIndex(vec2 pos, vec2 blockSize, vec2 dim) {
    float columns = dim.x/blockSize.x;
    float lines = dim.y/blockSize.y;
    vec2 f = floor(pos/blockSize);
    return f.x+0.5*columns + (f.y+0.5*lines)*columns;
}

vec4 blockCorrupt5(vec2 pos, vec2 outPos, int count, float randomSeed, vec2 sourceDim, mat3 modelTransform) {
    vec4 inCol = __source__(pos);
    vec4 outCol = inCol;

    float ratio = sourceDim.x/sourceDim.y;
    vec2 dim = vec2(2.0*ratio, 2.0);
    vec2 blockSize = dim / vec2(160.0, 80.0);
    float columns = dim.x/blockSize.x;
    float lines = dim.y/blockSize.y;
    float blocks = columns*lines;
    float index = bc5GetIndex(pos, blockSize, dim);

    float offset = modelTransform[2][0]*0.5*columns + modelTransform[2][1]*0.5*lines*columns + 0.5*blocks;
    float scale = length(vec2(modelTransform[0][0], modelTransform[0][1]));

    for(int i=0; i<count; ++i) {
        vec2 rnd = sineSurfaceRand2Seeded(vec2(10.0-float(i), 15.0+5.0*float(i)), randomSeed+4.46);
        float center = offset + rnd.x*blocks;
        float bSize = (rnd.x<-0.5+float(i)*0.1)? 0.5 : abs(rnd.y)*blocks*scale;
        float ind1 = center-bSize;
        float ind2 = center+bSize;

        bool inside = (index>=ind1 && index<=ind2);
        if (inside) {
            float subMode = floor(mod(rnd.x*15.0, 9.0));
            float g = 0.0;
            if (subMode==0.0) {
                g = fract(rand2relSeeded(floor(pos*320.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
            }
            else if (subMode==1.0) {
                g = fract(rand2relSeeded(floor(pos*160.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
            }
            else if (subMode==2.0) {
                g = fract(pos.x*40.0)>0.5 ? 1.0 : 0.0;
            }
            else if (subMode==3.0) {
                g = fract(pos.x*80.0)>0.5 ? 1.0 : 0.0;
            }
            else if (subMode==6.0) {
                g = fract(pos.x*80.0)>length(inCol.rgb)/1.7 ? 1.0 : 0.0;
            }
            else if (subMode==7.0) {
                g = fract(pos.x*10.0)<length(inCol.rgb)/1.7 ? 1.0 : 0.0;
            }
            else if (subMode==4.0) {
                g = mod((fract(pos.x*80.0)>0.5 ? 1.0 : 0.0) + (fract(pos.y*40.0)>0.5 ? 1.0 : 0.0), 2.0);
            }
            else if (subMode==5.0) {
                g = fract(rand2relSeeded(floor(pos*160.0), randomSeed).x) < length(inCol.rgb)/1.7 ? 1.0 : 0.0;
            }
            else {
                g = mod((fract(pos.x*40.0)>0.5 ? 1.0 : 0.0) + (fract(pos.y*20.0)>0.5 ? 1.0 : 0.0), 2.0);
            }
            outCol = vec4(g, g, g, 1.0);
            return outCol;
        }
    }

    return inCol;
}
