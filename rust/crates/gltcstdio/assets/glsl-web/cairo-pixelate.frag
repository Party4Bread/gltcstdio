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
#define u_pixelation (U[5].x)
#define u_shape (U[6].x)
#define u_thickness (U[7].x)
#define u_color (U[8])
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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

CairoTile cairoTile(vec2 uv, float k) {
    vec2 id = floor(uv);
    float alt = mod(id.x + id.y, 2.0);
    uv = fract(uv) - .5;
    vec2 p = abs(uv);
    if (alt==1.) p = p.yx;
    float ang = (k*0.5 + 0.5) * PI;
    vec2 n = vec2(sin(ang), cos(ang));
    float d = dot(p-.5, n);
    
    if (d*(alt-.5) < 0.0)
        id.x += sign(uv.x) * .5;
    else 
        id.y += sign(uv.y) * .5;
    
    d = min(d, p.x);
    d = max(d, -p.y);
    d = abs(d);
    d = min(d, dot(p-.5, vec2(n.y, -n.x)));
    
    return CairoTile(id+.5, d);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec4 cairoPixelate(vec2 uv, vec2 outPos, float pixelation, float shape, float thickness, vec4 color, mat3 modelTransform) {
    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    CairoTile cairo = cairoTile(u, shape);
    vec2 v = (modelTransform * vec3(cairo.center, 1.0)).xy;
    if (cairo.borderDist<thickness*0.5) {
        vec4 col = __source__(v);
        return mergeColor(col, color);
    }
    else {
        float l = length(modelTransform[0].xy);
        return __source__(v + pixelation * l * vec2(0.0, cairo.borderDist));            
    }   
}

void main() {
    fragColor = cairoPixelate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_pixelation, u_shape, u_thickness, u_color, u_modelTransform);
}
