#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[11];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_blend (U[5].x)
#define u_offset (U[6].x)
#define u_vignetting (U[7].x)
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

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

vec4 hexCoords(vec2 v) {
    vec2 r = vec2(1.0, SQRT3);
    vec2 h = r/2.0;
    vec2 a = vec2(mod(v.x, r.x), mod(v.y, r.y))-h;
    vec2 b = vec2(mod(v.x-h.x, r.x), mod(v.y-h.y, r.y))-h;
    vec2 hv = length(a)<length(b) ? a : b;
    vec2 id = v-hv;
    return vec4(hv, id);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float vig(float w, float vignetting) {
    return mix(w, 1.0, 1.0-vignetting);
}

float hexDist(vec2 p) {
    p = abs(p);
    return max(p.x, dot(p, normalize(vec2(1.0, SQRT3))));
}

float ww(vec2 u, float blend) {
            float d = (0.5-hexDist(u))*2.0;
            return smoothstep(-blend, blend, d);
        }

vec4 smoothKaleidoscope(vec2 uv, vec2 outPos, float blend, float offset, float vignetting, mat3 modelTransform, mat3 viewTransform) {
    vec2 u = uv;

    vec4 hex = hexCoords(u);
    mat3 inverseModelTransform = inverse(modelTransform);
    
    if (blend==0.0) {
        vec2 dv = offset*hex.zw;
        return __source__(tf(inverseModelTransform, hex.xy + dv));
    }
    else {
        vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
        float totalWeight = 0.0;
        vec4 black = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 hc = hex.xy;
        vec2 dv = offset*hex.zw;
        float wCenter = ww(hc, blend);
        total += wCenter*mix(black, __source__(tf(inverseModelTransform, hex.xy + dv)), vig(wCenter, vignetting));
        totalWeight += wCenter;

        vec2 delta = vec2(1.0, 0.0);
        vec2 hexRight = hc-delta;
        dv = offset*(hex.zw+delta);
        float wRight = ww(hexRight, blend);
        totalWeight += wRight;
        total += wRight*mix(black, __source__(tf(inverseModelTransform, hexRight.xy + dv)), vig(wRight, vignetting));

        delta = vec2(-1.0, 0.0);
        vec2 hexLeft = hc-delta;
        dv = offset*(hex.zw+delta);
        float wLeft = ww(hexLeft, blend);
        totalWeight += wLeft;
        total += wLeft*mix(black, __source__(tf(inverseModelTransform, hexLeft.xy + dv)), vig(wLeft, vignetting));

        delta = vec2(0.5, SQRT3_2);
        vec2 hexTopRight = hc-delta;
        dv = offset*(hex.zw+delta);
        float wTopRight = ww(hexTopRight, blend);
        totalWeight += wTopRight;
        total += wTopRight*mix(black, __source__(tf(inverseModelTransform, hexTopRight.xy + dv)), vig(wTopRight, vignetting));

        delta = vec2(-0.5, SQRT3_2);
        vec2 hexTopLeft = hc-delta;
        dv = offset*(hex.zw+delta);
        float wTopLeft = ww(hexTopLeft, blend);
        totalWeight += wTopLeft;
        total += wTopLeft*mix(black, __source__(tf(inverseModelTransform, hexTopLeft.xy + dv)), vig(wTopLeft, vignetting));

        delta = vec2(0.5, -SQRT3_2);
        vec2 hexBottomRight = hc-delta;
        dv = offset*(hex.zw+delta);
        float wBottomRight = ww(hexBottomRight, blend);
        totalWeight += wBottomRight;
        total += wBottomRight*mix(black, __source__(tf(inverseModelTransform, hexBottomRight.xy + dv)), vig(wBottomRight, vignetting));

        delta = vec2(-0.5, -SQRT3_2);
        vec2 hexBottomLeft = hc-delta;
        dv = offset*(hex.zw+delta);
        float wBottomLeft = ww(hexBottomLeft, blend);
        totalWeight += wBottomLeft;
        total += wBottomLeft*mix(black, __source__(tf(inverseModelTransform, hexBottomLeft.xy + dv)), vig(wBottomLeft, vignetting));

        return total/totalWeight;
    }        
}

void main() {
    fragColor = smoothKaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_blend, u_offset, u_vignetting, u_modelTransform, u_viewTransform);
}
