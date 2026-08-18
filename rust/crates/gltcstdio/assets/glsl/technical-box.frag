#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[15];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_shapeAspectRatio (U[5].x)
#define u_mode (int(U[6].x))
#define u_cornerStyle (int(U[7].x))
#define u_thickness (U[8].x)
#define u_size (U[9].x)
#define u_count (int(U[10].x))
#define u_color1 (U[11])
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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











































































































































































































































































































































// L-infinity signed distance to an axis-aligned box (negative inside) -> SQUARE corners.



// L-infinity distance to an axis-aligned segment [a,b] -> SQUARE caps (no rounding).













float dRect(vec2 p, vec2 c, vec2 E) { return max(abs(p.x - c.x) - E.x, abs(p.y - c.y) - E.y); }

float dSeg(vec2 p, vec2 a, vec2 b) { vec2 lo = min(a, b), hi = max(a, b); vec2 d = max(lo - p, p - hi); return max(d.x, d.y); }

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdTri(vec2 p, float r) {          // equilateral triangle pointing +y, negative inside
    const float k = 1.7320508;
    p.x = abs(p.x) - r;
    p.y = p.y + r / k;
    if (p.x + k * p.y > 0.0) p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0 * r, 0.0);
    return -length(p) * sign(p.y);
}

float tbBit(int mode, float i) { return mod(floor(float(mode) / pow(2.0, i)), 2.0); }

vec4 technicalBox(vec2 uv, vec2 outPos, vec2 outDim, float shapeAspectRatio, int mode, int cornerStyle, float thickness, float size, int count, vec4 color1, mat3 modelTransform) {
    vec4 bkg = __source__(uv);

    vec2 u = (inverse(modelTransform) * vec3(uv, 1.0)).xy;
    float modelScale = max(length(vec2(modelTransform[0][0], modelTransform[0][1])), 1e-6);

    float pixel = 2.0 / outDim.y;
    float aa = pixel * 0.75;
    float th = max(thickness * 0.01, pixel * 0.5);

    float ar = max(shapeAspectRatio, 0.01);
    vec2 E = vec2(ar, 1.0);              // box half-extents (outer frame)
    vec2 iF = E - size * 0.12;           // inner frame

    float d = 1e9;   // all elements share one colour (distances in box space)

    if (tbBit(mode, 0.0) > 0.5) d = min(d, abs(dRect(u, vec2(0.0), E)));
    if (tbBit(mode, 1.0) > 0.5) d = min(d, abs(dRect(u, vec2(0.0), iF)));

    // ruler ticks along the four outer edges, pointing inward (O(1)/pixel)
    if (tbBit(mode, 3.0) > 0.5 && count > 0) {
        float tickLen = size * 0.06;
        float spx = (2.0 * E.x) / float(count);
        float spy = (2.0 * E.y) / float(count);
        float txn = clamp(floor((u.x + E.x) / spx + 0.5) * spx - E.x, -E.x, E.x);
        float tyn = clamp(floor((u.y + E.y) / spy + 0.5) * spy - E.y, -E.y, E.y);
        d = min(d, dSeg(u, vec2(txn,  E.y), vec2(txn,  E.y - tickLen)));
        d = min(d, dSeg(u, vec2(txn, -E.y), vec2(txn, -E.y + tickLen)));
        d = min(d, dSeg(u, vec2( E.x, tyn), vec2( E.x - tickLen, tyn)));
        d = min(d, dSeg(u, vec2(-E.x, tyn), vec2(-E.x + tickLen, tyn)));
    }

    // corner marks: L / inverted-L / cross at the inner frame; cut marks hug the box, offset outward
    if (tbBit(mode, 2.0) > 0.5 && cornerStyle != 0) {
        float Lc = size * 0.14;
        float gap = size * 0.05;
        for (int sxi = 0; sxi < 2; ++sxi) {
            for (int syi = 0; syi < 2; ++syi) {
                float sx = sxi == 0 ? -1.0 : 1.0;
                float sy = syi == 0 ? -1.0 : 1.0;
                if (cornerStyle == 4) {
                    d = min(d, dSeg(u, vec2(sx * (E.x + gap), sy * E.y), vec2(sx * (E.x + gap + Lc), sy * E.y)));
                    d = min(d, dSeg(u, vec2(sx * E.x, sy * (E.y + gap)), vec2(sx * E.x, sy * (E.y + gap + Lc))));
                } else {
                    vec2 c = vec2(sx * iF.x, sy * iF.y);
                    if (cornerStyle == 3) {
                        d = min(d, dSeg(u, c - vec2(Lc, 0.0), c + vec2(Lc, 0.0)));
                        d = min(d, dSeg(u, c - vec2(0.0, Lc), c + vec2(0.0, Lc)));
                    } else {
                        float dir = (cornerStyle == 1) ? -1.0 : 1.0;    // L inward, inverted-L outward
                        d = min(d, dSeg(u, c, c + vec2(sx * dir * Lc, 0.0)));
                        d = min(d, dSeg(u, c, c + vec2(0.0, sy * dir * Lc)));
                    }
                }
            }
        }
    }

    // edge-midpoint datum triangles, pointing inward (solid)
    if (tbBit(mode, 4.0) > 0.5) {
        float r = size * 0.05;
        vec2 tC = vec2(0.0,  E.y - 1.3 * r);  d = min(d, sdTri(-(u - tC), r));
        vec2 bC = vec2(0.0, -E.y + 1.3 * r);  d = min(d, sdTri( (u - bC), r));
        vec2 rC = vec2( E.x - 1.3 * r, 0.0);  vec2 rq = u - rC; d = min(d, sdTri(vec2(rq.y, -rq.x), r));
        vec2 lC = vec2(-E.x + 1.3 * r, 0.0);  vec2 lq = u - lC; d = min(d, sdTri(vec2(-lq.y, lq.x), r));
    }

    // empty 2x2 title-block panel, inside the inner frame's bottom-right corner (+y is down)
    if (tbBit(mode, 5.0) > 0.5) {
        float pw = size * 0.6, ph = size * 0.26;
        vec2 pmax = iF;
        vec2 pmin = pmax - vec2(pw, ph);
        vec2 pc = (pmin + pmax) * 0.5, phf = (pmax - pmin) * 0.5;
        d = min(d, abs(dRect(u, pc, phf)));
        d = min(d, dSeg(u, vec2(pc.x, pmin.y), vec2(pc.x, pmax.y)));
        d = min(d, dSeg(u, vec2(pmin.x, pc.y), vec2(pmax.x, pc.y)));
    }

    float cov = 1.0 - smoothstep(th - aa, th + aa, d * modelScale);
    if (cov <= 0.0) return bkg;
    return mergeColor(bkg, vec4(color1.rgb, color1.a * cov));
}

void main() {
    fragColor = technicalBox((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_outDim, u_shapeAspectRatio, u_mode, u_cornerStyle, u_thickness, u_size, u_count, u_color1, u_modelTransform);
}
