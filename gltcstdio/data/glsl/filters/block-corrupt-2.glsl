float getIndex(vec2 pos, vec2 blockSize, vec2 dim) {
    float columns = dim.x/blockSize.x;
    float lines = dim.y/blockSize.y;
    vec2 f = floor(pos/blockSize);
    return f.x+0.5*columns + (f.y+0.5*lines)*columns;
}

vec4 blockBW(vec2 pos, vec2 outPos, int mode, int count, float randomSeed, vec2 sourceDim, mat3 objectTransform, mat3 modelTransform) {
            vec4 inCol = __source__(pos);
            vec4 outCol = inCol;
        
            float ratio = sourceDim.x/sourceDim.y;
            vec2 dim = vec2(2.0*ratio, 2.0);
            vec2 blockSize = dim / vec2(160.0, 80.0);
            float columns = dim.x/blockSize.x;
            float lines = dim.y/blockSize.y;
            float blocks = columns*lines;
            vec2 uv = tf(inverse(modelTransform), pos);
            
            float index = getIndex(vec2(uv.x, mod(uv.y+3.0, 6.0)-3.0), blockSize, dim);
            randomSeed += floor((uv.y+3.0)/6.0); // every vert. window of height 6 has a different random seed
//            float index = getIndex(uv, blockSize, dim);
        
//            mat3 invModelTransform = inverse(modelTransform);
            float offset = objectTransform[2][0]*0.5*columns + objectTransform[2][1]*0.5*lines*columns + 0.5*blocks;
            float scale = length(objectTransform[0].xy);
                
            for(int i=0; i<count; ++i) {
                vec2 rnd = sineSurfaceRand2Seeded(vec2(10.0-float(i), 15.0+5.0*float(i)), randomSeed+4.46);
                float center = offset + rnd.x*blocks;
                float bSize = (rnd.x<-0.5+float(i)*0.1)? 0.5 : abs(rnd.y)*blocks*scale;
                float ind1 = center-bSize;
                float ind2 = center+bSize;
        
                bool inside = (index>=ind1 && index<=ind2);
                if (inside) {
                    if (mode==0) { // BW
                        float subMode = floor(mod(rnd.x*15.0, 9.0));
                        float g = 0.0;
                        if (subMode==0.0) {
                            g = fract(rand2relSeeded(floor(uv*320.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==1.0) {
                            g = fract(rand2relSeeded(floor(uv*160.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==2.0) {
                            g = fract(uv.x*40.0)>0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==3.0) {
                            g = fract(uv.x*80.0)>0.5 ? 1.0 : 0.0;
                        }
                        else if (subMode==6.0) {
                            g = fract(uv.x*80.0)>length(inCol.rgb)/1.7 ? 1.0 : 0.0;
                        }
                        else if (subMode==7.0) {
                            g = fract(uv.x*10.0)<length(inCol.rgb)/1.7 ? 1.0 : 0.0;
                        }
                        else if (subMode==4.0) {
                            g = mod((fract(uv.x*80.0)>0.5 ? 1.0 : 0.0) + (fract(uv.y*40.0)>0.5 ? 1.0 : 0.0), 2.0);
                        }
                        else if (subMode==5.0) {
                            g = fract(rand2relSeeded(floor(uv*160.0), randomSeed).x) < length(inCol.rgb)/1.7 ? 1.0 : 0.0;
                        }
                        else {
                            g = mod((fract(uv.x*40.0)>0.5 ? 1.0 : 0.0) + (fract(uv.y*20.0)>0.5 ? 1.0 : 0.0), 2.0);
                        }
                        outCol = vec4(g, g, g, 1.0);
                    }
                    else if (mode==1) { // color = channel swap
                        float mode = (rnd.x+0.5)*4096.0;
                        outCol = swapRGBHSL(outCol, mode);
                    }
                    else if (mode==2) { // channel+pos
                        int channel = int(mod(rnd.x*100.0, 3.0));
                        vec2 delta = fract(rnd*10.0)*2.0-vec2(1.0, 1.0);
                        outCol[channel] = __source__(pos+delta)[channel];
                    }
                    else if (mode==3) { // pos
                        vec2 delta = fract(rnd*10.0)*2.0-vec2(1.0, 1.0);
                        outCol = __source__(pos+delta);
                    }
                    
                    return outCol;
                }
            }
        
            return inCol;
        }
