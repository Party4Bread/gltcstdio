#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_mode (int(U[5].x))
#define u_power (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))
#define u_redTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_greenTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))
#define u_blueTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

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


















































































































































































































































































































































vec2 getOffsetPos(mat3 transform, vec2 pos, float k, float power) {
    mat2 tScaleRot = mat2(transform[0].xy, transform[1].xy); //mat2(transform);
    vec2 u = tScaleRot*vec2(1.0, 0.0);
    vec2 v = tScaleRot*vec2(0.0, 1.0);
    vec2 nu = normalize(u);
    vec2 nv = normalize(v);
    vec2 t = vec2(transform[2][0], transform[2][1])*k;
    float tu = dot(nu, t);
    float tv = dot(nv, t);
    float scale = length(u);

    float pu = dot(nu, pos);
    if (pu<=tu-scale || pu>=tu+scale) return pos;
    float kk = pow((1.0 + cos((pu-tu)/scale*PI))/2.0, pow(1.07, -power*100.));

    return pos - nv * kk*tv;
}

vec4 rgbSpike(vec2 pos, vec2 outPos, int mode, float power, mat3 modelTransform, mat3 redTransform, mat3 greenTransform, mat3 blueTransform) {
            vec4 col = __source__(pos);
            float k = 1.0;
            
            mat3 rmt = modelTransform;
            mat3 gmt = modelTransform;
            mat3 bmt = modelTransform;
            
            if (mode==1) {
                vec2 dir = normalize(modelTransform[1].xy);
                vec2 itr = modelTransform[2].xy - 2. * dir * dot(dir, modelTransform[2].xy);
//                gmt = mat3(mat2(modelTransform));//mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
                gmt = mat3(modelTransform[0], modelTransform[1], vec3(0., 0., 1.));
                rmt = mat3(modelTransform[0], modelTransform[1], vec3(itr, 1.0));           
            }
            else if (mode==2) {
                //gmt = mat3(mat2(modelTransform));
                gmt = mat3(modelTransform[0], modelTransform[1], vec3(0., 0., 1.));
                rmt = mat3(modelTransform[0], modelTransform[1], vec3(-modelTransform[2].xy, 1.0));
            }
            
            vec4 red = __source__(getOffsetPos(rmt*redTransform, pos, k, power));
            vec4 green = __source__(getOffsetPos(gmt*greenTransform, pos, k, power));
            vec4 blue = __source__(getOffsetPos(bmt*blueTransform, pos, k, power));
            vec4 outColor =  vec4(red.r, green.g, blue.b, (red.a+green.a+blue.a)/3.0);
            return outColor;
        }

void main() {
    fragColor = rgbSpike((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_mode, u_power, u_modelTransform, u_redTransform, u_greenTransform, u_blueTransform);
}
