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
#define u_outDim (U[4].xy)
#define u_vignetting (U[5].x)
#define u_blur (U[6].x)
#define u_color1 (U[7])
#define u_color2 (U[8])
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_modelTransform2 (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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


















































































































































































































































































































































vec2 getOffsetPos(mat3 transform, vec2 pos, float vignetting) {
    vec2 tPos = (inverse(transform)*vec3(pos, 1.0)).xy;
    float dist = length(pos);
    if (dist<1.0) {
        tPos = mix(pos, tPos, 1.0 - vignetting*(1.0 - dist*dist));
    }
    return tPos;
}

vec4 colorOffsetGL(vec2 pos, vec2 outPos,
                   float vignetting, float blur,
                   vec4 color1, vec4 color2,
                   mat3 modelTransform, mat3 modelTransform2) {
    if (blur != 0.0) {
        vec2 p1 = getOffsetPos(modelTransform,  pos, vignetting);
        vec2 p2 = getOffsetPos(modelTransform2, pos, vignetting);
        vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
        float totalWeight = 0.0;
        float N = 100.0;
        float blurExp = pow(blur*2.0, -4.0);
        for (float i = 0.0; i <= N; i += 1.0) {
            float k = i / N;
            vec4 c1tone = mix(vec4(1.0, 1.0, 1.0, 1.0), color1, k);
            vec4 c2tone = mix(vec4(1.0, 1.0, 1.0, 1.0), color2, k);
            vec2 q1 = mix(pos, p1, k);
            vec2 q2 = mix(pos, p2, k);
            float weight = pow(k, blurExp);
            totalWeight += weight;

            vec4 s1 = __source__(q1);
            total.rgb += c1tone.rgb * s1.rgb * weight;
            total.a   += s1.a * weight;

            vec4 s2 = __source__(q2);
            total.rgb += c2tone.rgb * s2.rgb * weight;
            total.a   += s2.a * weight;
        }
        return total / (totalWeight * mix(1.0, 1.5, blur));
    } else {
        vec4 c1 = __source__(getOffsetPos(modelTransform,  pos, vignetting));
        vec4 c2 = __source__(getOffsetPos(modelTransform2, pos, vignetting));
        return vec4((c1*color1 + c2*color2).rgb, (c1.a + c2.a) * 0.5);
    }
}

void main() {
    fragColor = colorOffsetGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_vignetting, u_blur, u_color1, u_color2, u_modelTransform, u_modelTransform2);
}
