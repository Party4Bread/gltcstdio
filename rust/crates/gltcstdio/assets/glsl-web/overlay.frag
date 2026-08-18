#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source1;
layout(binding = 3) uniform texture2D t_source2;

#define u_source1 sampler2D(t_source1, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source2Dim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_blendMode (int(U[6].x))
#define u_intensity (U[7].x)
#define u_thickness (U[8].x)
#define u_shadows (U[9].x)
#define u_color (U[10])
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 overlay(vec2 uv, vec2 outPos, int blendMode, float intensity, float thickness, float shadows, vec4 color, vec2 source2Dim, mat3 modelTransform) {
    vec4 bkgColor = __source1__(uv);
    
    vec2 u = tf(inverse(modelTransform), uv);
    float ratio2 = source2Dim.x/source2Dim.y;
    vec2 borderDim = vec2(ratio2+thickness*0.3, 1.0+thickness*0.3);
    if (abs(u.x)<=ratio2 && abs(u.y)<=1.) {
        vec4 overColor = __source2__(u);
        vec4 blended = blend(blendMode, bkgColor, overColor);
        vec4 mixed = mix(bkgColor, blended, intensity);                    
        return mergeColor(bkgColor, mixed);
    }
    else if (abs(u.x)<=borderDim.x && abs(u.y)<=borderDim.y) {
        return color;
    }   
    else {
        if (shadows==0.0) return bkgColor;
        float d = sdRectangle(u, borderDim);
        float s = smoothstep(shadows*0.6, 0.0, d)*.5;
        return mergeColor(bkgColor, vec4(0., 0., 0., s));
        //return mix(bkgColor, vec4(0., 0., 0., 1.), s);
    }               
}

void main() {
    fragColor = overlay((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_blendMode, u_intensity, u_thickness, u_shadows, u_color, u_source2Dim, u_modelTransform);
}
