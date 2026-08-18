vec4 getBackground(vec3 dir, vec4 color) {
    return color; //vec4(0.0, 0.0, 0.0, 1.0);
}

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    //vec3 camX = normalize(cross(vec3(0.,0.,1.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

vec4 perspective(vec2 pos, vec2 outPos, int mode, int dual, mat4 model3DTransform, vec4 highFreqColor, vec2 sourceDim) {
            
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.); 
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m[0].xyz, m[1].xyz, m[2].xyz) * dir;

            vec4 col = getBackground(dir, highFreqColor);
    
            if (dir.z==0.0) return col;
            bool clip = mode==0;
            float ratio = sourceDim.x/sourceDim.y;

            float z =  0.;
            float k = (z-cameraPos.z)/dir.z;
            if (dual==1 || k>0.) {
                vec2 uv = dir.xy * k + cameraPos.xy;
                if (!clip || (abs(uv.x)<ratio && abs(uv.y)<1.)) {
                    col = __source__(uv);
                    float d = abs(k);
                    if (d>1.0 && highFreqColor.a>0.0) {
                        float fog = (abs(d)-1.0) * 0.2;
                        col = mergeColor(col, vec4(highFreqColor.rgb, min(1., highFreqColor.a*fog)));
                    }
                }
            }                
                        
            return col;
        }
