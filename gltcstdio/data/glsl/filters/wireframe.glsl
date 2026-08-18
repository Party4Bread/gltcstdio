#define SMALL_NUM 0.00001

#define SMALL_NUM 0.00001

float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

bool close(float a, float b) {
    return abs(a-b) < 0.00001;
}

vec4 distSegSeg(vec3 S1P0, vec3 S1P1, vec3 S2P0, vec3 S2P1) {
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

    return vec4(S1P0+sc*u, length(dP));   // return the closest distance
}

vec4 distSegSegZ(vec3 S1P0, vec3 S1P1, vec3 S2P0, vec3 S2P1, vec3 cameraPos, vec3 dir) {
    vec4 d = distSegSeg(S1P0, S1P1, S2P0, S2P1);
    float Z = dot(dir, d.xyz-cameraPos);
    return vec4(d.xyz, Z<0.0001 ? 1e10 : d.w/Z);
}

vec4 getBackground(vec2 pos) {
    return vec4(0.0, 0.0, 0.0, 1.0);
}

vec4 wireframe(vec2 pos, vec2 outPos, float intensity, int mode, int rezolution, 
            float thickness, float glow,
            mat4 model3DTransform, vec2 sourceDim, vec2 sourceElevationDim, 
            int sourceBkg_specified, int sourceElevation_specified,
            int transparencyMode,
            vec4 colorBkg, vec4 colorLines, vec4 colorFog
    ) {
            
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
        
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            //<ray-dir>
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            //</ray-dir>
            dir = mat3(m) * dir;
        
            bool heightMap = sourceElevation_specified==1;
        
            float maxZ = abs(intensity)*0.02;
            float ratio = heightMap ? (sourceElevationDim.x/sourceElevationDim.y) : (sourceDim.x/sourceDim.y);
            float dk = heightMap ? 2.0/sourceElevationDim.y : 2.0/sourceDim.y;
            vec3 step = dir * dk;
        
            float squareSize = 2.0/float(rezolution);
            //maxZ += squareSize; can't understand this, though adding glow distance would make sense
            float surfaceWidth = round((2.0*ratio)/squareSize)*squareSize;
            float surfaceHeight = 2.0;
            float countX = floor(surfaceWidth/squareSize+0.5);
            float countY = float(rezolution);
        
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
        
            if (k1>k2) return colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : colorBkg;
        //    if (k1>k2) return backgroundColor;
        
            float k = k1;
            vec3 p = cameraPos + k*dir;
        
            vec4 color = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : colorBkg; //backgroundColor;
            float h = 0.0;
            float dz = 0.0;
            float prevDz;
            vec4 prevColor;
            float prevH;
            bool stop;
        
            float intersected = 0.0;
            float intersDist = 1e9;
            vec3 triangleIntersection;
            
            vec4 outColor = vec4(0.0, 0.0, 0.0, 0.0);//color; //backgroundColor;
            vec2 nextLines = sign(dir.xy)*squareSize/2.0; //vec2(sign(dir.x)*squareSize, sign(dir.y)*squareSize)/2.0;
        int maxIter = 1000;
            float frameDist = 1e10;
            float th = 0.01*thickness / length(cameraPos);
            float glowAcc = 0.0;
            bool transparentToBackground = transparencyMode==0; // transparency acts either with relation to the background or to the source image mapped to the height map
            float underlyingColor = transparentToBackground ? 0.0 : 1.0-colorLines.a;
            vec4 frameColor = transparentToBackground
                ? vec4(mix(color.rgb, colorLines.rgb, colorLines.a), color.a)
                : (underlyingColor==0.0 ? colorLines : vec4(0.0, 0.0, 0.0, 1.0));
        
            // modes
            bool horizontals = true;
            bool verticals = true;
            bool solidSurface = true;
        
            if (mode==1) verticals = false;
            else if (mode==2) horizontals = false;
            else if (mode==3) solidSurface = false;
            else if (mode==4) { solidSurface = false; verticals = false; }
            else if (mode==5) { solidSurface = false; horizontals = false; }
            else if (mode==7) { solidSurface = false; }
            else if (mode==8) { }
            else if (mode==9) { verticals = false; }
            else if (mode==10) { horizontals = false; }
        
            while (intersected<1.0 && k<=k2 && maxIter>0) {
                // compute pixel center
                float indexX = (p.x+surfaceWidth/2.0)/squareSize;
                float indexY = (p.y+surfaceHeight/2.0)/squareSize;
        
                float fX = fract(indexX);
                float fY = fract(indexY);
                vec2 squareCenter;
        
                if (fX>0.9999 && dir.x>0.0) squareCenter.x = (ceil(indexX)+0.5)*squareSize;
                else if (fX<0.0001 && dir.x<0.0) squareCenter.x = (floor(indexX)-0.5)*squareSize;
                else squareCenter.x = (floor(indexX)+0.5)*squareSize;
                squareCenter.x -= surfaceWidth/2.0;
        
                if (fY>0.9999 && dir.y>0.0) squareCenter.y = (ceil(indexY)+0.5)*squareSize;
                else if (fY<0.0001 && dir.y<0.0) squareCenter.y = (floor(indexY)-0.5)*squareSize;
                else squareCenter.y = (floor(indexY)+0.5)*squareSize;
                squareCenter.y -= surfaceHeight/2.0;
                //        squareCenter = p;
        
                vec2 bottomLeft = squareCenter - vec2(squareSize, squareSize)/2.0;
        
                bool square = false;
                if (mode==6 || mode==7) {
                    if (mod(floor(bottomLeft.x/squareSize)+floor(bottomLeft.y/squareSize), 2.0)==0.0) square = true;
                }
                else if (mode>=8) {
                    float rnd = sin(floor(bottomLeft.x/squareSize)*78.0+4.0)*sin(floor(bottomLeft.y/squareSize)*45.0+44.0);
                    if (fract(rnd*10.0)<0.1) { square = true; }
                }
                bool triangles = (solidSurface || square) && (abs(squareCenter.x)<surfaceWidth/2.0 && abs(squareCenter.y)<surfaceHeight/2.0);
        
                // compute triangles intersection
                //float inters = getFrameDistance(bottomLeft, squareSize, p, dir, intensity, heightMap);
        
        
                // compute height and color
                triangleIntersection = vec3(INF, INF, INF);
                vec4 frameDistVec = vec4(0.0, 0.0, 0.0, 1e9);
                {
                    vec3 origin = p;
                    vec2 p = bottomLeft;
                    float step = squareSize;
                    vec2 s = vec2(step, 0.0);
                    vec2 p11 = p+s.xx;
            
                    vec4 c00 = heightMap ? __sourceElevation__(p) : __source__(p);
                    float h00 = height(intensity, c00);
                    vec3 A = vec3(p, h00);
            
                    vec4 c10 = heightMap ? __sourceElevation__(p+s): __source__(p+s);
                    float h10 = height(intensity, c10);
                    vec3 B = vec3(p+s, h10);
            
                    vec4 c01 = heightMap ? __sourceElevation__(p+s.yx): __source__(p+s.yx);
                    float h01 = height(intensity, c01);
                    vec3 C = vec3(p+s.yx, h01);
            
                    vec4 c11 = heightMap ? __sourceElevation__(p11): __source__(p11);
                    float h11 = height(intensity, c11);
                    vec3 D = vec3(p11, h11);
            
                    if (triangles) { // compute triangle intersections
                        float dzx1 = (h10-h00)/step;
                        float dzy1 = (h01-h00)/step;
                        float k1 = (h00-origin.z + (origin.x-p.x)*dzx1 + (origin.y-p.y)*dzy1) / (dir.z - dir.x*dzx1 - dir.y*dzy1);
            
                        float dzx2 = -(h01-h11)/step;
                        float dzy2 = -(h10-h11)/step;
                        float k2 = (h11-origin.z + (origin.x-p11.x)*dzx2 + (origin.y-p11.y)*dzy2) / (dir.z - dir.x*dzx2 - dir.y*dzy2);
            
                        if (k1>0.0) {
                            vec3 intersection = origin + k1*dir;
                            vec2 relInt = intersection.xy-p.xy;
                            if (relInt.x>=0.0 && relInt.x<=step && relInt.y>=0.0 && relInt.y<=step && step-relInt.x>=relInt.y) {
                                triangleIntersection = intersection;
                            }
                        }
                        if (k2>0.0) {
                            vec3 intersection = origin + k2*dir;
                            vec2 relInt = intersection.xy-p.xy;
                            if (relInt.x>=0.0 && relInt.x<=step && relInt.y>=0.0 && relInt.y<=step && step-relInt.x<=relInt.y) {
                                triangleIntersection = intersection;
                            }
                        }
                    }
            
                    vec3 inf = origin + 1e6 * dir;
                    //float frameDistVec = min(distSegSegZ(origin, inf, A, B, cameraPos, dir), distSegSegZ(origin, inf, C, D, cameraPos, dir));
                    float W = surfaceWidth/2.0+0.00001;
                    float H = surfaceHeight/2.0+0.00001;
                    if (horizontals) {
                        vec4 fdAB = distSegSegZ(origin, inf, A, B, cameraPos, dir);
                        if (p.y>=-H && p.x>=-H && p11.x<=H && fdAB.w<frameDistVec.w) frameDistVec = fdAB;
                        vec4 fdCD = distSegSegZ(origin, inf, C, D, cameraPos, dir);
                        if (p11.y<=H && p.x>=-H && p11.x<=H && fdCD.w<frameDistVec.w) frameDistVec = fdCD;
                    }
                    if (verticals) {
                        vec4 fdAC = distSegSegZ(origin, inf, A, C, cameraPos, dir);
                        if (p.x>=-H && p.y>=-H && p11.y<=H && fdAC.w<frameDistVec.w) frameDistVec = fdAC;
                        vec4 fdBD = distSegSegZ(origin, inf, B, D, cameraPos, dir);
                        if (p11.x<=H && p.y>=-H && p11.y<=H && fdBD.w<frameDistVec.w) frameDistVec = fdBD;
                    }
                }
                mat3 inters = mat3(frameDistVec.xyz, triangleIntersection, vec3(frameDistVec.w, 0.0, 0.0));
                //mat3 inters = getFrameDistanceZ(bottomLeft, squareSize, p, dir, intensity, heightMap, cameraPos, surfaceWidth, surfaceHeight, horizontals, verticals, triangles);
        
                //if (square && inters[1].x!=INF) { frameDist = 0.0; frameColor = u_Color1; break; }
        
                intersDist = (square && inters[1].x!=INF) ? 0.0 : inters[2].x;
                
                if (intersDist<frameDist) {
                    frameDist = intersDist;
                    if (underlyingColor>0.0) {
                        vec4 currentColor = mix(colorLines, __source__(inters[0].xy), underlyingColor);
                        if (length(currentColor.rgb)>length(frameColor.rgb)) frameColor.rgb = currentColor.rgb;
                    }
                    if (square && inters[1].x!=INF) break;
                }
        
                if (intersDist<th) break; // solid hit
                else if (glow>0.0) {
                    glowAcc += 1.0 * pow(th/intersDist, 1.0-glow*0.75)*smoothstep(th+0.1*glow, th, intersDist);
                }
        
                if (solidSurface && inters[1].x!=INF) break;
        
        //        // compute triangles intersection
        //        if (solidSurface || u_Mode>=6) {
        //            if (trianglesIntersection(bottomLeft, squareSize, p, dir, intensity, heightMap)) {
        //                if (u_Mode==6 || u_Mode==7) {
        //                    if (mod(floor(bottomLeft.x/squareSize)+floor(bottomLeft.y/squareSize), 2.0)==0.0) { frameDist = 0.0; frameColor = u_Color1; break; }
        //                }
        //                else if (u_Mode>=8) {
        //                    float rnd = sin(floor(bottomLeft.x/squareSize)*78.0+4.0)*sin(floor(bottomLeft.y/squareSize)*45.0+44.0);
        //                    if (fract(rnd*10.0)<0.1) { frameDist = 0.0; frameColor = u_Color1; break; }
        //                }
        //                if (solidSurface) break;
        //            }
        //        }
        
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
            //if (abs(p.x)>surfaceWidth/2.0 || abs(p.y)>surfaceHeight/2.0) outColor = vec4(1.0, 0.0, 0.0, 1.0);
        
            //frame
            float frameK = frameDist<th ? 1.0 : clamp(glowAcc, 0.0, 1.0);//1.0 * pow(th/frameDist, 1.0-u_Glow*0.0075)*smoothstep(th+0.001*u_Glow, th, frameDist); //clamp(0.001/(frameDist+0.0001*u_Thickness), 0.0, 1.0));
            outColor = mix(outColor, frameColor, frameK);
            
            if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                float kFog = smoothstep(nearDist, farDist, length(cameraPos-triangleIntersection));
                outColor.rgb = mix(outColor.rgb, colorFog.rgb, kFog);
            }
        
            return outColor;
        
        
        //    return mix(mix(vec4(length(cross(dir, vec3(0.0, 0.0, 1.0))), 1.0-length(cross(dir, vec3(0.0, 0.0, 1.0))), 0.0, 1.0), getBackground(pos), 0.5), wireColor, intersected);
        }
