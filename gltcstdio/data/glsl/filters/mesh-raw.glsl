#define SMALL_NUM 0.00001

vec3 backgroundDirect(vec3 dir, vec2 outPos, vec2 sourceBkgDim, int backgroundMode) {
    if (backgroundMode==1) return planeMap(dir, sourceBkgDim);
    else if (backgroundMode==2) return boxMap(dir, sourceBkgDim);
    else if (backgroundMode==3) return vec3(outPos, 1.);
    else return sphereMap(dir, sourceBkgDim);
}

vec3 backgroundForReflection(vec3 dir, vec2 sourceBkgDim, int backgroundMode) {
    if (backgroundMode == 1) return planeMap(dir, sourceBkgDim);
    else if (backgroundMode == 2) return boxMap(dir, sourceBkgDim);
    else return sphereMap(dir, sourceBkgDim);
}

vec3 boxMap(vec3 dir, vec2 sourceBkgDim) {
    float ratio = (sourceBkgDim.y/sourceBkgDim.x);
    float X = 0.5;
    float Y = 0.5;
    if (abs(dir.y)>abs(dir.z)*ratio && abs(dir.y)>abs(dir.x)*ratio) {
        X += -dir.x/dir.y*0.5;
        Y += -dir.z/dir.y*0.5;
    }
    else if (abs(dir.x)<abs(dir.z)) {
        X += dir.x/abs(dir.z)*ratio*0.5 * -sign(dir.z);
        Y += dir.y/abs(dir.z)*0.5;
    }
    else {
        X += dir.z/abs(dir.x)*ratio*0.5 * -sign(dir.x);
        Y += dir.y/abs(dir.x)*0.5;
    }
    return vec3(X, Y, 1.0);
}

float distSegSeg(vec3 S1P0, vec3 S1P1, vec3 S2P0, vec3 S2P1) {
    vec3 u = S1P1 - S1P0;
    vec3 v = S2P1 - S2P0;
    vec3 w = S1P0 - S2P0;
    float a = dot(u,u);         // always >= 0
    float b = dot(u,v);
    float c = dot(v,v);         // always >= 0
    float d = dot(u,w);
    float e = dot(v,w);
    float D = a*c - b*b;        // always >= 0
    float sc, sN, sD = D;       // sc = sN / sD, default sD = D >= 0
    float tc, tN, tD = D;       // tc = tN / tD, default tD = D >= 0

    // compute the line parameters of the two closest points
    if (D < SMALL_NUM) { // the lines are almost parallel
        sN = 0.0;         // force using point P0 on segment S1
        sD = 1.0;         // to prevent possible division by 0.0 later
        tN = e;
        tD = c;
    }
    else {                 // get the closest points on the infinite lines
        sN = (b*e - c*d);
        tN = (a*e - b*d);
        if (sN < 0.0) {        // sc < 0 => the s=0 edge is visible
            sN = 0.0;
            tN = e;
            tD = c;
        }
        else if (sN > sD) {  // sc > 1  => the s=1 edge is visible
            sN = sD;
            tN = e + b;
            tD = c;
        }
    }

    if (tN < 0.0) {            // tc < 0 => the t=0 edge is visible
        tN = 0.0;
        // recompute sc for this edge
        if (-d < 0.0)
            sN = 0.0;
        else if (-d > a)
            sN = sD;
        else {
            sN = -d;
            sD = a;
        }
    }
    else if (tN > tD) {      // tc > 1  => the t=1 edge is visible
        tN = tD;
        // recompute sc for this edge
        if ((-d + b) < 0.0)
            sN = 0.0;
        else if ((-d + b) > a)
            sN = sD;
        else {
            sN = (-d +  b);
            sD = a;
        }
    }
    // finally do the division to get sc and tc
    sc = (abs(sN) < SMALL_NUM ? 0.0 : sN / sD);
    tc = (abs(tN) < SMALL_NUM ? 0.0 : tN / tD);

    // get the difference of the two closest points
    vec3 dP = w + (sc * u) - (tc * v);  // =  S1(sc) - S2(tc)

    return length(dP);   // return the closest distance
}

