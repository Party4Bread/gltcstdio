float sdf(vec3 p, float radius) {
    return sdTorus(p, .4, radius*0.8);
}            

vec3 getCol(vec2 uv) {
    return texture(iChannel0, (uv+iResolution.xy*.5/iResolution.y)*vec2(iResolution.y/iResolution.x, 1.0)).rgb;
}

float getHeight(vec3 col, vec2 uv) {
    return (col.r+col.g+col.b)*0.1;
}

mat4 rotX(float ang) {
    return mat4(1.0, 0.0, 0.0, 0.0,
                0.0, cos(ang), sin(ang), 0.0,
                0.0, sin(ang), -cos(ang), 0.0,
                0.0, 0.0, 0.0, 1.0);

}

mat4 rotY(float ang) {
    return mat4(cos(ang), 0.0, sin(ang), 0.0,
                0.0, 1.0, 0.0, 0.0,
                sin(ang), 0.0, -cos(ang), 0.0,
                0.0, 0.0, 0.0, 1.0);

}

vec3 normal(vec3 p, float radius) {
    float d = 0.0001;
    float s = sdf(p,radius);
    return normalize(vec3(
        (s-sdf(vec3(p.x-d, p.y, p.z),radius))/d,
        (s-sdf(vec3(p.x, p.y-d, p.z),radius))/d,
        (s-sdf(vec3(p.x, p.y, p.z-d),radius))/d
        ));
}

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

vec3 rayMarch(vec3 p0, vec3 dir, float side, float radius) {
    float d = sdf(p0,radius);
    float s = sign(d);
    float totalD = 0.0;
    int step = 0;
    while (step < 1000 && d<100.) {
        totalD += d*side;
        vec3 p = p0 + totalD*dir;
        d = sdf(p,radius);
        if (abs(d)<0.0001) return p;
        ++step;
    }
    return vec3(INF);
}

