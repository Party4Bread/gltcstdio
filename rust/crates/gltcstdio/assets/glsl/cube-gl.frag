#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
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


















































































































































































































































































































































vec3 cubeFaceNormal(vec3 center, vec3 intersection) {
    vec3 delta = intersection - center;
    vec3 a = abs(delta);
    if (a.x > a.y && a.x > a.z) return vec3(sign(delta.x), 0.0, 0.0);
    else if (a.y > a.z) return vec3(0.0, sign(delta.y), 0.0);
    else return vec3(0.0, 0.0, sign(delta.z));
}

vec3 cubeIntersection(vec3 center, float radius, vec3 origin, vec3 dir) {
    vec3 relOrigin = origin-center;
    float kOut = INF;
    float kIn = 0.0;
    if (dir.x!=0.0) {
        float k1 = -(relOrigin.x-radius)/dir.x;
        float k2 = -(relOrigin.x+radius)/dir.x;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.x)>radius) return vec3(INF, INF, INF);

    if (dir.y!=0.0) {
        float k1 = -(relOrigin.y-radius)/dir.y;
        float k2 = -(relOrigin.y+radius)/dir.y;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.y)>radius) return vec3(INF, INF, INF);

    if (dir.z!=0.0) {
        float k1 = -(relOrigin.z-radius)/dir.z;
        float k2 = -(relOrigin.z+radius)/dir.z;
        kIn = max(kIn, min(k1, k2));
        kOut = min(kOut, max(k1, k2));
    }
    else if (abs(relOrigin.z)>radius) return vec3(INF, INF, INF);

//    if (k1>k2) return vec3(INF, INF, INF);
//    return origin + k1*dir;
    float k = kIn>0.0 ? kIn : kOut;
    if (k<=0.0 || kOut<kIn) return vec3(INF, INF, INF);
    vec3 inters = origin + k*dir;
//    float err = 0.00001;
//    if (kIn<=0.0 || abs(inters.x-center.x)>radius+err || abs(inters.y-center.y)>radius+err || abs(inters.z-center.z)>radius+err) return vec3(INF, INF, INF);
    return inters;
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
                vec4 mixedCol = mix(reflectedColor, refractedColor, clamp(incidence + balance, 0.0, 1.0));
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

void main() {
    fragColor = cubeGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_model3DTransform, u_sourceDim, u_intensity, u_reflectivity, u_objectColor, u_glowColor, u_bkgColor, u_backgroundStyle);
}
