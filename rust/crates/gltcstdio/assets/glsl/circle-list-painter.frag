#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;
layout(binding = 4) uniform texture2D t_source3;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_source3 sampler2D(t_source3, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_source2Dim (U[5].xy)
#define u_outDim (U[6].xy)
#define u_source3_specified (int(U[7].x))
#define u_count (int(U[8].x))
#define u_padding (U[9].x)
#define u_thickness (U[10].x)
#define u_borderColor (U[11])

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source3__texelFetch__(c) texelFetch(u_source3, (c), 0)
#define __source3__(p) texture(u_source3, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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

        vec4 circleListPainter(vec2 pos, vec2 outPos, vec2 sourceDim, vec2 source2Dim, vec2 outDim, int count, float padding, float thickness, vec4 borderColor, int source3_specified) {
            // from sourceDim determine gridSize
            //return __source2__(pos*2.0);
            float ar = sourceDim.x / sourceDim.y;
            float pixel = 2.0/outDim.y;
            float maxLen = max(1.0, ar);
            float gridSize = maxLen / 8.0; // highly dependent on matching what RandomTilePlacer does...
            
            vec4 sizePix = __source2__texelFetch__(ivec2(0, 0)) * 255.0;
//            vec4 sizePix = vec4(0.0, 0.03921568, 0.0, 0.03921568) * 255.0;
//            float gridWidth = ceil((ar)/gridSize) * 2.;
//            float gridHeight = ceil((1.0)/gridSize) * 2.;
            float gridWidth = round(/*sizePix.r*256.0 +*/ sizePix.g);
            float gridHeight = round(/*sizePix.b*256.0 +*/ sizePix.b);
            
            // which cell are we in => y
            vec2 cell = vec2(floor(pos.x/gridSize), floor(pos.y/gridSize));
            int y = int(cell.x+gridWidth/2. + (cell.y+gridHeight/2.)*gridWidth) + 1;
            int xx = 0;
            
            
            // read source2Dim line until alpha!=1.0, determining if we're in the circle
            bool stop = false;
            vec4 bkgCol = (source3_specified==1) ? __source3__(pos) : vec4(0.0, 0.0, 0.0, 1.0);
            vec4 color = bkgCol;
            vec3 bestCircle = vec3(0., 0., -1.);
                        
            while (!stop && xx<400) { // highly dependent on MAX_CIRCLES_PER_CELL in RandomTilePlacer
                vec4 first = __source2__texelFetch__(ivec2(xx*2, y))*255.0;
                vec4 second = __source2__texelFetch__(ivec2(xx*2+1, y))*255.0;
                stop = first.a==0.0;
                if (!stop) {
                    ++xx;
                    float x = round(first.r)*256.0 + (first.g);
                    if (x>=32768.) x = x-65536.;
                    x /= 32768.;
                    float y = round(first.b)*256.0 + (second.r);
                    if (y>=32768.) y = y-65536.;
                    y /= 32768.;
                    float r = round(second.g)*256.0 + (second.b);
                    if (r>=32768.) r = r-65536.;
                    r /= 32768.;
                    
                    vec2 center = vec2(x, y);
                    if (ar>1.0) { center *= ar; r *= ar; }
                    vec2 delta = pos-center;
                    if (dot(delta, delta) < r*r) {
                        //color = __source__(center);
                        bestCircle = vec3(center.x, center.y, r);
                    }
                }
            }
            
            if (bestCircle.z>0.0) {
                float trueRadius = (1.0-padding) * bestCircle.z;
                float innerBorderRadius = (1.0-thickness) * trueRadius;
                vec2 center = bestCircle.xy;
                float d = length(pos-center);
                float aar = pixel*0.5;
                float k = smoothstep(trueRadius+aar, trueRadius-aar, d);
                if (k==0.0) return bkgCol;
                float kb = smoothstep(innerBorderRadius+aar, innerBorderRadius-aar, d);
                vec4 centerCol = __source__(center);
                vec4 circleCol = centerCol; 
                if (kb<1.0) {
                    vec4 borderColor = mergeColor(centerCol, borderColor);
                    circleCol = mix(borderColor, centerCol, kb);
                }
                return mix(bkgCol, circleCol, k);
            }
            else {
                return bkgCol;
            }
            
            
//            if (gridHeight!=10. || gridWidth!=10.) {
//                float scale = 15.;
//                vec2 uv = pos * scale;
//                vec2 u = fract(uv+0.5);
//                vec2 dg =  abs(u-0.5);
//                if (abs(uv.x - sizePix.g*scale)<0.1) return vec4(1.0, 0. ,0. ,1.0);
//                float widx = round(uv.x)==gridWidth ? 0.08 : 0.033;
//                float widy = round(uv.y)==gridHeight ? 0.08 : 0.033;
//                if (dg.x<widx || dg.y<widy) return (round(uv.x)==0.0 || round(uv.y)==0.0) ? vec4(1., 1., 0, 1.) : vec4(1.);
//                return vec4(0.0, 0.0, 1., 1.0);
//            }
//            if (float(y-1)>=source2Dim.y || float(y)<0.) return vec4(1.0, 1.0, 0., 1.0);
//            return (xx==0) ? vec4(1.0, 0. ,0., 1.0) : color;
            
//            float g = float(xx)/20.0;
//            return vec4(g, g, g, 1.0);
            
        }

void main() {
    fragColor = circleListPainter((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_source2Dim, u_outDim, u_count, u_padding, u_thickness, u_borderColor, u_source3_specified);
}
