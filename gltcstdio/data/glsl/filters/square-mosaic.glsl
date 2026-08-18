float bestErr = 1e9;
float err;
vec3 c1, c2;
float count1;
float kPart;
vec2 dPart;
vec3 outCol;
                    c1 = vec3(0.);
                    c2 = vec3(0.);
                    count1 = 0.;
                    for(float j=0.; j<n; ++j) {
                        for(float i=0.; i<n; ++i) {
                            vec2 u=vec2(s2 + i*step, s2 +j*step);
                            vec3 col = __source__(tf(modelTransform, (id+u)/R)).rgb;
                            
                            count1 += 1.0-kPart;
                            c1 += (1.0-kPart) * col;
                            c2 += kPart * col;
                        }
                    }
                    c1 = count1==0.0 ? c1 : c1/count1;
                    c2 = count1==n*n ? c2 : c2/(n*n-count1);
                    err = 0.0;
                    for(float j=0.; j<n; ++j) {
                        for(float i=0.; i<n; ++i) {
                            vec2 u=vec2(s2 + i*step, s2 +j*step);
                            vec3 col = __source__(tf(modelTransform, (id+u)/R)).rgb;
                            
                            err += mix(dot(c1-col, c1-col), dot(c2-col, c2-col), kPart);
                        }
                    }
                    if (err < bestErr) {
                        bestErr = err;
                        vec2 u = cv*tileScale +.5; //vv;
                        
                    }                                        
                
        vec4 tiledMosaic(vec2 uv, vec2 outPos, vec2 sourceDim, mat3 modelTransform,
            int sourceBkg_specified,
            int levels, float threshold, int precizion,
            int borderMode, float thickness, vec4 borderColor, float borderControl
            ) {
            vec2 v = (inverse(modelTransform) * vec3(uv, 1.0)).xy; 
            int N = precizion;
            float n = float(N);
            float step = 1./n;
            float s2 = step*.5;
            threshold = threshold*threshold;
            
            //float R = 25.0+20.*sin(iTime);
            float Rbase = 5.;
            float R = 1.;
            for(int k=0; k<levels-1; ++k) {
                vec2 id = floor(v*R);
                vec3 ccol = __source__(tf(modelTransform, (id+0.5)/R)).rgb;
                float var = 0.;
                for(float j=0.; j<n; ++j) {
                    for(float i=0.; i<n; ++i) {
                        vec2 u=vec2(s2 + i*step, s2 +j*step);
                        vec3 col = __source__(tf(modelTransform, (id+u)/R)).rgb;
                        var += dot(ccol-col, ccol-col);
                    }
                }
        
                if (var/(n*n) < threshold) break;
                R *= 2.;
            }
        
            v = v*R;
            vec2 id = floor(v);
            vec2 vv = v-id;
            vec2 cv = vv - 0.5;
            float borderThreshold = 0.5 - thickness*0.5*R/pow(2.0, float(levels-1));
            float tileScale = 0.5 / borderThreshold;
            if (abs(cv.x)>borderThreshold || abs(cv.y)>borderThreshold) {
                vec4 col;
                if (borderMode==0) {
                    col = borderColor;
                }
                else if (borderMode==1) {
                    col = __source__(tf(modelTransform, (id+0.5)/R));
                    col.rgb += borderControl;
                }
                else if (borderMode==2) {
                    col = __source__(tf(modelTransform, (id+0.5)/R));
                    col.rgb -= borderControl;
                }
                else if (borderMode==3) { // vignette
                    col = __source__(tf(modelTransform, (id+0.5)/R));
                    col.rgb -= borderControl * (length(tf(modelTransform, (id+0.5)/R))-0.5*sqrt(1.0 + (sourceDim.x*sourceDim.x)/(sourceDim.y*sourceDim.y)));
                }
                else { // scatter
                    vec2 delta = (hash22(id)-0.5) * borderControl;
                    col = __source__(tf(modelTransform, (id+0.5)/R) + delta);
                }
                        
                return sourceBkg_specified==0 ? mergeColor(__source__(uv), col) : mergeColor(__sourceBkg__(uv), col);
            }
            else {
                
                return vec4(outCol, 1.);
            }
//            v = (modelTransform * vec3((id+.5)/R, 1.0)).xy;
//            return __source__(v);
        }            
        
