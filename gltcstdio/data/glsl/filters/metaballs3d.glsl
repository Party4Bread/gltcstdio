float implicitFn(vec3 p, vec4[32] spheres, int spheres_size) {
    float total = 0.0;
    for (int i = 0; i < spheres_size; ++i) {
        total += 1.0 / length(spheres[i].xyz - p) - 1.0 / spheres[i].a;
    }
    return total;
}

vec3 getNormal(vec3 p, vec4[32] spheres, int spheres_size) {
    float d = 0.01;
    float d2 = d * 2.0;
    return normalize(vec3(
        (implicitFn(vec3(p.x - d, p.y, p.z), spheres, spheres_size) - implicitFn(vec3(p.x + d, p.y, p.z), spheres, spheres_size)) / d2,
        (implicitFn(vec3(p.x, p.y - d, p.z), spheres, spheres_size) - implicitFn(vec3(p.x, p.y + d, p.z), spheres, spheres_size)) / d2,
        (implicitFn(vec3(p.x, p.y, p.z - d), spheres, spheres_size) - implicitFn(vec3(p.x, p.y, p.z + d), spheres, spheres_size)) / d2
    ));
}

vec3 getIntersectionD(vec3 origin, vec3 dir, float sphereRad, vec4[32] spheres, int spheres_size) {
    float minDist = 1e9;
    vec2 kBounds = sphereIntersectionK(vec3(0.0), sphereRad, origin, dir);
    if (kBounds.x >= 1e8) return vec3(-1.0, 0.0, minDist);
    float k0 = max(0.0, kBounds.x);
    float k1 = k0;

    float originSign = sign(implicitFn(origin, spheres, spheres_size));
    float steps = 100.0;
    float dk = (kBounds.y - k0) / steps;
    vec3 x0 = origin + k0 * dir;
    vec3 x1 = x0;
    float a = implicitFn(x0, spheres, spheres_size);
    float b = a;

    do {
        k0 = k1;
        x0 = x1;
        a = b;
        k1 += dk;
        x1 = origin + k1 * dir;
        b = implicitFn(x1, spheres, spheres_size);
        minDist = min(minDist, abs(b));
    } while (k1 < kBounds.y && sign(b) == originSign);

    if (sign(b) == originSign) return vec3(-1.0, 0.0, minDist);

    float de = 0.001;
    int maxSecantIter = 100;
    int iter = 0;
    while (iter < maxSecantIter) {
        float dy = b - a;
        dk = k1 - k0;
        float deriv = dy / dk;

        float k2 = k0 - a / deriv;
        if (k2 < kBounds.x || k2 > kBounds.y) k2 = (k0 + k1) / 2.0;

        vec3 x2 = origin + k2 * dir;
        float c = implicitFn(x2, spheres, spheres_size);
        minDist = min(minDist, abs(c));
        if (abs(c) < de) return vec3(k2, float(iter), minDist);

        if (sign(a) != sign(c)) {
            k1 = k2;
            b = c;
        }
        else {
            k0 = k2;
            a = c;
        }

        ++iter;
    }
    return vec3((k0 + k1) / 2.0, float(iter), minDist);
}

        vec4 metaballs3d(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim,
                     float intensity, float reflectivity,
                     vec4 objectColor, vec4 glowColor, vec4 bkgColor,
                     int backgroundStyle,
                     vec4[32] spheres, int spheres_size) {

            mat4 invModelTransform = inverse(model3DTransform);
            vec3 cameraPos = (invModelTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            float D = 1.0;
            vec3 dir = normalize(vec3(pos.x * D, pos.y * D, -1.0));
            dir = mat3(invModelTransform) * dir;

            float eta = 1.0 - 2.0 * intensity;

            vec3 origin = cameraPos;
            int maxIter = 12;
            int iter = maxIter;
            int minI = -1;
            float minK = 999999.99;
            float incidence = 2.0;
            vec4 reflectedColor = vec4(0.0, 0.0, 0.0, 1.0);
            float minDist = 1e9;
            bool objectIntersected = false;

            float sphereRad = (glowColor.r == 0.0 && glowColor.g == 0.0 && glowColor.b == 0.0) ? 2.5 : 5.0;

            do {
                minK = 999999.99;
                minI = -1;

                vec3 inters = getIntersectionD(origin, dir, sphereRad, spheres, spheres_size);
                float k = inters.x;
                if (k > 0.0 && k < minK) {
                    minK = k;
                    minI = 0;
                    objectIntersected = true;
                }
                else if (iter == maxIter) {
                    minDist = min(minDist, inters.z);
                }

                if (minI >= 0) {
                    vec3 intersection = origin + minK * dir;
                    vec3 normal = implicitFn(origin, spheres, spheres_size) <= 0.0 ? getNormal(intersection, spheres, spheres_size) : -getNormal(intersection, spheres, spheres_size);
                    if (iter == maxIter) {
                        incidence = abs(dot(normal, dir));
                        vec3 reflectedDir = reflect(dir, normal);
                        vec4 _reflBkg = vec4(0.0);
                        if (backgroundStyle == 0) {
    vec3 _o_n = normalize(reflectedDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    vec2 _o_pos = vec2(-_o_alpha / PI * 0.5 * _o_nX, 0.5 + _o_nY * _o_beta / PI) * 2.0 - 1.0;
    _reflBkg = __source__(_o_pos);
}
else if (backgroundStyle == 1) {
    vec2 _o_pos = vec2(-(reflectedDir).x / (reflectedDir).z, -(reflectedDir).y / (reflectedDir).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    _reflBkg = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle == 2) {
    float _o_ratio = sourceDim.y / sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((reflectedDir).y) > abs((reflectedDir).z) * _o_ratio && abs((reflectedDir).y) > abs((reflectedDir).x) * _o_ratio) {
        _o_X += -(reflectedDir).x / (reflectedDir).y * 0.5;
        _o_Y += -(reflectedDir).z / (reflectedDir).y * 0.5;
    }
    else if (abs((reflectedDir).x) < abs((reflectedDir).z)) {
        _o_X += (reflectedDir).x / abs((reflectedDir).z) * _o_ratio * 0.5 * -sign((reflectedDir).z);
        _o_Y += (reflectedDir).y / abs((reflectedDir).z) * 0.5;
    }
    else {
        _o_X += (reflectedDir).z / abs((reflectedDir).x) * _o_ratio * 0.5 * -sign((reflectedDir).x);
        _o_Y += (reflectedDir).y / abs((reflectedDir).x) * 0.5;
    }
    _reflBkg = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    _reflBkg = vec4((reflectedDir) * 0.5 + 0.5, 1.0);
}
                        reflectedColor = _reflBkg;
                    }
                    dir = refract(dir, normal, eta);
                    origin = intersection + dir * 0.001;
                }

                --iter;
            } while (minI >= 0 && iter > 0);

            float balance = 1.0 - 2.0 * reflectivity;
            vec4 _bkg = vec4(0.0);
            if (backgroundStyle == 0) {
    vec3 _o_n = normalize(dir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    vec2 _o_pos = vec2(-_o_alpha / PI * 0.5 * _o_nX, 0.5 + _o_nY * _o_beta / PI) * 2.0 - 1.0;
    _bkg = __source__(_o_pos);
}
else if (backgroundStyle == 1) {
    vec2 _o_pos = vec2(-(dir).x / (dir).z, -(dir).y / (dir).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    _bkg = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle == 2) {
    float _o_ratio = sourceDim.y / sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((dir).y) > abs((dir).z) * _o_ratio && abs((dir).y) > abs((dir).x) * _o_ratio) {
        _o_X += -(dir).x / (dir).y * 0.5;
        _o_Y += -(dir).z / (dir).y * 0.5;
    }
    else if (abs((dir).x) < abs((dir).z)) {
        _o_X += (dir).x / abs((dir).z) * _o_ratio * 0.5 * -sign((dir).z);
        _o_Y += (dir).y / abs((dir).z) * 0.5;
    }
    else {
        _o_X += (dir).z / abs((dir).x) * _o_ratio * 0.5 * -sign((dir).x);
        _o_Y += (dir).y / abs((dir).x) * 0.5;
    }
    _bkg = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    _bkg = vec4((dir) * 0.5 + 0.5, 1.0);
}
            vec4 mixedCol = mix(reflectedColor, _bkg, clamp(0.0, 1.0, incidence + balance));
            if (objectIntersected) mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * objectColor.rgb, 1.0), objectColor.a);
            else mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * bkgColor.rgb, 1.0), bkgColor.a);
            float glowIntensity = 1.4 / pow(minDist, clamp(1.0, 3.0, minDist));
            vec4 glowCol = mixedCol + vec4(glowColor.rgb * glowIntensity, 0.0) * glowColor.a;
            return glowCol;
        }
