vec4 radialInterpolateBrokenGL(vec2 pos, vec2 outPos, int count, float angle, float thickness, mat3 modelTransform) {
    // Pap filter sets doInverseModelTransform=true, so its
    // u_ModelTransform equals inverse(forwardModel). pap2mp's
    // `modelTransform` is the forward matrix; compute the inverse
    // in-shader to enter model space.
    mat3 invM = inverse(modelTransform);

    // Pap: u = u_ModelTransform * vec3(pos, 1.0)  (Pap's already-inverted matrix)
    vec2 u = (invM * vec3(pos, 1.0)).xy;
    float d = length(u);

    // Pap: thickn = 0.01*u_Thickness (Pap thickness 0..100). pap2mp 0..1.
    float thickn = thickness;

    // Outside the unit ring? Return source. Note: the comparison reads
    // the original `pos` from the source — only the ring is repainted.
    if (d < 1.0 - thickn || d > 1.0) {
        return __source__(pos);
    }

    float ha = angle / 2.0;

    // Safety gate from Pap (effectively always true at sensible angles).
    if (angle <= PI2) {
        if (d > 0.0) {
            float ang = acos(u.x / d);
            if (u.y < 0.0) ang = PI2 - ang;

            ang += PI / 2.0 + ha;
            // GLSL ES has no fmod — use mod (HOWTO_EFFECTS pitfall).
            ang = mod(ang + PI2, PI2);
            if (ang <= angle) {
                ang = angle - ang;
                float angleRange = angle / float(count);
                float index = floor(ang / angle * float(count));
                float ang1 = -ha + angleRange * index;
                float ang2 = -ha + angleRange * (index + 1.0);
                // Pap: u_InverseModelTransform * vec3(...) is the
                // forward back-transform (Pap's u_InverseModelTransform
                // = inverse(inverse(forward)) = forward). pap2mp uses
                // `modelTransform` directly.
                vec2 pos1 = (modelTransform * vec3(-d * sin(ang1), -d * cos(ang1), 1.0)).xy;
                vec4 col1 = __source__(pos1);
                vec2 pos2 = (modelTransform * vec3(-d * sin(ang2), -d * cos(ang2), 1.0)).xy;
                vec4 col2 = __source__(pos2);

                // Pap mix order: `mix(col1, col2, 1.0 - ka)`. The
                // non-broken sibling shader uses `mix(col1, col2, ka)`
                // — preserve the `1.0 -` inversion verbatim.
                return mix(col1, col2, 1.0 - (ang - angleRange * index) / angleRange);
            }
        }
    }

    return __source__(pos);
}
