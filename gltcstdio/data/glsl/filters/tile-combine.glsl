vec4 tileCombine(vec2 uv, vec2 outPos, 
int mode, float thickness, vec4 colorBorder, 
vec2 source1Dim, vec2 source2Dim, mat3 modelTransform) {
    if (mode==0) {
        float id = round(uv.y * 0.5);
        float y = mod(uv.y+1.0, 2.0) - 1.0;                   
        if (mod(id, 2.0)==0.0) {
            float ratio1 = source1Dim.x/source1Dim.y;
            float ratio = (ratio1+thickness)/(1.0+thickness);
            float x = mod(uv.x + ratio, 2.0*ratio) - ratio; 
            float b = 1./(1.0+thickness);
            if (abs(x)>ratio-1.0+b || abs(y)>b) return colorBorder;
            return __source1__(vec2(x, y) / b);
        } else {
            float ratio1 = source2Dim.x/source2Dim.y;
            float ratio = (ratio1+thickness)/(1.0+thickness);
            float x = mod(uv.x + ratio, 2.0*ratio) - ratio; 
            float b = 1./(1.0+thickness);
            if (abs(x)>ratio-1.0+b || abs(y)>b) return colorBorder;
            return __source2__(vec2(x, y) / b);
        }                    
    }
    else if (mode==1) {
        float id = round(uv.x* 0.5);
        float x = mod(uv.x+1.0, 2.0) - 1.0;
        if (mod(id, 2.0)==0.0) return __source1__(vec2(x, uv.y) * source1Dim.x/source1Dim.y); else return __source2__(vec2(x, uv.y) * source2Dim.x/source2Dim.y);                    
    }
    else {
        vec2 id = round(uv * 0.5);
        vec2 u = mod(uv+1.0, 2.0) - 1.0;
        float b = 1.0 - thickness;
        if (abs(u.x)>b || abs(u.y)>b) return colorBorder;
        u /= b;
        if (mod(id.x+id.y, 2.) == 0.0) return __source1__(u); else return __source2__(u);
    }
}
