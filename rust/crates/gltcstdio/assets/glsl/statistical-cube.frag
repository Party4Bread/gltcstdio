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
#define u_intensity (U[6].x)
#define u_model3DTransform (mat4(U[7], U[8], U[9], U[10]))

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


















































































































































































































































































































































float height(float intensity, vec4 color) {
    return intensity*0.04* ((color.r + color.g + color.b)/3.0 - 0.5);
}

vec4 statisticalCube(vec2 pos, vec2 outPos, float intensity, mat4 model3DTransform, vec2 sourceDim) {
    vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);

    mat4 m = inverse(model3DTransform);
    vec3 cameraPos = (m * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 dir = normalize(vec3(pos.x, pos.y, -1.0));
    dir = mat3(m) * dir;

    float maxZ = abs(intensity)*0.02;
    float ratio = (sourceDim.x/sourceDim.y);
    float dk = 2.0/sourceDim.y;
    vec3 step = dir * dk;

    float k1 = 0.0;
    float k2 = 100000000.0;

    // Ray-box intersection for X bounds
    if (dir.x>0.0) {
        float k3 = (-ratio-cameraPos.x)/dir.x;
        float k4 = (ratio-cameraPos.x)/dir.x;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    else if (dir.x<0.0) {
        float k3 = (ratio-cameraPos.x)/dir.x;
        float k4 = (-ratio-cameraPos.x)/dir.x;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    // Ray-box intersection for Y bounds
    if (dir.y>0.0) {
        float k3 = (-1.0-cameraPos.y)/dir.y;
        float k4 = (1.0-cameraPos.y)/dir.y;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    else if (dir.y<0.0) {
        float k3 = (1.0-cameraPos.y)/dir.y;
        float k4 = (-1.0-cameraPos.y)/dir.y;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    // Ray-box intersection for Z bounds
    if (dir.z>0.0) {
        float k3 = (-maxZ-cameraPos.z)/dir.z;
        float k4 = (maxZ-cameraPos.z)/dir.z;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }
    else if (dir.z<0.0) {
        float k3 = (maxZ-cameraPos.z)/dir.z;
        float k4 = (-maxZ-cameraPos.z)/dir.z;
        k1 = max(k1, k3);
        k2 = min(k2, k4);
    }

    // No intersection with the cube
    if (k1>k2) return backgroundColor;

    // March along the ray, looking for height surface intersection
    float k = k1;
    vec3 p = cameraPos + k*dir;
    vec4 color = backgroundColor;
    float h = 0.0;
    float dz = 0.0;
    float prevDz;
    vec4 prevColor;
    float prevH;
    bool stop;
    do {
        prevColor = color;
        prevDz = dz;
        prevH = h;

        color = __source__(p.xy);
        h = height(intensity, color);
        dz = p.z-h;

        p += step;
        k += dk;
        stop = dz==0.0 || (k!=k1 && sign(dz)==-sign(prevDz));
    } while (k<=k2 && !stop);

    stop = stop || abs(dz)<dk;

    // Return intersection statistics:
    // R = cube depth, G = hit flag, B = normalized hit distance
    return vec4((k2-k1), stop?1.0:0.0, (k-k1)/(k2-k1), 1.0);
}

void main() {
    fragColor = statisticalCube((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_model3DTransform, u_sourceDim);
}
