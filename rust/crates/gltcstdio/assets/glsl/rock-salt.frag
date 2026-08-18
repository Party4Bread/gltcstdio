#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_intensity (U[5].x)
#define u_iterations (int(U[6].x))
#define u_shapeAspectRatio (U[7].x)
#define u_distortion (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))

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















































































































































































































































































































































vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 rockSalt(vec2 pos, vec2 outPos, float intensity, int iterations, float shapeAspectRatio, float distortion, mat3 modelTransform) {
    mat3 inverseModelTransform = inverse(modelTransform);
    vec2 u = tf(inverseModelTransform, pos);

    float tileWidth = 2.0;
    float tileHeight = 2.0 * shapeAspectRatio;

    vec2 tileSize = vec2(length(vec2(modelTransform[0][0], modelTransform[1][0])) * tileWidth,
                         length(vec2(modelTransform[0][1], modelTransform[1][1])) * tileHeight );

    intensity = intensity * 0.1;
    float s = 1.0 + intensity;

    vec2 tileCenter;
    vec2 p;

    for(int i=0; i<iterations; ++i) {
        float row = floor(u.y/tileHeight);
        float column = floor(u.x/tileWidth);

        tileCenter = vec2((column+0.5) * tileWidth, (row+0.5) * tileHeight);

        vec2 v = u - tileCenter;

        p = (modelTransform * vec3(v*s + tileCenter, 1.0)).xy;

        vec2 r;
        bool borderX = false;
        bool borderY = false;
        if (distortion > 0.0) {
            float d = distortion;
            r = v / vec2(tileWidth, tileHeight) + vec2(0.5, 0.5);

            if (r.x < d/2.0) {
                r.x = 2.0*r.x/d;
                borderX = true;
                p.x -= tileSize.x*(1.0-r.x)/(0.5+r.x);
            }
            else if (r.x > 1.0-d/2.0) {
                r.x = 2.0*(1.0-r.x)/d;
                borderX = true;
                p.x += tileSize.x*(1.0-r.x)/(0.5+r.x);
            }

            if (r.y < d/2.0) {
                r.y = 2.0*r.y/d;
                borderY = true;
                p.y -= tileSize.y*(1.0-r.y)/(0.5+r.y);
            }
            else if (r.y > 1.0-d/2.0) {
                r.y = 2.0*(1.0-r.y)/d;
                borderY = true;
                p.y += tileSize.y*(1.0-r.y)/(0.5+r.y);
            }
        }
        u = (inverseModelTransform * vec3(p, 1.0)).xy;//p;
    }

    vec4 outColor = __source__(p);
   
    return outColor;           
}

void main() {
    fragColor = rockSalt((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_intensity, u_iterations, u_shapeAspectRatio, u_distortion, u_modelTransform);
}
