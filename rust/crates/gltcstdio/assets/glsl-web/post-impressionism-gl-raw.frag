#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[20];
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
#define u_variability (U[6].x)
#define u_thickness (U[7].x)
#define u_angle (U[8].x)
#define u_blend (U[9].x)
#define u_color1 (U[10])
#define u_color2 (U[11])
#define u_color3 (U[12])
#define u_locusMode (int(U[13].x))
#define u_locusTransform (mat3(U[14].xyz, U[15].xyz, U[16].xyz))
#define u_modelTransform (mat3(U[17].xyz, U[18].xyz, U[19].xyz))

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) textureLod(u_source, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)
#define __source2__texelFetch__(c) texelFetch(u_source2, (c), 0)
#define __source2__(p) textureLod(u_source2, (vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5), 0.0)




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







































































































































































































































































































































































float piFmod(float a, float b) {
    return a - b * trunc(a / b);
}

float piLocusGetBlock(vec2 pos) {
    float inside = 0.0;
    float i2 = floor(pos.x / 10.0) + floor(pos.y / 10.0);
    float divisor = floor(piFmod((pos.x - 2.0 * pos.y) / 200.0, 24.0)) / 2.0;
    float threshold = piFmod((pos.x + 2.0 * pos.y) / 200.0, 24.0) / 6.0;
    float total = 0.0;
    vec4 rdmz = vec4(piFmod(i2 * 8877.0, 65536.0), piFmod(55.0 + i2 * 777.0, 65536.0),
                     piFmod(i2 * 413.0, 65536.0), piFmod(4445.0 + i2 * 78.0, 65536.0));
    for (int i = 0; i < 5; ++i) {
        vec2 v = vec2(piFmod(pos.x, 8.0), piFmod(pos.y, 8.0));
        float index = v.x + v.y * 8.0;
        float idx = piFmod(pos.y, 300.0) > 150.0 ? 3.0 : clamp(floor(index / 16.0), 0.0, 3.0);
        float ins = piFmod(floor(rdmz[int(idx)] / pow(2.0, index - idx * 16.0)), 2.0);
        total += ins;
        pos = floor(pos / divisor);
    }
    inside = total >= threshold ? 1.0 : 0.0;
    return inside;
}

float piLocusGetHue(vec4 c) {
    float r = c.r, g = c.g, b = c.b;
    float mini = min(r, min(g, b));
    float maxi = max(r, max(g, b));
    if (maxi == mini) return 0.0;
    else if (maxi == r) return piFmod(((60.0 * (g - b) / (maxi - mini)) + 360.0), 360.0);
    else if (maxi == g) return (60.0 * (b - r) / (maxi - mini)) + 120.0;
    else return (60.0 * (r - g) / (maxi - mini)) + 240.0;
}

