float torusSphereSdfSmin(float a, float b) {
    // Pap's exp-based smooth-min with k=32, clamped to avoid log(0).
    float k = 32.0;
    float res = exp(-k * a) + exp(-k * b);
    return -log(max(0.0001, res)) / k;
}

float torusSphereImplicitFn(vec3 p, float radius) {
    float R = 0.5;
    float r = R * radius;
    vec2 q1 = vec2(sqrt(p.x * p.x + p.y * p.y) - R, p.z);
    vec2 q2 = vec2(sqrt(p.x * p.x + p.z * p.z) - R, p.y);
    vec2 q3 = vec2(sqrt(p.z * p.z + p.y * p.y) - R, p.x);
    return torusSphereSdfSmin(length(q1) - r, torusSphereSdfSmin(length(q2) - r, length(q3) - r));
}

vec2 torusSphereBoundingSphereK(vec3 center, float radius, vec3 origin, vec3 dir) {
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
        if (l > 0.0) return vec2(max(0.0, l1), l2);
    }
    return vec2(-1.0, -1.0);
}

vec3 torusSphereRayMarch(vec3 origin, vec3 dir, float radius, vec4 glowColor) {
    // Pap only applies the bounding-sphere early-out when glow is black.
    // 0.5*(1 + 1.25 + u_Radius*0.02) becomes 0.5*(2.25 + radius) in bank units.
    float minDist = 1e9;
    float k = 0.0;
    if (glowColor.r == 0.0 && glowColor.g == 0.0 && glowColor.b == 0.0) {
        vec2 kBounds = torusSphereBoundingSphereK(vec3(0.0), 0.5 * (2.25 + radius), origin, dir);
        float kk = kBounds.x;
        if (kk < 0.0) return vec3(kk, 0.0, minDist);
    }
    float de = 0.0001;
    int maxIter = 1256;
    int iter = 0;
    vec3 p = origin;
    float dist = torusSphereImplicitFn(p, radius);
    while (abs(dist) > de && iter < maxIter) {
        k += abs(dist);
        p = origin + k * dir;
        dist = torusSphereImplicitFn(p, radius);
        minDist = min(minDist, abs(dist));
        ++iter;
    }
    return dist < de ? vec3(k, float(iter), minDist) : vec3(-1.0, float(iter), minDist);
}

vec3 torusSphereNormal(vec3 p, float radius) {
    float d = 0.0001;
    float d2 = d * 2.0;
    return normalize(vec3(
        (torusSphereImplicitFn(vec3(p.x - d, p.y, p.z), radius) - torusSphereImplicitFn(vec3(p.x + d, p.y, p.z), radius)) / d2,
        (torusSphereImplicitFn(vec3(p.x, p.y - d, p.z), radius) - torusSphereImplicitFn(vec3(p.x, p.y + d, p.z), radius)) / d2,
        (torusSphereImplicitFn(vec3(p.x, p.y, p.z - d), radius) - torusSphereImplicitFn(vec3(p.x, p.y, p.z + d), radius)) / d2
    ));
}

        vec4 torusSphereGl(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim,
                           float intensity, float reflectivity, float radius,
                           vec4 objectColor, vec4 glowColor, vec4 bkgColor,
                           int backgroundStyle) {
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

            do {
                minK = 999999.99;
                minI = -1;
                vec3 inters = torusSphereRayMarch(origin, dir, radius, glowColor);
                float k = inters.x;
                if (k > 0.0 && k < minK) { minK = k; minI = 0; objectIntersected = true; }
                else if (iter == maxIter) { minDist = min(minDist, inters.z); }

                if (minI >= 0) {
                    vec3 intersection = origin + minK * dir;
                    vec3 normal = torusSphereImplicitFn(origin, radius) <= 0.0
                        ? torusSphereNormal(intersection, radius)
                        : -torusSphereNormal(intersection, radius);
                    if (iter == maxIter) {
                        incidence = abs(dot(normal, dir));
                        vec3 reflectedDir = reflect(dir, normal);
                        vec4 _reflBkg = vec4(0.0);
                        if (backgroundStyle == 0) {
    vec3 _o_n = normalize(reflectedDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    _reflBkg = __source__(vec2(-_o_alpha / PI * 2.0, 2.0 * _o_beta / PI));
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
    _bkg = __source__(vec2(-_o_alpha / PI * 2.0, 2.0 * _o_beta / PI));
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
            // Preserve Pap's clamp(0.0, 1.0, x) quirk = min(1, x).
            vec4 mixedCol = mix(reflectedColor, _bkg, clamp(0.0, 1.0, incidence + balance));
            if (objectIntersected) mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * objectColor.rgb, 1.0), objectColor.a);
            else mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * bkgColor.rgb, 1.0), bkgColor.a);
            // Pap torus-sphere glow uses linear falloff (pow(minDist, 1.0)).
            return mixedCol + vec4(glowColor.rgb * 0.1 / pow(minDist, 1.0), 0.0) * glowColor.a;
        }
