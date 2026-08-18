        vec4 sphereGlobeGl(vec2 pos, vec2 outPos, vec2 sourceDim, mat4 model3DTransform,
                           float intensity, float balance) {
            mat4 inv = inverse(model3DTransform);
            vec3 cameraPos = (inv * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
            dir = mat3(inv[0].xyz, inv[1].xyz, inv[2].xyz) * dir;

            // ray vs glass sphere centred at origin, radius 0.5
            float a = dot(dir, dir);
            float b = 2.0 * dot(dir, cameraPos);
            float c = dot(cameraPos, cameraPos) - 0.25;
            float delta = b * b - 4.0 * a * c;
            float l = -1.0;
            if (delta >= 0.0) {
                float sqrtDelta = sqrt(delta);
                float l1 = (-b - sqrtDelta) / (2.0 * a);
                float l2 = (-b + sqrtDelta) / (2.0 * a);
                l = l1 > 0.0 ? l1 : (l2 > 0.0 ? l2 : -1.0);
            }

            vec4 result;
            if (l > 0.0) {
                vec3 intersection = cameraPos + l * dir;
                vec3 normal = normalize(intersection);
                float eta = intensity;
                float incidence = abs(dot(normal, dir));
                vec3 refractedDir = refract(dir, normal, eta);
                vec3 reflectedDir = reflect(dir, normal);
                vec4 reflectedColor;
                {
    vec3 _n = normalize(reflectedDir);
    vec2 _ll = projEquirectangular(_n);           // (atan(z, x), asin(y))
    float _nX = 2.0;
    float _nY = 1.0;
    vec2 _u = vec2(-_ll.x / PI * 0.5 * _nX, 0.5 + _ll.y * _nY / PI);
    // mirror-wrap longitude into [0,1] (source on one hemisphere, mirror on the other)
    float _xa = abs(_u.x);
    _xa = _xa - 2.0 * floor(_xa * 0.5);
    float _x = (_xa > 1.0) ? (2.0 - _xa) : _xa;
    float _y = clamp(_u.y, 0.0, 1.0);
    // hemisphere coord [0,1]^2 -> full source in centred-V2 space [-ratio, ratio] x [-1, 1]
    float _ratio = sourceDim.x / sourceDim.y;
    reflectedColor = __source__(vec2((_x - 0.5) * 2.0 * _ratio, (_y - 0.5) * 2.0));
}
                vec4 refractedColor;
                {
    vec3 _n = normalize(refractedDir);
    vec2 _ll = projEquirectangular(_n);           // (atan(z, x), asin(y))
    float _nX = 2.0;
    float _nY = 1.0;
    vec2 _u = vec2(-_ll.x / PI * 0.5 * _nX, 0.5 + _ll.y * _nY / PI);
    // mirror-wrap longitude into [0,1] (source on one hemisphere, mirror on the other)
    float _xa = abs(_u.x);
    _xa = _xa - 2.0 * floor(_xa * 0.5);
    float _x = (_xa > 1.0) ? (2.0 - _xa) : _xa;
    float _y = clamp(_u.y, 0.0, 1.0);
    // hemisphere coord [0,1]^2 -> full source in centred-V2 space [-ratio, ratio] x [-1, 1]
    float _ratio = sourceDim.x / sourceDim.y;
    refractedColor = __source__(vec2((_x - 0.5) * 2.0 * _ratio, (_y - 0.5) * 2.0));
}
                // Pap mixes reflected->refracted by clamp(0.0, 1.0, incidence + balance), whose
                // quirky arg order evaluates to min(1, incidence + balance) on hardware; since
                // incidence + balance >= 0 always, that is clamp(incidence + balance, 0, 1).
                result = mix(reflectedColor, refractedColor, clamp(incidence + balance, 0.0, 1.0));
            } else {
                // camera outside the sphere: rays that miss show the bare equirectangular env
                vec4 bkg;
                {
    vec3 _n = normalize(dir);
    vec2 _ll = projEquirectangular(_n);           // (atan(z, x), asin(y))
    float _nX = 2.0;
    float _nY = 1.0;
    vec2 _u = vec2(-_ll.x / PI * 0.5 * _nX, 0.5 + _ll.y * _nY / PI);
    // mirror-wrap longitude into [0,1] (source on one hemisphere, mirror on the other)
    float _xa = abs(_u.x);
    _xa = _xa - 2.0 * floor(_xa * 0.5);
    float _x = (_xa > 1.0) ? (2.0 - _xa) : _xa;
    float _y = clamp(_u.y, 0.0, 1.0);
    // hemisphere coord [0,1]^2 -> full source in centred-V2 space [-ratio, ratio] x [-1, 1]
    float _ratio = sourceDim.x / sourceDim.y;
    bkg = __source__(vec2((_x - 0.5) * 2.0 * _ratio, (_y - 0.5) * 2.0));
}
                result = bkg;
            }
            return result;
        }
