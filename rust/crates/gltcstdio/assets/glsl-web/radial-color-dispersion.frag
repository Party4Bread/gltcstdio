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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_hardness (U[7].x)
#define u_shapeAspectRatio (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

vec4 getRGBWeights(float w) {
    return vec4(
        max(0.0, -w),
        max(0.0, 1.0-abs(w)),
        max(0.0, w),
        1.0
    );
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec2 withShapeAspectRatio(vec2 u, float ar) {
    return vec2(u.x*ar, u.y) * 2.0/(1. + ar);
}

vec4 radialColorDispersion(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float hardness, float shapeAspectRatio, mat3 modelTransform) {
            vec2 p = tf(inverse(modelTransform), pos);
            float stepLen = 2.0/sourceDim.y;//0.002;

            if (p.x==0.0 && p.y==0.0) return __source__(pos);

            float pDist = length(p);
            float shapeDist = length(withShapeAspectRatio(p, shapeAspectRatio));
            float k = smoothstep(hardness*0.999, 1.0, shapeDist);
        
            vec2 dir = normalize(p);
            vec2 step = dir * stepLen;
        
            float distance = k * intensity;
            float halfDist = distance * .5;
                        
            vec4 totalColor = vec4(0.0, 0.0, 0.0, 0.0);
            vec4 totalW = vec4(0.0, 0.0, 0.0, 0.0);
            
            float start = max(0.0, pDist-halfDist);
            float end = pDist+halfDist;
            float actualDistance = end-start;
            if (actualDistance<=stepLen) return __source__(pos);
            
//            for(float d = start; d<end; d += stepLen) {
//                vec2 q = tf(modelTransform, d*dir);
//                vec4 weights = getRGBWeights((d-start)/actualDistance * 2.0 - 1.0);
//                totalColor += weights * __source__(q);
//                totalW += weights;
//            }
            vec2 startQ = tf(modelTransform, start*dir);
            vec2 endQ = tf(modelTransform, end*dir);
            float n = max(3.0, ceil(actualDistance/stepLen));
            for(float i=0.0; i<n; ++i) {
                float k = i/(n-1.0);
                vec2 q = mix(startQ, endQ, k);
                vec4 weights = getRGBWeights(k * 2.0 - 1.0);
                vec4 col = __source__(q);
                totalColor += weights * col*col;
                totalW += weights;
            }
        
            vec4 dispersedColor = sqrt(totalColor / totalW); //n * 1.5;
            //vec4 baseColor = __source__(pos);
        
            return dispersedColor;
        }

void main() {
    fragColor = radialColorDispersion((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_hardness, u_shapeAspectRatio, u_modelTransform);
}
