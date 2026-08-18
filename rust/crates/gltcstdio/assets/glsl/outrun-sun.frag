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
#define u_thickness (U[5].x)
#define u_color1 (U[6])
#define u_color2 (U[7])
#define u_glow (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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















































































































































































































































































































































vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 outrunSun(vec2 uv, vec2 outPos, float thickness, vec4 color1, vec4 color2, float glow, mat3 modelTransform) {
    vec2 u = tf(inverse(modelTransform), uv);

    vec4 bkgCol = __source__(uv);
    float l = length(u);
    vec4 color = bkgCol;
    bool inside = false;
    
    if (l<1.0) {
        if (u.y>0.0) {
            float i = 1.0+u.y*(thickness*4.);
            if (fract(i*i)>0.5) {
                color = mix(color1, color2, 0.5+u.y*0.5);
                inside = true;
            }
        }
        else if (u.y<=0.0) {
            color = mix(color1, color2, 0.5+u.y*0.5);
            inside = true;
        }
    }
    
    if (!inside && glow>0.0) {
        float d = max(0.0, l-1.0)+1.1;
        vec4 glowColor = mix(color1, color2, 0.5+u.y*0.5);
        float alpha = pow(d, -2.5) * glow;
        color.rgb = mix(color.rgb, glowColor.rgb, alpha);                
    }

    return mergeColor(bkgCol, color);
}

void main() {
    fragColor = outrunSun((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_thickness, u_color1, u_color2, u_glow, u_modelTransform);
}
