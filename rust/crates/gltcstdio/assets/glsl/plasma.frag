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
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_balance (U[7].x)
#define u_hardness (U[8].x)
#define u_dampening (U[9].x)
#define u_color1 (U[10])
#define u_color2 (U[11])
#define u_colorVariability (U[12].x)
#define u_randomSeed (U[13].x)
#define u_variability (U[14].x)
#define u_modelTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

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















































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
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

vec4 plasma(vec2 uv, vec2 outPos, int source_specified, float intensity, float balance, float hardness, float dampening, vec4 color1, vec4 color2, float colorVariability, float randomSeed, float variability, mat3 modelTransform) {
    vec2 u = uv;
    vec2 u2 = u*0.3;

    vec2 p = floor(u+0.5);
    vec2 p2 = floor(u2+0.5);

    float N = 4.0;
    float t = 0.0;
    float tk2 = 0.0;
    vec3 tc = vec3(0.0, 0.0, 0.0);
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {
            vec2 q = p+vec2(i, j);
            vec2 q2 = p2+vec2(i, j);
			vec2 rnd = rand2relSeeded(q, randomSeed);
			vec2 rnd2 = rand2relSeeded(q2, randomSeed);

            vec3 col = color2.rgb + vec3(rnd2.x, rnd2.y, fract((rnd2.x+rnd2.y)*50.0)-0.5)*colorVariability*2.0;

            vec2 c = q+rnd*variability*2.;
            vec2 c2 = q2+rnd2*2.0;

            vec2 d = u-c;
            vec2 d2 = u2-c2;

            float k2 = 1.0/(0.001+dot(d2, d2));
            float k = 1.0/(dampening + smoothstep(0.0, 3.0, length(d)));

            t += k;
            tk2 += k2;
            tc += col*k2;
        }
    }

    // good simple:
    //float k = smoothstep(-0.50, -0.455, sin(t*0.05));//t*0.0055 > 1.0 ? 1.0 : 0.0;
    float a = mix(-2.0, balance, hardness);
    float b = mix(2.0, balance, hardness);
    float k = smoothstep(a, b, sin(t*intensity*2.));//t*0.0055 > 1.0 ? 1.0 : 0.0;
    tc /= tk2;

    vec4 outColor = mix(color1, vec4(tc, color2.a), k);
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}

void main() {
    fragColor = plasma((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_intensity, u_balance, u_hardness, u_dampening, u_color1, u_color2, u_colorVariability, u_randomSeed, u_variability, u_modelTransform);
}
