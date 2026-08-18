float getFog(float dist, float alpha) {
    return max((dist-0.5)*4.0, 0.0) * alpha;
}

vec3 getIntersectionD(vec3 origin, vec3 dir, float radius) {
    float minDist = 1e9;
    float k = 0.0;
    vec2 kBounds = sphereIntersectionSpec(vec3(0.0, 0.0, 0.0), 0.5*(1.0+radius*2.0), origin, dir);
    float kk = kBounds.x;
    if (kk<0.0) return vec3(kk, 0.0, minDist);

    float de = 0.0001;
    int maxIter = 1256;
    int iter = 0;
    vec3 p = origin;
    float dist = implicitFn(p, radius);
    while (abs(dist)>de && iter<maxIter) {
        k += abs(dist)*0.5;
        p = origin + k*dir;
        dist = implicitFn(p, radius);
        minDist = min(minDist, abs(dist));
        ++iter;
    }
    return dist<de ? vec3(k, iter, minDist) : vec3(-1.0, iter, minDist);
}

float implicitFn(vec3 p, float radius) {
    float R = 0.5;
    float r = R*radius*2.0;
    float a = sqrt(p.x*p.x + p.y*p.y) - R;
    return sqrt(a*a + p.z*p.z) - r;
}

vec2 sphereIntersectionSpec(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius*radius;
    float delta = b*b - 4.0*a*c; //147
    if (delta>=0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0*a);
        float l2 = (-b + sqrtDelta) / (2.0*a);
        float l = l1>0.0 ? l1 : (l2>0.0 ? l2 : -1.0);
        if (l>0.0) {
            return vec2(max(0.0, l1), l2);
        }
    }
    return vec2(-1.0, -1.0);
}

        vec4 torusMap(vec2 pos, vec2 outPos, float radius, float blend, vec4 colorFog, vec2 sourceDim, mat4 model3DTransform, mat3 texTransform) {
            vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
            mat3 invTt = inverse(texTransform);
            
            float D = 1.6666666666666667;
            vec3 cameraPos = vec3(0., 0., 0.);
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = normalize(mat3(m) * dir);
        
            vec3 origin = cameraPos;
            vec3 inters = getIntersectionD(origin, dir, radius);
        
            float k = inters.x;
        
            float ratio = sourceDim.x/sourceDim.y;
            blend = blend*0.5;
            float width = ratio*(1.0-blend);
            float height = 1.0-blend;
            float bWidth = width - ratio*blend;
            float bHeight = height - blend;
        
            if (k>0.0) {
        
                vec3 intersection = origin + k*dir;
        
                float R = 0.5;
                float r = R*radius*2.0;
                float x = atan(intersection.x, intersection.y) / PI * width;
                float a = sqrt(intersection.x*intersection.x + intersection.y*intersection.y) - R;
                float y = atan(a, -intersection.z) / PI * height;
        
                vec4 col;
                if (blend == 0.0) col = __source__(tf(invTt, vec2(x, y)));
                else {
                    vec2 u00 = tf(invTt, vec2(x, y));
                    vec2 u10 = tf(invTt, vec2(x-sign(x)*(ratio+bWidth), y));
                    vec2 u01 = tf(invTt, vec2(x, y-sign(y)*(1.0+bHeight)));
                    vec2 u11 = tf(invTt, vec2(x-sign(x)*(ratio+bWidth), y-sign(y)*(1.0+bHeight)));
                    col = mix(
                        mix(__source__(u00), __source__(u10), smoothstep(0.0, 2.0*blend*ratio, abs(x)-bWidth)),
                        mix(__source__(u01), __source__(u11), smoothstep(0.0, 2.0*blend*ratio, abs(x)-bWidth)),
                        smoothstep(0.0, 2.0*blend, abs(y)-bHeight)
                    );
                }
        
                float dist = length(origin-intersection);
                float fog = getFog(dist, colorFog.a);
                return vec4(mix(col.rgb, colorFog.rgb, fog), col.a);
            }
            else {
                vec4 col = vec4(0.0, 0.0, 0.0, 1.0); //background(dir);
                float dist = 2.0;
                float fog = clamp(0.0, 1.0, getFog(dist, colorFog.a));
                return vec4(mix(col.rgb, colorFog.rgb, fog), col.a);
            }
        }            
