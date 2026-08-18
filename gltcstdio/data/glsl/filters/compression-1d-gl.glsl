vec4 compression1dGL(vec2 pos, vec2 outPos, float intensity, float angle, int displacement_specified, mat3 modelTransform) {
    // Pap uploads `u_ModelTransform = inverse(forwardModel)` (because
    // `doInverseModelTransform()=true`); pap2mp passes the forward
    // matrix, so we invert here to preserve identical math.
    mat3 invM = inverse(modelTransform);

    vec2 dir = vec2(sin(angle), cos(angle));
    vec2 pp = dot(dir, pos) * dir;
    vec2 p = (invM * vec3(pp, 1.0)).xy;

    // Sample the displacement field if provided, else source0.
    // Pap: `(u_Tex1Transform[2][2]!=0.0) ? source1 : source0`.
    vec4 fieldSample = (displacement_specified != 0) ? __displacement__(p) : __source__(p);
    float d = (length(fieldSample.rgb) / 1.73205 - 0.5) * 2.0;

    // Pap: intensity*0.04 (Pap -100..100). pap2mp intensity -1..1 → ×4.0.
    float scaledIntensity = intensity * 4.0;
    vec4 outColor = __source__(pp + (pos - pp) * (1.0 + d * scaledIntensity));
    return outColor;
}
