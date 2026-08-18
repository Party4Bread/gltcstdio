#version 450
layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 fragColor;

layout(binding = 0, std140) uniform Params {
    vec4 U[9];
};
layout(binding = 1) uniform sampler samp;
layout(binding = 2) uniform texture2D t_source;

#define u_source sampler2D(t_source, samp)
#define u_worldAspect (U[0].x)
#define u_viewTransform (mat3(U[1].xyz, U[2].xyz, U[3].xyz))
#define u_outDim (U[4].xy)
#define u_count (int(U[5].x))
#define u_modelTransform (mat3(U[6].xyz, U[7].xyz, U[8].xyz))

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

vec4 hexRadialInterpolateGL(vec2 pos, vec2 outPos, int count, mat3 modelTransform) {
    // Inverse-sampling convention (codebase norm, matches KaleidoscopeML): the hex
    // grid lives in inverse(modelTransform) space, and image samples map back via the
    // forward modelTransform. `modelTransform` is thus a plain placement transform
    // (scale ∝ feature size), so the standard touch client inverts the whole transform
    // holistically — no per-component hacks. Default modelTransform = scale(1/30), so
    // gridTransform = scale(30), reproducing the original grid density exactly.
    mat3 gridTransform = inverse(modelTransform);
    vec2 u = (gridTransform * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;                  // side of triangle
    float halfTileWidth = tileWidth * 0.5;
    float tileHeight = tileWidth * SQRT3_2; // height of a triangle
    float centerHeight = tileWidth / (2.0 * SQRT3);

    float X = u.x;
    float Y = u.y;

    float row = floor(Y / tileHeight);
    float column = floor(X / halfTileWidth);

    float dx = X - column * halfTileWidth;
    float dy = Y - row * tileHeight;

    // Downward-slope rectangle parity (GLSL ES `mod` — identity with the
    // Pap shader's `fmod` for the positive `row+column` produced by the
    // tessellation; HOWTO_EFFECTS pitfall: no fmod in GLSL ES).
    bool down = mod(row + column, 2.0) == 0.0;
    float cx, cy;  // triangle center

    if (down) {
        if (dy > tileHeight - dx * SQRT3) {
            cy = (row + 1.0) * tileHeight - centerHeight;
            cx = (column + 1.0) * halfTileWidth;
            down = true;
        } else {
            cy = row * tileHeight + centerHeight;
            cx = column * halfTileWidth;
            down = false;
        }
    } else {
        if (dy > dx * SQRT3) {
            cy = (row + 1.0) * tileHeight - centerHeight;
            cx = column * halfTileWidth;
            down = true;
        } else {
            cy = row * tileHeight + centerHeight;
            cx = (column + 1.0) * halfTileWidth;
            down = false;
        }
    }
    // `down` now means "in a down-pointing triangle".

    // Hex satellite center for this triangle.
    float hcx, hcy;
    int tripos = int(mod(column + 3.0 * row, 6.0));
    if (tripos == 2) {
        hcx = column * halfTileWidth;
        hcy = (row + 1.0) * tileHeight;
    } else if (tripos == 1) {
        hcx = (column + 1.0) * halfTileWidth;
        hcy = (row + 1.0) * tileHeight;
    } else if (tripos == 0) {
        if (down) {
            hcx = (column + 2.0) * halfTileWidth;
            hcy = (row + 1.0) * tileHeight;
        } else {
            hcx = (column - 1.0) * halfTileWidth;
            hcy = row * tileHeight;
        }
    } else if (tripos == 5) {
        hcx = column * halfTileWidth;
        hcy = row * tileHeight;
    } else if (tripos == 4) {
        hcx = (column + 1.0) * halfTileWidth;
        hcy = row * tileHeight;
    } else { // tripos == 3
        if (down) {
            hcx = (column - 1.0) * halfTileWidth;
            hcy = (row + 1.0) * tileHeight;
        } else {
            hcx = (column + 2.0) * halfTileWidth;
            hcy = row * tileHeight;
        }
    }

    // Three satellite candidates (centers of adjacent hexes).
    vec2 relPos = u;
    vec2 center = vec2(hcx, hcy);
    vec2 c1 = vec2(-halfTileWidth, -tileHeight) + center;
    vec2 c2 = vec2(tileWidth, 0.0) + center;
    vec2 c3 = vec2(-halfTileWidth, tileHeight) + center;

    vec2 coord = center;
    float d;
    if (length(c1 - relPos) <= tileWidth) {
        relPos -= c1;
        d = length(relPos);
        coord = c1;
    } else if (length(c2 - relPos) <= tileWidth) {
        relPos -= c2;
        d = length(relPos);
        coord = c2;
    } else {
        // Fallback: Pap shader assigns c3 unconditionally (no guard).
        relPos -= c3;
        d = length(relPos);
        coord = c3;
    }

    // Polar angle of `relPos` around the satellite, with `ha = PI` offset
    // matching Pap. Pap also adds `u_Phase`, but the filter never uploads
    // `u_Phase`, so it defaults to 0 — dropped here.
    float ha = PI;
    float ang = acos(relPos.x / d);
    if (relPos.y < 0.0) ang = PI2 - ang;
    ang += PI * 0.5 + ha;
    ang = mod(ang + PI2, PI2);
    ang = PI2 - ang;

    float cnt = float(count);
    float angleRange = PI2 / cnt;
    float index = floor(ang / PI2 * cnt);
    float ang1 = -ha + angleRange * index;
    float ang2 = -ha + angleRange * (index + 1.0);

    // Sample positions in image space: walk back through the forward modelTransform
    // from the satellite-anchored ray-tangent points.
    vec2 pos1 = (modelTransform * vec3(coord.x - d * sin(ang1), coord.y - d * cos(ang1), 1.0)).xy;
    vec4 col1 = __source__(pos1);
    vec2 pos2 = (modelTransform * vec3(coord.x - d * sin(ang2), coord.y - d * cos(ang2), 1.0)).xy;
    vec4 col2 = __source__(pos2);

    // Pap mix-by-fractional-angle within the sector.
    return mix(col1, col2, (ang - angleRange * index) / angleRange);
}

void main() {
    fragColor = hexRadialInterpolateGL((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_count, u_modelTransform);
}
