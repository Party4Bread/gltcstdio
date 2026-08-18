#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_explosions (int(U[7].x))
#define u_particles (int(U[8].x))
#define u_intensity (U[9].x)
#define u_power (U[10].x)
#define u_spread (U[11].x)
#define u_blend (U[12].x)
#define u_randomSeed (U[13].x)
#define u_color (U[14])
#define u_colorVariability (U[15].x)
#define u_modelTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

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



























































































































































































































































































































































vec2 hash12(float x) {
    return vec2(
        fract(sin(x*776.4577)*45.77), 
        fract(sin(x*376.4517+1.2524)*88.77) );
}

float sparc(vec2 u, float power) {
    float len = length(u);
    //return 1./len;
    return 1./pow(len, power);
}

float explosion(vec2 u, int n, float id, float time, float blend, float power) {
    float total = 0.;
    for(int i=0; i<n; ++i) {
        vec2 rnd = hash12(1. + id + float(i));
        float angle = rnd.x * PI2;
        float speed = pow(rnd.y, 0.35);
        vec2 pos = speed * time * vec2(cos(angle), sin(angle));

        float decay = smoothstep(15.0, 5.0, time);
        float lum = sparc(u-pos, power) * decay;

        //total = mix(total + max(0., (1.0-total)) * lum, total + lum, blend);
        total = pow(pow(total, blend) + pow(lum, blend), 1./blend);
    }
    return total;
}

float sdUnevenCapsule( vec2 p, float r1, float r2, float h ) {
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,vec2(-b,a));
    if (k < 0.0) return length(p) - r1;
    if (k > a*h) return length(p-vec2(0.0,h)) - r2;
    return dot(p, vec2(a,b) ) - r1;
}

float trail(vec2 p, vec2 a, vec2 b, float power) {
    vec2 ba = b-a;
    float h = length(ba);
    float cosa = ba.x/h;
    float sina = ba.y/h;
    vec2 u = mat2(sina, cosa, -cosa, sina) * (p-a);
    float bigR = 0.05;
    float smallR = 0.01;
    float len = h==0.0 ? length(p-b) : sdUnevenCapsule(u, 0.01, 0.05, h) + bigR;
    return 1./pow(len, power);
}

float explosionT(vec2 u, int n, float id, float time, float deltaT, float blend, float power) {
    float total = 0.;
    for(int i=0; i<n; ++i) {
        vec2 rnd = hash12(1. + id + float(i));
        float angle = rnd.x * PI2;
        vec2 speed = pow(rnd.y, 0.35) * vec2(cos(angle), sin(angle));
        vec2 posA = speed * max(0.0, time-deltaT);
        vec2 posB = speed * time;
        float decay = smoothstep(20.0, 5.0, time);
        float lum = max(0., trail(u, posA, posB, power) * decay);

        //total = mix(total + max(0., (1.0-total)) * lum, total + lum, blend);
        total = pow(pow(total, blend) + pow(lum, blend), 1./blend);
    }
    return total;
}

vec3 hash13(float x) {
//    return vec3(
//        fract(sin(x*776.4577)*45.771), 
//        fract(cos(x*442.8831)*65.111), 
//        fract(sin(x*376.4517+1.2524)*88.771) );
    return fract(vec3(
        sin(x*776.4577)*45.771, 
        cos(x*442.8831)*65.111, 
        sin(x*376.4517+1.2524)*88.771) );
}

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 spilloverChannels(vec4 c) {
    float overflow = (max(c.r-1.0, 0.0) + max(c.g-1.0, 0.0) + max(c.b-1.0, 0.0)) / 3.0;
    c.r += overflow;
    c.g += overflow;
    c.b += overflow;
    return c;
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 fireworks(vec2 uv, vec2 outPos, vec2 sourceDim, int mode, int explosions, int particles, float intensity, float power, float spread, float blend, float randomSeed, vec4 color, float colorVariability, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 u = tf(inverse(modelTransform), uv);

    float time = randomSeed;

    float CYCLE = 20.0;
    vec3 outCol = vec3(0.);
    //float g = sparc(uv);
    float sliceDuration = CYCLE/float(explosions);
    float timeSlice = floor(time/sliceDuration);
    
    for(int e=0; e<explosions; ++e) {
        float explosionId = timeSlice-float(e);
        float startTime = explosionId * sliceDuration;
        float eTime = time - startTime; 
        vec2 center = (hash12(explosionId)-0.5) * 20.0 * spread;
        
        float g;
        if (mode==0) g = explosion(u-center, particles, float(particles) *explosionId, eTime, blend, power);
        else if (mode==1) g = explosionT(u-center, particles, float(particles) *explosionId, eTime, .5, blend, power);
        else if (mode==2) g = explosionT(u-center, particles, float(particles) *explosionId, eTime, 1.3, blend, power);
        else if (mode==3) g = explosionT(u-center, particles, float(particles) *explosionId, eTime, 3.0, blend, power);
        
        vec3 col = color.rgb + (hash13(explosionId*10.)-0.5)*colorVariability;
        outCol += intensity * g * col;
    }

    return spilloverChannels(mergeColor(inc, vec4(outCol, min(1.0, luma(outCol)))));
    //return spilloverChannels(inc + vec4(outCol, 1.));
}

void main() {
    fragColor = fireworks((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_mode, u_explosions, u_particles, u_intensity, u_power, u_spread, u_blend, u_randomSeed, u_color, u_colorVariability, u_modelTransform);
}
