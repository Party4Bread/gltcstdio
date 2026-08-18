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
#define u_outDim (U[4].xy)
#define u_source_specified (int(U[5].x))
#define u_scale (int(U[6].x))
#define u_innerScale (int(U[7].x))
#define u_color1 (U[8])
#define u_color2 (U[9])
#define u_color3 (U[10])
#define u_color4 (U[11])
#define u_borderColor (U[12])
#define u_mode (int(U[13].x))
#define u_thickness (U[14].x)
#define u_border (U[15].x)
#define u_balance (U[16].x)
#define u_offset (U[17].x)

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





















































































































































































































































































































































float getSpiralIndex(vec2 uv) {
    vec2 v = fract(uv);
    vec2 u = floor(uv);
    
    vec2 m = abs(u + .5);
    float level = max(m.x, m.y) + .5;
    
    if (u.y==-level) {
        return 4.*level*level - 1. - (level-1.-u.x);
    }
    else if (u.x==-level) {
        return 4.*level*level - 1. - (2.*level-1.) + (-level-u.y);
    }
    else if (u.y==level-1.) {
        return 4.*(level-1.)*(level-1.) - 1. + (2.*level - 1.) + (level-1.-u.x);
    }
    else {
        return 4.*(level-1.)*(level-1.) - 1. + (u.y + level);
    }
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float mir(float x, float a) {
    return a * (1. - abs(mod(x, 2.*a)/a - 1.));
}

vec2 remap(vec2 uv, int scale) {
    float s = float(scale);
    return uv*s - float(scale/2);    
}

vec4 squareSpiral(vec2 uv, vec2 outPos, vec2 outDim, int source_specified, int scale, int innerScale, vec4 color1, vec4 color2, vec4 color3, vec4 color4, vec4 borderColor, int mode, float thickness, float border, float balance, float offset) {
    vec2 orig2Uv = uv;
    if (mode>=1) uv = mod(uv+vec2(1., 1.), 2.) - vec2(1., 1.);
//    if (mode==2) return vec4(uv.x, uv.y, .5, 1.);
    
    vec2 origUv = uv;
//    uv = remap((uv + vec2(outDim.x/outDim.y, 1.))*.5, scale);
    uv = remap((uv + vec2(1., 1.))*.5, scale);
    float index = getSpiralIndex(uv);
    float intensity = 1./float(scale*scale);
    float k = intensity * index;
    if (balance!=0.0) k = k * pow(1000., balance);
    if (offset!=0.0) k += offset;
    if (mode!=0) {
        k = mir(k, 1.0);
    }
    vec4 outColor = mix(color1, color2, k);
       
    vec2 uv2 = fract(uv);
    float t = thickness * 0.5;
    if (uv2.x>t && uv2.x<1.-t && uv2.y>t && uv2.y<1.-t) {
        uv2 = remap((uv2-t) / (1.-thickness), innerScale);
        float index = getSpiralIndex(uv2);
        float intensity = 1./float(innerScale*innerScale);
        float k = intensity * index;
        vec4 innerColor = mix(color3, color4, k);
        outColor = mergeColor(outColor, innerColor);
    }
    
    if (border>0.) {
        vec2 fuv = fract(uv);
        if (fuv.x<border && abs(index - getSpiralIndex(uv-vec2(1.0, 0.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.y<border && abs(index - getSpiralIndex(uv-vec2(0.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x>1.-border && abs(index - getSpiralIndex(uv+vec2(1.0, 0.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.y>1.-border && abs(index - getSpiralIndex(uv+vec2(0.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x<border && fuv.y<border && abs(index - getSpiralIndex(uv-vec2(1.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x>1.-border && fuv.y<border && abs(index - getSpiralIndex(uv+vec2(1.0, -1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x<border && fuv.y>1.-border && abs(index - getSpiralIndex(uv+vec2(-1.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (fuv.x>1.-border && fuv.y>1.-border && abs(index - getSpiralIndex(uv+vec2(1.0, 1.0)))>1.0) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (mode==1) {
            if (origUv.x<-1.0+2.*border/float(scale) || origUv.x>1.0-2.*border/float(scale)) {
                outColor = mergeColor(outColor, borderColor);
            }
        }
    }
    if (mode==2) {
        if (origUv.x<-1.0+2.*border/float(scale) || origUv.x>1.0-2.*border/float(scale)) {
            outColor = mergeColor(outColor, borderColor);
        }
        else if (orig2Uv.y<-1.0+2.*border/float(scale) || orig2Uv.y>1.0-2.*border/float(scale)) {
            outColor = mergeColor(outColor, borderColor);
        }
    }
    
    if (source_specified==1) return mergeColor(__source__(outPos), outColor);
    else return outColor;
}

void main() {
    fragColor = squareSpiral((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_outDim, u_source_specified, u_scale, u_innerScale, u_color1, u_color2, u_color3, u_color4, u_borderColor, u_mode, u_thickness, u_border, u_balance, u_offset);
}
