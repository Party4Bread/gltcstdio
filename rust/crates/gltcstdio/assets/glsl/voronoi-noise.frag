#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_octaves (int(U[6].x))
#define u_variability (U[7].x)
#define u_randomSeed (U[8].x)
#define u_color1 (U[9])
#define u_color2 (U[10])
#define u_threshold (U[11].x)
#define u_thresholdColor (U[12])

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

vec4 voronoiNoise(vec2 pos, vec2 outPos, int source_specified, mat3 viewTransform, int octaves, float variability, float randomSeed, vec4 color1, vec4 color2, float threshold, vec4 thresholdColor) {
    vec2 u = pos;
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
        
    float total = 0.;
    float noise = 0.0;
    float amplitude = 1.0;

    for(int k=0; k<octaves; ++k) {
        vec2 v = floor(vec2(u.x+0.5, u.y+0.5));
        float closest = 1e9;
        for(int j=-2; j<=2; ++j) {
            for(int i=-2; i<=2; ++i) {
                vec2 point = vec2(v.x+float(i), v.y+float(j));
                vec2 displace = (rand2relSeeded(point, randomSeed) * variability)* 2.0;
                float distance = length(point+displace - u);
                if (distance < closest) {
                    closest = distance;
                }
            }
        }
        total += amplitude;
        noise += amplitude * closest;
        amplitude *= 0.5;
        u = u*2.0 + vec2(1.34, 2.55);
    }
    
    noise /= total;
    
    vec4 outColor;
    if (threshold==0.0) outColor = mix(color1, color2, noise);
    else if (threshold<0.0) {
        if (noise >= 1.0 + threshold) {
            outColor = thresholdColor;
        }
        else {
            outColor = mix(color1, color2, (noise)/(1.0+threshold));
        }
    }
    else {
        if (noise <= threshold) {
            outColor = thresholdColor;
        }
        else {
            outColor = mix(color1, color2, (noise-threshold)/(1.0-threshold));
        }
    }
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor; 
}

void main() {
    fragColor = voronoiNoise((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_viewTransform, u_octaves, u_variability, u_randomSeed, u_color1, u_color2, u_threshold, u_thresholdColor);
}
