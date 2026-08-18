vec4 colorPickAliased(vec2 pos, vec2 outPos, float intensity, int count, vec2 sourceDim, vec2 colorFieldDim, int colorField_specified, float scaleX, float scaleY, mat3 modelTransform) {
    // Pap's filter overrides `doInverseModelTransform()` → true, so
    // `u_ModelTransform` is the inverse of the forward matrix. In
    // pap2mp `modelTransform` is the forward matrix; we use `invM`
    // at every site Pap's shader uses `u_ModelTransform` to preserve
    // identical math.
    mat3 invM = inverse(modelTransform);
    vec2 p = pos;
    vec4 color = __source__(pos);
    vec4 bestColor = color;
    float bestDist = 100.0;

    // Pap exponential encoding (CPU side):
    //   u_ScaleX = pow(1.1, scaleX_raw)
    //   u_ScaleY = pow(1.1, scaleY_raw)
    //   where scaleX_raw / scaleY_raw are -100..100 slider values.
    // Preserved here in-shader to match Pap's default look exactly.
    float scaleXEff = pow(1.1, scaleX);
    float scaleYEff = pow(1.1, scaleY);

    vec2 dim = (colorField_specified != 0)
        ? vec2(colorFieldDim.x/colorFieldDim.y - 1.0/colorFieldDim.y, 1.0 - 1.0/colorFieldDim.y)
        : vec2(sourceDim.x/sourceDim.y - 1.0/sourceDim.y, 1.0 - 1.0/sourceDim.y);
    vec2 orig = (invM*vec3(0.0, 0.0, 1.0)).xy;

    vec2 scaledDim = mat2(invM)*(2.0*dim);
    vec2 offset = scaledDim/2.0 - orig;
    vec2 bottomLeft = floor((p+offset)/scaledDim)*scaledDim - offset;
    vec2 topRight = ceil((p+offset)/scaledDim)*scaledDim - offset;

    float dist;
    vec2 pp;
    vec4 c;

    float N = max(1.0, floor(float(count)/2.0)-1.0);
    for(float i=0.0; i<float(count); ++i) {
        float d = floor(i/2.0)/N;
        if (mod(i, 2.0)==0.0) {
            pp = vec2(bottomLeft.x + d*(topRight.x-bottomLeft.x), bottomLeft.y + mod(p.y*scaleYEff, topRight.y-bottomLeft.y));
            c = (colorField_specified!=0) ? __colorField__(pp) : __source__(pp);
            dist = length(color-c);
            if (dist<bestDist) {
                bestDist = dist;
                bestColor = c;
            }
        }
        else {
            pp = vec2(bottomLeft.x + mod(p.x*scaleXEff, topRight.x-bottomLeft.x), bottomLeft.y + d*(topRight.y-bottomLeft.y));
            c = (colorField_specified!=0) ? __colorField__(pp) : __source__(pp);
            dist = length(color-c);
            if (dist<bestDist) {
                bestDist = dist;
                bestColor = c;
            }
        }
    }

    return mix(color, bestColor, intensity);
}
