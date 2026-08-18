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
#define u_outDim (U[4].xy)
#define u_pixelation (U[5].x)
#define u_thickness (U[6].x)
#define u_color (U[7])
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































float hexDist(vec2 p) {
    p = abs(p);
    return max(p.x, dot(p, normalize(vec2(1.0, SQRT3))));
}

vec4 hexPolarBorderCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    float x = atan(hv.y, hv.x);
    float y = 0.5-hexDist(hv);
    vec2 id = v-hv;
    return vec4(x, y, id);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 hexCubePixelate(vec2 uv, vec2 outPos, float pixelation, float thickness, vec4 color, mat3 modelTransform) {
            vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
            vec4 hex = hexPolarBorderCoords(u);
            vec2 v = (modelTransform * vec3(hex.zw, 1.0)).xy;
            if (hex.y<thickness*0.5) {
                vec4 col = __source__(v);
                return mergeColor(col, color);
            }
            else {
                float l = length(modelTransform[0].xy);
                vec2 pickCoord;
                float Y = mix(hex.y, 0.5, pixelation);
                float a = hex.x;
                float a2 = a - PI/6.0;
//                if (abs(a)>2.0*PI/3.0) pickCoord = hex.zw + Y*vec2(0.0, 0.5);
//                else if (a<0.0) pickCoord = hex.zw + Y*0.5*vec2(-SQRT3_2, -0.5);
//                else pickCoord = hex.zw + Y*0.5*vec2(SQRT3_2, -0.5);
                if (a>-5.0*PI/6.0 && a<-PI/6.0) pickCoord = hex.zw + Y*vec2(0.0, -0.5);
                else if (a<=-5.0*PI/6.0 || a>PI_2) pickCoord = hex.zw + Y*0.5*vec2(-SQRT3_2, 0.5);
                else pickCoord = hex.zw + Y*0.5*vec2(SQRT3_2, 0.5);
                v = (modelTransform * vec3(pickCoord, 1.0)).xy;
                return __source__(v);            
            }   
        }

void main() {
    fragColor = hexCubePixelate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_pixelation, u_thickness, u_color, u_modelTransform);
}
