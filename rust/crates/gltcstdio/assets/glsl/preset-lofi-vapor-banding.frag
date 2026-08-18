#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[17];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_colorField;
layout(binding = 3) uniform texture2D t_source;

#define u_colorField sampler2D(t_colorField, samp)
#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_colorFieldDim (U[5].xy)
#define u_colorField_specified (int(U[6].x))
#define u_outDim (U[7].xy)
#define u_ModelTransform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_intensity (U[11].x)
#define u_count (int(U[12].x))
#define u_angle (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

#define __colorField__texelFetch__(c) texelFetch(u_colorField, (c), 0)
#define __colorField__(p) texture(u_colorField, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
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


















































































































































































































































































































































vec2 cpa_getSamplePos(vec2 p, float ang, vec2 bottomLeft, vec2 topRight) {
    vec2 dir = vec2(cos(ang), sin(ang));
    float kx1 = dir.x==0.0 ? -1.0 : (bottomLeft.x-p.x)/dir.x;
    float kx2 = dir.x==0.0 ? -1.0 : (topRight.x-p.x)/dir.x;
    float ky1 = dir.y==0.0 ? -1.0 : (bottomLeft.y-p.y)/dir.y;
    float ky2 = dir.y==0.0 ? -1.0 : (topRight.y-p.y)/dir.y;
    float k = kx1;
    if (k<0.0 || (kx2>=0.0 && kx2<k)) k = kx2;
    if (k<0.0 || (ky2>=0.0 && ky2<k)) k = ky2;
    if (k<0.0 || (ky1>=0.0 && ky1<k)) k = ky1;
    return p + k*dir;
}

vec4 colorPickAngular(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, vec2 colorFieldDim, int colorField_specified, float angle, mat3 modelTransform) {
    // Pap's filter overrides `doInverseModelTransform()` → true, so
    // `u_ModelTransform` is the inverse of the forward matrix. In
    // pap2mp `modelTransform` is the forward matrix; we use `invM`
    // at every site Pap's shader uses `u_ModelTransform` to preserve
    // identical math.
    mat3 invM = inverse(modelTransform);
    vec4 color = __source__(pos);
    vec4 bestColor = color;
    float bestDist = 100.0;
    vec2 p = pos;

    vec2 dim = (colorField_specified != 0)
        ? vec2(colorFieldDim.x/colorFieldDim.y - 1.0/colorFieldDim.y, 1.0 - 1.0/colorFieldDim.y)
        : vec2(sourceDim.x/sourceDim.y - 1.0/sourceDim.y, 1.0 - 1.0/sourceDim.y);
    vec2 orig = (invM*vec3(0.0, 0.0, 1.0)).xy;

    vec2 scaledDim = mat2(invM)*(2.0*dim);
    vec2 offset = scaledDim/2.0 - orig;
    vec2 bottomLeft = floor((p+offset)/scaledDim)*scaledDim - offset;
    vec2 topRight = ceil((p+offset)/scaledDim)*scaledDim - offset;

    for(int i=0; i<count; ++i) {
        // Full-circle angle iteration (vs pap2mp LowFreqBanding's
        // half-circle `* PI`). This is the headline divergence.
        float ang = float(i)/float(count)*PI2 + angle;

        vec2 sp = cpa_getSamplePos(p, ang, bottomLeft, topRight);
        vec4 c = (colorField_specified != 0) ? __colorField__(sp) : __source__(sp);
        float dist = length(color-c);
        if (dist<bestDist) {
            bestDist = dist;
            bestColor = c;
        }
    }

    return mix(color, bestColor, intensity);
}

void main() {
    fragColor = colorPickAngular((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_sourceDim, u_colorFieldDim, u_colorField_specified, u_angle, u_modelTransform);
}
