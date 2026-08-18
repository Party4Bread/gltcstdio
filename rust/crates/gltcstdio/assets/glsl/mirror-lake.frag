#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_shapeAspectRatio (U[6].x)
#define u_regularity (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

vec2 hash22b(vec2 u) {
    return vec2(
        fract(sin(dot(u.xy, vec2(13.7545,78.224)))* 43758.5453123), 
        fract(sin(dot(u.xy, vec2(15.7545,73.224)))* 43758.5453123) );
}

vec2 rndUnit(vec2 p) {
    vec2 rnd = hash22b(p)-0.5;
    float len = length(rnd);
    if (len==0.0) return vec2(0., 1.0); else return rnd/len;
}

float dotGridGradient(vec2 g, vec2 u) {
    return dot(u-g, rndUnit(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinNoise(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float getSurface(vec2 xz, float period, float ar, float intensity, float regularity) {
    return intensity * 10. * mix(perlinNoise(xz*vec2(1./ar, 1.)/period), 0.4*sin(xz.y/period), regularity);
    
}

vec3 getNormal(vec3 p, float period, float ar, float intensity, float regularity) {
    float d = period*0.001;
    float y = getSurface(p.xz, period, ar, intensity, regularity);
    float yx = getSurface(vec2(p.x+d, p.z), period, ar, intensity, regularity);
    float yz = getSurface(vec2(p.x, p.z+d), period, ar, intensity, regularity);
    return normalize(vec3((yx-y)/d, 1.0, (yz-y)/d));
}

vec3 getPlaneIntersection(float y, vec3 camera, vec3 dir) {
    float k = (y-camera.y)/dir.y;
    if (k>0.0) return camera + k*dir;
    else return vec3(INF);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 mirrorLake(vec2 uv, vec2 outPos, float intensity, float shapeAspectRatio, float regularity, mat3 modelTransform) {
    uv = tf(inverse(modelTransform), uv);
    
    float zoom = 1./pow(length(modelTransform[0].xy), 2.);

    vec3 dir = normalize(vec3(uv, zoom));
    vec3 camera = vec3(0.0, -500.0, 0.0); // set to 500 to flip orientation of the effect
    float Y = 0.0;
    vec4 color = vec4(1.0);
    vec3 intersection = getPlaneIntersection(Y, camera, dir);
    if (intersection.x!=INF) {
        vec3 normal = getNormal(intersection, 100., shapeAspectRatio, intensity, regularity);
        dir = reflect(dir, normal);
    }
    
    vec2 u = dir.xy / dir.z * zoom;
    
    u = tf(modelTransform, u);
    
    return __source__(u);
}

void main() {
    fragColor = mirrorLake((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_shapeAspectRatio, u_regularity, u_modelTransform);
}
