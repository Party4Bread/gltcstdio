#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[18];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;
layout(binding = 3) uniform texture2D t_source2;

#define u_source sampler2D(t_source, samp)
#define u_source2 sampler2D(t_source2, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_dampening (U[6].x)
#define u_mode (U[7].x)
#define u_thickness (U[8].x)
#define u_color1 (U[9])
#define u_color2 (U[10])
#define u_locusMode (int(U[11].x))
#define u_locusTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))
#define u_modelTransform (mat3(U[15].xyz, U[16].xyz, U[17].xyz))

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

































































































































































































































































































































































vec2 rand2rel(vec2 co) {
    float x = fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
    float y = fract(sin(dot(vec2(x, co.x) ,vec2(12.9898,78.233))) * 43758.5453);
    return vec2(x, y)-vec2(0.5, 0.5);
}

float sketchFmod(float a, float b) {
    return a - b * trunc(a / b);
}

float sketchLocusGetBlock(vec2 pos) {
    float inside = 0.0;
    float i2 = floor(pos.x / 10.0) + floor(pos.y / 10.0);
    float divisor = floor(sketchFmod((pos.x - 2.0 * pos.y) / 200.0, 24.0)) / 2.0;
    float threshold = sketchFmod((pos.x + 2.0 * pos.y) / 200.0, 24.0) / 6.0;
    float total = 0.0;
    vec4 rdmz = vec4(sketchFmod(i2 * 8877.0, 65536.0), sketchFmod(55.0 + i2 * 777.0, 65536.0),
                     sketchFmod(i2 * 413.0, 65536.0), sketchFmod(4445.0 + i2 * 78.0, 65536.0));
    for (int i = 0; i < 5; ++i) {
        vec2 v = vec2(sketchFmod(pos.x, 8.0), sketchFmod(pos.y, 8.0));
        float index = v.x + v.y * 8.0;
        float idx = sketchFmod(pos.y, 300.0) > 150.0 ? 3.0 : clamp(floor(index / 16.0), 0.0, 3.0);
        float ins = sketchFmod(floor(rdmz[int(idx)] / pow(2.0, index - idx * 16.0)), 2.0);
        total += ins;
        pos = floor(pos / divisor);
    }
    inside = total >= threshold ? 1.0 : 0.0;
    return inside;
}

float sketchLocusGetHue(vec4 c) {
    float r = c.r, g = c.g, b = c.b;
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));
    if (maxi == mini) return 0.0;
    else if (maxi == r) return sketchFmod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g) return (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else return (60.0 * (r - g) / (maxi - mini)) + 240.0;
}

float sketchGetLocus(vec2 pos, vec4 inCol, vec4 outCol, int locusMode, mat3 locusTransform) {
    if (locusMode == 0) return 1.0;
    mat3 m = locusTransform;
    if (locusMode <= 3) m = inverse(locusTransform);
    vec2 u = (m * vec3(pos, 1.0)).xy;
    if (locusMode == 1) {
        return max(abs(u.x), abs(u.y)) > 1.0 ? 0.0 : 1.0;
    } else if (locusMode == 2) {
        return smoothstep(0.5, 1.0, length(u));
    } else if (locusMode == 3) {
        return smoothstep(1.0, 0.5, length(u));
    } else if (locusMode == 4) {
        float hue = sketchLocusGetHue(inCol);
        float targetHue = sketchFmod(locusTransform[2][0] * 180.0, 360.0);
        float d = hue - targetHue;
        if (d < 0.0) d = -d;
        if (d > 180.0) d = 360.0 - d;
        float maxD = 360.0 / length(vec2(locusTransform[0][0], locusTransform[0][1]));
        d /= maxD;
        return smoothstep(1.0, 0.75, d);
    } else if (locusMode == 5) {
        vec2 v = floor(u * 40.0);
        return sketchLocusGetBlock(v);
    } else if (locusMode == 6) {
        float colDist = length(inCol.rgb - outCol.rgb);
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float maxDist = scale < 1.0 ? 1.732 * scale : 1.732 / scale;
        if (scale < 1.0) colDist = 1.732 - colDist;
        colDist /= maxDist;
        return smoothstep(1.0, 0.75, colDist);
    } else if (locusMode == 7) {
        return clamp(-locusTransform[2][0] + locusTransform[2][1], 0.0, 1.0);
    } else if (locusMode == 8) {
        float scale = length(vec2(locusTransform[0][0], locusTransform[0][1]));
        float angle = floor(locusTransform[2][0] * 3.0 + 0.5) / 12.0 * PI;
        float intensity = clamp(locusTransform[2][1], 0.0, 1.0);
        float ca = cos(angle), sa = sin(angle);
        float y = -sa * pos.x + ca * pos.y;
        float h = cos(y * scale * PI * 100.0);
        return intensity < 0.5 ? intensity * (h + 1.0) : 1.0 + (1.0 - intensity) * (h - 1.0);
    }
    return 1.0;
}

float sketchGetStroke(vec2 p, vec2 c, vec2 dir, float thickness) {
    if (dir.x == 0.0 && dir.y == 0.0) return 0.0;
    vec2 d = normalize(dir);
    p = mat2(vec2(d.x, -d.y), d.yx) * (p - c);
    float len = length(dir);
    float l = length(vec2(max(0.0, abs(p.x) - len), p.y));
    return l < thickness ? 1.0 : 0.0;
}

