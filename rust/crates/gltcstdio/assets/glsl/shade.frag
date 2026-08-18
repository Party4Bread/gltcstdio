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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_intensity (U[6].x)
#define u_height (U[7].x)
#define u_specular (U[8].x)
#define u_delta (U[9].x)
#define u_gamma (U[10].x)
#define u_lightSourceTransform (mat4(U[11], U[12], U[13], U[14]))

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















































































































































































































































































































































vec4 adjustGamma(vec4 col, float gamma) {
    if (gamma != 0.) {
        float p = pow(2., -gamma);
        col.r = pow(col.r, p);
        col.g = pow(col.g, p);
        col.b = pow(col.b, p);
    }
    
    return col;
}

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 shade(vec2 pos, vec2 outPos, vec2 sourceDim, float intensity, float height, float specular, float delta, float gamma, mat4 lightSourceTransform) {
                vec2 step = vec2(delta, 0.);
            
                vec2 uv = pos;
                vec4 col = __source__(uv);
                float h = luma(col.rgb);
//                vec2 grad = vec2(
//                    h - luma(__source__(uv-step).rgb) ,
//                    h - luma(__source__(uv-step.yx).rgb) ) / delta;
                
//                vec2 grad = vec2(dFdx(h), dFdy(h)) / delta;
    
                float pixel = 2.0/sourceDim.y;
                vec2 grad = vec2(dFdx(h), dFdy(h)) / pixel;
                
                vec3 normal = normalize(vec3(height*grad, 1.0));
                vec3 lightPos = (lightSourceTransform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
//                vec3 lightDir = normalize(vec3(1., 1., 1.));
                vec3 lightDir = normalize(vec3(uv, 0.) - lightPos);
                float illum = dot(normal, lightDir);
                
                vec3 reflectedLightDir = reflect(-lightDir, normal);
//                float spec = pow(max(0.0, reflectedLightDir.z), 5.0);
                float spec = pow(max(0.0, dot(reflectedLightDir, normalize(vec3(-uv, 0.5/height)))), 5.0);
                                
                float k = (0.1 + illum*intensity) / (0.1+intensity);
                return adjustGamma(vec4(col.rgb*k + spec*specular, col.a), gamma);
            }

void main() {
    fragColor = shade((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_intensity, u_height, u_specular, u_delta, u_gamma, u_lightSourceTransform);
}
