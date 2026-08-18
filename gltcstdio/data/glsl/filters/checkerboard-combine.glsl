vec4 checkerboardCombine(vec2 pos, vec2 outPos, float thickness, vec4 borderColor, vec2 source1Dim, vec2 source2Dim, mat3 viewTransform1, mat3 viewTransform2) {
    vec2 u = pos;

    float choice = mod(floor(u.x)+floor(u.y), 2.);
    vec2 v = (fract(u)-0.5)*2.;
 
    float d = min(abs(abs(v.x)-1.), abs(abs(v.y)-1.));
    if (d<thickness*0.1) return vec4(borderColor.rgb, 1.);
    
    v /= (1.-thickness*0.1);

    // each checker cell is a square viewport, so cover-fit each source with aspectRatio = 1.
    // fit is the base; the per-source viewTransform pans/zooms within the fitted cell.
    mat3 fit1 = getCoverFitTransform(1.0, source1Dim);
    mat3 fit2 = getCoverFitTransform(1.0, source2Dim);

    vec4 col = (choice>0.0) ? __source1__(tf(fit1 * inverse(viewTransform1), v)) : __source2__(tf(fit2 * inverse(viewTransform2), v));
      
    return col;
}
