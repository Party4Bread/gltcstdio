vec4 displacement1dGL(vec2 pos, vec2 outPos, float intensity, float angle, float phase2, int displacement_specified, mat3 modelTransform) {
    // Pap uploads `u_ModelTransform = inverse(forwardModel)` (because
    // `doInverseModelTransform()=true`); pap2mp passes the forward
    // matrix, so we invert here to preserve identical math.
    mat3 invM = inverse(modelTransform);

    vec2 dir = vec2(sin(angle), cos(angle));
    // Pap: dispDir = mat2(rot(phase2)) * dir
    vec2 dispDir = mat2(cos(phase2), -sin(phase2), sin(phase2), cos(phase2)) * dir;

    vec2 pp = dot(dir, pos) * dir;
    vec2 p = (invM * vec3(pp, 1.0)).xy;

    // Sample the displacement field if provided, else source0.
    // Pap: `(u_Tex1Transform[2][2]!=0.0) ? source1 : source0`.
    vec4 fieldSample = (displacement_specified != 0) ? __displacement__(p) : __source__(p);
    float d = (length(fieldSample.rgb) / 1.73205 - 0.5) * 2.0;

    // Pap: `u_Intensity * 0.01` (Pap -100..100). pap2mp intensity is
    // already -1..1, so drop the *0.01.
    vec4 outColor = __source__(pos + intensity * d * dispDir);
    return outColor;
}
