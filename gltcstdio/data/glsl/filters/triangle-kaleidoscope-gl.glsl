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
