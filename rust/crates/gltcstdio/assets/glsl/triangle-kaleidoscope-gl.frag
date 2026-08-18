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
#define u_ModelTransform (mat3(U[5].xyz, U[6].xyz, U[7].xyz))
#define u_Tex0Transform (mat3(U[8].xyz, U[9].xyz, U[10].xyz))
#define u_offset (U[11].x)
#define u_modelTransform (mat3(U[12].xyz, U[13].xyz, U[14].xyz))

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

vec4 triangleKaleidoscope(vec2 pos, vec2 outPos, float offset, mat3 modelTransform) {
    // Pap: u = u_ModelTransform * vec3(perspective(pos), 1.0). FORWARD modelTransform
    // (ImageGeomTransformGL default doInverseModelTransform=false); perspective is a
    // permanent no-op (PERSPECTIVE=0) so pos passes through unchanged.
    vec2 u = (modelTransform * vec3(pos, 1.0)).xy;

    float tileWidth = 2.0;                 // side of triangle
    float halfTileWidth = tileWidth/2.0;
    float tileHeight = tileWidth * SQRT3_2;     // height of a triangle
    float centerHeight = tileWidth / (2.0*SQRT3);

    float X = u.x;
    float Y = u.y;

    float row = floor(Y/tileHeight);
    float column = floor(X/(halfTileWidth));

    float dx = X - column*halfTileWidth;
    float dy = Y - row*tileHeight;

    // in this rectangle the line between 2 triangles has a downward slope
    bool down = mod(row+column, 2.0)==0.0;
    float cx, cy;                          // center of the triangle

    if (down) {
        if (dy > tileHeight - dx*SQRT3) {
            cy = (row+1.0) * tileHeight - centerHeight;
            cx = (column+1.0) * halfTileWidth;
            down = true;
        }
        else {
            cy = row * tileHeight + centerHeight;
            cx = column * halfTileWidth;
            down = false;
        }
    }
    else {
        if (dy > dx*SQRT3) {
            cy = (row+1.0) * tileHeight - centerHeight;
            cx = column * halfTileWidth;
            down = true;
        }
        else {
            cy = row * tileHeight + centerHeight;
            cx = (column+1.0) * halfTileWidth;
            down = false;
        }
    }
    // down now means whether we're in a down pointing triangle or not

    float hcx, hcy;
    // hex center selection (6-way lattice phase)
    int tripos = int(mod(column + 3.0*row, 6.0));
    if (tripos == 2) {
        hcx = column*halfTileWidth;
        hcy = (row+1.0)*tileHeight;
    }
    else if (tripos == 1) {
        hcx = (column+1.0)*halfTileWidth;
        hcy = (row+1.0)*tileHeight;
    }
    else if (tripos == 0) {
        if (down) {
            hcx = (column+2.0)*halfTileWidth;
            hcy = (row+1.0)*tileHeight;
        }
        else {
            hcx = (column-1.0)*halfTileWidth;
            hcy = row*tileHeight;
        }
    }
    else if (tripos == 5) {
        hcx = column*halfTileWidth;
        hcy = row*tileHeight;
    }
    else if (tripos == 4) {
        hcx = (column+1.0)*halfTileWidth;
        hcy = row*tileHeight;
    }
    else {  // tripos == 3
        if (down) {
            hcx = (column-1.0)*halfTileWidth;
            hcy = (row+1.0)*tileHeight;
        }
        else {
            hcx = (column+2.0)*halfTileWidth;
            hcy = row*tileHeight;
        }
    }

    // recompute dx, dy, cx, cy relative to center of hex
    dx = X - cx;
    dy = Y - cy;

    cx -= hcx;
    cy -= hcy;

    cx /= (tileHeight-centerHeight);
    cy /= (tileHeight-centerHeight);

    // rotation using (cy, cx) as (cos(a), sin(a)).
    // Pap: px = ((flip && u_AxialSym==1)?-1.0:1.0) * (cy*dx - cx*dy);
    // With u_AxialSym==0 baked, the flip negation never fires → no axial reflection.
    float px = cy*dx - cx*dy;
    float py = cx*dx + cy*dy;

    vec2 coord = vec2(px, py) + offset*offset*0.0001*u;

    // Sample the mirrored coord directly (same as KaleidoscopeML / TriangleTilesLegacy).
    // Pap's TEX_* source framing is identity in every Glitch use; callers that need
    // pan/zoom drive modelTransform / viewTransform instead (no texTransform param —
    // surfacing one made the engine emit an undeclared-u_Tex0Transform proj0 helper).
    return __source__(coord);
}

void main() {
    fragColor = triangleKaleidoscope((inverse(u_viewTransform) * vec3(((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), 1.0)).xy, ((v_uv - 0.5) * 2.0 * vec2(u_worldAspect, 1.0)), u_offset, u_modelTransform);
}
