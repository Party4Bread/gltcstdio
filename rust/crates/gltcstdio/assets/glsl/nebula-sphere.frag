#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_sourceBkg;

#define u_sourceBkg sampler2D(t_sourceBkg, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceBkg_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_color3 (U[8])
#define u_density (U[9].x)
#define u_model3DTransform (mat4(U[10], U[11], U[12], U[13]))
#define u_randomSeed (U[14].x)

#define __sourceBkg__texelFetch__(c) texelFetch(u_sourceBkg, (c), 0)
#define __sourceBkg__(p) texture(u_sourceBkg, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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







































































































































































































































































































































































float hash31(vec3 u) {
    return fract(sin(u.x*776.45+u.y*453.24+u.z*553.25)*45.77);
}

float noise(vec3 x) {
    vec3 i = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(
            mix(hash31(i + vec3(0, 0, 0)), hash31(i + vec3(1, 0, 0)), f.x),
            mix(hash31(i + vec3(0, 1, 0)), hash31(i + vec3(1, 1, 0)), f.x),
            f.y
        ),
        mix(
            mix(hash31(i + vec3(0, 0, 1)), hash31(i + vec3(1, 0, 1)), f.x),
            mix(hash31(i + vec3(0, 1, 1)), hash31(i + vec3(1, 1, 1)), f.x),
            f.y
        ),
        f.z
    );
}

float fbm(vec3 p) {
    float f = 0.0;
    float amp = 0.5;
    for(int i = 0; i < 4; i++) {
        f += amp * noise(p);
        p *= 2.0;
        amp *= 0.5;
    }
    return f;
}

float getDetailedNoise(vec3 p, float time) {
    vec3 q = vec3(
        fbm(p + vec3(0.0)),
        fbm(p + vec3(5.2, 1.3, 2.8)),
        fbm(p + vec3(1.8, 5.2, 2.1))
    );
    q += time * 0.1;

    float strength = 1.0;
    float n = fbm(p + q * strength);

    return smoothstep(0.45, 0.85, n);
}

float getDensity(vec3 p, float time) {
    vec3 center = vec3(0.0);
    float radius = 0.95;

    float dist = length(p - center);
    float shapeMask = 1.0 - smoothstep(radius - 0.1, radius, dist);
    if (shapeMask <= 0.0) return 0.0;

    vec3 noisePos = p * 1.5;
    float cloud = getDetailedNoise(noisePos, time);

    return cloud * shapeMask * 2.0;
}

vec3 getPointLight(vec3 p, vec3 lightPos, vec3 lightCol, float range) {
    float d = distance(p, lightPos);
    float atten = 1.0 - smoothstep(0.0, range, d);
    return lightCol * atten * atten * 3.5;
}

float hash21(vec2 p) {
    vec2 a = fract(-45.3277*p.xy);
    vec2 b = a + dot(a, a+123.3371);
	return fract(b.x*b.y);  
}

