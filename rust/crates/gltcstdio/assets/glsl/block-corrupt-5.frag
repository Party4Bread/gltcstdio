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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_randomSeed (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

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


















































































































































































































































































































































float bc5GetIndex(vec2 pos, vec2 blockSize, vec2 dim) {
    float columns = dim.x/blockSize.x;
    float lines = dim.y/blockSize.y;
    vec2 f = floor(pos/blockSize);
    return f.x+0.5*columns + (f.y+0.5*lines)*columns;
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

vec2 sineMix(vec2 val1, vec2 val2, float k) {
    return val1*(1.0+cos(k*PI))*0.5 + val2*(1.0+cos((1.0-k)*PI))*0.5;
}

vec2 sineSurfaceRand2Seeded(vec2 v, float seed) {
    vec2 u00 = floor(v);
    vec2 u01 = vec2(floor(v.x), ceil(v.y));
    vec2 u10 = vec2(ceil(v.x), floor(v.y));
    vec2 u11 = ceil(v);

    vec2 r00 = varyVec2NoiseSmoothly(rand2(u00), seed)-vec2(0.5, 0.5);
    vec2 r01 = varyVec2NoiseSmoothly(rand2(u01), seed)-vec2(0.5, 0.5);
    vec2 r10 = varyVec2NoiseSmoothly(rand2(u10), seed)-vec2(0.5, 0.5);
    vec2 r11 = varyVec2NoiseSmoothly(rand2(u11), seed)-vec2(0.5, 0.5);

    return sineMix(
            sineMix(r00, r01, fract(v.y)),
            sineMix(r10, r11, fract(v.y)),
            fract(v.x));
}

vec4 blockCorrupt5(vec2 pos, vec2 outPos, int count, float randomSeed, vec2 sourceDim, mat3 modelTransform) {
    vec4 inCol = __source__(pos);
    vec4 outCol = inCol;

    float ratio = sourceDim.x/sourceDim.y;
    vec2 dim = vec2(2.0*ratio, 2.0);
    vec2 blockSize = dim / vec2(160.0, 80.0);
    float columns = dim.x/blockSize.x;
    float lines = dim.y/blockSize.y;
    float blocks = columns*lines;
    float index = bc5GetIndex(pos, blockSize, dim);

    float offset = modelTransform[2][0]*0.5*columns + modelTransform[2][1]*0.5*lines*columns + 0.5*blocks;
    float scale = length(vec2(modelTransform[0][0], modelTransform[0][1]));

    for(int i=0; i<count; ++i) {
        vec2 rnd = sineSurfaceRand2Seeded(vec2(10.0-float(i), 15.0+5.0*float(i)), randomSeed+4.46);
        float center = offset + rnd.x*blocks;
        float bSize = (rnd.x<-0.5+float(i)*0.1)? 0.5 : abs(rnd.y)*blocks*scale;
        float ind1 = center-bSize;
        float ind2 = center+bSize;

        bool inside = (index>=ind1 && index<=ind2);
        if (inside) {
            float subMode = floor(mod(rnd.x*15.0, 9.0));
            float g = 0.0;
            if (subMode==0.0) {
                g = fract(rand2relSeeded(floor(pos*320.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
            }
            else if (subMode==1.0) {
                g = fract(rand2relSeeded(floor(pos*160.0), randomSeed).x) > 0.5 ? 1.0 : 0.0;
            }
            else if (subMode==2.0) {
                g = fract(pos.x*40.0)>0.5 ? 1.0 : 0.0;
            }
            else if (subMode==3.0) {
                g = fract(pos.x*80.0)>0.5 ? 1.0 : 0.0;
            }
            else if (subMode==6.0) {
                g = fract(pos.x*80.0)>length(inCol.rgb)/1.7 ? 1.0 : 0.0;
            }
            else if (subMode==7.0) {
                g = fract(pos.x*10.0)<length(inCol.rgb)/1.7 ? 1.0 : 0.0;
            }
            else if (subMode==4.0) {
                g = mod((fract(pos.x*80.0)>0.5 ? 1.0 : 0.0) + (fract(pos.y*40.0)>0.5 ? 1.0 : 0.0), 2.0);
            }
            else if (subMode==5.0) {
                g = fract(rand2relSeeded(floor(pos*160.0), randomSeed).x) < length(inCol.rgb)/1.7 ? 1.0 : 0.0;
            }
            else {
                g = mod((fract(pos.x*40.0)>0.5 ? 1.0 : 0.0) + (fract(pos.y*20.0)>0.5 ? 1.0 : 0.0), 2.0);
            }
            outCol = vec4(g, g, g, 1.0);
            return outCol;
        }
    }

    return inCol;
}

void main() {
    fragColor = blockCorrupt5((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_randomSeed, u_sourceDim, u_modelTransform);
}
