#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
    vec4 u_spheres[32];
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
#define u_objectColor (U[12])
#define u_glowColor (U[13])
#define u_bkgColor (U[14])
#define u_backgroundStyle (int(U[15].x))
#define u_spheres_size (int(U[16].x))
#define u_count (int(U[17].x))
#define u_radius (U[18].x)
#define u_regularity (U[19].x)
#define u_randomSeed (U[20].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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



























































































































































































































































































































































vec2 metaballsBoundingSphereK(vec3 center, float radius, vec3 origin, vec3 dir) {
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

float metaballsImplicitFn(vec3 p, int spheres_size) {
    float total = 0.0;
    for (int i = 0; i < spheres_size; ++i) {
        total += 1.0 / length(u_spheres[i].xyz - p) - 1.0 / u_spheres[i].a;
    }
    return total;
}

vec3 metaballsGetIntersectionD(vec3 origin, vec3 dir, float sphereRad, int spheres_size) {
    // Secant/bisection root finder for the metaballs implicit function, bounded by a
    // sphere of radius 2.5 (glow black) or 5.0 (with glow rim). Matches Pap's algorithm.
    float minDist = 1e9;
    vec2 kBounds = metaballsBoundingSphereK(vec3(0.0), sphereRad, origin, dir);
    if (kBounds.x < 0.0) return vec3(-1.0, 0.0, minDist);
    float k0 = max(0.0, kBounds.x);
    float k1 = k0;

    float originSign = sign(metaballsImplicitFn(origin, spheres_size));
    float steps = 100.0;
    float dk = (kBounds.y - k0) / steps;
    vec3 x0 = origin + k0 * dir;
    vec3 x1 = x0;
    float a = metaballsImplicitFn(x0, spheres_size);
    float b = a;

    do {
        k0 = k1;
        x0 = x1;
        a = b;
        k1 += dk;
        x1 = origin + k1 * dir;
        b = metaballsImplicitFn(x1, spheres_size);
        minDist = min(minDist, abs(b));
    } while (k1 < kBounds.y && sign(b) == originSign);

    if (sign(b) == originSign) return vec3(-1.0, 0.0, minDist);

    float de = 0.001;
    int maxIter = 100;
    int iter = 0;
    while (iter < maxIter) {
        float dy = b - a;
        dk = k1 - k0;
        float deriv = dy / dk;

        float k2 = k0 - a / deriv;
        if (k2 < kBounds.x || k2 > kBounds.y) k2 = (k0 + k1) / 2.0;

        vec3 x2 = origin + k2 * dir;
        float c = metaballsImplicitFn(x2, spheres_size);
        minDist = min(minDist, abs(c));
        if (abs(c) < de) return vec3(k2, float(iter), minDist);

        if (sign(a) != sign(c)) { k1 = k2; b = c; }
        else { k0 = k2; a = c; }
        ++iter;
    }
    return vec3((k0 + k1) / 2.0, float(iter), minDist);
}

vec3 metaballsNormal(vec3 p, int spheres_size) {
    float d = 0.01;
    float d2 = d * 2.0;
    return normalize(vec3(
        (metaballsImplicitFn(vec3(p.x - d, p.y, p.z), spheres_size) - metaballsImplicitFn(vec3(p.x + d, p.y, p.z), spheres_size)) / d2,
        (metaballsImplicitFn(vec3(p.x, p.y - d, p.z), spheres_size) - metaballsImplicitFn(vec3(p.x, p.y + d, p.z), spheres_size)) / d2,
        (metaballsImplicitFn(vec3(p.x, p.y, p.z - d), spheres_size) - metaballsImplicitFn(vec3(p.x, p.y, p.z + d), spheres_size)) / d2
    ));
}

        vec4 metaballsGl(vec2 pos, vec2 outPos, mat4 model3DTransform, vec2 sourceDim, float intensity, float reflectivity, vec4 objectColor, vec4 glowColor, vec4 bkgColor, int backgroundStyle, int spheres_size) {
            mat4 invModelTransform = inverse(model3DTransform);
            vec3 cameraPos = (invModelTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
            float D = 1.0;
            vec3 dir = normalize(vec3(pos.x * D, pos.y * D, -1.0));
            dir = mat3(invModelTransform) * dir;

            float eta = 1.0 - 2.0 * intensity;

            // Pap picks a smaller bounding sphere (2.5) when glow is black, larger (5.0)
            // otherwise, so rays near the metaball cluster can still register minDist for glow.
            float sphereRad = (glowColor.r == 0.0 && glowColor.g == 0.0 && glowColor.b == 0.0) ? 2.5 : 5.0;

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
                vec3 inters = metaballsGetIntersectionD(origin, dir, sphereRad, spheres_size);
                float k = inters.x;
                if (k > 0.0 && k < minK) { minK = k; minI = 0; objectIntersected = true; }
                else if (iter == maxIter) { minDist = min(minDist, inters.z); }

                if (minI >= 0) {
                    vec3 intersection = origin + minK * dir;
                    vec3 normal = metaballsImplicitFn(origin, spheres_size) <= 0.0
                        ? metaballsNormal(intersection, spheres_size)
                        : -metaballsNormal(intersection, spheres_size);
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
            // Preserve Pap's clamp(x, 0.0, 1.0) quirk = min(1, x).
            vec4 mixedCol = mix(reflectedColor, _bkg, clamp(incidence + balance, 0.0, 1.0));
            if (objectIntersected) mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * objectColor.rgb, 1.0), objectColor.a);
            else mixedCol = mix(mixedCol, mixedCol * vec4(2.0 * bkgColor.rgb, 1.0), bkgColor.a);
            // Pap metaballs glow: 1.4 / pow(minDist, clamp(minDist, 1.0, 3.0)) — the clamp quirk gives exponent = min(3, minDist).
            float glowIntensity = 1.4 / pow(minDist, clamp(minDist, 1.0, 3.0));
            return mixedCol + vec4(glowColor.rgb * glowIntensity, 0.0) * glowColor.a;
        }

void main() {
    fragColor = metaballsGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_model3DTransform, u_sourceDim, u_intensity, u_reflectivity, u_objectColor, u_glowColor, u_bkgColor, u_backgroundStyle, u_spheres_size);
}
