#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_rotateMode (int(U[6].x))
#define u_includedRect (U[7].xy)
#define u_colorOut (U[8])

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

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 rotateSmart(vec2 uv, vec2 outPos, int rotateMode, vec2 sourceDim, vec2 includedRect, vec4 colorOut, mat3 viewTransform) {
            float ratio = sourceDim.x/sourceDim.y;
            vec2 boundA = abs(tf(viewTransform, vec2(ratio, 1.)));
            vec2 boundB = abs(tf(viewTransform, vec2(ratio, -1.)));
            vec2 bounds = vec2(max(boundA.x, boundB.x), max(boundA.y, boundB.y));

            if (rotateMode<=1) {
                vec2 u = uv;
                bool inside = abs(u.x)<=ratio && abs(u.y)<=1.0; 
                return (inside||rotateMode==1) ? __source__(uv) : mergeColor(__source__(uv), colorOut);//__source__(uv);
            }
            if (rotateMode==3) {
                vec2 bounds2 = abs(tf(viewTransform, includedRect));
                vec2 v = tf(viewTransform, uv)*bounds.y;
                vec2 delta = abs(abs(v)-bounds2);
                //if (min(delta.x, delta.y)<0.01) return vec4(1., 0., 0., 1.);
                vec2 u = uv  * abs(bounds2.y);
                return __source__(u);
            }
            
            vec2 u = uv * bounds.y;
            bool inside = abs(u.x)<=ratio && abs(u.y)<=1.0; 
/*
      vec2 vert = tf(viewTransform, vec2(0., 1.));
      float vertLength = length(vert);
      vec2 v = tf(viewTransform, uv);
      //if (sdSegment(v, vec2(0.0), vert) < 0.01) return vec4(1., 1., 0., 1.);
//      vec2 iRect = vec2(-0.3, 1.); //includedRect;
      vec2 iRect = includedRect;
      if (length(u-iRect)<0.1) return vec4(0., 0.5, 1., 1.);
      vec2 uu = tf(viewTransform, u);
      vec2 tir = tf(viewTransform, iRect / bounds.y);
      
      if (abs(v.x)<abs(tir.x) && abs(v.y)<abs(tir.y)) return mergeColor(__source__(uv), vec4(.5, .5, 1., 0.2));
      
      //if (abs(uv.x)<abs(iRect.x)/ bounds.y && abs(uv.y)<abs(iRect.y)/ bounds.y) return mergeColor(__source__(uv), vec4(.5, .5, 1., 0.2));
      //if (sdSegment(uv, vec2(0.0), vec2(0., 1.)) < 0.01) return vec4(1., 0.0, 1., 1.);      
      //return vec4(fract(v), .5, 1.);
      //if (abs(v.x)<includedRect.x && abs(v.y)<includedRect.y) return vec4(1., 0., 0., 1.);
*/
            return inside ? __source__(uv) : mergeColor(__source__(uv), colorOut);
        }

void main() {
    fragColor = rotateSmart((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_rotateMode, u_sourceDim, u_includedRect, u_colorOut, u_viewTransform);
}
