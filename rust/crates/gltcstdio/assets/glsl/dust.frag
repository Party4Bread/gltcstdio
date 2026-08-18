#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_randomSeed (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

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

vec2 getDisplacement(vec2 pos, float scale, float randomSeed) {
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

                float intensity = 20.0;//scale*0.1;
                return displacement*intensity;

            }

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float threshold(float value) {
    return min(pow(min(1.1, value+0.3), 30.0), 4.0);
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

vec4 dust(vec2 uv, vec2 outPos, float intensity, float randomSeed, vec2 outDim, mat3 modelTransform) {
            mat3 invModelTransform = inverse(modelTransform);
            vec2 t = tf(invModelTransform, uv);
            float scale = length(invModelTransform[0].xy);

            vec4 col = __source__(uv);
            
            if (intensity != 0.0) {
        //        color.rgb = color.rgb * (1.0 + perlinDisplace(pos, t, u_Count, intensity*0.02).x);
                float lumNoise = voronoiOctaveNoise(getDisplacement(t, scale, randomSeed), 1);
                float g = threshold(lumNoise);
                float dustValue = intensity*g; // 0..intensity*4.0
//                if (balance<0.0) {
//                    float grey = dustValue>1.0 ? clamp(dustValue, 0.0, 4.0)/4.0 : 0.0;
//                    vec3 mergedCol = mix(col.rgb, vec3(grey), smoothstep(1.0, 1.2, dustValue));
//                    col.rgb = mix(col.rgb+dustValue, mergedCol, -balance);
//                }
//                else {
//                    float grey = 1.0;
//                    vec3 mergedCol = mix(col.rgb, vec3(grey), smoothstep(0.9, 1.1, dustValue));
//                    col.rgb = mix(col.rgb+dustValue, mergedCol, balance);
//                }
                col.rgb += intensity*g;//vec3(g, g, g); //col.rgb * (1.0 + intensity*0.02*lumNoise);
            }
        
            return col;
        }

void main() {
    fragColor = dust((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_randomSeed, u_outDim, u_modelTransform);
}
