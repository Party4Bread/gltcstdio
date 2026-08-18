#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[13];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_source_specified (int(U[4].x))
#define u_outDim (U[5].xy)
#define u_thickness (U[6].x)
#define u_borderColor (U[7])
#define u_colorShadow (U[8])
#define u_colorOffset (U[9])
#define u_color1 (U[10])
#define u_color2 (U[11])
#define u_color3 (U[12])

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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





















































































































































































































































































































































float hexDist(vec2 p) {
    p = abs(p);
    return max(p.x, dot(p, normalize(vec2(1.0, SQRT3))));
}

vec4 hexPolarBorderCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    float x = atan(hv.y, hv.x);
    float y = 0.5-hexDist(hv);
    vec2 id = v-hv;
    return vec4(x, y, id);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float reflectFloat(float x) {
    return 1.0-abs(mod(x, 2.)-1.0);
}

vec4 reflectVec4(vec4 u) {           
    return vec4(reflectFloat(u.x), reflectFloat(u.y), reflectFloat(u.z), reflectFloat(u.a)); 
}

vec4 hexCubes(vec2 uv, vec2 outPos, int source_specified, float thickness, vec4 borderColor, vec4 colorShadow, vec4 colorOffset, vec4 color1, vec4 color2, vec4 color3) {
    vec2 u = uv;
    
    vec4 col; 

    vec4 hex = hexPolarBorderCoords(u);
    float borderSize = thickness*0.5;
    if (hex.y<borderSize) return borderColor;
    float angle = mod(hex.x + PI2 + PI/6.0, PI2);
    vec2 id = hex.zw;
    float topIndex = id.y;
    float rightIndex = id.x-id.y*0.5;
    float leftIndex = id.x+id.y*0.5;
    
    float gradientStrength = colorOffset.a*colorOffset.a;

    if (angle<PI2_3) col = reflectVec4(color2 + vec4(colorOffset.r*rightIndex-0.5, 0.0, 0.0, 0.0) * gradientStrength);
    else if (angle<2.*PI2_3) col = reflectVec4(color1 + vec4(0.0, colorOffset.g*leftIndex-0.5, 0.0, 0.0) * gradientStrength);
    else col = reflectVec4(color3 + vec4(0.0, 0.0, colorOffset.b*topIndex-0.5, 0.0) * gradientStrength);
    
    float shadowK = (0.5-hex.y)/(0.5-borderSize);
    vec4 sCol = vec4(colorShadow.rgb, colorShadow.a*shadowK);
    col = mergeColor(col, sCol);
    
    if (source_specified==1) {
        col = mergeColor(__source__(uv), col);
    }
               
    return col;
}

void main() {
    fragColor = hexCubes((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_source_specified, u_thickness, u_borderColor, u_colorShadow, u_colorOffset, u_color1, u_color2, u_color3);
}
