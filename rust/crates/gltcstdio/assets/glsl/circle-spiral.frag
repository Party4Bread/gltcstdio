#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_power (U[6].x)
#define u_mode (int(U[7].x))
#define u_count (int(U[8].x))
#define u_modCount (int(U[9].x))
#define u_color1 (U[10])
#define u_color2 (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_modelTransform2 (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

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















































































































































































































































































































































vec4 hexCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    vec2 id = v-hv;
    return vec4(hv, id);
}

float measure(vec2 v, float power) {
    float low = min(abs(v.x), abs(v.y));
    float high = max(abs(v.x), abs(v.y));
    return high==0.0 ? 0.0 : high * pow(1.0 + pow(low/high, power), 1.0/power);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 circleRippleIllusion(vec2 uv, vec2 outPos, int source_specified, float power, int mode, int count, int modCount, vec4 color1, vec4 color2, mat3 modelTransform, mat3 modelTransform2) {
    float g = 1.0;
    mat3 inverseTransform = inverse(modelTransform);
    mat3 inverseTransform2 = inverse(modelTransform2);
    
    if (mode==1) {
        uv = mod(uv+1.0, 2.0) - 1.0;
    }
    else if (mode==2) {
        uv = hexCoords(uv*0.5).xy * 2.0;
    }
    else if (mode==3) {
        vec2 origUv = uv;
        uv = mod(uv+1.0, 2.0) - 1.0;
        if (measure(uv, power)>1.0) uv = (mod(origUv, 2.0) - 1.0) / (1./pow(0.5, 1./power)-1.);
    }
    else if (mode==4) {
        vec2 origUv = uv;
        uv = hexCoords(uv*0.5).xy * 2.0;
        if (measure(uv, power)>1.0) { 
            uv = hexCoords(origUv*0.5 - vec2(0., 1.0/SQRT3)).xy * 2.0; 
            uv *= 6.4641016; 
            if (measure(uv, power)>1.0) {
                uv = hexCoords(origUv*0.5 + vec2(0., 1.0/SQRT3)).xy * 2.0; 
                uv *= 6.4641016; 
            }
        }
    }
    
    //float invPower = 1./power;
    for(float i=0.0; i<float(count); ++i) {
        float d = measure(uv, power);
        if (d>1.0) { break; }
        uv = tf(inverseTransform, uv);
        if (mod(i+1.0, float(modCount))==0.0) uv = tf(inverseTransform2, uv);
        g = 1.0 - g;
    }
    vec4 col = mix(color1, color2, g);

    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}

void main() {
    fragColor = circleRippleIllusion((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_power, u_mode, u_count, u_modCount, u_color1, u_color2, u_modelTransform, u_modelTransform2);
}
