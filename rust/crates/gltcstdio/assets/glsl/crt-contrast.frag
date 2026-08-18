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
#define u_radius (U[7].x)
#define u_angle (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 crtContrast(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float radius, float angle, mat3 modelTransform) {
            radius = radius * 0.1;
            vec4 color = __source__(pos);
            
            float pixel = 2.0 / sourceDim.y;
            
            vec2 pos2 = tf(modelTransform, pos + radius*vec2(cos(angle), sin(angle)));
            int n = int(min(50., length(pos2-pos)/pixel));
            if (n<=0) return color;
            vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
            vec2 p = pos;
            vec2 delta = (pos2-pos)/float(n);
            float div = 0.0;
            for(int i=0; i<=n; ++i) {
                float d = float(i) / float(n);
                if (d<=1.0) {
//                    float k = (d>0.5) ? (1.0-d)*(1.0-d)*2.0 : 1.0 - d*d*2.0;
                    float k = 1.0;
                    total += k*__source__(p);
                    div += k;
                    p += delta;
                }
            }
            vec4 blur = total / div;
            
            float kIntensity = intensity * 2.;       
            return (1.0+kIntensity)*color - kIntensity*blur;   
        }

void main() {
    fragColor = crtContrast((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_radius, u_angle, u_modelTransform);
}
