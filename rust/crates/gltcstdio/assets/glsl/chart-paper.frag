#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[14];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_source_specified (int(U[5].x))
#define u_color (U[6])
#define u_gridColor (U[7])
#define u_thickness (U[8].x)
#define u_grain (U[9].x)
#define u_humidity (U[10].x)
#define u_modelTransform (mat3(U[11].xyz, U[12].xyz, U[13].xyz))

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


















































































































































































































































































































































mat3 cpXform(float sx, float sy, float rot, float tx, float ty) {
    float c = cos(rot), s = sin(rot);
    return mat3(vec3(sx * c, sx * s, 0.0), vec3(-sy * s, sy * c, 0.0), vec3(tx, ty, 1.0));
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

vec2 hash22b(vec2 u) {
    return vec2(
        fract(sin(dot(u.xy, vec2(13.7545,78.224)))* 43758.5453123), 
        fract(sin(dot(u.xy, vec2(15.7545,73.224)))* 43758.5453123) );
}

vec2 rndUnit(vec2 p) {
    vec2 rnd = hash22b(p)-0.5;
    float len = length(rnd);
    if (len==0.0) return vec2(0., 1.0); else return rnd/len;
}

float dotGridGradient(vec2 g, vec2 u) {
    return dot(u-g, rndUnit(g));
}

float smix(float a, float b, float k) {
    return mix(a, b, smoothstep(0.0, 1.0, k));
}

float perlinNoise(vec2 p) {
    vec2 s = vec2(1.0, 0.0);
    vec2 f = floor(p);
    vec2 d = p-f;
    float ix0 = smix(dotGridGradient(f, p), dotGridGradient(f+s, p), d.x);
    float ix1 = smix(dotGridGradient(f+s.yx, p), dotGridGradient(f+s.xx, p), d.x);
    return 0.5+smix(ix0, ix1, d.y)*0.5;
}

float perlinOctaveNoise(vec2 uv, int n) {
    mat2 transform = 2.1111*mat2(sin(1.), cos(1.), -cos(1.), sin(1.));
    
    float k = 1.;
    float x = 0.;
    float total = 0.;
    
    for(int i=0; i<n; ++i) {
        x += k * perlinNoise(uv);
        total += k;
        k *= 0.5;
        uv = transform * uv;
    }
    
    x /= total;  
    return x;
}

float sdSegment(vec2 u, vec2 a, vec2 b) {
    vec2 ua = u-a;
    vec2 ba = b-a;
    float h = clamp(dot(ua, ba)/dot(ba, ba), 0., 1.);
    return length(ua - ba*h);
}

vec2 tf(mat3 m, vec2 u) {
    return (m * vec3(u, 1.)).xy;
}

float simpleVignette(float vignette, vec2 uv, mat3 vignetteTransform) {
    float d = length(tf(vignetteTransform, uv));
    return mix(1.0-vignette, 1.0, smoothstep(0.5, 1.0, d));
}

vec4 chartPaper(vec2 uv, vec2 outPos, vec2 outDim, int source_specified, vec4 color, vec4 gridColor, float thickness, float grain, float humidity, mat3 modelTransform) {
    // ---- Baked transforms (from the reference stack) ----
    mat3 grainMT = cpXform(0.89405024, 0.89405024, 1.8886724, 0.0042433357, 0.00067456224);
    mat3 humMT   = cpXform(1.0422206, 1.0422206, 0.0, -0.37128782, 0.29456925);
    mat3 layerXf = mat3(vec3(0.5, 0.4, 0.0), vec3(-0.4, 0.5, 0.0), vec3(10.3, 4.4, 1.0));
    mat3 axisXf  = mat3(vec3(0.2, 0.0, 0.0), vec3(0.0, 0.2, 0.0), vec3(0.0, 0.0, 1.0));

    // ---- Baked humidity colours ----
    vec4 humColor  = vec4(0.205, 0.164, 0.084, 1.0);
    vec4 humColor2 = vec4(0.556, 0.45, 0.247, 1.0);

    // ===== 1. Flat base =====
    vec4 col = color;

    // ===== 2. Grain (multiplicative fibre noise; baked type=0, octaves=8) =====
    {
        vec2 gu = tf(inverse(grainMT), uv) * 300.0;
        float pn = 2.0 * (perlinOctaveNoise(gu, 8) - 0.5);
        col.rgb *= 1.0 + grain * 4.0 * pn;   // type=0 => purely multiplicative
    }

    // ===== 3. Humidity (aged staining + vignette; baked layers=3, octaves=10,
    //          stratification=8, balance=0.9, power=9, vignetting=0.5308) =====
    {
        vec2 hu = tf(inverse(humMT), uv);
        float totalHum = 0.0, k = 1.0, totalK = 0.0;
        mat3 invLayer = inverse(layerXf);
        for (int i = 0; i < 3; ++i) {
            float hum = 2.0 * (perlinOctaveNoise(hu, 10) - 0.5);
            hum = mod(hum * 8.0, 2.0) * 0.5;
            if (hum < 0.9) hum = hum / 0.9; else hum = 1.0 - (hum - 0.9) / (1.0 - 0.9);
            hum = pow(hum, 9.0);
            totalHum += hum * k;
            totalK += k;
            k *= 0.6;
            hu = tf(invLayer, hu);
        }
        totalHum /= mix(1.0, totalK, pow(0.5, 9.0));
        vec4 targetCol = totalHum < 0.5
            ? mix(col, mergeColor(col, humColor2), totalHum / 0.5)
            : mix(mergeColor(col, humColor2), mergeColor(col, humColor), (totalHum - 0.5) / 0.5);
        col = mix(col, targetCol, humidity * simpleVignette(0.5308397529538998, uv, mat3(1.0)));
    }

    // ===== 4. Graph grid (grid-only: border + major lines + minor square dots) =====
    {
        // Page-fit: the box [-1,1]x[-ar,ar] is scaled to fill `pageFill` of the page (minus a
        // margin) at ANY aspect ratio. The page half-width in uv is outAR, so the base scale
        // tracks outAR; ar = 1/outAR keeps the box page-shaped with square cells. The user
        // `modelTransform` (identity by default) then layers on extra pan/zoom.
        float pageFill = 0.9486;               // 0.8 * 0.9486 = 0.75888 => matches the reference at AR 0.8
        float outAR = outDim.x / outDim.y;
        float ar = 1.0 / outAR;                // graph box shape derived from the output aspect ratio
        float s = outAR * pageFill;
        mat3 fit = mat3(vec3(s, 0.0, 0.0), vec3(0.0, s, 0.0), vec3(0.0, 0.0, 1.0));
        mat3 M = fit * modelTransform;         // box -> (user pan/zoom) -> page-fit -> uv
        mat3 im = inverse(M);
        vec2 u = tf(im, uv);
        float pixel = 2.0 / outDim.y;
        float aa = length(tf(im, uv + vec2(pixel, 0.0)) - u) * 0.75;

        float modelScale = length(vec2(M[0][0], M[0][1]));
        if (modelScale < 1e-5) modelScale = 1e-5;
        float vb = 1.0 / modelScale;
        float lineHalf = thickness * 0.025 * vb;
        float gridHalf = lineHalf * 0.5;

        // axisTransform with Y column negated => data +y up
        mat3 atF = mat3(vec3(axisXf[0][0], axisXf[0][1], axisXf[0][2]),
                        vec3(-axisXf[1][0], -axisXf[1][1], -axisXf[1][2]),
                        vec3(axisXf[2][0], axisXf[2][1], axisXf[2][2]));
        mat3 iat = inverse(atF);
        vec2 dpos = tf(iat, u);
        float sxLen = length(vec2(atF[0][0], atF[0][1]));
        float syLen = length(vec2(atF[1][0], atF[1][1]));
        if (sxLen < 1e-5) sxLen = 1.0;
        if (syLen < 1e-5) syLen = 1.0;

        // Adaptive "nice" grid spacing (baked size=0.5). Kept faithful to the graph effect.
        float size = 0.5;
        float minLabelV = max(0.3 * size, 0.04);
        float unitVx = sxLen * modelScale;
        float unitVy = syLen * modelScale;
        float rawx = minLabelV / max(unitVx, 1e-6);
        float bx = pow(10.0, floor(log(max(rawx, 1.0)) / log(10.0)));
        float mxn = rawx / bx;
        float Lx = max(((mxn <= 1.0) ? 1.0 : (mxn <= 2.0) ? 2.0 : (mxn <= 5.0) ? 5.0 : 10.0) * bx, 1.0);
        float rawy = minLabelV / max(unitVy, 1e-6);
        float by = pow(10.0, floor(log(max(rawy, 1.0)) / log(10.0)));
        float myn = rawy / by;
        float Ly = max(((myn <= 1.0) ? 1.0 : (myn <= 2.0) ? 2.0 : (myn <= 5.0) ? 5.0 : 10.0) * by, 1.0);
        float minorX = Lx / 5.0;
        float minorY = Ly / 5.0;

        bool inBox = abs(u.x) <= 1.0 + aa && abs(u.y) <= ar + aa;

        float dLine = 1e9;
        float covGrid = 0.0;

        // Border (axisMode bit4)
        dLine = min(dLine, sdSegment(u, vec2(-1.0, -ar), vec2( 1.0, -ar)));
        dLine = min(dLine, sdSegment(u, vec2(-1.0,  ar), vec2( 1.0,  ar)));
        dLine = min(dLine, sdSegment(u, vec2(-1.0, -ar), vec2(-1.0,  ar)));
        dLine = min(dLine, sdSegment(u, vec2( 1.0, -ar), vec2( 1.0,  ar)));

        if (inBox) {
            // Major grid (el=1: half-weight lines)
            float dxM = abs(dpos.x - floor(dpos.x / Lx + 0.5) * Lx) * sxLen;
            float dyM = abs(dpos.y - floor(dpos.y / Ly + 0.5) * Ly) * syLen;
            float dMajor = min(dxM, dyM);
            covGrid = max(covGrid, 1.0 - smoothstep(gridHalf - aa, gridHalf + aa, dMajor));

            // Minor grid (el=11: small square dots at every minor node)
            vec2 ci = tf(atF, vec2(floor(dpos.x / minorX + 0.5) * minorX,
                                   floor(dpos.y / minorY + 0.5) * minorY));
            float dDot = max(abs(u.x - ci.x), abs(u.y - ci.y));
            covGrid = max(covGrid, 1.0 - smoothstep(gridHalf - aa, gridHalf + aa, dDot));
        }

        float covLine = (lineHalf <= 0.0) ? 0.0 : (1.0 - smoothstep(lineHalf - aa, lineHalf + aa, dLine));
        if (lineHalf <= 0.0) covGrid = 0.0;
        float cov = max(covLine, covGrid);

        col = mergeColor(col, vec4(gridColor.rgb, gridColor.a * cov));
    }

    // ===== Composite over the optional source (translucent paper reveals it) =====
    if (source_specified == 1) col = mergeColor(__source__(uv), col);
    return col;
}

void main() {
    fragColor = chartPaper((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_outDim, u_source_specified, u_color, u_gridColor, u_thickness, u_grain, u_humidity, u_modelTransform);
}
