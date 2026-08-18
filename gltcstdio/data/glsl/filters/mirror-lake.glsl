vec3 getPlaneIntersection(float y, vec3 camera, vec3 dir) {
    float k = (y-camera.y)/dir.y;
    if (k>0.0) return camera + k*dir;
    else return vec3(INF);
}

float getSurface(vec2 xz, float period, float ar, float intensity, float regularity) {
    return intensity * 10. * mix(perlinNoise(xz*vec2(1./ar, 1.)/period), 0.4*sin(xz.y/period), regularity);
    
}

vec3 getNormal(vec3 p, float period, float ar, float intensity, float regularity) {
    float d = period*0.001;
    float y = getSurface(p.xz, period, ar, intensity, regularity);
    float yx = getSurface(vec2(p.x+d, p.z), period, ar, intensity, regularity);
    float yz = getSurface(vec2(p.x, p.z+d), period, ar, intensity, regularity);
    return normalize(vec3((yx-y)/d, 1.0, (yz-y)/d));
}

vec4 mirrorLake(vec2 uv, vec2 outPos, float intensity, float shapeAspectRatio, float regularity, mat3 modelTransform) {
    uv = tf(inverse(modelTransform), uv);
    
    float zoom = 1./pow(length(modelTransform[0].xy), 2.);

    vec3 dir = normalize(vec3(uv, zoom));
    vec3 camera = vec3(0.0, -500.0, 0.0); // set to 500 to flip orientation of the effect
    float Y = 0.0;
    vec4 color = vec4(1.0);
    vec3 intersection = getPlaneIntersection(Y, camera, dir);
    if (intersection.x!=INF) {
        vec3 normal = getNormal(intersection, 100., shapeAspectRatio, intensity, regularity);
        dir = reflect(dir, normal);
    }
    
    vec2 u = dir.xy / dir.z * zoom;
    
    u = tf(modelTransform, u);
    
    return __source__(u);
}
