#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[10];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_iterations (int(U[5].x))
#define u_dampening (U[6].x)
#define u_modelTransform (mat3(U[7].xyz, U[8].xyz, U[9].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))

const float SIERPINSKI_SLOPE = 1.7320508075688772;



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




















































































































































































































































































































































bool inTriangle( in vec2 p, in vec2 a, in vec2 b, in vec2 c )
{
    vec2 e0 = b-a, e1 = c-b, e2 = a-c;
    vec2 v0 = p -a, v1 = p -b, v2 = p -c;
    float s = sign(e0.x*e2.y - e0.y*e2.x);
    return s*(v0.x*e0.y-v0.y*e0.x)>0.0 
        && s*(v1.x*e1.y-v1.y*e1.x)>0.0 
        && s*(v2.x*e2.y-v2.y*e2.x)>0.0; 
}

bool inTriangle(vec2 pos, vec2 root, float side, bool up) {
    float halfSide = side * 0.5;
    if (pos.x > root.x + halfSide || pos.x < root.x - halfSide || pos.y < root.y || pos.y > root.y + halfSide * SIERPINSKI_SLOPE) {
        return false;
    }
    if (up) {
        if (pos.x < root.x) {
            return (pos.x - root.x + halfSide) * SIERPINSKI_SLOPE > pos.y - root.y;
        }
        else {
            return (root.x + halfSide - pos.x) * SIERPINSKI_SLOPE > pos.y - root.y;
        }
    }
    else {
        if (pos.x < root.x) {
            return (halfSide - (pos.x - root.x + halfSide)) * SIERPINSKI_SLOPE < pos.y - root.y;
        }
        else {
            return (halfSide - (root.x + halfSide - pos.x)) * SIERPINSKI_SLOPE < pos.y - root.y;
        }
    }
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

vec4 sierpinski(vec2 pos, vec2 outPos, int iterations, float dampening, mat3 modelTransform, mat3 viewTransform) {
    vec2 shapePos = tf(inverse(modelTransform), pos);

    float size = 1.0;
    float halfSide = size * 0.5;
    vec2 root = vec2(0.0, -0.4330127018922193 * size);
    float inside = 0.0;

    if (inTriangle(shapePos, root, size, true)) {
        inside = 1.0;
        for(int i = 0; i < iterations; ++i) {
            if (inTriangle(shapePos, root, size * 0.5, false)) {
                inside = 0.0;
                break;
            }
            float quarterSide = halfSide * 0.5;
            vec2 dx = vec2(quarterSide, 0.0);
            if (inTriangle(shapePos, root - dx, halfSide, true)) {
                root -= dx;
            }
            else if (inTriangle(shapePos, root + dx, halfSide, true)) {
                root += dx;
            }
            else {
                root += vec2(0.0, quarterSide * SIERPINSKI_SLOPE);
            }
            size = halfSide;
            halfSide = quarterSide;
        }
    }

    float d = 1.0;
    if (dampening < 0.0) d = 1.0 + dampening * min(1.0, length(pos));
    else if (dampening > 0.0) d = 1.0 - dampening * (1.0 - min(1.0, length(pos)));

    vec2 u = mix(pos, tf(viewTransform, pos), inside * d);
    return __source__(u);
}

void main() {
    fragColor = sierpinski((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_iterations, u_dampening, u_modelTransform, u_viewTransform);
}
