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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_dual (int(U[7].x))
#define u_model3DTransform (mat4(U[8], U[9], U[10], U[11]))
#define u_highFreqColor (U[12])

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





















































































































































































































































































































































vec4 getBackground(vec3 dir, vec4 color) {
    return color; //vec4(0.0, 0.0, 0.0, 1.0);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 perspective(vec2 pos, vec2 outPos, int mode, int dual, mat4 model3DTransform, vec4 highFreqColor, vec2 sourceDim) {
            
            float D = 1.0;
            vec3 cameraPos = vec3(0., 0., 0.); 
//            cameraPos = mat3(model3DTransform) * cameraPos;
            mat4 m = inverse(model3DTransform);
            cameraPos = (m * vec4(cameraPos, 1.)).xyz;
            vec3 dir = normalize(vec3(pos.x*D, pos.y*D, -1.0));
            dir = mat3(m[0].xyz, m[1].xyz, m[2].xyz) * dir;

            vec4 col = getBackground(dir, highFreqColor);
    
            if (dir.z==0.0) return col;
            bool clip = mode==0;
            float ratio = sourceDim.x/sourceDim.y;

            float z =  0.;
            float k = (z-cameraPos.z)/dir.z;
            if (dual==1 || k>0.) {
                vec2 uv = dir.xy * k + cameraPos.xy;
                if (!clip || (abs(uv.x)<ratio && abs(uv.y)<1.)) {
                    col = __source__(uv);
                    float d = abs(k);
                    if (d>1.0 && highFreqColor.a>0.0) {
                        float fog = (abs(d)-1.0) * 0.2;
                        col = mergeColor(col, vec4(highFreqColor.rgb, min(1., highFreqColor.a*fog)));
                    }
                }
            }                
                        
            return col;
        }

void main() {
    fragColor = perspective((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_dual, u_model3DTransform, u_highFreqColor, u_sourceDim);
}
