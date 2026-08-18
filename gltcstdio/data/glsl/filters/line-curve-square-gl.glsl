vec4 segmentCrossCurve(vec2 uv, vec2 outPos, int mode, int count, float thickness, vec4 color, mat3 modelTransform) {
            vec2 u = tf(inverse(modelTransform), uv);
            if (mode<=1) {
                u = abs(u);
                if (u.x<u.y) u.xy = u.yx;
            }
            if (mode==1) u = 1.0 - u;
            
            vec2 a = vec2(0., 0.);
            vec2 b = a;
            float k = 0.0;
            float th = thickness / length(modelTransform[0].xy);
            float step = 2.0/float(count);
            if (mode<=1) {
                for(int i=0; i<count; ++i) {
                    a = vec2(1.0-float(i)*step, 0.0);
                    b = vec2(0.0, 1.0-a.x);
                    
                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, a, b)));
                    if (k>=1.0) break;
                }
            }
            else if (mode==2) {
                for(int i=0; i<=count; ++i) {
                    a = vec2(1.0-float(i)*step, -1.0);
                    b = vec2(-1.0, -a.x);
//                                vec2 ua = u-a;
//                    vec2 v;
//                    vec2 ua;
//                    float h;
//                    vec2 ba = b-a;
//                    float ba2 = dot(ba, ba);
////                                float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
////                                return length(ua - ba*h);
//
//                    ua = u-a;
//                    h = clamp(dot(ua, ba)/ba2, 0., 1.);
//                    l = length(ua - ba*h);   
//                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, l));
//                    if (k>=1.0) break;
//
//                    ua = -u-a;
//                    h = clamp(dot(ua, ba)/ba2, 0., 1.);
//                    l = length(ua - ba*h);   
//                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, l));
//                    if (k>=1.0) break;
//
//                    ua = vec2(u.x, -u.y)-a;
//                    h = clamp(dot(ua, ba)/ba2, 0., 1.);
//                    l = length(ua - ba*h);   
//                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, l));
//                    if (k>=1.0) break;
//
//                    ua = vec2(-u.x, u.y)-a;
//                    h = clamp(dot(ua, ba)/ba2, 0., 1.);
//                    l = length(ua - ba*h);   
//                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, l));
//                    if (k>=1.0) break;
                    
                    
                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(u, a, b)));
                    if (k>=1.0) break;

                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(-u, a, b)));
                    if (k>=1.0) break;

                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(vec2(u.x, -u.y), a, b)));
                    if (k>=1.0) break;

                    k = max(k, smoothstep(th*0.1 + 0.0005, th*0.1, sdSegment(vec2(-u.x, u.y), a, b)));
                    if (k>=1.0) break;

                }            
            }
            
            vec4 inCol = __source__(uv);
            vec4 mergeCol = mergeColor(inCol, color);
            return mix(inCol, mergeCol, k);
        }
