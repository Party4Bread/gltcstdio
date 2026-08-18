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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_InverseModelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_ModelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))
#define u_color (U[12])
#define u_thickness (U[13].x)
#define u_balance (U[14].x)
#define u_variability (U[15].x)
#define u_shadows (U[16].x)
#define u_randomSeed (U[17].x)
#define u_modelTransform (mat3(U[18].xyz, U[19].xyz, U[20].xyz))

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















































































































































































































































































































































vec2 rand2(vec2 v) {
    float x = fract(sin(dot(v.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, v.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y);
}

float varyNoiseSmoothly(float noise, float k) {
    float phase = acos(2.0*noise-1.0);
    float freq = fract(noise*16.0) + 0.5;
    return (1.0+cos(phase+freq*k))*0.5;
}

vec2 varyVec2NoiseSmoothly(vec2 noise, float k) {
    return vec2(varyNoiseSmoothly(noise.x, k), varyNoiseSmoothly(noise.y, k));
}

vec2 rand2relSeeded(vec2 co, float seed) {
    return varyVec2NoiseSmoothly(rand2(co), seed)-0.5;
}

vec4 streakedStripesGL(vec2 uv, vec2 outPos, vec4 color, float thickness, float balance, float variability, float shadows, float randomSeed, vec2 sourceDim, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec2 u = (invM * vec3(uv, 1.0)).xy;
    float pixel = 2.0 / sourceDim.y;
    // Pap: scale = length(vec2(u_ModelTransform[0][0], u_ModelTransform[0][1]))
    // Pap's u_ModelTransform is the forward (zoom-in) matrix that maps pos→u — here that
    // role is played by invM (modelTransform is the analog of Pap's u_InverseModelTransform).
    // Reading modelTransform here gave scale=0.05 instead of 20 → t (border half-width) and
    // st (dichotomy threshold) came out 400× too small → almost no white borders, most
    // visible as missing white when dezoom pushes balance negative (subdivision branch).
    float scale = length(invM[0].xy);
    // Pap: t = u_Thickness*0.0002*scale  (u_Thickness in 0..100)
    //     → with thickness in 0..1:  thickness * 0.02 * scale
    float t = thickness * 0.02 * scale;
    // Pap: var = u_Variability*0.08  (u_Variability in 0..100)
    //     → variability * 8.0
    float varAmt = variability * 8.0;
    float index = floor(u.x + 0.5);
    bool border = false;
    float light = 1.0;
    float x1 = 0.0;
    float x2 = 0.0;
    float i2 = 0.0;
    for (float i = index - 6.0; i <= index + 6.0; i += 1.0) {
        vec2 rnd2 = rand2relSeeded(vec2(i, i), randomSeed);
        x1 = i + varAmt * rnd2.x;
        // Pap: shadowSize = u_Shadows*0.04 * (1.0 + u_Variability*0.01 * rnd2.y)
        //   shadows 0..1, variability 0..1 (was 0..100): inner *0.01 collapses to *1.0
        float shadowSize = shadows * 4.0 * (1.0 + variability * rnd2.y);
        i2 = i + 1.0;
        x2 = i2 + varAmt * rand2relSeeded(vec2(i2, i2), randomSeed).x;
        if (abs(u.x - x1) < t || abs(x2 - u.x) < t) {
            border = true;
            break;
        } else if (x1 <= u.x && u.x <= x2) {
            // Pap: smoothstep(mix(-shadowSize, 0.0, u_Shadows*0.01), shadowSize, x2-u.x)
            light = smoothstep(mix(-shadowSize, 0.0, shadows), shadowSize, x2 - u.x);
            break;
        }
    }

    vec2 rnd = rand2relSeeded(vec2(sign(u.y), i2), randomSeed);
    int maxIter = 30;
    float st = t;
    if (balance < 0.0) {
        // Pap: 50.0/abs(u_Balance*u_Balance) *20.0  (u_Balance in -100..100)
        //   → with balance in -1..1: 50.0/abs(balance*balance*1.0e4) *20.0
        float Y = 50.0 / abs(balance * balance * 1.0e4) * 20.0 * (1.0 + 0.5 * varAmt * rnd.x);
        float dy = 50.0 / abs(balance * balance * 1.0e4) * 20.0 * (1.0 + 0.5 * varAmt * rnd.y);
        while (abs(u.y) > Y && abs(x2 - x1) > pixel && maxIter > 0) {
            float k = rnd.x + 0.5;
            float x12 = mix(x1, x2, k);
            if (abs(x2 - x1) < st || abs(u.x - x12) < st) {
                border = true;
                x1 = x2 = x12;
                break;
            } else if (u.x < x12) {
                x2 = x12;
            } else {
                x1 = x12;
            }
            Y += dy;
            dy *= 0.5;
            rnd = rand2relSeeded(rnd, randomSeed);
            --maxIter;
        }
    } else if (balance > 0.0) {
        border = false;
        // Pap: pow(abs(u_Balance), 1.5)*0.01 *20.0  (u_Balance in -100..100)
        //   → pow(abs(balance*100.0), 1.5)*0.01 *20.0
        float Y = pow(abs(balance * 100.0), 1.5) * 0.01 * 20.0 * (1.0 + 0.01 * varAmt * rnd.x);
        float dy = 50.0 / abs(balance * balance * 1.0e4) * 20.0 * (1.0 + 0.5 * varAmt * rnd.y);
        while (abs(u.y) < Y && abs(x2 - x1) > pixel && maxIter > 0) {
            float k = rnd.x + 0.5;
            float x12 = mix(x1, x2, k);
            if (u.x < x12) {
                x2 = x12;
            } else {
                x1 = x12;
            }
            Y -= dy;
            dy *= 0.5;
            rnd = rand2relSeeded(rnd, randomSeed);
            --maxIter;
        }
        if (st < abs(x2 - x1) / 2.0 && (abs(u.x - x1) < t || abs(x2 - u.x) < t)) {
            border = true;
        }
    }

    // Snap to stripe centre then sample source.
    u.x = (x1 + x2) / 2.0;
    vec2 v = (modelTransform * vec3(u, 1.0)).xy;
    vec4 col = __source__(v);
    vec4 outCol = border ? vec4(mix(col.rgb, color.rgb, color.a), col.a) : col;
    outCol = mix(vec4(0.0, 0.0, 0.0, 1.0), outCol, light);
    return outCol;
}

void main() {
    fragColor = streakedStripesGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color, u_thickness, u_balance, u_variability, u_shadows, u_randomSeed, u_sourceDim, u_modelTransform);
}
