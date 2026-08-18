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
#define u_outDim (U[4].xy)
#define u_spikeCount (int(U[5].x))
#define u_texTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_blend (U[9].x)
#define u_randomSeed (U[10].x)
#define u_variability (U[11].x)

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

vec2 reflct(float d, float sourceAngle, float alpha, float halfAlpha) {
    if (sourceAngle > halfAlpha) sourceAngle = alpha-sourceAngle;
    return d * vec2(cos(sourceAngle), sin(sourceAngle));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 kaleidoscope(vec2 pos, vec2 outPos, int spikeCount, mat3 texTransform, float blend, float randomSeed, float variability) {
    float totalWeight = 0.0;
    vec4 totalCol = vec4(0.0);
    vec2 totalCoord = vec2(0.0);
    vec4 lightestCol = vec4(0.0, 0.0, 0.0, 1.0);
    float lightestVal = 0.0;
    float lighting = 1.0;
    
    float N = 1.0;
    for(float j=-N; j<=N; ++j) {
        for(float i=-N; i<=N; ++i) {

            vec2 u = pos;
            vec2 id = floor((u+1.0)/2.0) + vec2(i, j);
            vec2 center = id*2.0;// + variability*vec2(rnd3.y, rnd2.y)*3.5;
            u = u-center;

            float d = length(u);
            float weight;
            if (blend<=0.0) {
                weight = max(abs(u.x), abs(u.y))<=1.0 ? 1.0 : 0.0;
                vec2 borderDist = u - vec2(-1.);
                vec2 lightFactor = smoothstep(0.0, 1.4, borderDist);
                float lightStrength = lightFactor.x * lightFactor.y;
                if (i==0. && j==0.) lighting = mix(1.0, lightStrength, -blend);// + blend * (1.0-lightStrength);
                /*if (i==0. && j==0.) {
                    if (mod(id.x+id.y, 2.)==0.) return vec4(lightStrength, lightStrength, lightStrength, 1.0);
                    return vec4(lighting, lighting, lighting, 1.0);
                }*/
            }
            else if (blend<0.15) {
                weight = smoothstep(1.0+blend, 1.0-blend, max(abs(u.x), abs(u.y)));
            }
            else if (blend<0.3) {
//                float squareWeight = smoothstep(1.0+u_Blend*0.01, 1.0-u_Blend*0.01, max(abs(u.x), abs(u.y)));
//                float circleWeight = smoothstep(1.4+u_Blend*0.01, 1.4-u_Blend*0.01, d);
                float squareWeight = smoothstep(1.0+0.15, 1.0-0.15, max(abs(u.x), abs(u.y)));
                float circleWeight = smoothstep(1.4+0.15, 1.4-0.15, d);
                weight = mix(squareWeight, circleWeight, (blend-0.15)/0.15);
            }
            else {
                float b = mix(0.15, 1.0, (blend-0.3)/0.7);
                weight = smoothstep(1.4+b, 1.4-b, d);
            }

            if (weight>0.0) {
                float sourceAngle = 0.0;

                float halfAlpha = 0.0;
                float alpha = 0.0;
                if (d > 0.0) {
                    float ang = atan(u.y, u.x);
                    if (ang<0.0) ang += PI2;

                    halfAlpha = PI/float(spikeCount);
                    alpha = halfAlpha * 2.0;
                    sourceAngle = mod(ang, alpha);
                }

                vec2 coord = reflct(d, sourceAngle, alpha, halfAlpha);
                float angle = 0.0;
                float scale = 1.0;
                vec2 t = vec2(0.0, 0.0);

                if (id.x!=0.0 || id.y!=0.0) {
                    vec2 rnd = rand2relSeeded(id, randomSeed);
                    angle = variability*rnd.x*PI*2.0;
                    scale = variability*rnd.y*0.2+1.0;
                    t = variability*rnd*2.0;
                    //tr = mat3(scale*cos(angle), scale*sin(angle), 0.0, -scale*sin(angle), scale*cos(angle), 0.0, t.x, t.y, 1.0); // this approach crashes on some devices such as Nexus 7
                }
                vec2 tc = tf(inverse(texTransform), coord);
                vec2 tcc = vec2(scale*(cos(angle)*tc.x+sin(angle)*tc.y)+t.x, scale*(-sin(angle)*tc.x+cos(angle)*tc.y)+t.y);
                vec4 col = __source__(tcc);
                

                totalCol += weight*col;
                totalWeight += weight;
            }
        }
    }

    return (totalCol/totalWeight) * vec4(vec3(lighting), 1.);
}

void main() {
    fragColor = kaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_spikeCount, u_texTransform, u_blend, u_randomSeed, u_variability);
}
