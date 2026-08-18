vec4 getBackground(vec3 dir) {
    return vec4(0.0, 0.0, 0.0, 1.0);
}

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    //vec3 camX = normalize(cross(vec3(0.,0.,1.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

vec4 translucentSlices(vec2 pos, vec2 outPos, float intensity, int count, float overlap, float dampening, int mode, mat4 model3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 0.5;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
    
            vec4 col = vec4(0.);
    
            if (dir.z==0.0) return col;
            float N = float(count);
            float layerSize = (1.0 + overlap*(N-1.0)) / N; // in luminosity "units"
            float layerOpaqueSize = 0.5 / N; // in luminosity "units"
            float maxDist = layerSize*.5-layerOpaqueSize;
            float layerOffset = (1.0-layerSize) / max(1.0, N-1.0); // in luminosity "units"
            float mid = (N-1.0) * .5;
            float zStep = D*2. * intensity/max(1.0, N-1.0);
            bool clip = mode==0;
            bool dual = false;
            float ratio = sourceDim.x/sourceDim.y;

            bool iterDir = dir.z*intensity>0.0;
            int i = iterDir ? 0 : count-1;
            int di = iterDir ? 1 : -1;
            while(true) {
                float z =  zStep * (float(i)-mid);
                float k = (z-cameraPos.z)/dir.z;
                if (dual || k>0.) {
                    vec2 uv = dir.xy * k + cameraPos.xy;
                    if (!clip || (abs(uv.x)<ratio && abs(uv.y)<1.)) {
                        vec4 sampleCol = __source__(uv);
                        float lum = luma(sampleCol.rgb);
                        float layerStart = layerOffset * float(i);
                        float layerEnd = layerStart + layerSize;
                        if (lum>=layerStart && lum<=layerEnd) { 
                            float lumCenter = (float(i)+.5)/N;
                            float lDist = abs(lum-lumCenter);
                            if (lDist<=layerOpaqueSize) {
                                col = mergeColorOpacifying(col, sampleCol);
                            }
                            else {
                                float ka = pow( max(0., 1.0-(lDist-layerOpaqueSize)/maxDist) , pow(10., dampening));
                                //col = mix(col, sampleCol, dampening);
                                col = mergeColorOpacifying(col, vec4(sampleCol.rgb, sampleCol.a*ka));
                                //col = mergeColorOpacifying(col, vec4(1.0, 0., 0., 0.2));
                            }
                            
                            if (col.a>0.995) break;
                        }
                    }
                }
                i += di;
                if ((iterDir && i>=count) || (!iterDir && i<0)) break;
                
            }
            
            col = mergeColorOpacifying(getBackground(dir), col);
                        
            return vec4(col.rgb, 1.);
        }
