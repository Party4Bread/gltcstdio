float moebiusImplicitFn(vec3 p, float radius, float twistCount, float phase) {
    float R = 0.5;
    float r = R * radius;
    float a = sqrt(p.x * p.x + p.y * p.y) - R;
    float angle = atan(-p.x, -p.y);
    vec2 u = vec2(a, p.z);
    float twist = angle * 0.25 * twistCount + phase;
    float ct = cos(twist);
    float st = sin(twist);
    u = mat2(ct, st, -st, ct) * u;
    return max(abs(u.x), abs(u.y)) - r;
}

vec2 moebiusBoundingSphereK(vec3 center, float radius, vec3 origin, vec3 dir) {
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

vec3 moebiusRayMarch(vec3 origin, vec3 dir, float radius, float twistCount, float phase) {
    // Pap's bound uses the raw radius with *1.42 (pre-shader-rescale units), matched here.
    float minDist = 1e9;
    float k = 0.0;
    vec2 kBounds = moebiusBoundingSphereK(vec3(0.0), 0.5 * (1.0 + radius * 1.42), origin, dir);
    float kk = kBounds.x;
    if (kk < 0.0) return vec3(kk, 0.0, minDist);
    float de = 0.0001;
    int maxIter = 1256;
    int iter = 0;
    vec3 p = origin;
    float dist = moebiusImplicitFn(p, radius, twistCount, phase);
    while (abs(dist) > de && iter < maxIter) {
        k += abs(dist * 0.25);
        p = origin + k * dir;
        dist = moebiusImplicitFn(p, radius, twistCount, phase);
        minDist = min(minDist, abs(dist));
        ++iter;
    }
    return dist < de ? vec3(k, float(iter), minDist) : vec3(-1.0, float(iter), minDist);
}

vec3 moebiusNormal(vec3 p, float radius, float twistCount, float phase) {
    float d = 0.0001;
    float d2 = d * 2.0;
    return normalize(vec3(
        (moebiusImplicitFn(vec3(p.x - d, p.y, p.z), radius, twistCount, phase) - moebiusImplicitFn(vec3(p.x + d, p.y, p.z), radius, twistCount, phase)) / d2,
        (moebiusImplicitFn(vec3(p.x, p.y - d, p.z), radius, twistCount, phase) - moebiusImplicitFn(vec3(p.x, p.y + d, p.z), radius, twistCount, phase)) / d2,
        (moebiusImplicitFn(vec3(p.x, p.y, p.z - d), radius, twistCount, phase) - moebiusImplicitFn(vec3(p.x, p.y, p.z + d), radius, twistCount, phase)) / d2
    ));
}

        vec4 moebiusTorusGl(vec2 pos, vec2 outPos, mat4 model3DTransform, mat3 texTransform, vec2 sourceDim,
                            float intensity, float reflectivity, float radius, int count, float phase, float blend,
                            float colorScheme, vec4 sourceColor, vec4 ambientColor, vec4 fogColor, float specular,
                            float lightDistance, float lightAngleX, float lightAngleY,
                            int backgroundStyle) {
            mat4 invModelTransform = inverse(model3DTransform);
            mat3 invTt = inverse(texTransform);
            // Build light position the same way Pap's Matrix4f chain does:
            // rotY(angleY) * rotX(angleX) * translate(0,0,distance) * (0,0,0,1)
            float _caX = cos(lightAngleX);
            float _saX = sin(lightAngleX);
            float _caY = cos(lightAngleY);
            float _saY = sin(lightAngleY);
            vec3 lightPos = vec3(
                lightDistance * _caX * _saY,
                -lightDistance * _saX,
                lightDistance * _caX * _caY
            );
            vec3 cameraPos = (invModelTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            float D = 1.0;
            vec3 dir = normalize(vec3(pos.x * D, pos.y * D, -1.0));
            dir = mat3(invModelTransform) * dir;

            float twistCount = float(count) - 1.0;
            float scaledBlend = blend * 0.005; // Pap's blend slider is 0..100 folded to 0..0.5
            float scaledSpecular = specular * 0.01; // Pap's specular slider is 0..100
            vec3 origin = cameraPos;
            vec3 inters = moebiusRayMarch(origin, dir, radius, twistCount, phase);
            float k = inters.x;

            float ratio = sourceDim.x / sourceDim.y;
            float width = ratio * (1.0 - scaledBlend);
            float height = 1.0 - scaledBlend;
            float bWidth = width - ratio * scaledBlend;
            float bHeight = height - scaledBlend;

            if (k > 0.0) {
                vec3 intersection = origin + k * dir;
                float R = 0.5;
                float angle = atan(-intersection.x, -intersection.y);
                float twist = angle * 0.25 * twistCount + phase;
                float x = angle / PI * width;
                float a = sqrt(intersection.x * intersection.x + intersection.y * intersection.y) - R;
                float y = (atan(a, intersection.z) + PI / 4.0 - twist) / PI * height;

                vec4 col;
                vec2 u00 = tf(invTt, vec2(x, y));
                if (scaledBlend == 0.0) col = __source__(u00);
                else {
                    vec2 u10 = tf(invTt, vec2(x - sign(x) * (ratio + bWidth), y));
                    vec2 u01 = tf(invTt, vec2(x, y - sign(y) * (1.0 + bHeight)));
                    vec2 u11 = tf(invTt, vec2(x - sign(x) * (ratio + bWidth), y - sign(y) * (1.0 + bHeight)));
                    col = mix(
                        mix(__source__(u00), __source__(u10),
                            smoothstep(0.0, 2.0 * scaledBlend * ratio, abs(x) - bWidth)),
                        mix(__source__(u01), __source__(u11),
                            smoothstep(0.0, 2.0 * scaledBlend * ratio, abs(x) - bWidth)),
                        smoothstep(0.0, 2.0 * scaledBlend, abs(y) - bHeight)
                    );
                }

                vec3 normal = moebiusNormal(intersection, radius, twistCount, phase);
                if (colorScheme != 0.0) col.rgb = mix(col.rgb, normal.rgb, colorScheme * 0.01);

                vec3 lightDir = normalize(lightPos - intersection);
                float incidence = smoothstep(0.0, 1.0, dot(-normal, lightDir));
                if (incidence > 0.0 && (sourceColor.r + sourceColor.g + sourceColor.b) > 0.0) {
                    if (moebiusRayMarch(intersection + lightDir * 0.001, lightDir, radius, twistCount, phase).x > 0.0) incidence = 0.0;
                }
                col.rgb = ambientColor.rgb * 2.0 * col.rgb + sourceColor.rgb * incidence * col.rgb;
                // Pap's tight specular: 1.0 - s*0.01 (inner) and 1.01 - s*0.0001 (outer) - 100x tighter than a naive smoothstep.
                col.rgb += smoothstep(1.0 - scaledSpecular, 1.01 - specular * 0.0001, dot(lightDir, -reflect(normalize(cameraPos - intersection), normal))) * sourceColor.rgb;

                float dist = length(origin - intersection);
                float fog = max((dist - 0.5) * 4.0, 0.0) * fogColor.a;
                return vec4(mix(col.rgb, fogColor.rgb, fog), col.a);
            }
            else {
                vec4 bkg = vec4(0.0);
                if (backgroundStyle == 0) {
    vec3 _o_n = normalize(dir);
    float _o_alpha = atan(_o_n.z, _o_n.x);
    float _o_beta = asin(_o_n.y);
    bkg = __source__(vec2(-_o_alpha / PI * 2.0, 2.0 * _o_beta / PI));
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
                // Pap uses dist = 2.0 in the miss branch, so fog = max((2 - 0.5) * 4, 0) * fogColor.a = 6 * fogColor.a, clamped.
                float fog = clamp(max((2.0 - 0.5) * 4.0, 0.0) * fogColor.a, 0.0, 1.0);
                return vec4(mix(bkg.rgb, fogColor.rgb, fog), bkg.a);
            }
        }
