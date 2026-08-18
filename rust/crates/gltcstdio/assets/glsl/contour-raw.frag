#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_count (int(U[6].x))
#define u_colorBkg (U[7])
#define u_colorStroke (U[8])
#define u_thickness (U[9].x)

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

vec4 mixColors(vec4 a, vec4 b, float k) {
    float ka = mix(a.a, b.a, k);
    return ka==0.0 
        ? mix(a, b, k)
        : vec4(mix(a.rgb*a.a, b.rgb*b.a, k)/ka, mix(a.a, b.a, k));
}

float sampleCol(vec4 color, float count) {
    return floor((color.r + color.g + color.b)*(count-1.0)/3.0 + 0.5);
}

vec4 contour(vec2 uv, vec2 outPos, vec2 sourceDim, int count, vec4 colorBkg, vec4 colorStroke, float thickness) {
            float pixel = 2.0 / sourceDim.y;
            vec2 p = vec2(pixel, 0.0);
        
            float sum = 0.0;
            float max = 0.0;
            float fRadius = thickness*0.01 / pixel;
            float r2 = fRadius*fRadius;
            int radius = int(floor(0.5 + fRadius));
            float fcount = float(count);
            
            float maxCoverage = 0.0;
            
            for(int j=-radius; j<=radius; ++j) {
                for(int i=-radius; i<=radius; ++i) {
                    vec2 delta = vec2(float(i), float(j));
                    vec2 minDelta = abs(delta) - 0.25;
                    if ((i==0 && j==0) || (dot(minDelta, minDelta)<r2)) {
//                        float coverage = 0.2;
//                        vec2 deltaTmp = minDelta + vec2(0.25, 0.25); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
//                        deltaTmp = minDelta + vec2(0.5, 0.0); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
//                        deltaTmp = minDelta + vec2(0.0, 0.5); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
//                        deltaTmp = minDelta + vec2(0.5, 0.5); if (dot(deltaTmp, deltaTmp)<r2) coverage += 0.2;
                        float coverage = smoothstep((fRadius+0.75)*(fRadius+0.75), (fRadius-0.75)*(fRadius-0.75), dot(delta, delta));
                        
                        vec2 pos = uv + delta*vec2(pixel, pixel);
                        float s0 = sampleCol(__source__(pos+p.xy), fcount);
                        float s1 = sampleCol(__source__(pos-p.xy), fcount);
                        float s2 = sampleCol(__source__(pos+p.yx), fcount);
                        float s3 = sampleCol(__source__(pos-p.yx), fcount);
                        float s = sampleCol(__source__(pos), fcount);
                        
                        bool onContour = s!=s0 || s!=s1 || s!=s2 || s!=s3;
                        if (onContour && maxCoverage<coverage) maxCoverage = coverage;
                    }
                }
            }
        
            vec4 color = mixColors(colorBkg, colorStroke, maxCoverage);
            vec4 bkgColor = __source__(uv);
        
            return mergeColor(bkgColor, color);
        }

void main() {
    fragColor = contour((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_count, u_colorBkg, u_colorStroke, u_thickness);
}
