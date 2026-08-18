float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec4 applyLighting(vec4 baseColor, float fromSource, float specular, vec4 ambientColor, vec4 sourceColor, float gamma) {
    vec3 sumRGB = ambientColor.rgb + sourceColor.rgb;
    float maxLum = max(max (sumRGB.r, sumRGB.g), sumRGB.b);
    if (maxLum == 0.0) return vec4(0.0, 0.0, 0.0, 1.0);

    vec3 color = (baseColor.rgb*ambientColor.rgb + baseColor.rgb*sourceColor.rgb*fromSource + sourceColor.rgb*specular) / maxLum;

    float lum = (color.r+color.g+color.b)/3.0;
    if (lum>0.0 && gamma!=0.0) {
        float gammaCorrectedLum = pow(lum, pow(1.02, -gamma*100.));
        color = color * gammaCorrectedLum/lum;
    }

    return clamp(vec4(color, baseColor.a), 0.0, 1.0);
}

vec4 getBackground(vec2 pos) {
    return vec4(0.0, 0.0, 0.0, 1.0);
}

        vec4 heightMap(vec2 pos, vec2 outPos, float intensity, mat4 model3DTransform, vec2 sourceDim,
            int sourceBkg_specified, int sourceElevation_specified,
            mat4 lightSourceTransform, float colorScheme,
            vec4 sourceColor, vec4 ambientColor, vec4 colorFog,
            float normalSmoothing, float surfaceSmoothness, float specular, float shadows, float gamma) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);

            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            //<ray-dir>
            vec3 dir = vec3(pos.x*D, pos.y*D, -1.0);
            //</ray-dir>
            dir = normalize(mat3(m) * dir);