vec3 rayMarchCloud(vec3 ro, vec3 rd, vec3 bgCol, vec2 bounds, vec2 fragCoord,
                   vec4 color1, vec4 color2, vec4 color3, float randomSeed, float densityMult) {
    // Animated light positions using random seed
    float t = randomSeed;
    vec3 l1Pos = vec3(sin(t), 0.0, cos(t)) * 0.5;
    vec3 l1Col = color1.rgb * 6.0;

    vec3 l2Pos = vec3(cos(t * 1.1) * 0.4, sin(t * 1.4) * 0.6, 0.0);
    vec3 l2Col = color2.rgb * 6.0;

    vec3 l3Pos = vec3(0.0, cos(t * 0.7) * 0.4, sin(t * 0.9) * 0.5);
    vec3 l3Col = color3.rgb * 6.0;

    vec3 col = bgCol;

    const int STEPS = 32;
    float stepSize = (bounds.y - bounds.x) / float(STEPS);
    float absorption = 8.0;

    // Dithering to reduce banding
    float dither = hash21(fragCoord + vec2(randomSeed * 10.0));
    float currentDist = bounds.y - (stepSize * dither);

    for(int i = 0; i < STEPS; i++) {
        currentDist -= stepSize;
        if(currentDist < bounds.x) break;

        vec3 p = ro + rd * currentDist;

        // Get cloud density
        float dens = getDensity(p, randomSeed) * densityMult;

        // Distance to lights
        float d1 = length(p - l1Pos);
        float d2 = length(p - l2Pos);
        float d3 = length(p - l3Pos);

        // Direct light glow (visible even through low density)
        vec3 glow = vec3(0.0);
        glow += l1Col / (0.001 + d1 * d1 * 20.0);
        glow += l2Col / (0.002 + d2 * d2 * 20.0);
        glow += l3Col / (0.001 + d3 * d3 * 20.0);

        // Incident light on cloud
        vec3 lightEnergy = vec3(0.0);
        if(dens > 0.001) {
            lightEnergy += getPointLight(p, l1Pos, l1Col, 1.0);
            lightEnergy += getPointLight(p, l2Pos, l2Col, 1.0);
            lightEnergy += getPointLight(p, l3Pos, l3Col, 1.0);
            lightEnergy += vec3(0.02); // Ambient
        }

        // Composition
        float T = exp(-dens * absorption * stepSize);
        vec3 E = (dens * lightEnergy + glow * 0.05) * stepSize;

        col = col * T + E;
    }

    return col;
}

vec2 sphereIntersect(vec3 ro, vec3 rd, float r) {
    float b = dot(ro, rd);
    float c = dot(ro, ro) - r * r;
    float h = b * b - c;
    if(h < 0.0) return vec2(-1.0);
    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

vec4 nebulaSphere(vec2 pos, vec2 outPos, int sourceBkg_specified, vec4 color1, vec4 color2, vec4 color3,
                  float density, mat4 model3DTransform, float randomSeed) {

    float D = 1.0;
    vec3 ro = vec3(0.0, 0.0, 0.0);

    // Apply inverse transform to camera
    mat4 m = inverse(model3DTransform);
    ro = (m * vec4(ro, 1.0)).xyz;

    // Get ray direction
    vec3 rd = normalize(vec3(pos.x * D, pos.y * D, -1.0));
    rd = mat3(m[0].xyz, m[1].xyz, m[2].xyz) * rd;

    // Background
    vec3 bgCol = sourceBkg_specified==1 ? __sourceBkg__(pos).rgb : vec3(0.0);
    vec3 col = bgCol;

    // Intersect with bounding sphere
    float sphereRadius = 1.0;
    vec2 bounds = sphereIntersect(ro, rd, sphereRadius);

    if (bounds.x > 0.0) {
        // Volumetric rendering
        vec3 volumeCol = rayMarchCloud(ro, rd, bgCol, bounds, outPos,
                                       color1, color2, color3, randomSeed, density * 0.1);

        // Surface effects
        vec3 pSurface = ro + rd * bounds.x;
        vec3 normal = normalize(pSurface);

        float viewAngle = clamp(dot(normal, -rd), 0.0, 1.0);
        float fresnel = pow(1.0 - viewAngle, 3.0);

        vec3 extLightDir = normalize(vec3(1.0, 1.0, -1.0));
        vec3 halfVec = normalize(extLightDir - rd);
        float spec = pow(max(dot(normal, halfVec), 0.0), 60.0);

        vec3 reflection = vec3(0.6, 0.8, 1.0) * fresnel;

        col = mix(volumeCol, reflection, fresnel * 0.4);
        col += vec3(1.0) * spec;
    }

    // Tone mapping
    col = col / (1.0 + col);
    // Gamma correction
    col = pow(col, vec3(0.4545));

    return vec4(col, 1.0);
}

void main() {
    fragColor = nebulaSphere((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceBkg_specified, u_color1, u_color2, u_color3, u_density, u_model3DTransform, u_randomSeed);
}
