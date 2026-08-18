vec3 cubeFaceNormal(vec3 center, vec3 intersection) {
    vec3 delta = intersection - center;
    vec3 a = abs(delta);
    if (a.x > a.y && a.x > a.z) return vec3(sign(delta.x), 0.0, 0.0);
    else if (a.y > a.z) return vec3(0.0, sign(delta.y), 0.0);
    else return vec3(0.0, 0.0, sign(delta.z));
}

        vec4 cubeGl(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim,
                    float intensity, float reflectivity,
                    vec4 objectColor, vec4 glowColor, vec4 bkgColor,
                    int backgroundStyle) {
            mat4 invModelTransform = inverse(model3DTransform);
            vec3 cameraPos = (invModelTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            float D = 1.0;
            vec3 dir = normalize(vec3(pos.x * D, pos.y * D, -1.0));
            dir = mat3(invModelTransform) * dir;

            float radius = 0.25;
            vec3 intersection = cubeIntersection(vec3(0.0), radius, cameraPos, dir);
            if (intersection.x < 1e8) {
                vec3 normal = cubeFaceNormal(vec3(0.0), intersection);
                float eta = 1.0 - 2.0 * intensity;
                float incidence = abs(dot(normal, dir));
                vec3 refractedDir = refract(dir, normal, eta);
                vec3 reflectedDir = reflect(dir, normal);
                vec4 reflectedColor = vec4(0.0);
                if (backgroundStyle == 0) {
    vec3 _o_n = normalize(reflectedDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    vec2 _o_pos = vec2(-_o_alpha / PI * 0.5 * _o_nX, 0.5 + _o_nY * _o_beta / PI) * 2.0 - 1.0;
    reflectedColor = __source__(_o_pos);
}
else if (backgroundStyle == 1) {
    vec2 _o_pos = vec2(-(reflectedDir).x / (reflectedDir).z, -(reflectedDir).y / (reflectedDir).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    reflectedColor = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
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
    reflectedColor = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    reflectedColor = vec4((reflectedDir) * 0.5 + 0.5, 1.0);
}

                vec3 intersection2 = cubeIntersection(vec3(0.0), radius, intersection + refractedDir * 0.00001, refractedDir);
                if (intersection2.x < 1e8) {
                    normal = -cubeFaceNormal(vec3(0.0), intersection2);
                    refractedDir = refract(refractedDir, normal, eta);
                }

                vec4 refractedColor = vec4(0.0);
                if (backgroundStyle == 0) {
    vec3 _o_n = normalize(refractedDir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    vec2 _o_pos = vec2(-_o_alpha / PI * 0.5 * _o_nX, 0.5 + _o_nY * _o_beta / PI) * 2.0 - 1.0;
    refractedColor = __source__(_o_pos);
}
else if (backgroundStyle == 1) {
    vec2 _o_pos = vec2(-(refractedDir).x / (refractedDir).z, -(refractedDir).y / (refractedDir).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    refractedColor = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
}
else if (backgroundStyle == 2) {
    float _o_ratio = sourceDim.y / sourceDim.x;
    float _o_X = 0.5;
    float _o_Y = 0.5;
    if (abs((refractedDir).y) > abs((refractedDir).z) * _o_ratio && abs((refractedDir).y) > abs((refractedDir).x) * _o_ratio) {
        _o_X += -(refractedDir).x / (refractedDir).y * 0.5;
        _o_Y += -(refractedDir).z / (refractedDir).y * 0.5;
    }
    else if (abs((refractedDir).x) < abs((refractedDir).z)) {
        _o_X += (refractedDir).x / abs((refractedDir).z) * _o_ratio * 0.5 * -sign((refractedDir).z);
        _o_Y += (refractedDir).y / abs((refractedDir).z) * 0.5;
    }
    else {
        _o_X += (refractedDir).z / abs((refractedDir).x) * _o_ratio * 0.5 * -sign((refractedDir).x);
        _o_Y += (refractedDir).y / abs((refractedDir).x) * 0.5;
    }
    refractedColor = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    refractedColor = vec4((refractedDir) * 0.5 + 0.5, 1.0);
}

                float balance = 1.0 - 2.0 * reflectivity;
                vec4 mixedCol = mix(reflectedColor, refractedColor, clamp(0.0, 1.0, incidence + balance));
                mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * objectColor.rgb, 1.0), objectColor.a);
                return mixedCol;
            }
            else {
                float minDist = abs(length(cross(dir, cameraPos)) / length(dir) - radius);
                vec4 bkg = vec4(0.0);
                if (backgroundStyle == 0) {
    vec3 _o_n = normalize(dir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    float _o_nX = 2.0;
    float _o_nY = 1.0;
    vec2 _o_pos = vec2(-_o_alpha / PI * 0.5 * _o_nX, 0.5 + _o_nY * _o_beta / PI) * 2.0 - 1.0;
    bkg = __source__(_o_pos);
}
else if (backgroundStyle == 1) {
    vec2 _o_pos = vec2(-(dir).x / (dir).z, -(dir).y / (dir).z);
    float _o_m = max(abs(_o_pos.x), abs(_o_pos.y));
    float _o_darken = 4.0 / max(4.0, _o_m);
    bkg = __source__(_o_pos) * vec4(_o_darken, _o_darken, _o_darken, 1.0);
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
    bkg = __source__(vec2(_o_X, _o_Y) * 2.0 - 1.0);
}
else {
    bkg = vec4((dir) * 0.5 + 0.5, 1.0);
}
                return bkg * mix(vec4(1.0), vec4(2.0 * bkgColor.rgb, 1.0), bkgColor.a)
                    + vec4(glowColor.rgb * 0.2 / pow(minDist, 1.5), 0.0) * glowColor.a;
            }
        }
