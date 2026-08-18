vec4 slim(vec2 pos, vec2 outPos, mat3 modelTransform, float intensity, vec2 sourceDim) {
        vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
        float ratio = sourceDim.x / sourceDim.y;
        float xMin = 0.5 - intensity*0.5;
        float xs = xMin + u.y*u.y*(0.5-xMin);
    
        float s = sign(u.x);
        float absX = abs(u.x)/ratio;
        float x2 = ratio*absX*0.5/xs; //ratio*(absX <= xs ? absX*0.5/xs : (0.5+(absX-xs)*0.5/(1.0-xs)));
        u.x = s*x2;
        u = tf(modelTransform, u);
        
        return __source__(u);
    }
