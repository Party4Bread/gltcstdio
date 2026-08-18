#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[12];
};
layout(binding = 1) uniform sampler samp;

#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_color (U[5])
#define u_colorVariability (U[6].x)
#define u_randomSeed (U[7].x)
#define u_variability (U[8].x)
#define u_modelTransform (mat3(U[9].xyz, U[10].xyz, U[11].xyz))





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
























































































































































































































































































































































vec3 getColor(float k, vec3 base, float variability) {
    return base + variability * vec3(cos(k*10.0), sin(k*7.4), sin(k*14.0+1.0));
}

vec2 getIndexRange(float y, float scale, float height, float variability) {
    float z = scale;
    float regularity = 0.25/(variability+1e-6);
    float amp = (0.1 + 0.1 / regularity) / z;
    float k = 0.1+height;
    float y1 = y + 1.0-amp;
    float y2 = y + 1.0+amp;
    return vec2(floor(y1/k), ceil(y2/k));
}

float wave(float i, float x, float scale, float phase, float height, float variability) {
    float z = scale;
    float regularity = 0.25/(variability+1e-6);
    float p = phase*i + sin(i*1.5)*10.0 / regularity;
    float freq = (6.0 + 0.0009*sin(i*4.) / regularity) * z;
    float amp = (0.1 + 0.1*sin(i*10.15) / regularity) / z;
    float k = 0.1+height;
    return  i*k - 1.0 + amp*sin(freq*x + p);
}

vec4 genWaves(vec2 uv, vec2 outPos, vec4 color, float colorVariability, float randomSeed, float variability, mat3 modelTransform) {
    float yinv = -1.0; // set to 1.0 to flip Y
    float N = 24.0;
    mat3 m = inverse(modelTransform);
    float scale = length(m[0].xy);
    float phase = m[2].x;
    float height = -yinv * m[2].y*0.05;
    float Y = yinv*uv.y;
    vec2 range = getIndexRange(Y, scale, height, variability);

    int step = 0;
    for(float i=range.x; i<=range.y; ++i) {
        if (Y < wave(i, uv.x, scale, phase, height, variability*variability)) {
            return vec4(getColor(6.89 + randomSeed*0.1 + 0.1*colorVariability*i /*+ uv.x*0.08*/, color.rgb, .5*colorVariability), color.a);
        }
        if ((step++) > 100) break;
    }

    return color;
}

void main() {
    fragColor = genWaves((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_color, u_colorVariability, u_randomSeed, u_variability, u_modelTransform);
}