vec4 applyLighting(vec4 baseColor, float fromSource, float specular, vec4 ambientColor, vec4 sourceColor, float gamma) {
    vec3 sumRGB = ambientColor.rgb + sourceColor.rgb;
    float maxLum = max(max (sumRGB.r, sumRGB.g), sumRGB.b);
    if (maxLum == 0.0) return vec4(0.0, 0.0, 0.0, 1.0);

    vec3 color = (baseColor.rgb*ambientColor.rgb + baseColor.rgb*sourceColor.rgb*fromSource + sourceColor.rgb*specular) / maxLum;

    float lum = (color.r+color.g+color.b)/3.0;
    if (lum>0.0 && gamma!=0.0) {
        float gammaCorrectedLum = pow(lum, pow(1.02, -gamma));
        color = color * gammaCorrectedLum/lum;
    }

    return clamp(vec4(color, baseColor.a), 0.0, 1.0);
}    

        vec4 rayMarcher(vec2 uv, vec2 outPos, mat4 model3DTransform, vec2 sourceDim, mat4 lightSourceTransform, mat4 bkgTransform,
                        mat4 camera3DTransform,
                        vec4 colorMaterial, float refractionIndex, float fresnelStrength,
                        float chromaticAberration, vec4 colorFog,
                        vec4 sourceColor, vec4 ambientColor, float specular, int backgroundStyle, float radius) {
            float D = 1.0;
//vec3 camera = vec3(0., 0., D);
            vec3 camera = vec3(0., 0., 0.);
            camera = ((camera3DTransform) * vec4(camera, 1.)).xyz;

            vec3 target = vec3(0.);
            vec3 camDir = getRay(uv, camera, target, 1.); // no longer used
            
            vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            
//mat4 invModelTransform = inverse(model3DTransform);
//mat3 model3DTransform3 = mat3(model3DTransform);
//camera = (invModelTransform * vec4(camera, 1.)).xyz;
//camDir = mat3(invModelTransform) * camDir; 
            
            mat4 invModelTransform = inverse(model3DTransform);
            mat3 model3DTransform3 = mat3(model3DTransform);
            camera = (invModelTransform * vec4(camera, 1.)).xyz;
            vec3 dir = normalize(vec3(uv.x*D, uv.y*D, -1.0));
            dir = mat3(camera3DTransform) * dir;
            camDir = normalize(mat3(invModelTransform) * dir);

            vec4 col = vec4(0., 0., 0., 1.);
            vec4 color = vec4(0., 0., 0., 1.);

            vec3 qIn = rayMarch(camera, camDir, 1.,radius);
            vec3 reflectDir = camDir;
            vec3 reflectK = vec3(1.);
            float ref = refractionIndex;
            float chromaticAbb = chromaticAberration;
            float absorption = pow(mix(30.0, 1000.0, smoothstep(0.95, 1., colorMaterial.a)), colorMaterial.a);

            if (qIn.x!=INF) {
                vec3 nIn = normal(qIn,radius);
                float incidence = abs(dot(nIn, camDir));
                float fresnel = pow(1.0-incidence, 6.-fresnelStrength*6.) * smoothstep(0.0, 0.025, fresnelStrength) * smoothstep(0.0, 0.025, fresnelStrength);                

                reflectDir = reflect(camDir, nIn);
                vec3 reflectivity = vec3(1.) - colorMaterial.rgb;
                reflectK = reflectivity;
                vec3 lightDir = normalize(qIn-lightPos);

                if (fresnel!=1.0) {
                    vec3 refractDir;// = refract(camDir, nIn, ref);
                    float k = 1.0 - ref * ref * (1.0 - dot(nIn, camDir) * dot(nIn, camDir));
                    if (k < 0.0)
                        refractDir = vec3(0.0);       // or genDType(0.0)
                    else
                        refractDir = ref * camDir - (ref * dot(nIn, camDir) + sqrt(k)) * nIn;

                    vec3 qOut = rayMarch(qIn-nIn*0.001, refractDir, -1.,radius);

                    vec3 n = -normal(qOut,radius);

                    vec3 rDir = refract(refractDir, n, 1./ref-chromaticAbb);
                    vec3 refractDirR = (length(rDir)==0.) ? reflect(refractDir, n) : rDir;

                    vec3 gDir = refract(refractDir, n, 1./ref);
                    vec3 refractDirG = (length(gDir)==0.) ? reflect(refractDir, n) : gDir;

                    vec3 bDir = refract(refractDir, n, 1./ref+chromaticAbb);
                    vec3 refractDirB = (length(bDir)==0.) ? reflect(refractDir, n) : bDir;
                    
                    //col = vec4(bkg(refractDirR).r, bkg(refractDirG).g, bkg(refractDirB).b, 1.);
                    //col = vec4(refractDirR.x*0.5+0.5, refractDirG.y*0.5+0.5, refractDirB.z*0.5+0.5, 1.);
                    vec4 colR, colG, colB;
refractDirR = model3DTransform3 * refractDirR;
refractDirG = model3DTransform3 * refractDirG;
refractDirB = model3DTransform3 * refractDirB;
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDirR);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    colR = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDirR).x/(refractDirR).z , -(refractDirR).y/(refractDirR).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    colR = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDirR).y)>abs((refractDirR).z)*_o_ratio && abs((refractDirR).y)>abs((refractDirR).x)*_o_ratio) {
        _o_X += -(refractDirR).x/(refractDirR).y*0.5;
        _o_Y += -(refractDirR).z/(refractDirR).y*0.5;
    }
    else if (abs((refractDirR).x)<abs((refractDirR).z)) {
        _o_X += (refractDirR).x/abs((refractDirR).z)*_o_ratio*0.5 * -sign((refractDirR).z);
        _o_Y += (refractDirR).y/abs((refractDirR).z)*0.5;
    }
    else {
        _o_X += (refractDirR).z/abs((refractDirR).x)*_o_ratio*0.5 * -sign((refractDirR).x);
        _o_Y += (refractDirR).y/abs((refractDirR).x)*0.5;
    }
    colR = __source__(vec2(_o_X, _o_Y));
}
else {
    colR = vec4((refractDirR)*0.5+0.5, 1.0);
}
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDirG);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    colG = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDirG).x/(refractDirG).z , -(refractDirG).y/(refractDirG).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    colG = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDirG).y)>abs((refractDirG).z)*_o_ratio && abs((refractDirG).y)>abs((refractDirG).x)*_o_ratio) {
        _o_X += -(refractDirG).x/(refractDirG).y*0.5;
        _o_Y += -(refractDirG).z/(refractDirG).y*0.5;
    }
    else if (abs((refractDirG).x)<abs((refractDirG).z)) {
        _o_X += (refractDirG).x/abs((refractDirG).z)*_o_ratio*0.5 * -sign((refractDirG).z);
        _o_Y += (refractDirG).y/abs((refractDirG).z)*0.5;
    }
    else {
        _o_X += (refractDirG).z/abs((refractDirG).x)*_o_ratio*0.5 * -sign((refractDirG).x);
        _o_Y += (refractDirG).y/abs((refractDirG).x)*0.5;
    }
    colG = __source__(vec2(_o_X, _o_Y));
}
else {
    colG = vec4((refractDirG)*0.5+0.5, 1.0);
}
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDirB);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    colB = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDirB).x/(refractDirB).z , -(refractDirB).y/(refractDirB).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    colB = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDirB).y)>abs((refractDirB).z)*_o_ratio && abs((refractDirB).y)>abs((refractDirB).x)*_o_ratio) {
        _o_X += -(refractDirB).x/(refractDirB).y*0.5;
        _o_Y += -(refractDirB).z/(refractDirB).y*0.5;
    }
    else if (abs((refractDirB).x)<abs((refractDirB).z)) {
        _o_X += (refractDirB).x/abs((refractDirB).z)*_o_ratio*0.5 * -sign((refractDirB).z);
        _o_Y += (refractDirB).y/abs((refractDirB).z)*0.5;
    }
    else {
        _o_X += (refractDirB).z/abs((refractDirB).x)*_o_ratio*0.5 * -sign((refractDirB).x);
        _o_Y += (refractDirB).y/abs((refractDirB).x)*0.5;
    }
    colB = __source__(vec2(_o_X, _o_Y));
}
else {
    colB = vec4((refractDirB)*0.5+0.5, 1.0);
}
                    col = vec4(colR.r, colG.g, colB.b, 1.);
                    
                    //float absorbed = min(1.0, absorption * pow(2.0, length(qI n-qOut)));
                    float absorbed = 1.0 - pow(0.5, absorption * length(qIn-qOut));
                    absorbed = mix(0.0, absorbed, smoothstep(0.0, 0.1, colorMaterial.a));
                    
                    color.rgb += colorMaterial.rgb * (1.0-fresnel) * (1.-absorbed) * col.rgb;                    
                    color.rgb += absorbed * colorMaterial.rgb * (ambientColor.rgb + max(0.0, dot(nIn, lightDir))*sourceColor.rgb);
                }

                if (fresnel!=0.0 || specular!=0.0) {
                    vec3 origReflectDir = reflectDir;
                    vec3 qR = rayMarch(qIn+nIn*0.001, reflectDir, 1.,radius);
                    if (qR.x!=INF) {
                         vec3 n = normal(qR,radius);
                         reflectDir = reflect(reflectDir, n);
                    }
reflectDir = model3DTransform3 * reflectDir;
                    if (backgroundStyle==0) {
    vec3 _o_n = normalize(reflectDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    col = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(reflectDir).x/(reflectDir).z , -(reflectDir).y/(reflectDir).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    col = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((reflectDir).y)>abs((reflectDir).z)*_o_ratio && abs((reflectDir).y)>abs((reflectDir).x)*_o_ratio) {
        _o_X += -(reflectDir).x/(reflectDir).y*0.5;
        _o_Y += -(reflectDir).z/(reflectDir).y*0.5;
    }
    else if (abs((reflectDir).x)<abs((reflectDir).z)) {
        _o_X += (reflectDir).x/abs((reflectDir).z)*_o_ratio*0.5 * -sign((reflectDir).z);
        _o_Y += (reflectDir).y/abs((reflectDir).z)*0.5;
    }
    else {
        _o_X += (reflectDir).z/abs((reflectDir).x)*_o_ratio*0.5 * -sign((reflectDir).x);
        _o_Y += (reflectDir).y/abs((reflectDir).x)*0.5;
    }
    col = __source__(vec2(_o_X, _o_Y));
}
else {
    col = vec4((reflectDir)*0.5+0.5, 1.0);
}
                    //col = vec4(bkg(reflectDir), 1.);
                    color.rgb += fresnel * col.rgb;
                    
                    // specular
                    float kSpec = 10.0 * specular * pow(max(0.0, dot(lightDir, origReflectDir)), 9.0);
                    color.rgb += sourceColor.rgb * kSpec;
                }
                
                // fog
                if (colorFog.a!=0.0) {
                    float dist = length(camera - qIn);
                    float kFog = 1.0 - pow(0.4, colorFog.a * max(0.0, dist-0.1));
                    color.rgb = mix(color.rgb, colorFog.rgb, kFog);
                }
                
            }
            else {
camDir = mat3(bkgTransform) * model3DTransform3 * camDir;
                if (backgroundStyle==0) {
    vec3 _o_n = normalize(camDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    col = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(camDir).x/(camDir).z , -(camDir).y/(camDir).z)*1.0 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    col = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((camDir).y)>abs((camDir).z)*_o_ratio && abs((camDir).y)>abs((camDir).x)*_o_ratio) {
        _o_X += -(camDir).x/(camDir).y*0.5;
        _o_Y += -(camDir).z/(camDir).y*0.5;
    }
    else if (abs((camDir).x)<abs((camDir).z)) {
        _o_X += (camDir).x/abs((camDir).z)*_o_ratio*0.5 * -sign((camDir).z);
        _o_Y += (camDir).y/abs((camDir).z)*0.5;
    }
    else {
        _o_X += (camDir).z/abs((camDir).x)*_o_ratio*0.5 * -sign((camDir).x);
        _o_Y += (camDir).y/abs((camDir).x)*0.5;
    }
    col = __source__(vec2(_o_X, _o_Y));
}
else {
    col = vec4((camDir)*0.5+0.5, 1.0);
}
                if (colorFog.a!=0.0) color.rgb = colorFog.rgb; else color = col;
            }

            return clamp(color, 0.0, 1.0);
        }
