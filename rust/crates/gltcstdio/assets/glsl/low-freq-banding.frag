#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_source2Dim (U[5].xy)
#define u_source2_specified (int(U[6].x))
#define u_outDim (U[7].xy)
#define u_intensity (U[8].x)
#define u_count (int(U[9].x))
#define u_angle (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) texture(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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


















































































































































































































































































































































vec2 getPos(vec2 p, float ang, vec2 bottomLeft, vec2 topRight) {
    vec2 dir = vec2(cos(ang), sin(ang));
    float kx1 = dir.x==0.0 ? -1.0 : (bottomLeft.x-p.x)/dir.x;
    float kx2 = dir.x==0.0 ? -1.0 : (topRight.x-p.x)/dir.x;
    float ky1 = dir.y==0.0 ? -1.0 : (bottomLeft.y-p.y)/dir.y;
    float ky2 = dir.y==0.0 ? -1.0 : (topRight.y-p.y)/dir.y;
    float k = kx1;
    if (k<0.0 || kx2>=0.0 && kx2<k) k = kx2;
    if (k<0.0 || ky2>=0.0 && ky2<k) k = ky2;
    if (k<0.0 || ky1>=0.0 && ky1<k) k = ky1;
    return p+k*dir;
}

vec4 lowFreqBanding(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, vec2 source2Dim, int source2_specified, float angle, mat3 modelTransform) {
    vec4 color = __source__(pos);
    vec4 bestColor = color;
    float bestDist = 100.0;

    float resolution = length(modelTransform[0].xy);
    float scale = 1.0/ resolution;
    vec2 p =  pos;

    vec2 dim = (source2_specified!=0) ? vec2(source2Dim.x/source2Dim.y-1.0/source2Dim.y, 1.0-1.0/source2Dim.y) : vec2(sourceDim.x/sourceDim.y-1.0/sourceDim.y, 1.0-1.0/sourceDim.y);
    vec2 orig = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;

    vec2 scaledDim = mat2(modelTransform)*(2.0*dim);
    vec2 offset = scaledDim/2.0 - orig;
    vec2 bottomLeft = floor((p+offset)/scaledDim)*scaledDim - offset;
    vec2 topRight = ceil((p+offset)/scaledDim)*scaledDim - offset;

    for(int i=0; i<count; ++i) {
        float ang = float(i)/float(count)*PI + angle;

        vec2 pp = getPos(p, ang, bottomLeft, topRight);
        vec4 c = (source2_specified!=0) ? __source2__(pp) : __source__(pp);
        float dist = length(color-c);
        if (dist<bestDist) {
            bestDist = dist;
            bestColor = c;
        }
    }

    return mix(color, bestColor, intensity);

}

void main() {
    fragColor = lowFreqBanding((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_count, u_sourceDim, u_source2Dim, u_source2_specified, u_angle, u_modelTransform);
}
