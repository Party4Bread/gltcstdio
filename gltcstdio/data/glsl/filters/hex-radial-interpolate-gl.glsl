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
