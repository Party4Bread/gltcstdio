#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_mask;
layout(binding = 3) uniform texture2D t_source1;
layout(binding = 4) uniform texture2D t_source2;

#define u_mask sampler2D(t_mask, samp)
#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_mask_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_blendMode (int(U[6].x))
#define u_intensity (U[7].x)
#define u_maskTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

#define __mask__texelFetch__(c) texelFetch(u_mask, (c), 0)
#define __mask__(p) texture(u_mask, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source1__texelFetch__(c) texelFetch(u_source1, (c), 0)
#define __source1__(p) texture(u_source1, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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















































































































































































































































































































































vec4 blend(int mode, vec4 a, vec4 b) {
    vec3 aa = a.rgb;
    vec3 bb = b.rgb;
    vec3 cc;
    { int _sw_sel = int(mode);
if (_sw_sel == int(1)) { cc = aa + bb; }
else if (_sw_sel == int(2)) { cc = aa * bb; }
else if (_sw_sel == int(3)) { cc = aa - bb; }
else if (_sw_sel == int(4)) { cc = abs(aa - bb); }
else if (_sw_sel == int(5)) { cc = aa / bb; }
else if (_sw_sel == int(10)) { return max(a, b); }
else if (_sw_sel == int(11)) { return min(a, b); }
else { return b; }
}
    return vec4(cc, mix(a.a, b.a, 0.5));
}

float luma(vec3 c) {
    return (0.2989*c.r + 0.587*c.g + 0.114*c.b);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 blendImg(vec2 pos, vec2 outPos, int blendMode, float intensity, int mask_specified, mat3 maskTransform) {
    vec4 in1 = __source1__(pos);
    vec4 in2 = __source2__(pos);
    //float mask = mask_specified==1 ? luma(__mask__(tf(maskTransform, pos)).rgb) : 0.5; // this makes more sense but see note above!!
    float mask = mask_specified==1 ? luma(__mask__(pos).rgb) : 0.5;
    //if (invert==1) mask = 1. - mask;
    vec4 blended = blend(blendMode, in1, in2);
    return mix(in1, blended, mask * intensity);
}

void main() {
    fragColor = blendImg((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_blendMode, u_intensity, u_mask_specified, u_maskTransform);
}
