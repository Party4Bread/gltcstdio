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

float sdf2(vec3 p) {
    float R = 0.5;
    float r = R*0.2;
    float a = sqrt(p.x*p.x + p.y*p.y) - R;
    float ang = atan(p.y, p.x)*0.5*(4.0-1.0);
    float ca = cos(ang);
    float sa = sin(ang);
    mat2 rot = mat2(ca, sa, sa, -ca);
    vec2 q = rot * vec2(a, p.z);
    if (q.x<0.0) q = -q;
    vec2 c1 = vec2(0.15, 0.);
    return 0.4*(length(q-c1) - r);
}

float sdf(vec3 p) {
    float R = 0.5;
    float r = R*0.2;
    float a = sqrt(p.x*p.x + p.y*p.y) - R;
    float ang = atan(p.y, p.x)*0.5*(6.0-1.0);
    float ca = cos(ang);
    float sa = sin(ang);
    mat2 rot = mat2(ca, sa, sa, -ca);
    vec2 q = rot * vec2(a, p.z);
    if (q.x<0.0) q = -q;
    vec2 c1 = vec2(0.15, 0.);
    vec2 d = abs(q-c1)-r;
    return 0.4*(length(max(d,0.0)) + min(max(d.x,d.y),0.0)); 
    //return 0.14*(length(max(q,0.0)) + min(max(q.x,q.y),0.0)); // interesting results using q instead of d but messy.
}

float sdf0(vec3 p) {
    p = abs(p)-0.3;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

float sdf1(vec3 p) {
	return length(p)-0.75;
}

vec3 normal(vec3 p) {
    float d = 0.0001;
    float d2 = d*2.0;
    return normalize(vec3(
        (sdf(vec3(p.x+d, p.y, p.z))-sdf(vec3(p.x-d, p.y, p.z)))/d2,
        (sdf(vec3(p.x, p.y+d, p.z))-sdf(vec3(p.x, p.y-d, p.z)))/d2,
        (sdf(vec3(p.x, p.y, p.z+d))-sdf(vec3(p.x, p.y, p.z-d)))/d2
        ));
}

vec3 getRay(vec2 uv, vec3 camera, vec3 target, float focalDist) {
    vec3 camZ = normalize(target-camera);
    vec3 camX = normalize(cross(vec3(0.,1.,0.), camZ));
    vec3 camY = cross(camZ,camX);
    return normalize(camZ*focalDist + uv.x*camX + uv.y*camY);
}

vec3 rayMarch(vec3 p0, vec3 dir) {
    float d = sdf(p0);
    float s = sign(d);
    float totalD = 0.0;
    int step = 0;
    while (step < 1000 && d<100.0) {
        totalD += abs(d)*1.0;
        vec3 p = p0 + totalD*dir;
        d = sdf(p);
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

vec4 getBackground(vec2 pos) {
    return vec4(0.0, 0.0, 0.0, 1.0);
}

        vec4 basicRayMarcher(vec2 uv, vec2 outPos, mat4 model3DTransform, vec2 sourceDim, mat4 lightSourceTransform, float colorScheme,
                        vec4 colorTransmission, float refractionIndex,
                        vec4 sourceColor, vec4 ambientColor, float specular, float shadows, int backgroundStyle) {
            float D = 2.;
            vec3 camera = vec3(0., 0., D);
            camera = ((model3DTransform) * vec4(camera, 1.)).xyz;
        
            vec3 target = vec3(0.);
            vec3 camDir = getRay(uv, camera, target, 1.);
                
            vec4 col = vec4(0., 0., 0., 1.);
            vec4 color = vec4(0., 0., 0., 1.);
            
            vec3 q = rayMarch(camera, camDir);
            vec3 reflectDir = camDir;
            vec3 reflectK = vec3(1.);
            
            if (q.x!=INF) {
                vec3 n = normal(q);
                float incidence = abs(dot(n, camDir));
                reflectDir = reflect(camDir, n);
                reflectK = vec3(1.) - colorTransmission.rgb;
                if (length(colorTransmission.rgb)!=0.0) {
                    vec3 refractDir = refract(camDir, n, refractionIndex);
                    q = rayMarch(q-n*0.001, refractDir);
                    if (q.x!=INF) {
                         n = normal(q);
                         refractDir = refract(refractDir, -n, 1./refractionIndex);
                         if (backgroundStyle==0) {
    vec3 _o_n = normalize(refractDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_ratio = sourceDim.x/sourceDim.y;
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    col = __source__(vec2(-_o_alpha/PI*0.5*_o_nX, 0.5+_o_nY*_o_beta/PI));
}
else if (backgroundStyle==1) {
    vec2 _o_pos = vec2(-(refractDir).x/(refractDir).z * sourceDim.y/sourceDim.x, -(refractDir).y/(refractDir).z)*0.5 ;
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0/max(4.0, _o_m);
    col = __source__(_o_pos)*vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle==2) {
    float _o_ratio = sourceDim.y/sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractDir).y)>abs((refractDir).z)*_o_ratio && abs((refractDir).y)>abs((refractDir).x)*_o_ratio) {
        _o_X += -(refractDir).x/(refractDir).y*0.5;
        _o_Y += -(refractDir).z/(refractDir).y*0.5;
    }
    else if (abs((refractDir).x)<abs((refractDir).z)) {
        _o_X += (refractDir).x/abs((refractDir).z)*_o_ratio*0.5 * -sign((refractDir).z);
        _o_Y += (refractDir).y/abs((refractDir).z)*0.5;
    }
    else {
        _o_X += (refractDir).z/abs((refractDir).x)*_o_ratio*0.5 * -sign((refractDir).x);
        _o_Y += (refractDir).y/abs((refractDir).x)*0.5;
    }
    col = __source__(vec2(_o_X, _o_Y));
}
else {
    col = vec4((refractDir)*0.5+0.5, 1.0);
}
                         color.rgb += colorTransmission.rgb * col.rgb;
                    }
                    else {
                        color.rgb = vec3(1., 0., 0.);
                    }       
                }
            }

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
    vec2 _o_pos = vec2(-(reflectDir).x/(reflectDir).z * sourceDim.y/sourceDim.x, -(reflectDir).y/(reflectDir).z)*0.5 ;
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
            color.rgb += reflectK * col.rgb;
        
            return clamp(color, 0.0, 1.0);
        }            
