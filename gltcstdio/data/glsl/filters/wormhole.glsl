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

vec4 wormhole(vec2 pos, vec2 outPos, float intensity, int count, float overlap, vec4 color, mat4 model3DTransform, mat4 inverseModel3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 5.;
            vec3 cameraPos = vec3(0., 0., D);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            cameraPos = ((model3DTransform) * vec4(cameraPos, 1.)).xyz;
            vec3 target = vec3(0.);
            vec3 dir = getRay(pos, cameraPos, target, D);
    
            vec4 col = getBackground(dir);
    
           float d = length(cameraPos.xy);
           float a = 
                        
            return col;
        }
