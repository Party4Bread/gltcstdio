#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[16];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_intensity (U[8].x)
#define u_balance (U[9].x)
#define u_modelTransform (mat3(U[10].xyz, U[11].xyz, U[12].xyz))
#define u_objectTransform (mat3(U[13].xyz, U[14].xyz, U[15].xyz))

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


















































































































































































































































































































































vec2 mashHash2(vec2 c) {
    return fract(sin(vec2(dot(c, vec2(127.1, 311.7)), dot(c, vec2(269.5, 183.3)))) * 43758.5453);
}

vec4 mashGL(vec2 pos, vec2 outPos, float intensity, float balance, mat3 modelTransform, mat3 objectTransform) {
    vec2 frag = pos;
    vec2 center = modelTransform[2].xy;          // (u_ModelTransform * vec3(0,0,1)).xy
    vec4 inCol = __source__(frag);

    float STEP = intensity * 2.0;                // Pap u_Power
    float scaleM = length(modelTransform[0].xy); // Pap `scale` (MODEL_SCALE, default 0.1)
    float cellLen = length(objectTransform[0].xy);
    float marchCell = max(0.0, cellLen - 1.0) * 0.02;  // identity = 0 (no shuffle)
    vec2 marchBias = objectTransform[2].xy;
    float stepLen = 0.001 * STEP;

    // mode 21 = INVERT + CIRCULAR + DIR 5
    vec2 dir = -normalize(frag - center);        // INVERT
    vec2 origdir = dir;
    float dist = length(center - frag);          // CIRCULAR
    vec2 p = frag;                               // INVERT: start at the fragment
    vec2 q = p;

    vec3 maxC = vec3(0.0);
    vec3 minC = vec3(1.0);
    float sumV = 0.0;
    float maxV = 0.0;
    float k = 0.0;

    float d = 0.0;
    for (int i = 0; i < 400; ++i) {              // count = 400
        if (d >= dist) break;
        q += (dir + marchBias) * stepLen;
        if (marchCell > 1e-6) {
            // datamosh shuffle: each cell samples a coherent hash-displaced spot
            vec2 cell = floor(q / marchCell);
            p = (cell + 0.5) * marchCell + (mashHash2(cell) - 0.5) * marchCell * 6.0;
        } else {
            p = q;
        }
        vec3 col = __source__(p).rgb;
        float vv = (col.r + col.g + col.b) / 3.0;
        sumV += vv;
        maxC = max(maxC, col);
        minC = min(minC, col);
        k += 0.001 * vv;
        if (vv > maxV) maxV = vv;
        // DIR 5: snap direction to the dominant axis, toggled by accumulated brightness
        dir = (mod(maxV * 50.0, 2.0) < 1.0) ? normalize(vec2(origdir.x, 0.0)) : normalize(vec2(0.0, origdir.y));
        d += stepLen;
    }

    float insidness = k * STEP / scaleM;
    vec4 outCol;
    if (insidness < 1.0) {
        vec4 iCol = vec4(mix(minC, maxC, 1.0 - 3.0 * k), 1.0);   // style 10: light -> dark
        if (balance >= 0.0) {
            outCol = mix(iCol, inCol, balance);                  // Pap u_Balance*0.01 -> balance
        } else {
            outCol = vec4((iCol * inCol * min(1.0, -balance * 2.0) + iCol * (1.0 + balance * 0.6)).rgb, inCol.a);
        }
    } else {
        outCol = __source__(frag);
    }

    outCol.a = inCol.a;
    outCol.rgb = clamp(outCol.rgb, 0.0, 1.0);
    return outCol;
}

void main() {
    fragColor = mashGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_balance, u_modelTransform, u_objectTransform);
}
