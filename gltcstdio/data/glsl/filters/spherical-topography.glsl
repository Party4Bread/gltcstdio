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

vec4 sphericalTopography(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, int count, float overlap, 
        int sourceBkg_specified, vec4 colorFog, int mode, float kernelRadius, vec4 colorKernel, float blend,
        mat4 model3DTransform) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            float ratio = sourceDim.x/sourceDim.y;
            float blendedWidth = sourceDim.x * (1.0-blend*0.5);
            float blendedRatio = blendedWidth / sourceDim.y;
            
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = vec3(pos.x*D, pos.y*D, -1.0);
            dir = normalize(mat3(m) * dir);
            
//            float D = 5.;
//            vec3 cameraPos = vec3(0., 0., D);
//            cameraPos = ((model3DTransform) * vec4(cameraPos, 1.)).xyz;
//            vec3 target = vec3(0.);
//            vec3 dir = getRay(pos, cameraPos, target, D);


            float kFog = 1e9;
            vec4 col = colorFog.a!=0.0 ? vec4(colorFog.rgb, 1.0) : sourceBkg_specified==1 ? __sourceBkg__(outPos) : vec4(0.0, 0.0, 0.0, 1.0);
    
            if (dir.z==0.0) return col;
            float N = float(count);
            float layerSize = (1.0 + overlap*(N-1.0)) / N; // in luminosity "units"
            float layerOffset = (1.0-layerSize) / max(1.0, N-1.0); // in luminosity "units"
            float mid = (N-1.0) * .5;
            //float zStep = D*2. * intensity/max(1.0, N-1.0);
            
            if (mode==2) intensity = -intensity;

            vec3 normalPoint = cameraPos + dot(dir, -cameraPos)*dir;
            float kNormal = dot(normalPoint-cameraPos, dir);
            float startLayer = (length(cameraPos)-1.0)*N/intensity + mid;
            float normalLayer = (length(normalPoint)-1.0)*N/intensity + mid;
//            float N0 = kNormal>=0.0 ? ceil(startLayer) : floor(startLayer);
//            float N1 = kNormal>=0.0 ? floor(normalLayer) : N-1.0;
            float iterDir = (mode==2 ? -1.0 : 1.0) * (intensity >= 0.0 ? 1.0 : -1.0);
            float N0 = clamp(ceil(startLayer), 0.0, N-1.);
            float N1 = clamp(floor(normalLayer), 0.0, N-1.);
            float N2 = (iterDir>=0.0) ? N-1.0 : 0.0;
            
            float opacity = 0.0;
            
            vec3 intersection;      
            if (N0*iterDir>=N1*iterDir) {
                for(float i=N0; i*iterDir>=N1*iterDir; i -= iterDir) {
                    float radius = 1.0 + (i-mid)/N*intensity;
                    intersection = sphereFirstIntersection(vec3(0.), radius, cameraPos, dir);
                    if (intersection.x<INF) {
                        float angle = atan(intersection.x, intersection.z);

                        vec4 sampleCol;
                        float x = angle/PI;
                        float X = x * (1.0+blend); 
                        if (abs(x)<=1.0-blend) {
                            vec2 q = vec2(x/(1.0+blend)*ratio, intersection.y/radius);
                            sampleCol = __source__(q);
                        }
                        else {
                            float x1 = x/(1.0+blend);
                            float x2 = sign(x) * (-1. + (abs(x)-(1.0-blend))/(1.0+blend));
                            vec2 q1 = vec2(x1*ratio, intersection.y/radius);
                            vec2 q2 = vec2(x2*ratio, intersection.y/radius);
                            float k = 0.5*(abs(x)-(1.0-blend))/blend;
                            sampleCol = mix(__source__(q1), __source__(q2), k);
                        }                            
                        
                        if (radius<=kernelRadius) {
                            kFog = length(cameraPos - intersection);
                            col = mergeColor(sampleCol, colorKernel); 
                            opacity = 1.0;
                            break;                         
                        } 
                        float lum = luma(sampleCol.rgb);
                        float layerStart = layerOffset * float(i);
                        float layerEnd = layerStart + layerSize;
                        if (lum>=layerStart && lum<=layerEnd) { 
                            kFog = length(cameraPos - intersection);
                            col = sampleCol; 
                            opacity = 1.0;
                            break; 
                        }
                    }
                }
            }
            if (opacity!=1.0 && N1*iterDir<=N2*iterDir) {
                for(float i=N1; i*iterDir<=N2*iterDir; i += iterDir) {
                    float radius = 1.0 + (i-mid)/N*intensity;
                    intersection = sphereLastIntersection(vec3(0.), radius, cameraPos, dir);
                    if (intersection.x<INF) {
                        float angle = atan(intersection.x, intersection.z);
                        
                        vec4 sampleCol;
                        float x = angle/PI;
                        float X = x * (1.0+blend); 
                        if (abs(x)<=1.0-blend) {
                            vec2 q = vec2(x/(1.0+blend)*ratio, intersection.y/radius);
                            sampleCol = __source__(q);
                        }
                        else {
                            float x1 = x/(1.0+blend);
                            float x2 = sign(x) * (-1. + (abs(x)-(1.0-blend))/(1.0+blend));
                            vec2 q1 = vec2(x1*ratio, intersection.y/radius);
                            vec2 q2 = vec2(x2*ratio, intersection.y/radius);
                            float k = 0.5*(abs(x)-(1.0-blend))/blend;
                            sampleCol = mix(__source__(q1), __source__(q2), k);
                        }        
                        
                        if (radius<=kernelRadius) {
                            kFog = length(cameraPos - intersection);
                            col = mergeColor(sampleCol, colorKernel); 
                            opacity = 1.0;
                            break;                         
                        } 
                        float lum = luma(sampleCol.rgb);
                        float layerStart = layerOffset * float(i);
                        float layerEnd = layerStart + layerSize;
                        if (lum>=layerStart && lum<=layerEnd) { 
                            kFog = length(cameraPos - intersection);
                            col = sampleCol; 
                            opacity = 1.0;
                            break; 
                        }
                    }
                }            
            }
            
            if (colorFog.a!=0.0) {
                float nearDist = 2.0 * (1.-colorFog.a);
                float farDist = 2.*nearDist;
                kFog = smoothstep(nearDist, farDist, kFog); //1.0 - pow(0.4, colorFog.a * max(0.0, kFog-0.1));
                col.rgb = mix(col.rgb, colorFog.rgb, kFog);
            }
//     col.r = (length(normalPoint)>=1.0 ? 1.0 : 0.0);
//     col.g = (length(normalPoint)>=1.5 ? 1.0 : 0.0);
            return col;
        }
