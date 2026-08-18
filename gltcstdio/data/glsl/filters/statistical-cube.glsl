float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec4 statisticalCube(vec2 pos, vec2 outPos, float intensity, mat4 model3DTransform, vec2 sourceDim) {
    vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);

    mat4 m = inverse(model3DTransform);
    vec3 cameraPos = (m * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
    dir = mat3(m) * dir;

    float maxZ = abs(intensity)*0.02;
    float ratio = (sourceDim.x/sourceDim.y);
    float dk = 2.0/sourceDim.y;
    vec3 step = dir * dk;

    float k1 = 0.0;
    float k2 = 100000000.0;

    // Ray-box intersection for X bounds
    if (dir.x>0.0) {
        float k3 = (-ratio-cameraPos.x)/dir.x;
        float k4 = (ratio-cameraPos.x)/dir.x;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    else if (dir.x<0.0) {
        float k3 = (ratio-cameraPos.x)/dir.x;
        float k4 = (-ratio-cameraPos.x)/dir.x;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    // Ray-box intersection for Y bounds
    if (dir.y>0.0) {
        float k3 = (-1.0-cameraPos.y)/dir.y;
        float k4 = (1.0-cameraPos.y)/dir.y;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    else if (dir.y<0.0) {
        float k3 = (1.0-cameraPos.y)/dir.y;
        float k4 = (-1.0-cameraPos.y)/dir.y;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    // Ray-box intersection for Z bounds
    if (dir.z>0.0) {
        float k3 = (-maxZ-cameraPos.z)/dir.z;
        float k4 = (maxZ-cameraPos.z)/dir.z;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    else if (dir.z<0.0) {
        float k3 = (maxZ-cameraPos.z)/dir.z;
        float k4 = (-maxZ-cameraPos.z)/dir.z;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    // No intersection with the cube
    if (k1>k2) return backgroundColor;

    // March along the ray, looking for height surface intersection
    float k = k1;
    vec3 p = cameraPos + k*dir;
    vec4 color = backgroundColor;
    float h = 0.0;
    float dz = 0.0;
    float prevDz;
    vec4 prevColor;
    float prevH;
    bool stop;
    do {
        prevColor = color;
        prevDz = dz;
        prevH = h;

        color = __source__(p.xy);
        h = height(intensity, color);
        dz = p.z-h;

        p += step;
        k += dk;
        stop = dz==0.0 || (k!=k1 && sign(dz)==-sign(prevDz));
    } while (k<=k2 && !stop);

    stop = stop || abs(dz)<dk;

    // Return intersection statistics:
    // R = cube depth, G = hit flag, B = normalized hit distance
    return vec4((k2-k1), stop?1.0:0.0, (k-k1)/(k2-k1), 1.0);
}