float piGetLocus(vec2 pos, vec4 inCol, vec4 outCol, int locusMode, mat3 locusTransform) {
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
        float hue = piLocusGetHue(inCol);
        float targetHue = piFmod(locusTransform[2][0] * 180.0, 360.0);
        float d = hue - targetHue;
        if (d < 0.0) d = -d;
        if (d > 180.0) d = 360.0 - d;
        float maxD = 360.0 / length(vec2(locusTransform[0][0], locusTransform[0][1]));
        d /= maxD;
        return smoothstep(1.0, 0.75, d);
    } else if (locusMode == 5) {
        vec2 v = floor(u * 40.0);
        return piLocusGetBlock(v);
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

vec2 piPerturbate(vec2 p, vec2 dir, float variabilityScaled) {
    if (variabilityScaled == 0.0) return p;
    float M = variabilityScaled < 0.0 ? 1.0 : 5.0;
    float len = length(dir);
    vec2 ort = vec2(dir.y, -dir.x);
    float x = dot(p, dir) / (len * len) * M;
    float y = dot(p, ort) / (len * len);
    p += variabilityScaled * 0.004 * dir * sin(1.0 * x + 21.54) * cos(5.0 * y + 5245.24);
    p += variabilityScaled * 0.002 * dir * sin(3.0 * x + 0.21) * cos(15.0 * y + 0.575);
    p += variabilityScaled * 0.001 * dir * sin(10.0 * x - 1.0) * cos(50.0 * y + 1.255);
    p += variabilityScaled * 0.002 * ort * sin(1.2 * x + 21.4) * cos(4.52 * y + 525.24);
    p += variabilityScaled * 0.001 * ort * sin(3.4 * x + 0.1) * cos(17.0 * y + 0.75);
    p += variabilityScaled * 0.0005 * ort * sin(10.7 * x - 1.0) * cos(47.7 * y + 1.25);
    return p;
}

vec2 piGetStroke(vec2 p, vec2 c, vec2 dir, float thickness, float variabilityScaled) {
    if (dir.x == 0.0 && dir.y == 0.0) return vec2(0.0, 0.0);
    vec2 d = normalize(dir);
    float len = length(dir);
    p = piPerturbate(p, dir, variabilityScaled);
    p = mat2(vec2(d.x, -d.y), d.yx) * (p - c);
    float l = length(vec2(max(0.0, abs(p.x) - len), p.y));
    float k = clamp((p.x + len) / (2.0 * len), 0.0, 1.0);
    return vec2(l < thickness ? 1.0 : 0.0, k);
}

float piLuma(vec3 c) {
    return 0.2989 * c.r + 0.587 * c.g + 0.114 * c.b;
}

vec2 piResponse(vec2 u) {
    if (u.x == 0.0 && u.y == 0.0) return u;
    return normalize(u);
}

        vec4 postImpressionismGL(vec2 pos, vec2 outPos, int count,
                                 float variability, float thickness, float angle, float blend,
                                 vec4 color1, vec4 color2, vec4 color3,
                                 int locusMode, mat3 locusTransform, mat3 modelTransform) {
            // Pap variability is -100..100 used as `var*0.004`/`var*0.002`/… per-axis.
            //   pap2mp variability is -1..1; multiply by 100 once to keep the *math* identical.
            float variabilityScaled = variability * 100.0;
            // Pap u_Thickness 0..100; pap2mp 0..1; Pap shader uses `u_Thickness*0.01/resolution`.
            float thicknessFactor = thickness;  // already 0..1 → equivalent of Pap*0.01
            // Pap u_Gradient (= blend uniform) 0..100; pap2mp 0..1; Pap shader uses `u_Gradient*0.05`.
            float gradient = blend * 5.0;
            float ang = angle + 1.57079;

            float strokeIntensity = 0.0;
            float resolution = length(vec2(modelTransform[0][0], modelTransform[0][1]));
            vec2 sp = floor(pos * resolution + 0.5) / resolution
                    - fract(modelTransform[2].xy) / resolution;
            float delta = 0.02;
            float step = 1.0 / resolution;
            vec4 curColor = vec4(0.0, 0.0, 0.0, 1.0);
            mat2 rot = mat2(cos(ang), sin(ang), -sin(ang), cos(ang));

            float fCount = float(count);
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
                    vec2 g = rot * (piResponse(grad) / resolution / 2.0 * fCount);
                    vec2 st = piGetStroke(pos, pp, g, thicknessFactor / resolution, variabilityScaled);
                    if (st.x > 0.0) {
                        strokeIntensity = max(strokeIntensity, st.x);
                        float kGrad = (st.y - 0.5) * gradient + 0.5;
                        float alpha = mix(color2.a, color3.a, st.y);
                        vec4 color = vec4(
                            mix(color2.rgb, color3.rgb, mix(st.y, kGrad, min(color2.a, color3.a))),
                            alpha
                        );
                        if (color.a < 1.0) {
                            vec4 bk = mix(
                                __source__(pp - g * 0.5 * gradient),
                                __source__(pp + g * 0.5 * gradient),
                                0.5
                            );
                            color = vec4(mix(bk.rgb, color.rgb, color.a), bk.a);
                        }
                        if (piLuma(color.rgb) >= piLuma(curColor.rgb)) curColor = color;
                    }
                }
            }

            vec4 bkgCol = __source__(pos);
            curColor = mix(color1, curColor, strokeIntensity);
            curColor = vec4(
                mix(bkgCol.rgb, curColor.rgb, curColor.a),
                mix(bkgCol.a, curColor.a, curColor.a)
            );
            float locus = piGetLocus(pos, bkgCol, curColor, locusMode, locusTransform);
            return mix(bkgCol, curColor, locus);
        }

void main() {
    fragColor = postImpressionismGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_variability, u_thickness, u_angle, u_blend, u_color1, u_color2, u_color3, u_locusMode, u_locusTransform, u_modelTransform);
}
