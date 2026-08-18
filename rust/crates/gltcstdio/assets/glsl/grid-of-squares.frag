#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[21];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_shape (U[6].x)
#define u_shadows (U[7].x)
#define u_colorIn (U[8])
#define u_colorOut (U[9])
#define u_colorShadow (U[10])
#define u_colorGlow (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_insideTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))
#define u_cellTransform (mat3(U[18].xyz, U[19].xyz, U[20].xyz))

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

vec4 mergeGlow(vec4 bkg, vec4 glow) {
    return vec4(bkg.rgb + glow.rgb*glow.a, bkg.a);
}

float sdDisk(vec2 u, float r) {
    return length(u)-r;
}

float sdEquiTriangle(vec2 u) {
    u.x = abs(u.x) - 1.;
    u.y = u.y + 1./SQRT3;
    if (u.x+SQRT3*u.y>0.) u = vec2(u.x-SQRT3*u.y, -SQRT3*u.x-u.y)/2.;
    u.x -= clamp(u.x, -2., 0.);
    return -length(u) * sign(u.y);
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

float sdf(vec2 u, float count, float shape, mat3 cellTransform) {
    u = (cellTransform * vec3((u-clamp(round(u), -count, count)) * 2., 1.)).xy;
    
    if (shape<0.0) return sdRectangle(u, vec2(0.5));
    else if (shape<=1.0) return mix(sdRectangle(u, vec2(0.5)), sdDisk(u, 0.5), shape);
    else if (shape<=2.0) return mix(sdDisk(u, 0.5), sdEquiTriangle(u*1.5), shape-1.0);
    else return sdEquiTriangle(u*1.5);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 gridOfSquares(vec2 uv, vec2 outPos, int count, float shape, float shadows, vec4 colorIn, vec4 colorOut, vec4 colorShadow, vec4 colorGlow, mat3 modelTransform, mat3 insideTransform, mat3 cellTransform) {
    vec2 u = tf(inverse(modelTransform), uv);
    
    float d = sdf(u, float(count), shape, inverse(cellTransform));
   
    float shadow = 0.0;
    vec4 tint = vec4(0.0);
    vec2 v = uv;
    if (d>0.0) {
        if (shadows>0.0) shadow = 0.7*smoothstep(shadows, 0., d);
        tint = colorOut;
    }
    else {
        if (shadows<0.0) shadow = 0.7*smoothstep(shadows, 0., d);
        tint = colorIn;
        v = tf(inverse(insideTransform), uv);
    }
    
    vec4 color = __source__(v);
    vec4 glow = (colorGlow.a!=0.0) ? vec4(colorGlow.rgb * 0.01/abs(d), min(1.0, colorGlow.a* 0.01/abs(d))) : vec4(0.);           
    return mergeGlow(mergeColor(mergeColor(color, tint), vec4(colorShadow.rgb, colorShadow.a*shadow)), glow);
}

void main() {
    fragColor = gridOfSquares((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_shape, u_shadows, u_colorIn, u_colorOut, u_colorShadow, u_colorGlow, u_modelTransform, u_insideTransform, u_cellTransform);
}
