float sampleCol(vec4 color, int count) {
    return floor((color.r + color.g + color.b)*(float(count)-1.0)/3.0 + 0.5);
}

float sampleVal(float val, int count) {
    return floor(val*(float(count)-1.0)/3.0 + 0.5);
}

bool inside(vec2 pos, float X, float Y) {
    return abs(pos.y)<=Y && abs(pos.x)<=X;
}

vec4 contourInterpolate(vec2 pos, vec2 outPos, vec2 sourceDim, int mode, int count, mat3 modelTransform) {
            float pixel = 2.0 / sourceDim.y;
            float X = sourceDim.x / sourceDim.y;//sourceDim.x>sourceDim.y ? 1.0 : sourceDim.x / sourceDim.y;
            float Y = 1.0;//sourceDim.x>sourceDim.y ? sourceDim.y / sourceDim.x : 1.0;
            
            vec2 p = vec2(pixel, 0.0);
            vec2 d = pixel*normalize(mat2(modelTransform) * p);
//            vec2 d = mat2(modelTransform) * p;

            vec4 col = __source__(pos);
//            float s = sampleCol(col, count);
            float gPos = col.r + col.g + col.b;
            float gLightest = gPos;
            float gDarkest = gPos;
            float s = sampleVal(gPos, count);
            
            if (mode==0) {
                vec4 lightest = col;
                vec4 darkest = col;
                bool advance = false;
                vec2 pos1 = pos;
                vec2 pos2 = pos;

                do {
                    vec2 next = pos1+d;
                    vec4 cNext = __source__(next);
                    float gNext = cNext.r + cNext.g + cNext.b;
                    float sNext = sampleVal(gNext, count);
                    advance = sNext==s && inside(next, X, Y);
                    if (advance) {
                        pos1 = next;
                        if (gNext>gLightest) { lightest = cNext; gLightest = gNext; }
                        if (gNext<gDarkest) { darkest = cNext; gDarkest = gNext; }
                    }
                } while (advance);

                do {
                    vec2 next = pos2-d;
                    vec4 cNext = __source__(next);
                    float gNext = cNext.r + cNext.g + cNext.b;
                    float sNext = sampleVal(gNext, count);
                    advance = sNext==s && inside(next, X, Y);
                    if (advance) {
                        pos2 = next;
                        if (gNext>gLightest) { lightest = cNext; gLightest = gNext; }
                        if (gNext<gDarkest) { darkest = cNext; gDarkest = gNext; }
                    }
                } while (advance);

                vec2 dd = pos2-pos1;
                float len = length(dd);
                if (len==0.0) return col;

                vec4 outCol = mix(darkest, lightest, dot((pos-pos1)/len, (pos2-pos1)/len));

                return outCol;                
            }
            else /*if (mode==1)*/ {
                vec2 pos1 = pos;
                while (sampleCol(__source__(pos1+d), count)==s && inside(pos1+d, X, Y)) {
                    pos1 += d;
                }
                vec4 col1 = __source__(pos1);
    
                vec2 pos2 = pos;
                while (sampleCol(__source__(pos2-d), count)==s && inside(pos2-d, X, Y)) {
                    pos2 -= d;
                }
                vec4 col2 = __source__(pos2);
    
                vec2 dd = pos2-pos1;
                float len = length(dd);
                if (len==0.0) return col;
    
                vec4 outCol = mix(col1, col2, dot((pos-pos1)/len, (pos2-pos1)/len));
    //            return vec4(vec3(length(pos-pos1), length(pos-pos2), len*0.1), 1.0);
    
                return outCol;
            }
        }
