        vec4 circleListPainter(vec2 pos, vec2 outPos, vec2 sourceDim, vec2 source2Dim, vec2 outDim, int count, float padding, float thickness, vec4 borderColor, int source3_specified) {
            // from sourceDim determine gridSize
            //return __source2__(pos*2.0);
            float ar = sourceDim.x / sourceDim.y;
            float pixel = 2.0/outDim.y;
            float maxLen = max(1.0, ar);
            float gridSize = maxLen / 8.0; // highly dependent on matching what RandomTilePlacer does...
            
            vec4 sizePix = __source2__texelFetch__(ivec2(0, 0)) * 255.0;
//            vec4 sizePix = vec4(0.0, 0.03921568, 0.0, 0.03921568) * 255.0;
//            float gridWidth = ceil((ar)/gridSize) * 2.;
//            float gridHeight = ceil((1.0)/gridSize) * 2.;
            float gridWidth = round(/*sizePix.r*256.0 +*/ sizePix.g);
            float gridHeight = round(/*sizePix.b*256.0 +*/ sizePix.b);
            
            // which cell are we in => y
            vec2 cell = vec2(floor(pos.x/gridSize), floor(pos.y/gridSize));
            int y = int(cell.x+gridWidth/2. + (cell.y+gridHeight/2.)*gridWidth) + 1;
            int xx = 0;
            
            
            // read source2Dim line until alpha!=1.0, determining if we're in the circle
            bool stop = false;
            vec4 bkgCol = (source3_specified==1) ? __source3__(pos) : vec4(0.0, 0.0, 0.0, 1.0);
            vec4 color = bkgCol;
            vec3 bestCircle = vec3(0., 0., -1.);
                        
            while (!stop && xx<400) { // highly dependent on MAX_CIRCLES_PER_CELL in RandomTilePlacer
                vec4 first = __source2__texelFetch__(ivec2(xx*2, y))*255.0;
                vec4 second = __source2__texelFetch__(ivec2(xx*2+1, y))*255.0;
                stop = first.a==0.0;
                if (!stop) {
                    ++xx;
                    float x = round(first.r)*256.0 + (first.g);
                    if (x>=32768.) x = x-65536.;
                    x /= 32768.;
                    float y = round(first.b)*256.0 + (second.r);
                    if (y>=32768.) y = y-65536.;
                    y /= 32768.;
                    float r = round(second.g)*256.0 + (second.b);
                    if (r>=32768.) r = r-65536.;
                    r /= 32768.;
                    
                    vec2 center = vec2(x, y);
                    if (ar>1.0) { center *= ar; r *= ar; }
                    vec2 delta = pos-center;
                    if (dot(delta, delta) < r*r) {
                        //color = __source__(center);
                        bestCircle = vec3(center.x, center.y, r);
                    }
                }
            }
            
            if (bestCircle.z>0.0) {
                float trueRadius = (1.0-padding) * bestCircle.z;
                float innerBorderRadius = (1.0-thickness) * trueRadius;
                vec2 center = bestCircle.xy;
                float d = length(pos-center);
                float aar = pixel*0.5;
                float k = smoothstep(trueRadius+aar, trueRadius-aar, d);
                if (k==0.0) return bkgCol;
                float kb = smoothstep(innerBorderRadius+aar, innerBorderRadius-aar, d);
                vec4 centerCol = __source__(center);
                vec4 circleCol = centerCol; 
                if (kb<1.0) {
                    vec4 borderColor = mergeColor(centerCol, borderColor);
                    circleCol = mix(borderColor, centerCol, kb);
                }
                return mix(bkgCol, circleCol, k);
            }
            else {
                return bkgCol;
            }
            
            
//            if (gridHeight!=10. || gridWidth!=10.) {
//                float scale = 15.;
//                vec2 uv = pos * scale;
//                vec2 u = fract(uv+0.5);
//                vec2 dg =  abs(u-0.5);
//                if (abs(uv.x - sizePix.g*scale)<0.1) return vec4(1.0, 0. ,0. ,1.0);
//                float widx = round(uv.x)==gridWidth ? 0.08 : 0.033;
//                float widy = round(uv.y)==gridHeight ? 0.08 : 0.033;
//                if (dg.x<widx || dg.y<widy) return (round(uv.x)==0.0 || round(uv.y)==0.0) ? vec4(1., 1., 0, 1.) : vec4(1.);
//                return vec4(0.0, 0.0, 1., 1.0);
//            }
//            if (float(y-1)>=source2Dim.y || float(y)<0.) return vec4(1.0, 1.0, 0., 1.0);
//            return (xx==0) ? vec4(1.0, 0. ,0., 1.0) : color;
            
//            float g = float(xx)/20.0;
//            return vec4(g, g, g, 1.0);
            
        }            