vec2 sketchResponse(vec2 u, float dampeningTh) {
    if (u.x == 0.0 && u.y == 0.0) return u;
    float len = length(u);
    len = len < dampeningTh ? 0.0 : pow((len - dampeningTh) / (1.0 - dampeningTh), 0.1);
    return len * normalize(u);
}

        vec4 sketchGL(vec2 pos, vec2 outPos, int count, float dampening,
                      float mode, float thickness, vec4 color1, vec4 color2,
                      int locusMode, mat3 locusTransform, mat3 modelTransform) {
            // Pap-equivalent: u_Thickness is 0..100; here `thickness` is 0..1, so
            //   the `*0.01` (Pap pixel-norm scale) is folded in.
            float thicknessNorm = thickness * 0.02;
            // Pap pre-rescales u_Dampening to `(p*0.01)^2`. pap2mp `dampening` is 0..1;
            //   equivalent rescale: dampening^2 (Pap 20→pap2mp 0.2 → in-shader 0.04).
            float dampeningTh = dampening * dampening;
            float style = mode;  // already 0..1

            float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
            vec2 sp = floor(pos * resolution + 0.5) / resolution;
            float delta = 0.005;
            float step = 1.0 / resolution;

            float sum = 0.0;
            float fCount = float(count);
            // Pap iterates `j, i in [-count, +count]` floats. Implement as int loop with
            // hardcoded max and runtime break to keep GLSL ES happy (no dynamic bounds).
            for (int jj = 0; jj <= 200; ++jj) {
                if (jj > 2 * count) break;
                float j = float(jj) - fCount;
                for (int ii = 0; ii <= 200; ++ii) {
                    if (ii > 2 * count) break;
                    float i = float(ii) - fCount;
                    vec2 pp = sp + vec2(i, j) * step;
                    vec2 grad;
                    {
    float _o_d = delta;
    vec4 _o_cx0 = __source2__((pp) + vec2(_o_d, 0.0));
    vec4 _o_cx1 = __source2__((pp) - vec2(_o_d, 0.0));
    vec4 _o_cy0 = __source2__((pp) + vec2(0.0, _o_d));
    vec4 _o_cy1 = __source2__((pp) - vec2(0.0, _o_d));
    grad = vec2(
        ((_o_cx0.r + _o_cx0.g + _o_cx0.b) - (_o_cx1.r + _o_cx1.g + _o_cx1.b)) / 3.0 / (_o_d * 2.0),
        ((_o_cy0.r + _o_cy0.g + _o_cy0.b) - (_o_cy1.r + _o_cy1.g + _o_cy1.b)) / 3.0 / (_o_d * 2.0)
    );
}
                    grad = grad * delta / 2.0;
                    vec2 g = sketchResponse(grad, dampeningTh) / resolution / 2.0 * fCount;
                    sum += sketchGetStroke(pos, pp, vec2(g.y, -g.x), thicknessNorm);
                    if (style <= 0.5) {
                        float val;
                        { vec4 _o_c = __source2__(pos); val = (_o_c.r + _o_c.g + _o_c.b) / 3.0; }
                        vec2 index = floor(pp * resolution);
                        float k = index.x + index.y;
                        if (mod(k, 4.0) >= val * 4.0) {
                            sum += sketchGetStroke(pos, pp,
                                normalize(grad) / resolution / 2.0 * fCount,
                                thicknessNorm * smoothstep(0.0, 0.5, style));
                        }
                    } else {
                        float val;
                        { vec4 _o_c = __source2__(pp); val = (_o_c.r + _o_c.g + _o_c.b) / 3.0; }
                        float ratio = floor(val * 5.0 + 0.5);
                        if (ratio < 5.0) {
                            vec2 index = floor((pp + 20.0) * resolution);
                            float vDir = 1.0;
                            float k = index.x - vDir * index.y;
                            if (ratio == 0.0 || mod(k, ratio) == 0.0) {
                                vec2 hDir = normalize(rand2rel(index) * 1.0 + vec2(ratio + vDir, 1.0))
                                    / resolution / 2.0 * fCount;
                                sum += sketchGetStroke(pos, pp, hDir,
                                    thicknessNorm * smoothstep(0.5, 1.0, style));
                            }
                        }
                    }
                }
            }

            float k = sum > 0.0 ? 1.0 : 0.0;
            vec4 color = mix(color1, color2, k);
            vec4 bkgCol = __source__(pos);
            vec4 mixCol = vec4(mix(bkgCol.rgb, color.rgb, color.a), bkgCol.a);

            // Locus blend — `isIntensityBlendable = true` collapses to intensity=1.0 since
            // GradientNormals doesn't surface intensity, so the outer mix degenerates to
            // `mix(source, result, locus)` (Pap's final shader line).
            float locus = sketchGetLocus(pos, bkgCol, mixCol, locusMode, locusTransform);
            return mix(bkgCol, mixCol, locus);
        }

void main() {
    fragColor = sketchGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_dampening, u_mode, u_thickness, u_color1, u_color2, u_locusMode, u_locusTransform, u_modelTransform);
}
