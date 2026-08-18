#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_color1 (U[5])
#define u_color2 (U[6])
#define u_color3 (U[7])
#define u_color4 (U[8])
#define u_colorBkg (U[9])
#define u_hardness (U[10].x)
#define u_variability (U[11].x)
#define u_colorVariability (U[12].x)
#define u_randomSeed (U[13].x)
#define u_acuteness (U[14].x)
#define u_radiality (U[15].x)





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


















































































































































































































































































































































float changeIn01(float x, float range, float k) {
    float r2 = range*0.5;
    float a = x-r2;
    float b = x+r2;
    if (a<0.0) {
        b -= a;
        a = 0.;
    }
    if (b>1.0) {
        a += 1.-b;
        b = 1.;
    }
    return a + (b-a)*k;
}

vec3 hash23(vec2 u) {
    return vec3(
        fract(sin(u.x*776.45+u.y*453.24)*45.77), 
        fract(sin(u.x*376.45+u.y*853.24)*88.77),
        fract(sin(u.x*457.77+u.y*667.17)*65.57) );
}

vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

vec4 randomConeGradients(vec2 u, vec2 outPos, vec4 color1, vec4 color2, vec4 color3, vec4 color4, vec4 colorBkg, float hardness, float variability, float colorVariability, float randomSeed,
    float acuteness, float radiality
) {
    float intensity = variability * 4.;
    
    vec2 b = floor(u+0.5); 
    float N = floor(2.0+0.5*abs(intensity));
    float totalW = colorBkg.a*colorBkg.a*2.;
    vec3 col = totalW*colorBkg.rgb;
    for(float j=b.y-N; j<=b.y+N; ++j) {
        for(float i=b.x-N; i<=b.x+N; ++i) {
            vec2 id = vec2(i, j);
            vec2 rnd1 = rand2relSeeded(id, randomSeed);
            vec2 rnd2 = rand2relSeeded(id+1., randomSeed);
            vec2 c = id + intensity * rnd1;
            vec2 dir = normalize(mix(rnd2, normalize(c), radiality));
            //vec2 dir = normalize(-id);
            float d = length(u-c);
//            float w = pow(smoothstep(1.64, 0., d), 2.25) * pow(smoothstep(-1.0, 1.0, dot(normalize(u-c), dir)), 0.5);
            float w = pow(0.001+0.999*smoothstep(1.64, 0., d), 2.2+1.6*hardness) * (acuteness==1.0 ? 1.0 : pow(smoothstep(-1.0, 1.0, dot(normalize(u-c), dir)), (2.0-acuteness*2.)));
            //float w = pow(max(0., 1.-d), 1.25) * pow(smoothstep(-0.5, 1.0, dot(normalize(u-c), dir)), 0.25);
            //w *=w*w; // optional
            float selector = mod(rnd1.x*40., 4.0);
            float rndR = fract(rnd1.y*10.);
            float rndB = fract(rnd2.x*10.);
            float rndG = fract(rnd2.y*10.);
            vec4 baseCol = selector<1.0 ? color1 : selector<2.0 ? color2 : selector<3.0 ? color3 : color4;
            baseCol.r = changeIn01(baseCol.r, colorVariability, rndR);
            baseCol.g = changeIn01(baseCol.g, colorVariability, rndG);
            baseCol.b = changeIn01(baseCol.b, colorVariability, rndB);
            col += w * baseCol.rgb;//hash23(id);
            totalW += w;
        }
    }

    return vec4(col/totalW, 1.0);
}

void main() {
    fragColor = randomConeGradients((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color1, u_color2, u_color3, u_color4, u_colorBkg, u_hardness, u_variability, u_colorVariability, u_randomSeed, u_acuteness, u_radiality);
}
