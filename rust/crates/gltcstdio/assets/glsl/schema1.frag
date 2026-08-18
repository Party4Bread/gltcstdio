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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_shapeAspectRatio (U[6].x)
#define u_iterations (int(U[7].x))
#define u_intensity (U[8].x)
#define u_variability (U[9].x)
#define u_randomSeed (U[10].x)
#define u_color1 (U[11])
#define u_color2 (U[12])
#define u_thickness (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))

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

vec2 distort(vec2 pos, vec2 a, vec2 b, vec2 splits, vec4 rect, float intensity, float seed, int mode) {
    vec2 rnd = rand2relSeeded(splits, seed+122.1);
    float dx = rect.z-rect.x;
    float dy = rect.w-rect.y;
    if (dx>dy) {
        return pos + vec2(sign(rnd.x)*dx/dy*intensity*0.0005, 0.0);
    }
    else {
        return pos + vec2(0.0, sign(rnd.y)*dy/dx*intensity*0.0005);
    }
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
}

float roundedRectField(vec2 uv, float shapeAspectRatio) {
    // rounded-rectangle-gradient viewTransform: scale 1.1036 (translation ignored).
    // Generators sample world = inverse(viewTransform)*coord, so divide by the scale.
    uv /= 1.1036;
    vec2 rectSize = vec2(1.0, shapeAspectRatio);
    rectSize /= length(rectSize);
    float d = sdRectangle(uv*2.0, rectSize);
    return step(d*0.25, 0.0);
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

vec4 schema1(vec2 uv, vec2 outPos, vec2 sourceDim, float shapeAspectRatio, int iterations, float intensity, float variability, float randomSeed, vec4 color1, vec4 color2, float thickness, mat3 modelTransform) {
    vec4 bg = __source__(uv);

    // (1) overlay placement: map screen uv into the pattern's local frame.
    vec2 p = (inverse(modelTransform) * vec3(uv, 1.0)).xy;

    // Internal dichotomic-break subdivision depth + bias (from the snuggly-caterpillar
    // dichotomic-break modelTransform: scale 0.057275485, translation 0).
    float scale = 1.0/0.057275485;
    vec2 bias = vec2(0.0, 0.0);

    int mode = 9;
    float ratio = 1.0;              // square pattern field
    float pixel = 2.0/sourceDim.y;

    bool border = false;
    vec4 rect;
    float rndStep = 0.0;            // mode 9 -> rndStep 0
    float regularity = 1.0-variability;

    for(int j=0; j<iterations; ++j) {
        rect = vec4(-ratio, -1.0, ratio, 1.0);
        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0);
        float sPos = 0.0;
        float sscale = 0.5;
        float inverter = 0.0;

        for (float i=0.0; i+sPos<scale; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed+122.1+rndStep*float(j));
            vec2 size = rect.zw-rect.xy;
            if (size.x<pixel || size.y<pixel) break;

            if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
            float variability = 1.0-max(0.0, (regularity*2.0-1.0));

            if (horSplit) {
                float Y = mix(rect.y, rect.w, variability*withBias(rnd.y, bias.y)+0.5);
                if (abs(Y-p.y)<thickness*0.1) { border = true; break; }
                if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            else {
                float X = mix(rect.x, rect.z, variability*withBias(rnd.x, bias.x)+0.5);
                if (abs(X-p.x)<thickness*0.1) { border = true; break; }
                if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            horSplit = !horSplit;
            inverter = 1.0-inverter;
            sscale *= 0.5;
            bias *= 0.5;
        }
        if (border) break;
        p = distort(p, rect.xy, rect.zw, splits, rect, intensity, randomSeed, mode);
    }

    // (2) per-cell color: rounded-rectangle field at the distorted point, mapped to the two
    // hatch colors (color2 outside the shape / transparent, color1 inside).
    float k = roundedRectField(p, shapeAspectRatio);
    vec4 fg = border ? color2 : mix(color2, color1, k);

    // (3) overlay composite over the background (intensity was 1.0 -> full).
    return mergeColor(bg, fg);
}

void main() {
    fragColor = schema1((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_shapeAspectRatio, u_iterations, u_intensity, u_variability, u_randomSeed, u_color1, u_color2, u_thickness, u_modelTransform);
}
