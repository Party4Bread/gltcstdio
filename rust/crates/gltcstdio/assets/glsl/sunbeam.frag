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
#define u_intensity (U[5].x)
#define u_dampening (U[6].x)
#define u_normalization (U[7].x)
#define u_color (U[8])
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















































































































































































































































































































































float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 sunbeam(vec2 uv, vec2 outPos, float intensity, float dampening, float normalization, vec4 color, mat3 modelTransform) {                   
    vec4 inc = __source__(uv);

    vec2 pos = (modelTransform * vec3(0.0, 0.0, 1.0)).xy;
    float radius = length(modelTransform[0].xy);
    float strongRadius = radius * (1.0 - dampening*dampening);
    float step = 0.01; // up from 0.001 in Chroma Lab: this seems both better looking and faster!
    vec2 dir = normalize(uv-pos);
    float k = 1.0;
    float dist = length(pos-uv);
    for(float d = 0.0; d<min(radius, dist); d+=step) {
        vec2 p = pos + dir*d;
        float damp = smoothstep(strongRadius*0.25, strongRadius, d);
        float v = mix(1.0, luma(__source__(p).rgb), damp);
        //k += 0.001*v;
        k = min(k, max(0.0, v*v));
        //k = min(k, pow(max(0.0, v-d), 2.0));
        //k = min(k, max(0.0, v-d));
    }
    k = k*intensity*10.0;
    vec3 light = k*color.rgb;

    float value = (inc.r+inc.g+inc.b)/3.0;
    /*float reduce = mix(1.0, smoothstep(1.0, 0.0, value), u_Normalize*0.01);
    return inc + reduce*vec4(light, 0.0);*/
    //float reduce = mix(1.0, 1.0/(1.0+k*u_Color1.a), u_Normalize*0.1);
    float alpha = mix(smoothstep(1.0, 0.0, value), 1.0, color.a);
    float reduce = mix(1.0, 1.0/(1.0+intensity*10.0), normalization);
    //return (inc + vec4(light, 0.0))*vec4(vec3(reduce), 1.0);
    //return vec4(vec3(k), 1.0);
    return vec4((inc.rgb+alpha*light)*reduce, inc.a);
}

void main() {
    fragColor = sunbeam((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_dampening, u_normalization, u_color, u_modelTransform);
}
