#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_gradientMap;
layout(binding = 3) uniform texture2D t_source;

#define u_gradientMap sampler2D(t_gradientMap, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_gradientMap_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_angle (U[6].x)
#define u_thickness (U[7].x)
#define u_color1 (U[8])
#define u_color2 (U[9])
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))

#define __gradientMap__texelFetch__(c) texelFetch(u_gradientMap, (c), 0)
#define __gradientMap__(p) texture(u_gradientMap, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
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

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 response(vec2 u) {
    if (u.x==0.0 && u.y==0.0) return u;
    float len = length(u);
    len = 1.0;
    vec2 n = normalize(u);
    return len*n;
}

mat2 rotation2(float angle) {
    float ca = cos(angle);
    float sa = sin(angle);
    return mat2(ca, sa, -sa, ca);
}

vec4 gradientStrokes(vec2 pos, vec2 outPos, float angle, float thickness, vec4 color1, vec4 color2, int gradientMap_specified, mat3 modelTransform) {
    float strokeIntensity = 0.0;
    mat3 inverseModelTransform = inverse(modelTransform);
    float resolution = length(inverseModelTransform[0].xy);
    vec2 sp = floor(pos*resolution+0.5)/resolution - fract(inverseModelTransform[2].xy)/resolution;
    float delta = 0.02;
    vec4 curColor = vec4(0.0, 0.0, 0.0, 1.0);
    float n = 0.;
    float ang = angle;
    mat2 rot = rotation2(ang);
    float N = 1.0;
    vec2 pp = sp;
    
    vec2 d = vec2(delta, 0.0);
    float sample00 = luma((gradientMap_specified==0 ? __source__(pp+d.xy) : __gradientMap__(pp+d.xy)).rgb);
    float sample01 = luma((gradientMap_specified==0 ? __source__(pp-d.xy) : __gradientMap__(pp-d.xy)).rgb);
    float sample10 = luma((gradientMap_specified==0 ? __source__(pp+d.yx) : __gradientMap__(pp+d.yx)).rgb);
    float sample11 = luma((gradientMap_specified==0 ? __source__(pp-d.yx) : __gradientMap__(pp-d.yx)).rgb);
    vec2 grad = vec2(
        (sample00-sample01)/(delta*2.0),
        (sample10-sample11)/(delta*2.0) ) * delta/2.0;
    //vec2 grad = getGradient(pp, delta)*delta/2.0;
    
    vec2 g = rot * (response(grad) /resolution/2.0 * N);
    float dp = dot(pos-sp, normalize(g));
    //float k = smoothstep(-0.01, 0.01, dp);
    float k = smoothstep(-thickness/resolution, thickness/resolution, dp);
    vec4 outCol = mix(color1, color2, k);
    return mergeColor(__source__(pos), outCol);
}

void main() {
    fragColor = gradientStrokes((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_angle, u_thickness, u_color1, u_color2, u_gradientMap_specified, u_modelTransform);
}
