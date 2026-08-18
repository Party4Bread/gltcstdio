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
#define u_intensity (U[5].x)
#define u_dampening (U[6].x)
#define u_blend (U[7].x)
#define u_dispersion (U[8].x)
#define u_fadeThickness (U[9].x)
#define u_frequency (U[10].x)
#define u_thickness (U[11].x)
#define u_variability (U[12].x)
#define u_modelTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))
#define u_dampeningTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

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















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 halo(vec2 uv, vec2 outPos, float intensity, float dampening, float blend, float dispersion, float fadeThickness, float frequency, float thickness, float variability, mat3 modelTransform, mat3 dampeningTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float lum = intensity;
    frequency = pow(1.05, frequency);
    
    vec2 v = u;
    float angle = atan(v.y, v.x);
    float len = length(v);
    //float qvar = sin(angle*300.0 * (1.5+sin(angle*3.0)));
    float qvar = sin(angle*frequency * (1.5+sin(angle*3.0))) 
        * sin(angle*frequency*0.88 * (1.5+sin(angle*7.0))) 
        * sin(angle*frequency*0.81 * (1.5+sin(angle*11.0)));
    float expand = 1.0 + qvar * variability * (0.3+0.25*(1.0+sin(angle*5.0))* (1.0+sin(angle*14.0)));
    len = (len - (1.0-thickness*.5)) * expand + (1.0-thickness*.5);

    float d = len;
    float dr = len * (1.0+dispersion);
    float kr = smoothstep(1.0-thickness, 1.0-thickness+fadeThickness, dr) * smoothstep(1.0, 1.0-fadeThickness, dr);    
    float dg = len;
    float kg = smoothstep(1.0-thickness, 1.0-thickness+fadeThickness, dg) * smoothstep(1.0, 1.0-fadeThickness, dg);     
    float db = len * (1.0-dispersion);
    float kb = smoothstep(1.0-thickness, 1.0-thickness+fadeThickness, db) * smoothstep(1.0, 1.0-fadeThickness, db);    
    vec3 halo =  vec3(kr, kg, kb);
            

    // dampen
    d = length(tf(inverse(dampeningTransform), u));
    float dampen = 1.0 - dampening * smoothstep(1.0, 0.5, d);
    
    halo *= dampen;

    vec4 col = vec4(lum*halo, 1.0);           
    vec4 bkgCol = __source__(uv);
    float k1 = blend;
    float k2 = 1.-blend;
    vec4 outCol = mix(bkgCol, bkgCol+col, k2+k1*min(lum*k2*10., 1.));
    return outCol;
}

void main() {
    fragColor = halo((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_dampening, u_blend, u_dispersion, u_fadeThickness, u_frequency, u_thickness, u_variability, u_modelTransform, u_dampeningTransform);
}
