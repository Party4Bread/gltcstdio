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

vec4 topography(vec2 pos, vec2 outPos, float intensity, int count, float overlap, int mode, 
        int sourceBkg_specified, vec4 colorFog, 
        mat4 model3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 0.5;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            //<ray-dir>
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            //</ray-dir>
            dir = mat3(m) * dir;

//            float D = 5.;
//            vec3 cameraPos = vec3(0., 0., D);
////            cameraPos = mat3(model3DTransform) * cameraPos;
//            cameraPos = ((model3DTransform) * vec4(cameraPos, 1.)).xyz;
//            vec3 target = vec3(0.);
//            vec3 dir = getRay(pos, cameraPos, target, D);

//            vec3 cameraPos = vec3(0.0, 0.0, D);
//            vec3 dir = normalize(vec3(pos.x, pos.y, 0.0) - cameraPos);
//            cameraPos = (inverseModel3DTransform * vec4(cameraPos, 1.0)).xyz;
////            cameraPos = (inverse(inverseModel3DTransform) * vec4(cameraPos, 1.0)).xyz;
//            dir = mat3(inverseModel3DTransform) * dir;
            float kFog = 1e9;
            //vec4 col = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
            vec4 col = vec4(0.0, 0.0, 0.0, 0.0);

            if (dir.z==0.0) return col;
            float N = float(count);
            float layerSize = (1.0 + overlap*(N-1.0)) / N; // in luminosity "units"
            float layerOffset = (1.0-layerSize) / max(1.0, N-1.0); // in luminosity "units"
            float mid = (N-1.0) * .5;
            float zStep = D*2. * intensity/max(1.0, N-1.0);
            bool clip = mode==0;
            bool dual = false;
            float ratio = sourceDim.x/sourceDim.y;

            bool iterDir = dir.z*intensity>0.0;
            int i = iterDir ? 0 : count-1;
            int di = iterDir ? 1 : -1;
            while (true) {
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
                            vec3 intersection = dir * k + cameraPos;
                            kFog = length(cameraPos - intersection);
                            //col = sampleCol;
                            col = mergeColorOpacifying(col, sampleCol); // works well for fully transparent, not so well for partially transparent
                            if (col.a==1.0) break; 
                        }
                    }
                }
                i += di;
                if ((iterDir && i>=count) || (!iterDir && i<0)) break;    
            }
                    
            if (col.a<1.0) {
                vec4 bkg = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
                col = mergeColor(bkg, col);
            }
                    
            if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                kFog = smoothstep(nearDist, farDist, kFog); //1.0 - pow(0.4, colorFog.a * max(0.0, kFog-0.1));
                col.rgb = mix(col.rgb, colorFog.rgb, kFog);
            }
            
            return col;
        }
