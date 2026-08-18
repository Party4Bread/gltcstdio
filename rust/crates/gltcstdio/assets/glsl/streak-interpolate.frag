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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))
#define u_count (int(U[9].x))
#define u_size (U[10].x)
#define u_textureSensitivity (U[11].x)

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

vec4 streakInterpolate(vec2 uv, vec2 outPos, mat3 modelTransform, vec2 sourceDim, int count, float size, float textureSensitivity) {
    mat3 inverseModelTransform = inverse(modelTransform);
    
    vec2 u = tf(inverseModelTransform, uv);
    float ratio = sourceDim.x/sourceDim.y;
    float scale = length(inverseModelTransform[0].xy);
    float l = size*1.5 * max(1.0, ratio) * scale;
    float b = 0.2 * textureSensitivity * scale;
    float pixel = 2.0/sourceDim.y * scale;

    if (abs(u.x)<l && abs(u.y)<1.0+abs(b)) {
        float ya = -1.0;
        float yb = 1.0;
        if (b!=0.0) {
            vec2 p = vec2(u.x, ya);
            vec2 ip = (modelTransform * vec3(p, 1.0)).xy;
            vec4 c = __source__(ip);
            float value = (c.r+c.g+c.b);
            float threshold = 1.5;
            float dt = threshold * pixel/b;
            float dir = -sign(b * (value-threshold));
            //p.y  += dir*b;
            while (dir!=0.0 && abs(p.y-ya)<abs(b)) {
                p.y += dir*pixel;
                ip = (modelTransform * vec3(p, 1.0)).xy;
                c = __source__(ip);
                value = (c.r+c.g+c.b);
                float newdir = -sign(b * (value-threshold));
                if (dir!=newdir) dir = 0.0;
                threshold -= dir*dt;
            }
            ya = p.y;

            p = vec2(u.x, yb);
            ip = (modelTransform * vec3(p, 1.0)).xy;
            c = __source__(ip);
            value = (c.r+c.g+c.b);
            threshold = 1.5;
            dt = threshold * pixel/b;
            dir = sign(b * (value-threshold));
            //p.y  += dir*b;
            while (dir!=0.0 && abs(p.y-yb)<abs(b)) {
                p.y += dir*pixel;
                ip = (modelTransform * vec3(p, 1.0)).xy;
                c = __source__(ip);
                value = (c.r+c.g+c.b);
                float newdir = sign(b * (value-threshold));
                if (dir!=newdir) dir = 0.0;
                threshold += dir*dt;
            }
            yb = p.y;
        }

//        if (abs(u.y-ya)<pixel*1.7) return vec4(1.0, 0.0, 0.0, 1.0);

        if (u.y>=ya && u.y<=yb) {
            float stride = (yb-ya)/float(count); 
            float y = u.y-ya;//+1.0;
            float y1 = floor(y/stride)*stride + ya;//-1.0;
            float y2 = y1+stride;
            vec2 p1 = (modelTransform * vec3(u.x, y1, 1.0)).xy;
            vec2 p2 = (modelTransform * vec3(u.x, y2, 1.0)).xy;

            return mix(__source__(p1), __source__(p2), (u.y-y1)/stride);
        }
    }
    return __source__(uv);

}

void main() {
    fragColor = streakInterpolate((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_modelTransform, u_sourceDim, u_count, u_size, u_textureSensitivity);
}
