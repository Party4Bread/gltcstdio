#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_iterations (int(U[8].x))
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_texTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_thickness (U[15].x)
#define u_color (U[16])

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

vec2 getDir(float angle) {
    return vec2(sin(angle), cos(angle));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 kifs(vec2 pos, vec2 outPos, int iterations, mat3 modelTransform, mat3 texTransform, float thickness, vec4 color) {
    pos *= 1.25;
    pos.x = abs(pos.x);
//    float ang = 5.0/6.0*PI + u_ModelTransform[2][1];
    float ang = 5.0/6.0*PI;// * u_ModelTransform[0][0];
    pos.y += tan(ang)*0.5;
    vec2 n = getDir(ang);
    float d = dot(pos-vec2(0.5, 0.0), n);
    pos -= n*max(0.0, d)*2.0;

    float ang1 = 2.0/3.0*PI + modelTransform[2][0];
    vec2 n1 = getDir(ang1);
    float ang2 = 2.0/3.0*PI + modelTransform[2][1];
    vec2 n2 = getDir(ang2);
    float scale = 1.0;
    pos.x += 0.5;
    for(int i=0; i<iterations; ++i) {
        pos *= 3.0* modelTransform[0][0];
        scale *= 3.0* modelTransform[0][0];
        pos.x -= 1.5;

        pos.x = abs(pos.x);
        pos.x -= 0.5;
        if ((i/2)*2==i) pos -= n1*min(0.0, dot(pos, n1))*2.0;
        else pos -= n2*min(0.0, dot(pos, n2))*2.0;
    }

    d = length(pos-vec2(clamp(pos.x, -1.0, 1.0), 0.0));

    pos /= scale;
    float k = d/scale<thickness*0.1 ? 1.0 : 0.0; //smoothstep(u_Thickness*0.01, 0.0, d/scale);
    vec4 col = __source__(tf(inverse(texTransform), pos));
    if (k>0.0) {
        return vec4(mix(col.rgb, color.rgb, color.a), col.a);
    }
    else {
        return col;
    }
}

void main() {
    fragColor = kifs((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_iterations, u_modelTransform, u_texTransform, u_thickness, u_color);
}
