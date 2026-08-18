#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
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
#define u_balance (U[11].x)

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec2 projEquirectangular(vec3 dir) {
    vec3 u = normalize(dir);
    float lambda = atan(u.z, u.x); // longitude
    float phi = asin(u.y); // latitude
    return vec2(lambda, phi);
}

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
                // Pap mixes reflected->refracted by clamp(incidence + balance, 0.0, 1.0), whose
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

void main() {
    fragColor = sphereGlobeGl((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_model3DTransform, u_intensity, u_balance);
}
