#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_model3DTransform (mat4(U[6], U[7], U[8], U[9]))
#define u_intensity (U[10].x)
#define u_reflectivity (U[11].x)
#define u_radius (U[12].x)
#define u_count (int(U[13].x))
#define u_objectColor (U[14])
#define u_glowColor (U[15])
#define u_bkgColor (U[16])
#define u_backgroundStyle (int(U[17].x))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




// gltcstdio GLSL support library.
// Every function below was verified to compile against GL 3.3.
// Prototypes precede bodies so intra-library call order is irrelevant.

#define INF 1e20
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI4 12.566370614359172
#define PI_2 1.5707963267948966
#define PI_3 1.0471975511965976
#define PI2_3 2.0943951023931953
#define SQRT3 1.7320508075688772
#define SQRT3_2 0.8660254037844386
#define SQRT3_6 0.288675134594813
#define SQRT2 1.4142135623730951
#define SQRT2_2 0.7071067811865476
#define THIRD 0.33333333333
#define TWO_THIRDS 0.666666666667

struct HexTile {
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct CairoTile {
    vec2 center;
    float borderDist;
};
struct TriangleTile {
    bool up;
    vec2 center;
    vec2 pos;
    float angle;    
    float centerDist;
    float borderDist;
};
struct Tile {
    float centerDist;
    vec2 tileId;
    float borderDist;
    vec2 center;
    vec2 borderNormal;
    float secondCenterDist;
    vec2 secondTileId;    
    float thirdCenterDist;
};

// ---- prototypes ----










































































































































































































// ---- bodies ----



















        























































































// allow vec4's



























































































































































































































































































































































float torusKnotImplicitFn(vec3 p, float radius, float count) {
    // Pap's implicitFn (not implicitFn0) - single-tube variant selected via q.x<0 ? -q fold.
    float R = 0.5;
    float r = R * radius;
    float a = sqrt(p.x * p.x + p.y * p.y) - R;
    float ang = atan(p.y, p.x) * 0.5 * (count - 1.0);
    float ca = cos(ang);
    float sa = sin(ang);
    mat2 rot = mat2(ca, sa, sa, -ca);
    vec2 q = rot * vec2(a, p.z);
    if (q.x < 0.0) q = -q;
    vec2 c1 = vec2(0.15, 0.0);
    return 0.4 * (length(q - c1) - r);
}

vec3 torusKnotNormal(vec3 p, float radius, float count) {
    float d = 0.0001;
    float d2 = d * 2.0;
    return normalize(vec3(
        (torusKnotImplicitFn(vec3(p.x - d, p.y, p.z), radius, count) - torusKnotImplicitFn(vec3(p.x + d, p.y, p.z), radius, count)) / d2,
        (torusKnotImplicitFn(vec3(p.x, p.y - d, p.z), radius, count) - torusKnotImplicitFn(vec3(p.x, p.y + d, p.z), radius, count)) / d2,
        (torusKnotImplicitFn(vec3(p.x, p.y, p.z - d), radius, count) - torusKnotImplicitFn(vec3(p.x, p.y, p.z + d), radius, count)) / d2
    ));
}

vec2 torusKnotBoundingSphereK(vec3 center, float radius, vec3 origin, vec3 dir) {
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

vec3 torusKnotRayMarch(vec3 origin, vec3 dir, float radius, float count, vec4 glowColor) {
    // Pap only applies the bounding-sphere early-out when glow is black (otherwise we need
    // to compute minDist across space even for rays that miss). Unit conversion: Pap's
    // 0.5*(1 + 1.25 + u_Radius*0.02) becomes 0.5*(2.25 + radius) in bank units.
    float minDist = 1e9;
    float k = 0.0;
    if (glowColor.r == 0.0 && glowColor.g == 0.0 && glowColor.b == 0.0) {
        vec2 kBounds = torusKnotBoundingSphereK(vec3(0.0), 0.5 * (2.25 + radius), origin, dir);
        float kk = kBounds.x;
        if (kk < 0.0) return vec3(kk, 0.0, minDist);
    }
    float de = 0.0001;
    int maxIter = 1256;
    int iter = 0;
    vec3 p = origin;
    float dist = torusKnotImplicitFn(p, radius, count);
    while (abs(dist) > de && iter < maxIter) {
        k += abs(dist);
        p = origin + k * dir;
        dist = torusKnotImplicitFn(p, radius, count);
        minDist = min(minDist, abs(dist));
        ++iter;
    }
    return dist < de ? vec3(k, float(iter), minDist) : vec3(-1.0, float(iter), minDist);
}

        vec4 torusKnotGl(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim,
                         float intensity, float reflectivity, float radius, int count,
                         vec4 objectColor, vec4 glowColor, vec4 bkgColor,
                         int backgroundStyle) {
            mat4 invModelTransform = inverse(model3DTransform);
            vec3 cameraPos = (invModelTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            float D = 1.0;
            vec3 dir = normalize(vec3(pos.x * D, pos.y * D, -1.0));
            dir = mat3(invModelTransform) * dir;

            float eta = 1.0 - 2.0 * intensity;
            float fcount = float(count);

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
                vec3 inters = torusKnotRayMarch(origin, dir, radius, fcount, glowColor);
                float k = inters.x;
                if (k > 0.0 && k < minK) { minK = k; minI = 0; objectIntersected = true; }
                else if (iter == maxIter) { minDist = min(minDist, inters.z); }

                if (minI >= 0) {
                    vec3 intersection = origin + minK * dir;
                    vec3 normal = torusKnotImplicitFn(origin, radius, fcount) <= 0.0
                        ? torusKnotNormal(intersection, radius, fcount)
                        : -torusKnotNormal(intersection, radius, fcount);
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
            // Pap's quirky clamp(x, 0.0, 1.0) = min(max(0,1), x) = min(1, x) -- preserved verbatim.
            vec4 mixedCol = mix(reflectedColor, _bkg, clamp(incidence + balance, 0.0, 1.0));
            if (objectIntersected) mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * objectColor.rgb, 1.0), objectColor.a);
            else mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * bkgColor.rgb, 1.0), bkgColor.a);
            // Pap torus-knot glow uses linear falloff (pow(minDist, 1.0)), not 1.5 like Sphere.
            return mixedCol + vec4(glowColor.rgb * 0.1 / pow(minDist, 1.0), 0.0) * glowColor.a;
        }

void main() {
    fragColor = torusKnotGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_model3DTransform, u_sourceDim, u_intensity, u_reflectivity, u_radius, u_count, u_objectColor, u_glowColor, u_bkgColor, u_backgroundStyle);
}
