vec4 iteratedRipplesGL(vec2 pos, vec2 outPos, float intensity, float dampening, int count, mat3 modelTransform) {
    mat3 invM = inverse(modelTransform);
    vec4 color = __source__(pos);

    vec2 u = (invM * vec3(pos, 1.0)).xy;
    float rippleCount = float(count);

    // 6-iteration cascade: hardcoded in the Pap shader; preserved.
    for (int i = 0; i < 6; ++i) {
        float d = length(u);
        if (d >= 1.0) {
            return color;
        } else {
            // Pap: dampening>=0 ? pow(1-d, dampening*0.02) : pow(d, -dampening*0.05)
            //   with dampening in -1..1 (pap2mp) instead of -100..100 (Pap):
            float dampen = dampening >= 0.0
                ? pow(1.0 - d, dampening * 2.0)
                : pow(d, -dampening * 5.0);
            // Pap: intensity*0.01 * sin(d * rippleCount * PI) * dampen
            //   with intensity 0..1 (pap2mp): drop the *0.01.
            float dilation = 1.0 + intensity * sin(d * rippleCount * PI) * dampen;
            u *= dilation;
        }
    }

    if (intensity < 0.0) u = -u;
    u = (modelTransform * vec3(u, 1.0)).xy;
    return __source__(u);
}
