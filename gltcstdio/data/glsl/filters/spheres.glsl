float sphereHitDist(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin - center;
    float a = dot(dir, dir);
    float b = 2.0 * dot(dir, relOrigin);
    float c = dot(relOrigin, relOrigin) - radius * radius;
    float delta = b * b - 4.0 * a * c;
    if (delta >= 0.0) {
        float sqrtDelta = sqrt(delta);
        float l1 = (-b - sqrtDelta) / (2.0 * a);
        float l2 = (-b + sqrtDelta) / (2.0 * a);
        float l = l1 > 0.0 ? l1 : (l2 > 0.0 ? l2 : -1.0);
        if (l > 0.0) {
            return l;
        }
    }
    return -1.0;
}

        vec4 spheres(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim,
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

            do {
                minK = 999999.99;
                minI = -1;
                for (int i = 0; i < spheres_size; ++i) {
                    float k = sphereHitDist(spheres[i].xyz, spheres[i].a, origin, dir);
                    if (k > 0.0 && k < minK) {
                        minK = k;
                        minI = i;
                    }
                    else {
                        minDist = min(minDist, abs(length(cross(dir, cameraPos - spheres[i].xyz)) / length(dir) - spheres[i].a));
                    }
                }
                if (minI >= 0) {
                    vec3 center = spheres[minI].xyz;
                    vec3 intersection = origin + minK * dir;
                    vec3 relInt = intersection - center;
                    vec3 normal = length(origin - center) <= spheres[minI].a ? -normalize(relInt) : normalize(relInt);
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
                        reflectedColor = _reflBkg * mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(2.0 * objectColor.rgb, 1.0), objectColor.a);
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
            vec4 col = _bkg * mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(2.0 * bkgColor.rgb, 1.0), bkgColor.a) + vec4(glowColor.rgb * 0.2 / pow(minDist, 1.5), 0.0) * glowColor.a;

            return mix(reflectedColor, col, clamp(0.0, 1.0, incidence + balance));
        }
