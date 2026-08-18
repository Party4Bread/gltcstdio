#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_InverseModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_ModelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_count (int(U[11].x))
#define u_angle (U[12].x)
#define u_thickness (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

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















































































































































































































































































































































vec4 radialInterpolateBrokenGL(vec2 pos, vec2 outPos, int count, float angle, float thickness, mat3 modelTransform) {
    // Pap filter sets doInverseModelTransform=true, so its
    // u_ModelTransform equals inverse(forwardModel). pap2mp's
    // `modelTransform` is the forward matrix; compute the inverse
    // in-shader to enter model space.
    mat3 invM = inverse(modelTransform);

    // Pap: u = u_ModelTransform * vec3(pos, 1.0)  (Pap's already-inverted matrix)
    vec2 u = (invM * vec3(pos, 1.0)).xy;
    float d = length(u);

    // Pap: thickn = 0.01*u_Thickness (Pap thickness 0..100). pap2mp 0..1.
    float thickn = thickness;

    // Outside the unit ring? Return source. Note: the comparison reads
    // the original `pos` from the source — only the ring is repainted.
    if (d < 1.0 - thickn || d > 1.0) {
        return __source__(pos);
    }

    float ha = angle / 2.0;

    // Safety gate from Pap (effectively always true at sensible angles).
    if (angle <= PI2) {
        if (d > 0.0) {
            float ang = acos(u.x / d);
            if (u.y < 0.0) ang = PI2 - ang;

            ang += PI / 2.0 + ha;
            // GLSL ES has no fmod — use mod (HOWTO_EFFECTS pitfall).
            ang = mod(ang + PI2, PI2);
            if (ang <= angle) {
                ang = angle - ang;
                float angleRange = angle / float(count);
                float index = floor(ang / angle * float(count));
                float ang1 = -ha + angleRange * index;
                float ang2 = -ha + angleRange * (index + 1.0);
                // Pap: u_InverseModelTransform * vec3(...) is the
                // forward back-transform (Pap's u_InverseModelTransform
                // = inverse(inverse(forward)) = forward). pap2mp uses
                // `modelTransform` directly.
                vec2 pos1 = (modelTransform * vec3(-d * sin(ang1), -d * cos(ang1), 1.0)).xy;
                vec4 col1 = __source__(pos1);
                vec2 pos2 = (modelTransform * vec3(-d * sin(ang2), -d * cos(ang2), 1.0)).xy;
                vec4 col2 = __source__(pos2);

                // Pap mix order: `mix(col1, col2, 1.0 - ka)`. The
                // non-broken sibling shader uses `mix(col1, col2, ka)`
                // — preserve the `1.0 -` inversion verbatim.
                return mix(col1, col2, 1.0 - (ang - angleRange * index) / angleRange);
            }
        }
    }

    return __source__(pos);
}

void main() {
    fragColor = radialInterpolateBrokenGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_angle, u_thickness, u_modelTransform);
}
