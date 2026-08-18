vec4 iteratedShape(vec2 uv, vec2 outPos, int insideImage_specified,
                int shape, int iterations,
                float shadows, float roundness, float multiplier,
                float brightness, float contrast, float saturation, float hue,
                vec4 colorIn, vec4 colorOut, vec4 colorShadow, vec4 colorGlow, 
                int insideLock, mat3 modelTransform, mat3 insideTransform) {
            
            vec2 u = tf(inverse(modelTransform), uv);
            
            mat3 targetTransform = insideLock==0 ? inverse(modelTransform)*insideTransform : insideTransform;
            vec2 iTranslation = targetTransform[2].xy;
            vec2 iScale = vec2(length(targetTransform[0].xy), length(targetTransform[1].xy));
            float iRotation = atan(targetTransform[0].y/iScale.x, targetTransform[0].x/iScale.x);
            float ik = 1.0/float(iterations);
            float ikRot = iRotation * ik; 
//            targetTransform = mat3(mat2(pow(iScale.x, ik), 0.0, 0.0, pow(iScale.y, ik)) * mat2(cos(ikRot), sin(ikRot), -sin(ikRot), cos(ikRot)));
            targetTransform = mat3(pow(iScale.x, ik), 0.0, 0.0, 0.0, pow(iScale.y, ik), 0.0, 0.0, 0.0, 1.0) * mat3(cos(ikRot), sin(ikRot), 0.0, -sin(ikRot), cos(ikRot), 0.0, 0.0, 0.0, 1.0);
            targetTransform[2] = vec3(iTranslation*ik, 1.0);
            targetTransform = inverse(targetTransform);
     
            
            float d = 0.0;
            float shadow = 0.0;
            vec4 tint = vec4(0.0);
            vec2 v = uv;
            bool inside = false;
            
            int i = 0;
            for(; i<iterations; ++i) {

                if (shape==0) {
                    d = sdRectangle(u, dimFromShapeAspectRatio(0.8, 1.0));
                }
                else if (shape==1) {
                    d = sdDisk(u, 0.8);     
                }
                else if (shape==2) {
                    d = sdEquiTriangle(u*1.0);     
                }
                else if (shape==3) {
                    d = sdHeart(vec2(u.x*0.66, 0.5-u.y*0.66));     
                }
                else if (shape==4) {
                    d = sdVesica(u, 0.9, mix(0.7, 0.0, 0.6));
                }
                else if (shape==5) {
                    d = sdNgon(u, 0.8, 4);
                }
                else if (shape==6) {
                    d = sdStar(vec2(u.x, -u.y), 5, 0.75, 2.0 + 0.35*(5.0-2.0));
                }
                else if (shape==7) {
                    d = sdNgon(vec2(u.x, -u.y), 0.8, 5);
                }
                else if (shape==8) {
                    d = sdNgon(u, 0.8, 6);
                }
                else if (shape==9) {
                    d = sdStar(vec2(u.x, -u.y), 24, 0.75, 2.0 + 0.18*(24.0-2.0));
                }
                d = d*multiplier - roundness;
                
                bool inside = d<=0.0;
                 
                if (inside) {
                    if (shadows<0.0) shadow = 0.7*smoothstep(shadows, 0., d);
                    u = tf(targetTransform, u);
                    v = u;
                }
                else {
                    if (shadows>0.0) shadow = 0.7*smoothstep(shadows, 0., d);
                    break;
                }
            }

            float insideK = (float(i) + (inside ? 1.0 : 0.0)) * ik;
            insideK = pow(insideK, 0.5);
            
            tint =  mix(colorOut, colorIn, insideK);
            
            vec4 color = (insideImage_specified==1 && inside) ? __insideImage__(v) : __source__(v);
            color = adjustColorHSLuv(color, brightness*insideK, mix(1.0, contrast, insideK), 0.0, 0.0, saturation*insideK, hue*insideK, vec4(0.0));
            vec4 glow = (colorGlow.a!=0.0) ? vec4(colorGlow.rgb * 0.01/abs(d), min(1.0, colorGlow.a* 0.01/abs(d))) : vec4(0.);           
            return mergeGlow(mergeColor(mergeColor(color, tint), vec4(colorShadow.rgb, colorShadow.a*shadow)), glow);
        }