//            vec3 cameraPos = (inverseModel3DTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
//            vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
//            dir = mat3(inverseModel3DTransform) * dir;

            float maxZ = abs(intensity)*0.02;
            float ratio = (sourceDim.x/sourceDim.y);
            float dk = 2.0/sourceDim.y;
            vec3 step = dir * dk;
            bool heightMap = sourceElevation_specified==1;

            vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

        //    if (dot(dir, lightPos-cameraPos)>length(lightPos-cameraPos)*0.99) return vec4(1.0, 1.0, 1.0, 1.0); // show light source

            float k1 = 0.0;
            float k2 = 100000000.0;

            if (dir.x!=0.0) {
                float s = sign(dir.x);
                float k3 = (-s*ratio-cameraPos.x)/dir.x;
                float k4 = (s*ratio-cameraPos.x)/dir.x;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (dir.y!=0.0) {
                float s = sign(dir.y);
                float k3 = (-s-cameraPos.y)/dir.y;
                float k4 = (s-cameraPos.y)/dir.y;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            float maxZ2 = maxZ+0.0001; // prevent flickering on edge case
            if (dir.z!=0.0) {
                float s = sign(dir.z);
                float k3 = (-s*maxZ2-cameraPos.z)/dir.z;
                float k4 = (s*maxZ2-cameraPos.z)/dir.z;
                k1 = max(k1, k3);
                k2 = min(k2, k4);
            }

            if (k1>k2) return colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(pos) : vec4(0.0, 0.0, 0.0, 1.0);

            float k = k1;
            vec3 p = cameraPos + k*dir;

            vec4 color = backgroundColor;
            float h = 0.0;
            float dz = 0.0;
            float prevDz;
            vec4 prevColor = vec4(0.0, 0.0, 0.0, 1.0);
            float prevH;
            bool stop;
            
            k2 += dk; // eliminates circular banding issue
            if (heightMap) {
                do {
                    prevDz = dz;
                    prevH = h;

                    h = height(intensity, __sourceElevation__(p.xy));
                    dz = p.z-h;

                    p += step;
                    k += dk;
                    stop = dz==0.0 || (k!=k1 && sign(dz)==-sign(prevDz));
                } while (k<=k2 && !stop);
                vec2 pp = (p-step).xy;
                color = __source__(pp);
                prevColor = __source__(pp-step.xy);
            }
            else {
                do {
                    prevColor = color;
                    prevDz = dz;
                    prevH = h;

                    color = __source__(p.xy);
                    h = height(intensity, color);
                    dz = p.z-h;

                    p += step;
                    k += dk;
                    stop = dz==0.0 || (k!=k1 && sign(dz)==-sign(prevDz));
                } while (k<=k2 && !stop);
            }
            
            //stop = stop || abs(dz)<dk; // not needed with k2 += dk;
            
            if (!stop) return colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(pos) : vec4(0.0, 0.0, 0.0, 1.0);

            float kk = (dz==0.0 || k1+dk>k2) ? 1.0 : abs(prevDz)/(abs(dz)+abs(prevDz));
            float hh = mix(prevH, h, kk);
            float hRatio = maxZ==0.0 ? 1.0 : hh/maxZ;
            //if (intensity==0.0) { prevColor = color; kk = 1.0; hh = h; }
            if (colorScheme <=50.0) {
                float darken = 1.0 + colorScheme*0.02*hRatio;
                color = mix(prevColor, color, kk) * vec4(darken, darken, darken, 1.0);
            }
            else {
                float darken = 1.0 + hRatio;
                float kkk = (colorScheme-50.0)*0.02;
                vec4 col = mix(prevColor, color, kk) * vec4(darken, darken, darken, 1.0);
                color = mix(col, vec4(darken*0.5, darken*0.5, darken*0.5, 1.0), kkk);
            }

            //if (stop) return color; else return vec4(vec3(1.0, 0.0, 0.0), 1.0);

            vec3 lightVec = lightPos - p;
            vec3 lightDir = normalize(lightVec);

            float lighting = 1.0;
            float spec = 0.0;
            float shadowing = sourceColor.r + sourceColor.g + sourceColor.b;
            if (shadowing!=0.0) {
                vec3 intersection = p;
                float deltaX = 0.002;
                float deltaY = 0.002;
                float dzdx = 0.0;
                float dzdy = 0.0;
                int maxNormalIter = 6;

                float N = 1.0 + ceil(normalSmoothing/20.0);
                float bx = 0.0005 + normalSmoothing*0.0001;
                float sx = N>=2.0 ? bx/(N-1.0) : 0.0;
                if (!heightMap)
                    for(int i = 0; i<int(N); ++i) {
                        float deltaX = bx+float(i)*sx;
                        dzdx += (height(intensity, __source__(vec2(intersection.x+deltaX, intersection.y)))
                            - height(intensity, __source__(vec2(intersection.x-deltaX, intersection.y))));
                    }
                else
                    for(int i = 0; i<int(N); ++i) {
                        float deltaX = bx+float(i)*sx;
                        dzdx += (height(intensity, __sourceElevation__(vec2(intersection.x+deltaX, intersection.y)))
                            - height(intensity, __sourceElevation__(vec2(intersection.x-deltaX, intersection.y))));
                    }

                dzdx /= N;
                deltaX = bx+(N-1.0)/2.0*sx;

                float by = 0.0005 + normalSmoothing*0.0001;
                float sy = N>=2.0 ? by/(N-1.0) : 0.0;

                if (!heightMap)
                    for(int i = 0; i<int(N); ++i) {
                        float deltaY = by+float(i)*sy;
                        dzdy = (height(intensity, __source__(vec2(intersection.x, intersection.y+deltaY)))
                           - height(intensity, __source__(vec2(intersection.x, intersection.y-deltaY))));
                    }
                else
                    for(int i = 0; i<int(N); ++i) {
                        float deltaY = by+float(i)*sy;
                        dzdy = (height(intensity, __sourceElevation__(vec2(intersection.x, intersection.y+deltaY)))
                           - height(intensity, __sourceElevation__(vec2(intersection.x, intersection.y-deltaY))));
                    }

                dzdy /= N;
                deltaY = by+(N-1.0)/2.0*sy;

                vec3 unormal = vec3(-2.0*deltaY*dzdx, -2.0*deltaX*dzdy, deltaX*deltaY);
                vec3 normal = (unormal.x==0.0 && unormal.y==0.0 && unormal.z==0.0) ? vec3(0.0, 0.0, 1.0) : normalize(unormal);

                lighting = (dot(lightDir, normal)+1.0)/2.0;

                if (surfaceSmoothness<100.0) {
                    if (lighting<0.5) lighting = pow(lighting*2.0, 100.0/surfaceSmoothness) / 2.0;
                    else lighting = pow((lighting-0.5)*2.0, 0.01*surfaceSmoothness) / 2.0 + 0.5;
                }

                if (specular!=0.0) {
                    vec3 reflectLightDir = reflect(lightDir, normal);
                    spec = (specular<25.0?specular*0.04:1.0) * pow(clamp(dot(dir, reflectLightDir), 0.0, 1.0), 10.0-specular*0.1);
                }
            }

            float kFog = length(cameraPos - p);


            float shad = shadows;
            if (shadowing!=0.0 && shad > 0.0 && intensity!=0.0) {
                p = p-2.0*step; // avoid intersecting immediately
                vec3 lightStep = lightDir * dk;

                k1 = 0.0;
                float k2 = length(lightVec);

                if (lightDir.x!=0.0) {
                    float s = sign(lightDir.x);
                    float k3 = (-s*ratio-p.x)/lightDir.x;
                    float k4 = (s*ratio-p.x)/lightDir.x;
                    if (k4>0.0) k2 = min(k2, k4);
                    if (k3>0.0) k2 = min(k2, k3);
                }

                if (lightDir.y!=0.0) {
                    float s = sign(lightDir.y);
                    float k3 = (-s-p.y)/lightDir.y;
                    float k4 = (s-p.y)/lightDir.y;
                    if (k4>0.0) k2 = min(k2, k4);
                    if (k3>0.0) k2 = min(k2, k3);
                }

                float maxZ2 = maxZ+0.0001; // prevent flickering on edge case
                if (lightDir.z!=0.0) {
                    float s = sign(lightDir.z);
                    float k3 = (-s*maxZ2-p.z)/lightDir.z;
                    float k4 = (s*maxZ2-p.z)/lightDir.z;
                    if (k4>0.0) k2 = min(k2, k4);
                    if (k3>0.0) k2 = min(k2, k3);
                }

                k = 0.0;

                h = 0.0;
                dz = 0.0;
                stop = false;

                if (heightMap) {
                    do {
                        prevDz = dz;
                        prevH = h;

                        h = height(intensity, __sourceElevation__(p.xy));
                        dz = p.z-h;

                        p += lightStep;
                        k += dk;
                        stop = dz==0.0 || (k!=k1 && sign(dz)==-sign(prevDz));
                    } while (k<=k2 && !stop);
                }
                else {
                    do {
                        prevDz = dz;
                        prevH = h;

                        h = height(intensity, __source__(p.xy));
                        dz = p.z-h;

                        p += lightStep;
                        k += dk;
                        stop = dz==0.0 || (k!=k1 && sign(dz)==-sign(prevDz));
                    } while (k<=k2 && !stop);
                }


                if (stop) {
                    lighting = min(1.0-shadows, lighting);
                    spec = 0.0;
                }
            }

            color = applyLighting(color, lighting, spec, ambientColor, sourceColor, gamma);

             if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                kFog = smoothstep(nearDist, farDist, kFog); //1.0 - pow(0.4, colorFog.a * max(0.0, kFog-0.1));
                color.rgb = mix(color.rgb, colorFog.rgb, kFog);
            }

            return clamp(color, 0.0, 1.0);
        }
