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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_count (int(U[7].x))
#define u_modelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))

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
























































































































































































































































































































































bool inside(vec2 pos, float X, float Y) {
    return abs(pos.y)<=Y && abs(pos.x)<=X;
}

float sampleCol(vec4 color, int count) {
    return floor((color.r + color.g + color.b)*(float(count)-1.0)/3.0 + 0.5);
}

float sampleVal(float val, int count) {
    return floor(val*(float(count)-1.0)/3.0 + 0.5);
}

vec4 contourInterpolate(vec2 pos, vec2 outPos, vec2 sourceDim, int mode, int count, mat3 modelTransform) {
            float pixel = 2.0 / sourceDim.y;
            float X = sourceDim.x / sourceDim.y;//sourceDim.x>sourceDim.y ? 1.0 : sourceDim.x / sourceDim.y;
            float Y = 1.0;//sourceDim.x>sourceDim.y ? sourceDim.y / sourceDim.x : 1.0;
            
            vec2 p = vec2(pixel, 0.0);
            vec2 d = pixel*normalize(mat2(modelTransform) * p);
//            vec2 d = mat2(modelTransform) * p;

            vec4 col = __source__(pos);
//            float s = sampleCol(col, count);
            float gPos = col.r + col.g + col.b;
            float gLightest = gPos;
            float gDarkest = gPos;
            float s = sampleVal(gPos, count);
            
            if (mode==0) {
                vec4 lightest = col;
                vec4 darkest = col;
                bool advance = false;
                vec2 pos1 = pos;
                vec2 pos2 = pos;

                do {
                    vec2 next = pos1+d;
                    vec4 cNext = __source__(next);
                    float gNext = cNext.r + cNext.g + cNext.b;
                    float sNext = sampleVal(gNext, count);
                    advance = sNext==s && inside(next, X, Y);
                    if (advance) {
                        pos1 = next;
                        if (gNext>gLightest) { lightest = cNext; gLightest = gNext; }
                        if (gNext<gDarkest) { darkest = cNext; gDarkest = gNext; }
                    }
                } while (advance);

                do {
                    vec2 next = pos2-d;
                    vec4 cNext = __source__(next);
                    float gNext = cNext.r + cNext.g + cNext.b;
                    float sNext = sampleVal(gNext, count);
                    advance = sNext==s && inside(next, X, Y);
                    if (advance) {
                        pos2 = next;
                        if (gNext>gLightest) { lightest = cNext; gLightest = gNext; }
                        if (gNext<gDarkest) { darkest = cNext; gDarkest = gNext; }
                    }
                } while (advance);

                vec2 dd = pos2-pos1;
                float len = length(dd);
                if (len==0.0) return col;

                vec4 outCol = mix(darkest, lightest, dot((pos-pos1)/len, (pos2-pos1)/len));

                return outCol;                
            }
            else /*if (mode==1)*/ {
                vec2 pos1 = pos;
                while (sampleCol(__source__(pos1+d), count)==s && inside(pos1+d, X, Y)) {
                    pos1 += d;
                }
                vec4 col1 = __source__(pos1);
    
                vec2 pos2 = pos;
                while (sampleCol(__source__(pos2-d), count)==s && inside(pos2-d, X, Y)) {
                    pos2 -= d;
                }
                vec4 col2 = __source__(pos2);
    
                vec2 dd = pos2-pos1;
                float len = length(dd);
                if (len==0.0) return col;
    
                vec4 outCol = mix(col1, col2, dot((pos-pos1)/len, (pos2-pos1)/len));
    //            return vec4(vec3(length(pos-pos1), length(pos-pos2), len*0.1), 1.0);
    
                return outCol;
            }
        }

void main() {
    fragColor = contourInterpolate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_mode, u_count, u_modelTransform);
}
