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
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_mode (int(U[6].x))
#define u_cornerStyle (int(U[7].x))
#define u_thickness (U[8].x)
#define u_border (U[9].x)
#define u_size (U[10].x)
#define u_count (int(U[11].x))
#define u_color1 (U[12])
#define u_borderColor (U[13])

#define __source__texelFetch__(c) texelFetch(u_source, (c), 0)
#define __source__(p) texture(u_source, __mirror_wrap__(vec2((p).x / u_worldAspect, (p).y) / 2.0 + 0.5))




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










vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

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

vec4 technicalBorder(vec2 uv, vec2 outPos, vec2 sourceDim, vec2 outDim, int mode, int cornerStyle, float thickness, float border, float size, int count, vec4 color1, vec4 borderColor) {
    float ratio = sourceDim.x / sourceDim.y;
    float borderSize = border * 2.0 * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 img = vec2(outDim.x / outDim.y * ratio / newBounds.x, 1.0 / newBounds.y);  // photo region half-extents
    vec2 H = vec2(outDim.x / outDim.y, 1.0);                                          // sheet (canvas) half-extents

    float pixel = 2.0 / outDim.y;
    float aa = pixel * 0.75;
    float th = max(thickness * 0.01, pixel * 0.5);

    // base: photo inside, border colour in the added margin
    float dImg = dRect(uv, vec2(0.0), img);
    vec4 base = (dImg < 0.0) ? __source__(uv) : mergeColor(__source__(uv), borderColor);

    vec2 m = max(H - img, vec2(0.0));    // margin thickness
    vec2 oF = H - 0.30 * m;              // outer frame (near sheet edge)
    vec2 iF = img + 0.15 * m;           // inner frame (hugs the photo)

    float d = 1e9;   // all elements share one colour

    if (tbBit(mode, 0.0) > 0.5) d = min(d, abs(dRect(uv, vec2(0.0), oF)));
    if (tbBit(mode, 1.0) > 0.5) d = min(d, abs(dRect(uv, vec2(0.0), iF)));

    // margin ruler ticks along the four outer-frame edges (O(1)/pixel)
    if (tbBit(mode, 3.0) > 0.5 && count > 0) {
        float tickLen = size * 0.06;
        float spx = (2.0 * oF.x) / float(count);
        float spy = (2.0 * oF.y) / float(count);
        float txn = clamp(floor((uv.x + oF.x) / spx + 0.5) * spx - oF.x, -oF.x, oF.x);
        float tyn = clamp(floor((uv.y + oF.y) / spy + 0.5) * spy - oF.y, -oF.y, oF.y);
        d = min(d, dSeg(uv, vec2(txn,  oF.y), vec2(txn,  oF.y - tickLen)));
        d = min(d, dSeg(uv, vec2(txn, -oF.y), vec2(txn, -oF.y + tickLen)));
        d = min(d, dSeg(uv, vec2( oF.x, tyn), vec2( oF.x - tickLen, tyn)));
        d = min(d, dSeg(uv, vec2(-oF.x, tyn), vec2(-oF.x + tickLen, tyn)));
    }

    // corner marks (at the inner frame, close to the photo); cut marks align with the image bounds
    if (tbBit(mode, 2.0) > 0.5 && cornerStyle != 0) {
        float Lc = size * 0.14;
        float gap = size * 0.05;
        for (int sxi = 0; sxi < 2; ++sxi) {
            for (int syi = 0; syi < 2; ++syi) {
                float sx = sxi == 0 ? -1.0 : 1.0;
                float sy = syi == 0 ? -1.0 : 1.0;
                if (cornerStyle == 4) {                                   // cut marks: aligned with image bounds, in the margin, gap at corner
                    d = min(d, dSeg(uv, vec2(sx * (img.x + gap), sy * img.y), vec2(sx * (img.x + gap + Lc), sy * img.y)));
                    d = min(d, dSeg(uv, vec2(sx * img.x, sy * (img.y + gap)), vec2(sx * img.x, sy * (img.y + gap + Lc))));
                } else {
                    vec2 c = vec2(sx * iF.x, sy * iF.y);                  // L / inverted-L / cross sit at the inner frame
                    if (cornerStyle == 3) {                              // cross
                        d = min(d, dSeg(uv, c - vec2(Lc, 0.0), c + vec2(Lc, 0.0)));
                        d = min(d, dSeg(uv, c - vec2(0.0, Lc), c + vec2(0.0, Lc)));
                    } else {
                        float dir = (cornerStyle == 1) ? -1.0 : 1.0;    // L inward, inverted-L outward
                        d = min(d, dSeg(uv, c, c + vec2(sx * dir * Lc, 0.0)));
                        d = min(d, dSeg(uv, c, c + vec2(0.0, sy * dir * Lc)));
                    }
                }
            }
        }
    }

    // edge-midpoint datum triangles, pointing inward
    if (tbBit(mode, 4.0) > 0.5) {
        float r = size * 0.05;
        vec2 tC = vec2(0.0,  oF.y - 1.3 * r);  d = min(d, sdTri(-(uv - tC), r));
        vec2 bC = vec2(0.0, -oF.y + 1.3 * r);  d = min(d, sdTri( (uv - bC), r));
        vec2 rC = vec2( oF.x - 1.3 * r, 0.0);  vec2 rq = uv - rC; d = min(d, sdTri(vec2(rq.y, -rq.x), r));
        vec2 lC = vec2(-oF.x + 1.3 * r, 0.0);  vec2 lq = uv - lC; d = min(d, sdTri(vec2(-lq.y, lq.x), r));
    }

    // reserved title-block panel (empty 2x2), over the photo's bottom corner, flush with the border
    if (tbBit(mode, 5.0) > 0.5) {
        float pw = size * 0.6, ph = size * 0.26;
        vec2 pmax = img;                            // bottom-right corner of the photo, touching the border
        vec2 pmin = pmax - vec2(pw, ph);
        vec2 pc = (pmin + pmax) * 0.5, phf = (pmax - pmin) * 0.5;
        float panelIn = 1.0 - smoothstep(-aa, aa, dRect(uv, pc, phf));        // solid borderColor under the panel
        base = mix(base, mergeColor(base, borderColor), panelIn);
        d = min(d, abs(dRect(uv, pc, phf)));                                  // panel outline
        d = min(d, dSeg(uv, vec2(pc.x, pmin.y), vec2(pc.x, pmax.y)));         // vertical divider  -> 2 cols
        d = min(d, dSeg(uv, vec2(pmin.x, pc.y), vec2(pmax.x, pc.y)));         // horizontal divider -> 2 rows
    }

    float cov = 1.0 - smoothstep(th - aa, th + aa, d);
    return mergeColor(base, vec4(color1.rgb, color1.a * cov));
}

void main() {
    fragColor = technicalBorder((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_outDim, u_mode, u_cornerStyle, u_thickness, u_border, u_size, u_count, u_color1, u_borderColor);
}
