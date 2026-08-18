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

vec4 wallpaper(vec2 pos, vec2 outPos, float radius, int mode, float lighting, mat4 model3DTransform, vec2 sourceDim) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.);
            //mat4 m = inverse(model3DTransform * mat4(1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., -1.0, 1.));
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m) * dir;
    
            vec4 col = getBackground(dir);
    
            if (dir.z==0.0) return col;
            bool clip = mode==0;
            float ratio = sourceDim.x/sourceDim.y;

            float z =  0.;
            float Y = 0.5;
            float kz = planeIntersectionK(vec3(0.0), vec3(0.0, 0.0, 1.0), cameraPos, dir);
            float ky = planeIntersectionK(vec3(0.0, Y, 0.0), vec3(0.0, 1.0, 0.0), cameraPos, dir);
            vec2 cylCenter = vec2(radius, Y-radius);
            vec2 kc = cylinderIntersectionK(radius, cameraPos.zyx-vec3(cylCenter, 0.), dir.zyx);
            float bestK = INF;
                        
            if (kc.x < bestK) {
                vec3 uv = cameraPos + kc.x*dir;
                if (uv.z<radius && uv.y>Y-radius)  { //will probably require inversion on Y
                    float angle = atan(uv.y-Y+radius, radius - uv.z);
                    float y = Y + radius * (angle - 1.0);
                    col = __source__(vec2(uv.x, y));
                    bestK = kc.x;
                }
            }
            if (kc.y < bestK) {
                vec3 uv = cameraPos + kc.y*dir;
                if (uv.z<radius && uv.y>Y-radius)  { //will probably require inversion on Y
                    float angle = atan(uv.y-Y+radius, radius - uv.z);
                    float y = Y + radius * (angle - 1.0);
                    col = __source__(vec2(uv.x, y));
                    bestK = kc.y;
                }
            }
            if (ky < bestK) {
                vec3 uv = cameraPos + ky*dir;
                if (uv.z>=radius) {
                    col = __source__(uv.xz + vec2(0.0, Y + radius * (PI_2-2.)));
                    bestK = ky;
                }
            }
            if (kz < bestK) {
                vec3 uv = cameraPos + kz*dir;
                if (uv.y<=Y-radius) {
                    col = __source__(uv.xy);
                    bestK = kz;
                }
            }
//            if (!found && kz!=INF) {
//                vec3 uv = cameraPos + kz*dir;
//                if (true || uv.y<=0.*(Y-radius)) {
//                    col = __source__(uv.xy);
//                    found = true;
//                }
//            }
            if (lighting>0.0) {
                vec3 intersection = cameraPos + bestK * dir;
                vec3 normal = vec3(0., 0., 1.);
//                if (abs(intersection.y-Y)<0.0001) normal = vec3(0., 1., 0.);
                if (intersection.z>=radius) normal = vec3(0., -1., 0.);
                else if (abs(intersection.z)>0.0001) normal = normalize(vec3(0., cylCenter.y-intersection.y, cylCenter.x-intersection.z));
//                if (intersection.z>=radius) return vec4(0., 1., 0., 1.);
//                else if (abs(intersection.z)>0.0001) return vec4(1., 0., 0., 1.);
//                else return vec4(0., 0., 1., 1.);
                
                vec3 lightPos = vec3(-10000.0, 20000.0, 40000.0);
                vec3 lightToIntersection = normalize(intersection-lightPos);
                float illum = dot(-lightToIntersection, normal);
                float k = mix(1.0, 0.7 + 0.3 * max(0.0, illum), min(1., lighting*2.));
                col.rgb *= k;
                
//                vec3 reflectDir = reflect(normalize(intersection-cameraPos), normal);
//                vec3 lpIntersection = planeIntersection(lightPos, vec3(0.0, 0.0, -1.0), intersection, reflectDir);
//                if (lpIntersection.x!=INF) {
//                    float d = sdRectangle(lpIntersection.xy-lightPos.xy, vec2(5000.));
//                    if (d<0.0) col.rgb += mix(0.0, 1.0, max(0., lighting*2.-1.));
//                }
                float specular = pow(max(0., dot(reflect(-lightToIntersection, normal), normalize(cameraPos-intersection))), 5.);
                col.rgb += mix(0.0, specular, max(0., lighting*2.-1.));
            }
    
            return col;
        }
