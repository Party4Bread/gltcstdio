vec4 hexCubePixelate(vec2 uv, vec2 outPos, float pixelation, float thickness, vec4 color, mat3 modelTransform) {
            vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
            vec4 hex = hexPolarBorderCoords(u);
            vec2 v = (modelTransform * vec3(hex.zw, 1.0)).xy;
            if (hex.y<thickness*0.5) {
                vec4 col = __source__(v);
                return mergeColor(col, color);
            }
            else {
                float l = length(modelTransform[0].xy);
                vec2 pickCoord;
                float Y = mix(hex.y, 0.5, pixelation);
                float a = hex.x;
                float a2 = a - PI/6.0;
//                if (abs(a)>2.0*PI/3.0) pickCoord = hex.zw + Y*vec2(0.0, 0.5);
//                else if (a<0.0) pickCoord = hex.zw + Y*0.5*vec2(-SQRT3_2, -0.5);
//                else pickCoord = hex.zw + Y*0.5*vec2(SQRT3_2, -0.5);
                if (a>-5.0*PI/6.0 && a<-PI/6.0) pickCoord = hex.zw + Y*vec2(0.0, -0.5);
                else if (a<=-5.0*PI/6.0 || a>PI_2) pickCoord = hex.zw + Y*0.5*vec2(-SQRT3_2, 0.5);
                else pickCoord = hex.zw + Y*0.5*vec2(SQRT3_2, 0.5);
                v = (modelTransform * vec3(pickCoord, 1.0)).xy;
                return __source__(v);            
            }   
        }
