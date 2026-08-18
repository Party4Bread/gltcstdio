#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[5];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)





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















































































































































































































































































































































vec4 borderKaleid3Mask(vec2 uv, vec2 outPos) {
    const float PI_ = 3.14159265359;
    const float COUNT = 6.0;
    const float halfAlpha = PI_ / COUNT;
    const float alpha = halfAlpha * 2.0;

    // Stage 3: kaleidoscopify(source, 6, phase=1.1+pi, scale=1.65 [*1.6 internally]) with ty=0.65
    const float TX = 0.0;
    const float TY = 0.65;
    const float PHASE = 1.1 + PI_;
    const float K_SCALE = 1.6 * 1.65;

    float d = length(uv);
    float sourceAngle = 0.0;
    if (d > 0.0) {
        float ang = atan(uv.y, uv.x);
        if (ang < 0.0) ang += 2.0 * PI_;
        // Original KaleidoscopeGL runs with REGULARITY=100 -> variability=0, which takes the
        // spike-displacement branch where the in-wedge mirror reflection is commented out. So the
        // fold is a pure rotational wrap (mod alpha) with NO reflection. Reflecting here makes every
        // wedge symmetric and turns the central hole into a smooth "double hexagon" instead of a star.
        sourceAngle = mod(ang, alpha);
    }
    vec2 coord = d * vec2(cos(sourceAngle), sin(sourceAngle));

    float cp = cos(PHASE);
    float sp = sin(PHASE);
    vec2 texSample = vec2(
        K_SCALE * (cp * coord.x - sp * coord.y) + TX,
        K_SCALE * (sp * coord.x + cp * coord.y) + TY
    );

    // Stage 2: discreteGradientify(source, 18) -> RectTilesGL with model scale=10, intensity=18
    const float RT_SCALE = 10.0;
    const float TILE_SIZE = 2.0;
    const float INV_RT = 1.0 / RT_SCALE;
    const float TILE_INTENSITY = 18.0;

    vec2 u_rt = RT_SCALE * texSample;
    float tileSpan = INV_RT * TILE_SIZE;
    float s = 1.0 + TILE_INTENSITY * 0.01 * (2.0 / tileSpan - 1.0);
    vec2 tileCenter = vec2(
        (floor(u_rt.x / TILE_SIZE) + 0.5) * TILE_SIZE,
        (floor(u_rt.y / TILE_SIZE) + 0.5) * TILE_SIZE
    );
    vec2 v = u_rt - tileCenter;
    vec2 p = INV_RT * (v * s + tileCenter);

    // Stage 1: gradient(270 deg, posterize=2). The 270 deg rotation maps the gradient axis to y.
    // The original GL filters sample their source with GL_MIRRORED_REPEAT (ImageGeomTransformGL
    // mirrorTexture()==true -> addTexture, not addTextureRepeat), NOT plain GL_REPEAT. The mirrored
    // wrap is what makes the posterized stripes meet symmetrically along the fold seams and produces
    // sharp star points; plain repeat gave shallow, rounded lobes (the "double hexagon" look).
    // GL_MIRRORED_REPEAT of the gradient texcoord t=(p.y+1)/2 -> triangle wave m in [0,1]:
    float m0 = mod((p.y + 1.0) / 2.0, 2.0);
    float m = 1.0 - abs(m0 - 1.0);
    float kPost = step(0.5, m);   // posterize-2 threshold
    return vec4(vec3(1.0 - kPost), 1.0);
}

void main() {
    fragColor = borderKaleid3Mask((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)));
}
