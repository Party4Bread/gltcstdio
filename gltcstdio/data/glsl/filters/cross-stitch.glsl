bool isHor(vec2 id, float mode) {
                int m = int(mode);
                float a = float(m%4+1);
                m/=4; float b =float(m%4+1); 
                m/=4; float c =float(m%4+1);
                m/=4; float d =float(m%4+1); //256
                m/=4; float e =float(m%4+2);
                m/=4; float f =float(m%4+1);
                m/=4; float g =float(m%4+1);
                m/=4; float h =float(m%4+1); // 65536
                m/=4; float i =float(m%4+2)*3.;
                m/=4; float j =float(m%4+2)*3.;
                m/=4; float k =float(m%4+1);
                
                return mod(floor(id.x/a)+floor(id.y/b), e+mod(id.y, g)) == mod(floor(id.x/i)+floor(id.y/j), k)*mod(floor(id.x/c)+floor(id.y/d), f+mod(id.x, h));
////                float kx = mod(mode, 2.0) + 1.0;
////                mode /= 2.0; float ky = mod(mode, 2.0) + 1.0;
////                mode /= 2.0; float a = mod(mode, 4.0) ;
////                mode /= 4.0; float b = mod(mode, 4.0) ;
////                
////                return mod(kx*id.x + ky*id.y, 2.+mod(mod(a*id.y, 5.) + mod(b*id.x, 5.), 2.)) == 0.0;
//                float rem = mod(mode, 2.0);
//                mode /= 2.;
//                bool r = false;
//                if (mode==0.) r = mod(id.x+id.y, 2.) == 0.0;
//                else if (mode==1.) r = mod(id.x+id.y, 3.) == 0.0;
//                else if (mode==2.) r = mod(id.x+id.y, 4.) == 0.0;
//                else if (mode==3.) r = mod(id.x+id.y, 5.) == 0.0;
//                else if (mode==4.) r = mod(id.x*2.+id.y, 2.) == 0.0;
//                else if (mode==5.) r = mod(id.x+id.y*2., 2.) == 0.0;
//                else if (mode==6.) r = mod(id.x*2.+id.y, 3.) == 0.0;
//                else if (mode==7.) r = mod(id.x+id.y*2., 3.) == 0.0;
//                else if (mode==8.) r = mod(id.x*2.+id.y, 4.) == 0.0;
//                else if (mode==9.) r = mod(id.x+id.y*2., 4.) == 0.0;
//                else if (mode==10.) r = mod(id.x*2.+id.y, 5.) == 0.0;
//                else if (mode==11.) r = mod(id.x+id.y*2., 5.) == 0.0;
//                else if (mode==12.) r = mod(id.x+id.y, 2.+mod(id.y, 2.)) == 0.0;
//                else if (mode==13.) r = mod(id.x+id.y, 2.+mod(id.x, 2.)) == 0.0;
//                else if (mode==14.) r = mod(id.x+id.y, 2.+mod(id.y, 3.)) == 0.0;
//                else if (mode==15.) r = mod(id.x+id.y, 2.+mod(id.x, 3.)) == 0.0;
//                
//                return rem==0.0 ? r : !r;                
            }

bool isHor2(vec2 id, float a, float b, float c, float d, float e, float f, float g, float h, float i, float j, float k) {                
    return mod(floor(id.x*a)+floor(id.y*b), e+mod(id.y, g)) == mod(floor(id.x*i)+floor(id.y*j), k)*mod(floor(id.x*c)+floor(id.y*d), f+mod(id.x, h));
}

float shade(float shadow, float dist) {
    return smoothstep(shadow, shadow*0.35, dist);
}

float getThick(float x, float thickness, float var, float seed) {
    if (var==0.0) return thickness;
    vec2 k = rand2relSeeded(vec2(x, x), seed) +.5;
    return mix(thickness*(1.-var), mix(thickness, 0.5, var), k.x);
}

vec4 crossStitch(vec2 uv, vec2 outPos, int mode1, int mode2, vec4 hColor, vec4 vColor, vec4 hBorderColor, vec4 vBorderColor, vec4 colorShadow, vec4 colorBkg, float randomSeed, float variability, float thickness, float shadows) {
    thickness *= 0.5;
    
    vec2 id = floor(uv);
    float mo = float(mode1) + float(mode2)*4096.;
                int m = int(mo);
                float pa = 1./float(m%4+1);
                m/=4; float pb =1./float(m%4+1); 
                m/=4; float pc =1./float(m%4+1);
                m/=4; float pd =1./float(m%4+1); //256
                m/=4; float pe =float(m%4+2);
                m/=4; float pf =float(m%4+1);
                m/=4; float pg =float(m%4+1);
                m/=4; float ph =float(m%4+1); // 65536
                m/=4; float pi =1./float(m%4+2)*3.;
                m/=4; float pj =1./float(m%4+2)*3.;
                m/=4; float pk =float(m%4+1);

    float thickVar = variability;
    float thicknessX = getThick(id.x, thickness, thickVar, randomSeed);
    float thicknessY = getThick(id.y, thickness, thickVar, randomSeed);
    float shadow = 0.5;

    vec2 u = fract(uv) - .5;
    vec2 unit = vec2(1.0, 0.0);

//    float top = (isHor(id+unit.yx, mo)) ? getThick(id.y+1.0, thickness, thickVar, randomSeed) : -1.0;
//    float bottom = (isHor(id-unit.yx, mo)) ? getThick(id.y-1.0, thickness, thickVar, randomSeed) : -1.0;
//    float right = (!isHor(id+unit, mo)) ? getThick(id.x+1.0, thickness, thickVar, randomSeed) : -1.0;
//    float left = (!isHor(id-unit, mo)) ? getThick(id.x-1.0, thickness, thickVar, randomSeed) : -1.0;
//
//    vec3 cc = crissCross(u, thicknessX, thicknessY, isHor(id, mo), top, right, bottom, left);
    float top = (isHor2(id+unit.yx, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.y+1.0, thickness, thickVar, randomSeed) : -1.0;
    float bottom = (isHor2(id-unit.yx, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.y-1.0, thickness, thickVar, randomSeed) : -1.0;
    float right = (!isHor2(id+unit, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.x+1.0, thickness, thickVar, randomSeed) : -1.0;
    float left = (!isHor2(id-unit, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk)) ? getThick(id.x-1.0, thickness, thickVar, randomSeed) : -1.0;

    vec3 cc = crissCross(u, thicknessX, thicknessY, isHor2(id, pa, pb, pc, pd, pe, pf, pg, ph, pi, pj, pk), top, right, bottom, left);

    vec4 col = colorBkg;

    if (cc.x==1.0) { // vertical ribbon
        col = hColor;
        if (abs(cc.z)>thicknessX*.8) col = mergeColor(hColor, hBorderColor);
    }
    else if (cc.x==0.0) { // horizontal ribbon
        col = vColor;
        if (abs(cc.z)>thicknessY*.8) col = mergeColor(vColor, vBorderColor);
    }
    if (cc.x!=-1.0) {
        col = mergeColor(col, vec4(colorShadow.rgb, colorShadow.a * shade(shadows, cc.y)));
    }

    return col;
}
