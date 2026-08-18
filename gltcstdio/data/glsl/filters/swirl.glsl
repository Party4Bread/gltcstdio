vec2 getCenter(vec2 o, vec2 u) {
    float a = dot(o, o) - 1.0;
    float b = -2.0*dot(o, u) + 2.0;
    float c = dot(u, u) - 1.0;
    float delta = b*b - 4.0*a*c;
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        if (l1>=0.0 && l1<=1.0) return l1*o;
        else if (l2>=0.0 && l2<=1.0) return l2*o;
    }
    return vec2(INF, INF);
}

vec4 swirl(vec2 pos, vec2 outPos, mat3 modelTransform, mat3 centerTransform, float intensity, float power, float dampening, vec4 highFreqColor) {
            vec2 u = (inverse(modelTransform) * vec3(pos, 1.0)).xy;
        
            float d = length(u);
        
            if (d>=1.0) {
                return __source__(pos);
            }
            else {        
        //        float dangle = sign(intensity) * smoothstep(1.0, mix(0.9, -4.0, dampening), d) * 0.5/pow(d, abs(intensity)*0.04);
                //float dangle = (d==0.0) ? 0.0 : intensity * pow(d, power) * smoothstep(1.0, 0.0, d);//smoothstep(1.0, mix(0.9, -4.0, dampening), d) * intensity*5.0/pow(d, mix(0.01, 1.6, power));
        
                /////
                vec2 centerMax = (centerTransform*vec3(0.0, 0.0, 1.0)).xy;
                vec2 center = getCenter(centerMax, u);
                if (center.x==INF) return __source__(pos);
                float d2 = length(u-center);
//                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), d2) * intensity/pow(d2, mix(0.01, 1.6, power*0.01));
//                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), d2) * intensity/pow(d2, mix(-10., 10., power*0.01));
                float dangle = smoothstep(1.0, mix(0.9, -4.0, dampening), d2) * intensity * pow(d2, -power); 
                /////
        
                float ca = cos(dangle);
                float sa = sin(dangle);
                u -= center;
                vec2 rotated = vec2(ca*u.x - sa*u.y, ca*u.y + sa*u.x)+center;
                //u += center;
        
                float darken = 0.0;
                if (highFreqColor.a!=0.0) {
                    darken = smoothstep(0.75*highFreqColor.a, 0.0, d2);
                }
                vec2 coord = (modelTransform * vec3(rotated, 1.0)).xy;
                vec4 col = __source__(coord);
        //        if (darken!=0.0) {
        //            vec4 hsl = RGBtoHSL(col);
        //            hsl.z *= (1.0-darken);
        //            return HSLtoRGB(hsl);
        //        } else return col;
                return mix(col, vec4(highFreqColor.rgb, col.a), darken);
            }
        }
