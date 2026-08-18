#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[22];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_sourceDim (U[4].xy)
#define u_outDim (U[5].xy)
#define u_margin (U[6].x)
#define u_paperColor (U[7])
#define u_inkColor (U[8])
#define u_markLength (U[9].x)
#define u_thickness (U[10].x)
#define u_panelAspect (U[11].x)
#define u_panelOutline (U[12].x)
#define u_mode (int(U[13].x))
#define u_barcodeCount (int(U[14].x))
#define u_barcodeSeed (U[15].x)
#define u_panelTransform (mat3(U[16].xyz, U[17].xyz, U[18].xyz))
#define u_modelTransform (mat3(U[19].xyz, U[20].xyz, U[21].xyz))

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















































































































































































































































































































































vec2 __mirror_wrap__(vec2 c) {
    return 1.0 - abs(mod(c, 2.0) - 1.0);
}

vec4 mergeColor(vec4 bkg, vec4 front) {
    return vec4(mix(bkg.rgb, front.rgb, front.a + (1.0-bkg.a)*(1.0-front.a)), max(bkg.a, front.a));
}

float sdRectangle(vec2 u, vec2 halfSize) {
    u = abs(u)-halfSize;
    return (u.x>=0. && u.y>=0.) ? length(u) : max(u.x, u.y);
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

vec4 labelFrame(vec2 uv, vec2 outPos, vec2 sourceDim, vec2 outDim, float margin, vec4 paperColor, vec4 inkColor, float markLength, float thickness, float panelAspect, float panelOutline, int mode, int barcodeCount, float barcodeSeed, mat3 panelTransform, mat3 modelTransform) {
    float gar = outDim.x / outDim.y;               // grown-canvas aspect; uv spans [-gar,gar] x [-1,1]
    float ratio = sourceDim.x / sourceDim.y;
    float borderSize = margin * 2.0 * min(1.0, ratio);
    vec2 newBounds = vec2(ratio, 1.0) + borderSize;
    vec2 threshold = vec2(gar * ratio / newBounds.x, 1.0 / newBounds.y);
    float aa = 1.5 / outDim.y;
    float th = thickness / 20.0;   // 0..1 param -> world half-width

    // ---- 1. Photo + paper margin (photo sampled through its own pan/zoom, OOB-mirrored) ----
    vec2 v = tf(inverse(modelTransform), uv);
    bool inside = sdRectangle(uv, threshold) < 0.0;
    vec4 col = inside ? __source__(v) : mergeColor(__source__(v), paperColor);

    // ---- 2. Margin border (mode bits3-4): 0 L-corners / 1 full / 2 thick / 3 double.
    //         Vertex sits halfway into the margin. When vertical text is present (mode bit2) a gap
    //         is reserved in the left edge of a full/thick/double border so the text isn't crossed. ----
    vec2 outer = vec2(gar, 1.0);
    vec2 vtx = threshold + 0.5 * (outer - threshold);
    int mBorder = (mode >> 3) & 3;
    int hasVText = (mode >> 2) & 1;
    float dB = 1e9;
    float bw = th;
    if (mBorder == 0) {
        for (int sx = -1; sx <= 1; sx += 2) {
            for (int sy = -1; sy <= 1; sy += 2) {
                vec2 c = vec2(float(sx) * vtx.x, float(sy) * vtx.y);
                dB = min(dB, sdSegment(uv, c, c - vec2(float(sx) * markLength, 0.0)));
                dB = min(dB, sdSegment(uv, c, c - vec2(0.0, float(sy) * markLength)));
            }
        }
    } else {
        if (mBorder == 2) bw = th * 3.0;
        dB = min(dB, sdSegment(uv, vec2(-vtx.x, -vtx.y), vec2(vtx.x, -vtx.y)));   // top
        dB = min(dB, sdSegment(uv, vec2(-vtx.x,  vtx.y), vec2(vtx.x,  vtx.y)));   // bottom
        dB = min(dB, sdSegment(uv, vec2( vtx.x, -vtx.y), vec2(vtx.x,  vtx.y)));   // right
        if (hasVText == 1) {                                                       // left with gap
            dB = min(dB, sdSegment(uv, vec2(-vtx.x, -vtx.y), vec2(-vtx.x, -vtx.y + 0.05)));
            dB = min(dB, sdSegment(uv, vec2(-vtx.x, -vtx.y + 0.45), vec2(-vtx.x, vtx.y)));
        } else {
            dB = min(dB, sdSegment(uv, vec2(-vtx.x, -vtx.y), vec2(-vtx.x, vtx.y)));
        }
    }
    float bcov = 1.0 - smoothstep(bw - aa, bw + aa, dB);
    if (mBorder == 3) {                                                            // double: inner rect
        bcov = max(bcov, 1.0 - smoothstep(th - aa, th + aa, abs(sdRectangle(uv, vtx - vec2(5.0 * th)))));
    }
    col = mergeColor(col, vec4(inkColor.rgb, inkColor.a * bcov));

    // ---- 3. Panel (sharp rectangle, paper) — tightly fits barcode+text with EQUAL margins.
    //         The text sits at the transform translation (`textC`); the panel is shifted UP so the
    //         text lands in the lower half and the barcode above it, both wrapped by margin `m`.
    //         +Y is down, so "up" = -Y. `corner-anchor`'s `vHalf`(=0.17) must equal (tHalf+m)/s. ----
    vec2 textC = vec2(panelTransform[2][0], panelTransform[2][1]);
    float s = length(vec2(panelTransform[0][0], panelTransform[0][1]));
    float tHalf = 0.10 * s;    // text half-height (approx)
    float bcH   = 0.16 * s;    // barcode half-height (taller bars = lower barcode aspect ratio)
    float g     = 0.03 * s;    // small gap between barcode and text (bars extend down toward it)
    float m     = 0.07 * s;    // uniform inner margin
    float panelHalfW = s * 0.5 * panelAspect;
    float bcCenterY   = textC.y - tHalf - g - bcH;
    float panelBottom = textC.y + tHalf + m;
    float panelTop    = bcCenterY - bcH - m;
    vec2  panelC = vec2(textC.x, 0.5 * (panelTop + panelBottom));
    float panelHalfH = 0.5 * (panelBottom - panelTop);
    float dPanel = sdRectangle(uv - panelC, vec2(panelHalfW, panelHalfH));
    col = mergeColor(col, vec4(paperColor.rgb, paperColor.a * (1.0 - smoothstep(-aa, aa, dPanel))));
    // Ink keyline (mode bits0-1): 0 none / 1 thin(0.5×) / 2 normal(1×) / 3 very thick(5×), scaling panelOutline.
    int panelLvl = mode & 3;
    float lvlMult = (panelLvl == 0) ? 0.0 : (panelLvl == 1) ? 0.5 : (panelLvl == 2) ? 1.0 : 5.0;
    float ol = (panelOutline / 20.0) * lvlMult;
    if (ol > 0.0) col = mergeColor(col, vec4(inkColor.rgb, inkColor.a * (1.0 - smoothstep(ol - aa, ol + aa, abs(dPanel)))));

    // ---- 4. Barcode (ink). Bar half-width tied to `thickness` (×0.9), thin = 1×, thick = 2×. ----
    vec2 bcCenter = vec2(textC.x, bcCenterY);
    float bcHalfW = panelHalfW * 0.85;
    if (abs(uv.x - textC.x) < panelHalfW && abs(uv.y - bcCenterY) < bcH * 1.6) {
        float N = float(barcodeCount);
        float dBar = 1e9;
        for (int i = 0; i < 40; i++) {
            if (i >= barcodeCount) break;
            float rnd = fract(sin((float(i) + barcodeSeed) * 12.9898) * 43758.5453);
            float w = (rnd < 0.5) ? 1.0 : 2.0;
            float bx = -bcHalfW + (float(i) + 0.5) / N * 2.0 * bcHalfW;
            vec2 bq = uv - (bcCenter + vec2(bx, 0.0));
            dBar = min(dBar, sdRectangle(bq, vec2(w * th * 0.9, bcH)));
        }
        col = mergeColor(col, vec4(inkColor.rgb, inkColor.a * (1.0 - smoothstep(-aa, aa, dBar))));
    }

    return col;
}

void main() {
    fragColor = labelFrame((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_sourceDim, u_outDim, u_margin, u_paperColor, u_inkColor, u_markLength, u_thickness, u_panelAspect, u_panelOutline, u_mode, u_barcodeCount, u_barcodeSeed, u_panelTransform, u_modelTransform);
}
