vec4 shade(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float height, float specular, float delta, float gamma, mat4 lightSourceTransform) {
                vec2 step = vec2(delta, 0.);
            
                vec2 uv = pos;
                vec4 col = __source__(uv);
                float h = luma(col.rgb);
//                vec2 grad = vec2(
//                    h - luma(__source__(uv-step).rgb) ,
//                    h - luma(__source__(uv-step.yx).rgb) ) / delta;
                
//                vec2 grad = vec2(dFdx(h), dFdy(h)) / delta;
    
                float pixel = 2.0/sourceDim.y;
                vec2 grad = vec2(dFdx(h), dFdy(h)) / pixel;
                
                vec3 normal = normalize(vec3(height*grad, 1.0));
                vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
//                vec3 lightDir = normalize(vec3(1., 1., 1.));
                vec3 lightDir = normalize(vec3(uv, 0.) - lightPos);
                float illum = dot(normal, lightDir);
                
                vec3 reflectedLightDir = reflect(-lightDir, normal);
//                float spec = pow(max(0.0, reflectedLightDir.z), 5.0);
                float spec = pow(max(0.0, dot(reflectedLightDir, normalize(vec3(-uv, 0.5/height)))), 5.0);
                                
                float k = (0.1 + illum*intensity) / (0.1+intensity);
                return adjustGamma(vec4(col.rgb*k + spec*specular, col.a), gamma);
            }
