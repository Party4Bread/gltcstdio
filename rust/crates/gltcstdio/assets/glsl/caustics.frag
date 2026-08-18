#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_intensity (U[6].x)
#define u_dispersion (U[7].x)
#define u_variability (U[8].x)
#define u_randomSeed (U[9].x)
#define u_vignetting (U[10].x)
#define u_color (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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

vec2 getDisplacement(vec2 pos, float variability, float randomSeed) {
                vec2 t = pos;

                float ci = floor(t.x);
                float cj = floor(t.y);

                float k = 0.0;

                vec2 displacement = vec2(0.0, 0.0);
                float radiusVariability = 1.0;
                float variab = 1.0;

                for(int j = -2; j <= 2; ++j) {
                    for(int i = -2; i <= 2; ++i) {
                        vec2 center = vec2(float(i)+ci, float(j)+cj);
                        vec2 delta = rand2relSeeded(center, randomSeed);
                        float radiusModifier = max(0.3, 1.2 + (delta.x * radiusVariability));
                        center += vec2(0.5, 0.5) + delta * variab;
                        vec2 d = t - center;
                        k = length(d);

                        float threshold = radiusModifier;
                        if (k < threshold) {
                            k /= threshold;
                            float r = (0.5-k)*(0.5-k)*4.0;
                            float dp = (1.0-r)/(0.5+r);
                            displacement += dp * d;
                        }
                    }
                }

                float scale = 10.0;
                float intensity = scale*0.3 * variability;
                return displacement*intensity;

            }

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float threshold(float value) {
    return min(pow(min(1.2, value+0.35), 10.0), 4.0);
}

float voronoiOctaveNoise(vec2 u, int n) {
    float noise = 0.0;
    float amplitude = 0.6;

    for(int k=0; k<n; ++k) {
        vec2 v = floor(vec2(u.x+0.5, u.y+0.5));
        float closest = 1e9;
        for(int j=-2; j<=2; ++j) {
            for(int i=-2; i<=2; ++i) {
                vec2 point = vec2(v.x+float(i), v.y+float(j));
                vec2 displace = (rand2(point) - vec2(0.5, 0.5))* 2.0;
                float distance = length(point+displace - u);
                if (distance < closest) {
                    closest = distance;
                }
            }
        }
        noise += amplitude * closest;
        amplitude *= 0.5;
        u = u*2.0 + vec2(1.34, 2.55);
    }

    return noise;
}

vec4 caustics(vec2 uv, vec2 outPos, int count, float intensity, float dispersion, float variability, float randomSeed, float vignetting, vec4 color, vec2 outDim, mat3 modelTransform) {
    vec2 t = tf(inverse(modelTransform), uv);
            
    vec4 col = __source__(uv);

    float falloff = 1.0;
    if (vignetting != 0.0) {
        float diag = max(1.0, outDim.x/outDim.y);
        float len = length(uv);
        float radius = (1.5-vignetting) * diag;
        falloff = max(0.0, (1.0 - vignetting*2.0*smoothstep(0.0, radius, len)));
    }

    if (intensity != 0.0) {
        vec3 light;
        if (dispersion == 0.0) {
            int n = count;
            vec2 displacement = getDisplacement(t, variability, randomSeed);
            float g = threshold(voronoiOctaveNoise(t + displacement, n));
            light = color.rgb * vec3(g, g, g);
        }
        else {
            float ab = dispersion * 0.1/(0.01+variability);
            int n = count;
            vec2 displacement = getDisplacement(t, variability, randomSeed);
            float r = threshold(voronoiOctaveNoise(t + displacement*(1.0-ab), n));
            float y = threshold(voronoiOctaveNoise(t + displacement*(1.0-0.5*ab), n));
            float g = threshold(voronoiOctaveNoise(t + displacement, n));
            float c = threshold(voronoiOctaveNoise(t + displacement*(1.0+0.5*ab), n));
            float b = threshold(voronoiOctaveNoise(t + displacement*(1.0+1.5*ab), n));
            light = color.rgb * vec3(r*0.66+0.33*y, 0.4*y+0.2*g+0.4*c, 0.15*c + 0.85*b);
        }

        col.rgb += intensity*5. * light * falloff;
    }

    return col;
}

void main() {
    fragColor = caustics((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_intensity, u_dispersion, u_variability, u_randomSeed, u_vignetting, u_color, u_outDim, u_modelTransform);
}
