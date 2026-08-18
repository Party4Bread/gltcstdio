#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_source2_specified (int(U[5].x))
#define u_outDim (U[6].xy)
#define u_intensity (U[7].x)
#define u_mode (U[8].x)
#define u_iterations (int(U[9].x))
#define u_angle (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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















































































































































































































































































































































vec4 ghostingMerge(vec2 uv, vec2 outPos, vec2 sourceDim, float intensity, float mode, int iterations, float angle, int source2_specified, mat3 modelTransform) {
//            mat3 inverseModelTransform = inverse(modelTransform);
            vec4 color = __source__(uv);
            vec4 bestColor = color;
            float bestDist = 100.0;
        
        
            float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
            float scale = 1.0/ resolution;
        
            vec2 dim = vec2(sourceDim.x/sourceDim.y-1.0/sourceDim.y, 1.0-1.0/sourceDim.y);
            vec2 orig = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;
        
            vec2 scaledDim = mat2(modelTransform)*(1.0*dim);
            vec2 offset = -vec2(modelTransform[2][0], modelTransform[2][1])/scaledDim;
            float N = float(iterations);
            vec2 step = N<=1.0? vec2(0.0, 0.0) : vec2(cos(angle), sin(angle))*scaledDim*2.0/(N-1.0);//*scaledDim*0.05;
            vec2 start = -step*scaledDim;
            int zeroDists = 0;
            for (float i=0.0; i<N; ++i) {
                vec2 pos1 = uv + offset + start + i*step;
                float ang = i/float(iterations)*PI2 + angle;
                vec2 pos2 = uv + offset + vec2(cos(ang), sin(ang))*scaledDim;
                vec2 p = mix(pos1, pos2, mode);
                vec4 c = (source2_specified==1) ? __source2__(p) : __source__(p);
                float dist = length(color-c);
                if (dist<bestDist) {
                    if (i==0.0 || dist!=0.0 || zeroDists!=0) {
                        bestDist = dist;
                        bestColor = c;
                    }
                    else if (dist==0.0) {
                        ++zeroDists;
                    }
                }
            }
        
            return bestColor;
        }

void main() {
    fragColor = ghostingMerge((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_mode, u_iterations, u_angle, u_source2_specified, u_modelTransform);
}
