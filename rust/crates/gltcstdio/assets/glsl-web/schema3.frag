#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[20];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_aspectRatio (U[6].x)
#define u_intensity (U[7].x)
#define u_iterations (int(U[8].x))
#define u_pixelation (U[9].x)
#define u_variability (U[10].x)
#define u_randomSeed (U[11].x)
#define u_color (U[12])
#define u_thickness (U[13].x)
#define u_modelTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_windowTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))

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

vec2 distort9(vec2 pos, vec4 rect, vec2 splits, float intensity, float seed) {
    vec2 rnd = rand2relSeeded(splits, seed+122.1);
    float dx = rect.z-rect.x;
    float dy = rect.w-rect.y;
    if (dx>dy) return pos + vec2(sign(rnd.x)*dx/dy*intensity*0.0005, 0.0);
    else       return pos + vec2(0.0, sign(rnd.y)*dy/dx*intensity*0.0005);
}

float rounded(float x, float prec) {
    return floor(x/prec+0.5)*prec;
}

float withBias(float x, float b) {
    float s = sign(b);
    float ab = abs(b);
    return pow(x+0.5, pow(2.0, -s*ab)) - 0.5;
}

vec4 schema3(vec2 uv, vec2 outPos, vec2 sourceDim, vec2 outDim, float intensity, int iterations, float pixelation, float variability, float randomSeed, vec4 color, float thickness, float aspectRatio, mat3 modelTransform, mat3 windowTransform) {
    float srcRatio = rounded(sourceDim.x/sourceDim.y, 0.01);   // source AR (drives the window)
    float outAR    = rounded(outDim.x/outDim.y, 0.01);         // output AR (drives the subdivision)
    float pixel = 2.0/outDim.y;

    // subdivision controls (same convention as dichotomic-break: modelTransform sets depth+bias)
    vec2 bias = (modelTransform*vec3(0.0, 0.0, 1.0)).xy;
    float scale = 1.0/length(vec2(modelTransform[0][0], modelTransform[0][1]));

    float th = thickness*0.1;

    // window: placed/sized/rotated by windowTransform, showing the source at ITS OWN aspect
    // ratio (no cover-fit, no squish). In window-local coords the box is |x|<=srcRatio, |y|<=1.
    float ws = length(windowTransform[1].xy);                  // window scale (local -> output uv)
    vec2 wl = (inverse(windowTransform) * vec3(uv, 1.0)).xy;    // window-local coords
    float sxg = (srcRatio - abs(wl.x)) * ws;                   // screen dist to vertical edge (+inside)
    float syg = (1.0      - abs(wl.y)) * ws;                   // screen dist to horizontal edge (+inside)

    // (1) inside the (possibly rotated) window -> clean, undistorted source.
    if (sxg>0.0 && syg>0.0) return __source__(wl);

    // (1b) window frame: a border-color line hugging the outside of the window edge.
    if ((abs(sxg)<th && syg>-th) || (abs(syg)<th && sxg>-th)) {
        vec4 col = __source__(uv);
        return vec4(mix(col.rgb, color.rgb, color.a), col.a);
    }

    // exclusion zone E: the largest axis-aligned rectangle inscribed in the (rotated) window
    // rect. For an unrotated window this is the window itself; for a rotated one the corners
    // that stick out past E are just covered by the source on top (edge-biased splits later).
    float winA = srcRatio * length(windowTransform[0].xy);     // window half-extent along local-x (uv)
    float winB = ws;                                           // window half-extent along local-y (uv)
    vec2  wax = normalize(windowTransform[0].xy);              // window x-axis direction
    float c1 = abs(wax.x), s1 = abs(wax.y);
    // Largest axis-aligned rectangle centered in the window: maximize W*H under the two corner
    // constraints  W*c1 + H*s1 <= winA  and  W*s1 + H*c1 <= winB. The optimum is a single-edge
    // tangent when the window is elongated enough (winA or winB "dominates"), otherwise the
    // both-edges vertex. Picking the vertex unconditionally is what blew up at 45deg; these
    // feasibility branches meet continuously and only divide by cos(2*theta) when it's non-zero.
    float sin2 = 2.0*c1*s1;                                    // sin(2*theta)
    float W, H;
    if (winA <= winB*sin2)      { W = winA/(2.0*c1); H = winA/(2.0*s1); }   // touch winA edges only
    else if (winB <= winA*sin2) { W = winB/(2.0*s1); H = winB/(2.0*c1); }   // touch winB edges only
    else { float det = c1*c1 - s1*s1; W = (winA*c1 - winB*s1)/det; H = (winB*c1 - winA*s1)/det; } // both
    W = max(W, 0.0); H = max(H, 0.0);
    vec2 wc = windowTransform[2].xy;
    float ex0 = wc.x-W, ey0 = wc.y-H, ex1 = wc.x+W, ey1 = wc.y+H;

    // (2) shatter: dichotomic-break (mode 9) over the OUTPUT canvas, parting around E.
    vec2 p = uv;
    bool border = false;
    vec4 rect;
    float regularity = 1.0-variability;

    for (int j=0; j<iterations; ++j) {
        rect = vec4(-outAR, -1.0, outAR, 1.0);
        bool horSplit = true;
        vec2 splits = vec2(0.0, 0.0);
        float sPos = 0.0;
        float sscale = 0.5;
        float inverter = 0.0;
        vec2 b = bias;

        for (float i=0.0; i+sPos<scale; ++i) {
            vec2 rnd = rand2relSeeded(splits, randomSeed+122.1);   // mode 9 -> rndStep 0
            vec2 size = rect.zw-rect.xy;
            if (size.x<pixel || size.y<pixel) break;

            if (rnd.x+0.5<regularity*2.0) horSplit = size.y>size.x;
            float var2 = 1.0-max(0.0, (regularity*2.0-1.0));

            if (horSplit) {
                float Y = mix(rect.y, rect.w, var2*withBias(rnd.y, b.y)+0.5);
                // part around the window: a split crossing E snaps to E's nearer horizontal edge.
                if (rect.x<ex1 && rect.z>ex0 && Y>ey0 && Y<ey1) Y = (Y-ey0<ey1-Y) ? ey0 : ey1;
                if (abs(Y-p.y)<th) { border = true; break; }
                if (p.y<Y) { rect.w = Y; ++splits.y; sPos += inverter*sscale; } else { rect.y = Y; splits.y += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            else {
                float X = mix(rect.x, rect.z, var2*withBias(rnd.x, b.x)+0.5);
                if (rect.y<ey1 && rect.w>ey0 && X>ex0 && X<ex1) X = (X-ex0<ex1-X) ? ex0 : ex1;
                if (abs(X-p.x)<th) { border = true; break; }
                if (p.x<X) { rect.z = X; ++splits.x; sPos += inverter*sscale; } else { rect.x = X; splits.x += 100.0; sPos += (1.0-inverter)*sscale; }
            }
            horSplit = !horSplit;
            inverter = 1.0-inverter;
            sscale *= 0.5;
            b *= 0.5;
        }
        if (border) break;
        p = distort9(p, rect, splits, intensity, randomSeed);
    }

    // (3) pixelate the sample coordinate (folds the `pixelate` stage in), then sample.
    vec2 ps = p;
    if (pixelation>1e-4) ps = floor(p/pixelation+0.5)*pixelation;

    if (border) {
        vec4 col = __source__(uv);
        return vec4(mix(col.rgb, color.rgb, color.a), col.a);
    }
    return __source__(ps);
}

void main() {
    fragColor = schema3((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_outDim, u_intensity, u_iterations, u_pixelation, u_variability, u_randomSeed, u_color, u_thickness, u_aspectRatio, u_modelTransform, u_windowTransform);
}
