#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[19];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_shadows (U[5].x)
#define u_intensity (U[6].x)
#define u_thickness (U[7].x)
#define u_borderColor (U[8])
#define u_colorShadow (U[9])
#define u_axisTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_viewTransform1 (mat3(U[13].xyz, U[14].xyz, U[15].xyz))
#define u_viewTransform2 (mat3(U[16].xyz, U[17].xyz, U[18].xyz))

#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) textureLod(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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















































































































































































































































































































































vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

vec2 interpolatedRand2(vec2 v) {
    float fractY = fract(v.y);
    return mix(
        mix(rand2(floor(v)), rand2(vec2(floor(v.x), ceil(v.y))), fractY),
        mix(rand2(vec2(ceil(v.x), floor(v.y))), rand2(ceil(v)), fractY),
        fract(v.x) );
}

vec2 fractalValueNoiseDisplace(vec2 u, vec2 v, int count, float intensity) {
    float s = 1.0;
    float maxDisplacement = intensity; 

    vec2 totalDisp = vec2(0.);

    for(int i = 0; i<count; ++i) {
        vec2 disp = interpolatedRand2(v*s);
        totalDisp += maxDisplacement * (disp - vec2(0.5, 0.5))*2.0;

        maxDisplacement *= 0.5;
        s *= 2.1055472;
    }

    return u + totalDisp;
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 shredCombine(vec2 pos, vec2 outPos, float shadows, float intensity, float thickness, vec4 borderColor, vec4 colorShadow, mat3 axisTransform, mat3 viewTransform1, mat3 viewTransform2) {
    mat3 inverseAxisTransform = inverse(axisTransform);
    vec2 u = tf(inverseAxisTransform, pos); 
    float scale = length(axisTransform[0].xy);
    u = fractalValueNoiseDisplace(u, u, 12, intensity * 5.0);
    float d = u.x * scale;
    
    float th = thickness*0.25;
    if (abs(d) < th) return borderColor;
    
    vec4 outCol;
    if (d<0.0) outCol = __source1__(tf(inverse(viewTransform1), pos));
    else outCol = __source2__(tf(inverse(viewTransform2), pos));

    if (shadows!=0.0) {
        float dShadow = (sign(shadows) * d) - th;
        if (dShadow>0.0) {
            float shadowStrength = smoothstep(abs(shadows), abs(shadows)*0.25, dShadow);
            vec4 shColor = vec4(colorShadow.rgb, colorShadow.a * shadowStrength);
            outCol = mergeColor(outCol, shColor);
        }
    }
    
    return outCol;
}

void main() {
    fragColor = shredCombine((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_shadows, u_intensity, u_thickness, u_borderColor, u_colorShadow, u_axisTransform, u_viewTransform1, u_viewTransform2);
}