float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec3 planeMap(vec3 dir, vec2 sourceBkgDim) {
    vec2 pos = vec2(-dir.x/dir.z * sourceBkgDim.y/sourceBkgDim.x, -dir.y/dir.z)*0.5 + vec2(0.5, 0.5);
    float m = max(abs(pos.x), abs(pos.y));
    float darken = 4.0/max(4.0, m);
    return vec3(pos, darken);
}

vec3 sphereMap(vec3 dir, vec2 sourceBkgDim) {
    vec3 n = normalize(dir);
    float alpha = atan(n.x, n.z);
    float beta = asin(n.y);
    float nX = 1.0;
    float nY = 1.0;
    return vec3(-alpha/3.14159265359 * nX, 0.5 + nY * beta/3.14159265359, 1.0);
}

        vec4 mesh3d(vec2 pos, vec2 outPos, float intensity, int rezolution, 
            float thickness, float glow, float specular, float normalSmoothing,
            mat4 model3DTransform, vec2 sourceDim, vec2 sourceBkgDim, vec2 sourceElevationDim, 
            int sourceBkg_specified, int sourceElevation_specified,
            int backgroundMode, float colorScheme, float reflectivity,
            vec4 colorBkg, vec4 colorLines, vec4 colorFog, vec4 colorSource, vec4 colorAmbient
    ) {

            //vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
        
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
        
            bool heightMap = sourceElevation_specified==1;
        
            float maxZ = abs(intensity)*0.02;
            float ratio =  heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
            //float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;
            //vec3 step = dir * dk;
        
            float squareSize = 2.0/float(rezolution);
            maxZ += squareSize;
            float surfaceWidth = round((2.0*ratio)/squareSize)*squareSize;
            float surfaceHeight = 2.0;
        
            float k1 = 0.0;
            float k2 = 100000000.0;
            
            if (dir.x!=0.0) {
                float s = sign(dir.x);
                float k3 = (-s*surfaceWidth/2.0-cameraPos.x)/dir.x;
                float k4 = (s*surfaceWidth/2.0-cameraPos.x)/dir.x;
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
        
        
            float k = k1;
            vec3 p = cameraPos + k*dir;
        
            vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
            if (sourceBkg_specified==1) {
                vec3 bkgDir = backgroundDirect(dir, outPos, sourceBkgDim, backgroundMode);
                color = __sourceBkg__(bkgDir.xy) * vec4(vec3(bkgDir.z), 1.0); 
            }
            
            if (k1>k2) return colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.) : color;
            //float h = 0.0;
            //float dz = 0.0;
            //float prevDz;
            //vec4 prevColor;
            //float prevH;
            //bool stop;
        
            //float strideX = sign(dir.x) * squareSize;
            //float strideY = sign(dir.y) * squareSize;
        
            float intersectDist = 1e9;
            float intersected = 0.0;
        
            vec4 outColor = color; //backgroundColor;
            vec2 nextLines = sign(dir.xy)*squareSize/2.0; //vec2(sign(dir.x)*squareSize, sign(dir.y)*squareSize)/2.0;
        int maxIter = 1000;
            float frameDist = 1e10;
        
            while (intersected<1.0 && k<=k2 && maxIter>0) {
                // compute pixel center
                float indexX = (p.x+surfaceWidth/2.0)/squareSize;
                float indexY = (p.y+surfaceHeight/2.0)/squareSize;
                float fX = fract(indexX);
                float fY = fract(indexY);
                vec2 squareCenter;
        
                if (fX>0.9999 && dir.x>0.0) squareCenter.x = (ceil(indexX)+0.5)*squareSize;
                else if (fX<0.0001 && dir.x<0.0) squareCenter.x = (floor(indexX)-0.5)*squareSize;
                else
                squareCenter.x = (floor(indexX)+0.5)*squareSize;
                squareCenter.x -= surfaceWidth/2.0;
        
                if (fY>0.9999 && dir.y>0.0) squareCenter.y = (ceil(indexY)+0.5)*squareSize;
                else if (fY<0.0001 && dir.y<0.0) squareCenter.y = (floor(indexY)-0.5)*squareSize;
                else
                squareCenter.y = (floor(indexY)+0.5)*squareSize;
                squareCenter.y -= surfaceHeight/2.0;
        //        squareCenter = p;
        
                if (abs(squareCenter.x)<surfaceWidth/2.0 && abs(squareCenter.y)<surfaceHeight/2.0) {
                    vec2 bottomLeft = squareCenter - vec2(squareSize, squareSize)/2.0;
        
                    // compute triangles intersection
                    mat3 intersection;
                        // compute height and color
    vec2 s = vec2(squareSize, 0.0);
    vec2 p11 = bottomLeft+s.xx;

    vec4 c00 = heightMap ? __sourceElevation__(bottomLeft): __source__(bottomLeft);
    float h00 = height(intensity, c00);
    vec3 A = vec3(bottomLeft, h00);

    vec4 c10 = heightMap ? __sourceElevation__(bottomLeft+s): __source__(bottomLeft+s);
    float h10 = height(intensity, c10);
    vec3 B = vec3(bottomLeft+s, h10);

    vec4 c01 = heightMap ? __sourceElevation__(bottomLeft+s.yx): __source__(bottomLeft+s.yx);
    float h01 = height(intensity, c01);
    vec3 C = vec3(bottomLeft+s.yx, h01);

    vec4 c11 = heightMap ? __sourceElevation__(p11): __source__(p11);
    float h11 = height(intensity, c11);
    vec3 D = vec3(p11, h11);

    vec3 inf = p + 1e6 * dir;
    float _frameDist = thickness==0.0 ? 1e9 : min(
        min(distSegSeg(p, inf, A, B), distSegSeg(p, inf, C, D)),
        min(distSegSeg(p, inf, A, C), distSegSeg(p, inf, B, D)) );

    float dzx1 = (h10-h00)/squareSize;
    float dzy1 = (h01-h00)/squareSize;
    float k1 = (h00-p.z + (p.x-bottomLeft.x)*dzx1 + (p.y-bottomLeft.y)*dzy1) / (dir.z - dir.x*dzx1 - dir.y*dzy1);

    float dzx2 = -(h01-h11)/squareSize;
    float dzy2 = -(h10-h11)/squareSize;
    float k2 = (h11-p.z + (p.x-p11.x)*dzx2 + (p.y-p11.y)*dzy2) / (dir.z - dir.x*dzx2 - dir.y*dzy2);

    vec3 normal = vec3(0.0, 0.0, 0.0);
    vec3 _intersection = vec3(INF, INF, INF);

    intersection = mat3(vec3(INF, INF, INF), vec3(0.0, 0.0, 0.0), vec3(_frameDist, 0.0, 0.0));
    
    if (k1>0.0) {
        _intersection = p + k1*dir;
        vec2 relInt = _intersection.xy-bottomLeft.xy;
        if (relInt.x>=0.0 && relInt.x<=squareSize && relInt.y>=0.0 && relInt.y<=squareSize
            && squareSize-relInt.x>=relInt.y) {
//            normal = normalize(cross(vec3(squareSize, 0.0, h10-h00), vec3(0.0, squareSize, h01-h00)));
            normal = normalize(mix(normalize(cross(vec3(squareSize, 0.0, h10-h00), vec3(0.0, squareSize, h01-h00))), normalize(cross(vec3(-squareSize, 0.0, h01-h11), vec3(0.0, -squareSize, h10-h11))), 0.5));
            if (normalSmoothing!=0.0) {
                float deltaX = 0.0005;
                float dzdx, dzdy;
                if (!heightMap)
                    dzdx = (height(intensity, __source__(vec2(_intersection.x+deltaX, _intersection.y)))
                       - height(intensity, __source__(vec2(_intersection.x-deltaX, _intersection.y))));
                else
                    dzdx = (height(intensity, __sourceElevation__(vec2(_intersection.x+deltaX, _intersection.y)))
                       - height(intensity, __sourceElevation__(vec2(_intersection.x-deltaX, _intersection.y))));
                
                float deltaY = 0.0005;
                if (!heightMap)
                    dzdy = (height(intensity, __source__(vec2(_intersection.x, _intersection.y+deltaY)))
                       - height(intensity, __source__(vec2(_intersection.x, _intersection.y-deltaY))));
                else
                    dzdy = (height(intensity, __sourceElevation__(vec2(_intersection.x, _intersection.y+deltaY)))
                       - height(intensity, __sourceElevation__(vec2(_intersection.x, _intersection.y-deltaY))));
                
                vec3 unormal = vec3(0.5*dzdx/deltaX, 0.5*dzdy/deltaY, 1.0);
                vec3 smoothNormal =  (unormal.x==0.0 && unormal.y==0.0 && unormal.z==0.0) ? vec3(0.0, 0.0, 1.0) : normalize(unormal);
                normal = mix(normal, smoothNormal, normalSmoothing);
            }
            intersection =  mat3(_intersection, normal, vec3(frameDist, 0.0, 0.0));
        }
    }
    if (k2>0.0) {
        _intersection = p + k2*dir;
        vec2 relInt = _intersection.xy-bottomLeft.xy;
        if (relInt.x>=0.0 && relInt.x<=squareSize && relInt.y>=0.0 && relInt.y<=squareSize
        && squareSize-relInt.x<=relInt.y) {
//            normal = normalize(cross(vec3(-squareSize, 0.0, h01-h11), vec3(0.0, -squareSize, h10-h11)));
            normal = normalize(mix(normalize(cross(vec3(squareSize, 0.0, h10-h00), vec3(0.0, squareSize, h01-h00))), normalize(cross(vec3(-squareSize, 0.0, h01-h11), vec3(0.0, -squareSize, h10-h11))), 0.5));
            if (normalSmoothing!=0.0) {
                float deltaX = 0.0005;
                float dzdx, dzdy;
                if (!heightMap)
                    dzdx = (height(intensity, __source__(vec2(_intersection.x+deltaX, _intersection.y)))
                       - height(intensity, __source__(vec2(_intersection.x-deltaX, _intersection.y))));
                else
                    dzdx = (height(intensity, __sourceElevation__(vec2(_intersection.x+deltaX, _intersection.y)))
                       - height(intensity, __sourceElevation__(vec2(_intersection.x-deltaX, _intersection.y))));
                
                float deltaY = 0.0005;
                if (!heightMap)
                    dzdy = (height(intensity, __source__(vec2(_intersection.x, _intersection.y+deltaY)))
                       - height(intensity, __source__(vec2(_intersection.x, _intersection.y-deltaY))));
                else
                    dzdy = (height(intensity, __sourceElevation__(vec2(_intersection.x, _intersection.y+deltaY)))
                       - height(intensity, __sourceElevation__(vec2(_intersection.x, _intersection.y-deltaY))));
                
                vec3 unormal = vec3(0.5*dzdx/deltaX, 0.5*dzdy/deltaY, 1.0);
                vec3 smoothNormal =  (unormal.x==0.0 && unormal.y==0.0 && unormal.z==0.0) ? vec3(0.0, 0.0, 1.0) : normalize(unormal);
                normal = mix(normal, smoothNormal, normalSmoothing);
            }
            intersection =  mat3(_intersection, normal, vec3(frameDist, 0.0, 0.0));
        }
    }
        
                    frameDist = min(intersection[2].x, frameDist);
        
                    if (intersection[0][0]!=INF /*&& indexY>0.0 && indexY<rezolution*/) {
                        intersectDist = min(intersectDist, length(cameraPos - intersection[0]));
                        vec4 col = colorScheme==0.0 ? __source__(squareCenter.xy)
                                : colorScheme==1.0 ? __source__(intersection[0].xy)
                                : mix(__source__(squareCenter.xy), __source__(intersection[0].xy), colorScheme);
        
                        vec4 sampled = col * vec4(colorAmbient.rgb*2.0, colorAmbient.a);
                        if (length(colorSource.rgb)!=0.0) { // light source
                            vec3 normal = intersection[1];
        
                            if (length(normal)>0.0) {
                                float alpha = sampled.a;
                                normal = normalize(normal);
                                vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
                                sampled += col*vec4(colorSource.rgb*2.0, 1.0) * clamp(dot(lightDir, normal), 0.0, 1.0);
        
                                if (specular!=0.0) {
                                    vec3 reflectLightDir = reflect(lightDir, normal);
                                    //float spec = specular;
                                    vec4 specularColor = colorSource * (specular<0.25?specular*4.0:1.0) * pow(clamp(dot(dir, reflectLightDir), 0.0, 1.0), 10.0-specular*10.0);//(dot(dir, reflectLightDir)) * vec4(spec, spec, spec, 1.0);
                                    sampled = sampled + specularColor;
                                }
                                sampled.a = alpha;
                            }
                        }
                        if (reflectivity!=0.0) {
                            vec3 normal = intersection[1];
                            vec3 reflectDir = reflect(dir, normal);
                            //vec2 backPos = reflectDir.xy / reflectDir.z;
                            
                            
                            vec4 reflected = vec4(0.0, 0.0, 0.0, 1.0);
                            if (sourceBkg_specified==1) {
                                vec3 refDir = backgroundForReflection(reflectDir, sourceBkgDim, backgroundMode);
                                reflected = __sourceBkg__(refDir.xy) * vec4(vec3(refDir.z), 1.);
                            }
        
                            float lum = (reflected.r+reflected.g+reflected.b)*0.3333333;
                            float k = min(1.0, lum*reflectivity*10.);
        //                    sampled = mix(colorSource, reflected, k);
                            sampled = mix(sampled, reflected, k); //reflectivity);
                        }
        
                        outColor =  intersected==0.0 ? sampled : vec4(mix(outColor.rgb, sampled.rgb, intersected/(intersected+sampled.a)), outColor.a+(1.0-outColor.a)*sampled.a);
                        intersected += sampled.a;
        
                    }
                }
        
                // advance
                vec2 next = squareCenter.xy + nextLines;
                vec2 deltaK = (next-p.xy)/dir.xy;
                float minK = min(deltaK.x, deltaK.y); //if (minK<0.0001) minK = max(deltaK.x, deltaK.y);
                k += minK;
                p += minK*dir;
                --maxIter;
            }
        //if (maxIter<=0) return vec4(0.0, 0.0, 1.0, 1.0);
        
            outColor = mix(color, vec4(outColor.rgb, color.a), outColor.a);
        
            //frame
            vec4 frameColor = vec4(mix(outColor.rgb, colorLines.rgb, colorLines.a), 1.0);
            float frameK = thickness==0.0 ? 0.0 : smoothstep(0.0, 1.0, smoothstep(0.02*thickness, 0.0, frameDist) + 0.4*(glow==0.0 ? 0.0 : smoothstep(0.2*glow, 0.0, frameDist)));
            outColor = mix(outColor, frameColor, frameK);
            //outColor = vec4(vec3(frameDist), 1.0);
            
            if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                float kFog = smoothstep(nearDist, farDist, intersectDist);
                outColor.rgb = mix(outColor.rgb, colorFog.rgb, kFog);
            }
        
            return outColor;
        
        
        //    return mix(mix(vec4(length(cross(dir, vec3(0.0, 0.0, 1.0))), 1.0-length(cross(dir, vec3(0.0, 0.0, 1.0))), 0.0, 1.0), getBackground(pos), 0.5), wireColor, intersected);
        }
