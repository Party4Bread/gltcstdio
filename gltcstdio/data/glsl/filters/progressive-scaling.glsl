vec4 getUnitColor(vec2 u) {
    float k = 0.0;
    vec2 v = u*10.0 - round(u*10.0);
    if (u.x>=0.0&&u.x<0.1 && u.y>=0.0&&u.y<0.1) k = 0.75;
    if (u.x>=0.0&&u.x<0.1 && u.y>=0.9&&u.y<1.) k = 0.75;
    if (u.x>=0.9&&u.x<1. && u.y>=0.0&&u.y<0.1) k = 0.75;
    if (u.x>=0.9&&u.x<1. && u.y>=0.9&&u.y<1.) k = 0.75;
    k = max(k, max(smoothstep(0.03, 0.02, abs(v.x)), smoothstep(0.03, 0.02, abs(v.y))));
    vec4 col = vec4(u.x, u.y, 0.5, 1.);
    if (abs(u.x-0.5)>0.5 || abs(u.y-0.5)>0.5) col.rgb *= 0.25;
    return mix(col, vec4(1.0), k);
}

vec4 progressiveScaling(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, int backgroundMode, float balance, float power, float offset, float colorScheme, mat3 texTransform) {
            if (mode>=100) { 
                uv = vec2(atan(uv.x, uv.y)/PI, length(uv));
                mode -= 100;
            }
            vec2 ar = vec2(sourceDim.x / sourceDim.y, 1.);
            
            bool inside = true;
            
            if (mode==0){
                float N = 200.;
                float S = 1.0;
                if (backgroundMode==1) uv.y = abs(uv.y);
                float y = -uv.y;
                float E = power;
                inside = false;
                if (y>0.0) {
                    //uv = uv*2.0 + ar;
                    uv = (outPos+1.0)*.5;
                }
                else {
                    float Y = 0.0;
                    for(float i=0.0; i<N; ++i) {
                        //float j = 2.*(i+2.);
                        float j = (i+3.);
                        Y += S/pow(j, E);
                        //if (abs(uv.y+Y)<0.02) { col = vec4(1.0); break; }
                        //if (y>-Y) { uv = ar + (uv-Y)*j*vec2(0.5,1./S); break; }
                        float sy = mix(pow(j, E)/S, Y*.5, balance);
                        if (y>-Y) { uv = ar + (uv-Y)*vec2(0.5*j, pow(j, E)/S); inside = true; break; }
                    }
                }
                uv.x += offset;
                uv = fract(uv);
            }
            else if (mode==1) {
//                float Y = floor(uv.y);
//                float circum = (Y+0.5) * 2. * PI;
//                float N = round(circum / 5.);
//                float sy = mix(1., Y*.5, balance);
//                uv = vec2(uv.x * N*.5, (uv.y - Y)*sy);
//                uv.x += offset;// * pow(Y, 0.8);
//                uv = fract(uv);
                
                float E = max(0.001, abs(power)) + 1.; // mirror around 1 and always ensure power!=1 as that is a singularity
                float S = 1./(1.-1./E);
                float y = backgroundMode==1 ? mir(uv.y, S) : uv.y;
                if (y>=0.0 && y<=S) {
                    float Y = floor(log((S-y)/S) / log(1./E));
//                    float ly = pow(E, -Y); // "glitchy" alternative: Y*.5;
                    float ly = mix(pow(E, -Y), Y*.5, balance); // "glitchy" alternative: Y*.5;
                    float y1 = S - S*ly;
                    float circum = (Y+0.5) * 2. * PI;
                    float N = round(circum / 5.);
                    uv = vec2(uv.x * N, (y - y1)/ly);
                    uv.x += offset;// * pow(Y, 0.8);
                    uv = fract(uv);
                }
                else {
                    inside = false;
                    uv = (outPos+1.0)*.5;
                }
            }
            else if (mode==2) {
                float E = max(0.001, abs(power)) + 1.; // mirror around 1 and always ensure power!=1 as that is a singularity
                float S = 1./(1.-1./E);
                float y = backgroundMode==1 ? mir(uv.y, S) : uv.y;
                if (y>=0.0 && y<=S) {
                    float Y = floor(log((S-y)/S) / log(1./E));
//                    float ly = pow(E, -Y); // "glitchy" alternative: Y*.5;
                    float ly = mix(pow(E, -Y), Y*.5, balance); // "glitchy" alternative: Y*.5;
                    float y1 = S - S*ly;
                    float N = pow(2., Y);
                    uv = vec2(uv.x * N, (y - y1)/ly);
                    uv.x += offset;// * pow(Y, 0.8);
                    uv = fract(uv);
                }
                else {
                    inside = false;
                    uv = (outPos+1.0)*.5;
                }
            }
        
        
            float kCol = colorScheme==1.0 ? 1.0 : fract(colorScheme * 5.);
            vec4 col1 = getUnitColor(uv);

            vec2 uv2 = (uv*2.0-1.0) * ar;
            uv2 = tf(inverse(texTransform), uv2);
            vec4 col3 = __source__(uv2);

            uv = tf(inverse(texTransform), uv);
            float g = fract(uv.x)<0.5 ? 1.0 : 0.0;
            float r = fract(uv.y);

            vec4 col2 = vec4(vec3(r, g, 0.5), 1.);
            vec4 col4 = vec4(vec3(g>0.5 ? 1.0 : 0.0), 1.);
            vec4 colSlopedThenGrad = vec4(vec3(kCol<=0.5 ? (uv.x-.5 > kCol*2.*(uv.y-.5) ? 0.0 : 1.0) : (kCol-0.5) + 0.25*((uv.y)/(kCol-.5)-(uv.x)/(kCol-.5))), 1.);

            
            vec4 colBorder = (abs(uv.x-0.5)>0.4 || abs(uv.y-0.5)>0.4) ? vec4(0., 0., 0., 1.) : col3; 
            
            vec4 resCol;
            if (colorScheme<0.2) resCol = mix(col3, colBorder, kCol);
            else if (colorScheme<0.4) resCol = mix(colBorder, col1, kCol);
            else if (colorScheme<0.6) resCol = mix(col1, col2, kCol);
            else if (colorScheme<0.8) resCol = mix(col2, col4, kCol);
            else resCol = colSlopedThenGrad;          
              
            if (inside || backgroundMode<=1) return resCol;
            else if (backgroundMode==2) return vec4(0., 0., 0., 1.);
            else if (backgroundMode==3) return vec4(1.);
            else return __source__(outPos);
        }
